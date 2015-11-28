//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------

//grg 26112015 1533 Delphi 10 changes

unit WavFile;

//TSingleArray input and output buffers are normalized: Abs() <= 32767

//to do: direct read/write mmio buffer like in lowpass.c MS demo (sdk_Graphics_AUDIO_lowpass.exe)
//to do: access buffers by pointer, not by index
//to do: read non-PCM files, convert from different sampling rates via ACM


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  MMSystem, SndTypes; //grg ve3nea , PermHint; //grg PermHint added

type
  TByteArray = array of byte;

  TAlWavFile = class(TComponent)
  private
    ckInfoRIFF, ckInfo: TMmckInfo;
    WaveFmt: TPcmWaveFormat;

    FFileName: TFileName;
    FIsOpen: boolean;
    rc: HMMIO;
    FHandle: HMMIO;
    FStereo: boolean;
    FSamplesPerSec: LongWord;
    FBytesPerSample: LongWord;
    FAlignBits: integer;
    FSampleCnt: LongWord;
    FLData: TSingleArray;
    FRData: TSingleArray;
    FWriteMode: boolean;
    FInfo: TStrings;
    FCurrentSample: LongWord;

    procedure SetBytesPerSample(const Value: LongWord);
    procedure SetSamplesPerSec(const Value: LongWord);
    procedure SetStereo(const Value: boolean);
    procedure InfoChanging(Sender: TObject);
    procedure SetInfo(const Value: TStrings);
    procedure SetFileName(const Value: TFileName);
  protected
    procedure ChkErr;
    procedure ErrIf(IsErr: boolean; Msg: string);
    procedure ChkNotOpen;
    procedure ReadInfo;
    procedure WriteInfo;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OpenRead;
    procedure OpenWrite;
    procedure Seek(SampleNo: LongWord);
    procedure Read(ASampleCnt: LongWord);
    function  ReadTo(ALData, ARData: PSingle; ASampleCnt: LongWord): LongWord;
    procedure Write;
    procedure WriteFrom(ALData, ARData: PSingle; ASampleCnt: LongWord);
    procedure NormalizeData;
    procedure Close;

    property SampleCnt: LongWord read FSampleCnt;
    property CurrentSample: LongWord read FCurrentSample;
    property IsOpen: boolean read FIsOpen;
    property LData: TSingleArray read FLData write FLData;
    property RData: TSingleArray read FRData write FRData;
  published
    property FileName : TFileName read FFileName write SetFileName;
    property Stereo: boolean read FStereo write SetStereo default false;
    property SamplesPerSec: LongWord read FSamplesPerSec write SetSamplesPerSec default 11025;
    property BytesPerSample: LongWord read FBytesPerSample write SetBytesPerSample default 2;
    property Info: TStrings read FInfo write SetInfo;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Snd', [TAlWavFile]);
end;

{ TAlWavFile }

//------------------------------------------------------------------------------
//                             create/destroy
//------------------------------------------------------------------------------

constructor TAlWavFile.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FBytesPerSample := 2;
  FSamplesPerSec := 11025;
  Stereo := false;

  FInfo := TStringList.Create;
  TStringList(FInfo).OnChanging := InfoChanging;
end;

destructor TAlWavFile.Destroy;
begin
  FInfo.Free;
  inherited Destroy;
end;






//------------------------------------------------------------------------------
//                               Open/Close/Seek
//------------------------------------------------------------------------------

procedure TAlWavFile.OpenRead;
begin
  ErrIf(FIsOpen, 'File already open');

  FWriteMode := false;
  FCurrentSample := 0;

  //open
  FHandle := mmioOpen(pchar(FFileName), nil, MMIO_READ or MMIO_ALLOCBUF or MMIO_DENYWRITE);
  ErrIf(FHandle = 0, 'Unable to open file');
  try
    //go to wav section
    ckInfoRiff.fccType := mmioStringToFOURCCA('WAVE', 0);
    rc := mmioDescend(FHandle, @ckInfoRIFF, nil, MMIO_FINDRIFF);
    ChkErr;

    //read Info strings
    ReadInfo;

    //go to format header
    ckInfo.ckid := mmioStringToFOURCCA('fmt ', 0);
    rc := mmioDescend(FHandle, @ckInfo, @ckInfoRIFF, MMIO_FINDCHUNK);
    ChkErr;
    ErrIf(ckInfo.cksize < SizeOf(TPcmWaveFormat), 'Invalid header size');
    //read header
    rc := mmioRead(FHandle, @WaveFmt, SizeOf(TPcmWaveFormat));
    ErrIf(rc <> SizeOf(TPcmWaveFormat), 'Unable to read header');
    ErrIf(WaveFmt.wf.wFormatTag <> WAVE_FORMAT_PCM, 'Unsupported compression method');
    //store parameters
    FStereo := WaveFmt.wf.nChannels = 2;
    FSamplesPerSec := WaveFmt.wf.nSamplesPerSec;
    FBytesPerSample := WaveFmt.wBitsPerSample shr 3;

    case WaveFmt.wf.nBlockAlign of
      1: FAlignBits := 0;
      2: FAlignBits := 1;
      4: FAlignBits := 2;
      end;

    //go to data
    rc := mmioAscend(FHandle, @ckInfo, 0);
    ChkErr;
    ckInfo.ckid := mmioStringToFOURCCA('data', 0);
    rc := mmioDescend(FHandle, @ckInfo, @ckInfoRiff, MMIO_FINDCHUNK);
    ChkErr;

    FSampleCnt := ckInfo.ckSize shr FAlignBits;
  except
    mmioClose(FHandle, 0);
    raise;
  end;

  FIsOpen := true;
end;


procedure TAlWavFile.OpenWrite;
begin
  ErrIf(FIsOpen, 'File already open');

  FWriteMode := true;
  FCurrentSample := 0;

  //open
  FHandle := mmioOpen(pchar(FFileName), nil, MMIO_CREATE or MMIO_ALLOCBUF or MMIO_WRITE or MMIO_DENYWRITE);
  ErrIf(FHandle = 0, 'Unable to open file');
  try
    //fill WaveFmt
    with WaveFmt.wf do
      begin
      wFormatTag := WAVE_FORMAT_PCM;
      if FStereo
        then nChannels := 2
        else nChannels := 1;
      nSamplesPerSec := FSamplesPerSec;
      nAvgBytesPerSec := FSamplesPerSec shl FAlignBits;
      nBlockAlign := 1  shl FAlignBits;
      WaveFmt.wBitsPerSample := (16 shl FAlignBits) shr nChannels;
      end;

    ckInfoRIFF.fccType := mmioStringToFOURCCA('WAVE', 0);
    rc := mmioCreateChunk(FHandle, @ckInfoRIFF, MMIO_CREATERIFF);
    ChkErr;

    //save Info strings
    {!}//WriteInfo;

    ckInfo.ckId := mmioStringToFOURCCA('fmt ', 0);
    ckInfo.ckSize := SizeOf(TPcmWaveFormat);
    rc := mmioCreateChunk(FHandle, @ckInfo, 0);
    ChkErr;
    rc := mmioWrite(FHandle, @WaveFmt, SizeOf(TPcmWaveFormat));
    ErrIf(rc <> SizeOf(TPcmWaveFormat), 'WAV write error');

    rc := mmioAscend(FHandle, @ckInfo, 0);
    ChkErr;

    ckInfo.ckid := mmioStringToFOURCCA('data', 0);
    //ckInfo.ckSize := 0;
    rc := mmioCreateChunk(FHandle, @ckInfo, 0);
    ChkErr;
  except
    mmioClose(FHandle, 0);
    raise;
  end;

  FSampleCnt := 0;
  FIsOpen := true;
end;


procedure TAlWavFile.Close;
begin
  ErrIf(not FIsOpen, 'File not open');

  if FWriteMode then
    begin
    //ascend from 'data'
    rc := mmioAscend(FHandle, @ckInfo, 0);
    {ChkErr;}

    {!}
    if FWriteMode then WriteInfo;

    //ascend from 'RIFF'
    rc := mmioAscend(FHandle, @ckInfoRiff, 0);
    {ChkErr;}
    end;

  rc := mmioClose(FHandle, 0);
  {ChkErr;}

  FIsOpen := false;
  FCurrentSample := 0;
end;


procedure TAlWavFile.Seek(SampleNo: LongWord);
var
  NewPos: integer;
begin
  ErrIf(not IsOpen, 'File not open');
  //ErrIf(FWriteMode, 'Cannot seek in write mode');
  ErrIf(SampleNo > FSampleCnt, 'Invalid Seek position');

  NewPos := ckInfo.dwDataOffset + (SampleNo shl FAlignBits);

  rc := mmioSeek(FHandle, NewPos, SEEK_SET);
  ErrIf(rc <> NewPos, 'WAV seek failed');

  FCurrentSample := SampleNo;
end;







//------------------------------------------------------------------------------
//                                   Read
//------------------------------------------------------------------------------

procedure TAlWavFile.Read(ASampleCnt: LongWord);
begin
  //free output arrays
  FLData := nil;
  FRData := nil;
  if ASampleCnt = 0 then Exit;

  //allocate output arrays
  SetLength(FLData, ASampleCnt);
  try
    if FStereo
      then
        begin
        SetLength(FRData, ASampleCnt);
        ASampleCnt := ReadTo(@FLData[0], @FRData[0], ASampleCnt);
        end
      else
        ASampleCnt := ReadTo(@FLData[0], nil, ASampleCnt);
    //resize buffers to reflect the # of samples actually read
    SetLength(FLData, ASampleCnt);
    if FStereo then SetLength(FRData, ASampleCnt);
  except
    FRData := nil;
    FLData := nil;
    raise;
  end;
end;


function TAlWavFile.ReadTo(ALData, ARData: PSingle; ASampleCnt: LongWord): LongWord;
var
  Buf: TByteArray;
  DataType: integer;
  i: integer;
begin
  ErrIf(not IsOpen, 'File not open');
  ErrIf(FWriteMode, 'File open in write mode');
  ErrIf(ALData = nil, 'Left buffer not supplied');
  ErrIf(Stereo and (ARData = nil), 'Right buffer not supplied');

  //allocate buffer

  //to do: direct read from the mmio buffer like in lowpass.c MS demo
  //(sdk_Graphics_AUDIO_lowpass.exe)

  SetLength(Buf, ASampleCnt shl FAlignBits);
  try
    //read
    ASampleCnt := mmioRead(FHandle, @Buf[0], Length(Buf));
    ErrIf(Integer(ASampleCnt) = -1, 'WAV read error');
    //ErrIf(ASampleCnt = 0, 'End of file');
    ASampleCnt := ASampleCnt shr FAlignBits;

    //convert data

    if FStereo
      then DataType := BytesPerSample shl 2
      else DataType := BytesPerSample;

    if ASampleCnt > 0 then
      case DataType of
        1: //8 bit mono
          for i:=0 to ASampleCnt-1 do
            begin
            //to do: access Buf by pointer

            //Buf[i]: byte          = 0..255
            //Integer(Buf[i])-128   = -128..127
            //shl 8                 = -32768..32512

            ALData^ := (Integer(Buf[i]) - 128) shl 8;
            Inc(ALData);
            end;

        2: //16 bit mono
          for i:=0 to ASampleCnt-1 do
            begin
            ALData^ := PSmallInt(@Buf[i shl 1])^;
            Inc(ALData);
            end;

        4: //8 bit stereo
          for i:=0 to ASampleCnt-1 do
            begin
            ALData^ := (Integer(Buf[i shl 1]) - 128) shl 8;
            ARData^ := (Integer(Buf[i shl 1] + 1) - 128) shl 8;
            Inc(ALData);
            Inc(ARData);
            end;

        8: //16 bit stereo
          for i:=0 to ASampleCnt-1 do
            begin
            ALData^ := PSmallInt(@Buf[i shl 2])^;
            ARData^ := PSmallInt(@Buf[(i shl 2) + 2])^;
            Inc(ALData);
            Inc(ARData);
            end;
        end;
  finally
    Buf := nil;
  end;

  Inc(FCurrentSample, ASampleCnt);
  Result := ASampleCnt;
end;






//------------------------------------------------------------------------------
//                                   Write
//------------------------------------------------------------------------------

procedure TAlWavFile.Write;
begin
  if Length(FLData) = 0 then Exit;
  if FRData = nil
    then WriteFrom(@FLData[0], nil, Length(FLData))
    else WriteFrom(@FLData[0], @FRData[0], Length(FLData));
end;


procedure TAlWavFile.WriteFrom(ALData, ARData: PSingle; ASampleCnt: LongWord);
var
  Buf: TByteArray;
  DataType: integer;
  i: integer;
begin
  ErrIf(not IsOpen, 'File not open');
  ErrIf(not FWriteMode, 'File open in read mode');
  ErrIf(ALData = nil, 'Left buffer not supplied');
  ErrIf(Stereo and (ARData = nil), 'Right buffer not supplied');

  //allocate buffer

  //to do: direct read from the mmio buffer like in lowpass.c MS demo
  //(sdk_Graphics_AUDIO_lowpass.exe)

  SetLength(Buf, ASampleCnt shl FAlignBits);
  try
    if FStereo
      then DataType := BytesPerSample shl 2
      else DataType := BytesPerSample;

    case DataType of
      1: //8 bit mono
        for i:=0 to ASampleCnt-1 do
          begin
          //ALData^    = -32767..32767 Single
          //Round()    = -32767..32767 integer
          //shr 8      = -128..127

          Buf[i] := (Round(ALData^) shr 8) + 128;
          Inc(ALData);
          end;

      2: //16 bit mono
        for i:=0 to ASampleCnt-1 do
          begin
          PSmallInt(@Buf[i shl 1])^ := Round(ALData^);
          Inc(ALData);
          end;

      4: //8 bit stereo
        for i:=0 to ASampleCnt-1 do
          begin
          Buf[i shl 1] := (Round(ALData^) shr 8) + 128;
          Buf[(i shl 1)+1] := (Round(ARData^) shr 8) + 128;
          Inc(ALData);
          Inc(ARData);
          end;

      8: //16 bit stereo
        for i:=0 to ASampleCnt-1 do
          begin
          PSmallInt(@Buf[i shl 2])^ := Round(ALData^);
          PSmallInt(@Buf[(i shl 2)+2])^ := Round(ARData^);
          Inc(ALData);
          Inc(ARData);
          end;
      end;

    //write
    rc := mmioWrite(FHandle, @Buf[0], Length(Buf));
    ErrIf(rc <> Length(Buf), 'WAV write error');
    Inc(FSampleCnt, ASampleCnt);
    FCurrentSample := FSampleCnt;
  finally
    Buf := nil;
  end;
end;




//------------------------------------------------------------------------------
//                             Property get/set
//------------------------------------------------------------------------------

procedure TAlWavFile.SetBytesPerSample(const Value: LongWord);
begin
  ChkNotOpen;
  FBytesPerSample := Value;

  FAlignBits := FBytesPerSample shr 1;
  if FStereo then Inc(FAlignBits);
end;


procedure TAlWavFile.SetSamplesPerSec(const Value: LongWord);
begin
  ChkNotOpen;
  FSamplesPerSec := Value;
end;


procedure TAlWavFile.SetStereo(const Value: boolean);
begin
  ChkNotOpen;
  FStereo := Value;

  FAlignBits := FBytesPerSample shr 1;
  if FStereo then Inc(FAlignBits);
end;


procedure TAlWavFile.SetFileName(const Value: TFileName);
begin
  ChkNotOpen;
  FFileName := Value;
end;


procedure TAlWavFile.InfoChanging(Sender: TObject);
begin
 // ChkNotOpen;
end;


procedure TAlWavFile.SetInfo(const Value: TStrings);
begin
  FInfo.Assign(Value);
end;





//------------------------------------------------------------------------------
//                      Read/write LIST/INFO chunk
//------------------------------------------------------------------------------
procedure TAlWavFile.WriteInfo;
var
  i: integer;
  InfName: AnsiString; //grg1 was String
  InfValue: AnsiString; //grg1 was String
  ckInfoLIST, ckInfoPiece: TMmckInfo;
begin
  //remove invalid info entries
  for i:= FInfo.Count-1 downto 0 do
    if (Length(FInfo[i]) < 6) or (FInfo[i][5] <> '=') then FInfo.Delete(i);
  //do not save empty info list
  if FInfo.Count = 0 then Exit;

  //create LIST chunk
  ckInfoLIST.fccType := mmioStringToFOURCCA('INFO', 0);
  rc := mmioCreateChunk(FHandle, @ckInfoLIST, MMIO_CREATELIST);
  ChkErr;

  //save info entries
  for i:= 0 to FInfo.Count-1 do
    begin
    InfName := AnsiString(Copy(FInfo[i], 1, 4)); //grg1 typecast



    InfValue := AnsiString(Copy(FInfo[i], 6, MAXINT)); //grg1 typecast    //create subchunk
	//create subchunk
    ckInfoPiece.ckId := mmioStringToFOURCCA(PAnsiChar(InfName), 0); //grg
    ckInfoPiece.ckSize := Length(InfValue);
    rc := mmioCreateChunk(FHandle, @ckInfoPiece, 0);
    ChkErr;
    //save subchunk data

    rc := mmioWrite(FHandle, PAnsiChar(InfValue), Length(InfValue)); //grg
    ErrIf(rc <> Length(InfValue), 'WAV write error');
    //exit subchunk
    rc := mmioAscend(FHandle, @ckInfoPiece, 0);
    ChkErr;
    end;

  //exit LIST
  rc := mmioAscend(FHandle, @ckInfoLIST, 0);
  ChkErr;
end;


procedure TAlWavFile.ReadInfo;
var
  Data: string;
  ckInfoLIST: TMmckInfo;
  InfName: string;
  InfValue: string;
  Len: integer;
begin
  FInfo.Clear;
  //descend into LIST/INFO
  ckInfoLIST.fccType := mmioStringToFOURCCA('INFO', 0);
  rc := mmioDescend(FHandle, @ckInfoLIST, @ckInfoRIFF, MMIO_FINDLIST);
  try
    if rc <> MMSYSERR_NOERROR then Exit;
    //read info
    SetLength(Data, ckInfoLIST.cksize - 4 {4-char list type});
    rc := mmioRead(FHandle, @Data[1], Length(Data));
    ErrIf(rc <> Length(Data), 'Unable to read header');
    //exit LIST
    rc := mmioAscend(FHandle, @ckInfoLIST, 0);
    ChkErr;
  finally
    //always rewind
    mmioSeek(FHandle, ckInfoRIFF.dwDataOffset + 4, SEEK_SET); 
  end;

  //parse info
  while Length(Data) > 8 {4 for chunk ID and 4 for length} do
    begin
    InfName := Copy(Data, 1, 4);
    Len := PInteger(@Data[5])^;
    InfValue := Copy(Data, 9, Len);
    Delete(Data, 1, 8+Len);
    if Copy(Data, 1, 1) = #0 then Delete(Data, 1, 1); //padded byte
    FInfo.Add(InfName + '=' + InfValue);
    end;
end;







//------------------------------------------------------------------------------
//                             Error checking
//------------------------------------------------------------------------------

procedure TAlWavFile.ChkErr;
var
  Buf: array [0..MAXERRORLENGTH-1] of Char;
begin
  if rc = MMSYSERR_NOERROR then Exit;

  if waveInGetErrorText(rc, Buf, MAXERRORLENGTH) = MMSYSERR_NOERROR
    then raise Exception.Create(Buf)
    else raise Exception.Create('Unknown error: ' + IntToStr(rc));
end;


procedure TAlWavFile.ErrIf(IsErr: boolean; Msg: string);
begin
  if IsErr then raise Exception.Create(Msg);
end;


procedure TAlWavFile.ChkNotOpen;
begin
  ErrIf(FIsOpen, 'Cannot change parameter when the file is open');
end;




procedure TAlWavFile.NormalizeData;
var
  i: integer;
  Mx: Single;
begin
  //find max in L
  Mx := 0;
  if FLData <> nil then
    for i:=0 to High(FLData) do
      if Abs(FLData[i]) > Mx then Mx := Abs(FLData[i]);
  //find max in R
  if FRData <> nil then
    for i:=0 to High(FRData) do
      if Abs(FRData[i]) > Mx then Mx := Abs(FRData[i]);
  //scale
  if Mx > 0 then
    begin
    Mx := 32767 / Mx;
    if FLData <> nil then
      for i:=0 to High(FLData) do FLData[i] := FLData[i] * Mx;
    if FRData <> nil then
      for i:=0 to High(FRData) do FRData[i] := FRData[i] * Mx;
    end;
end;


end.
