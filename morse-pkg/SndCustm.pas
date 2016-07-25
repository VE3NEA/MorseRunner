//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
unit SndCustm;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Forms, SyncObjs, MMSystem, SndTypes,
  Windows;

const
  DEFAULTBUFCOUNT = 8;

type
  TCustomSoundInOut = class;

  TWaitThread = class(TThread)
    private
      Owner: TCustomSoundInOut;
      Msg: TMsg;
      procedure ProcessEvent;
    protected
      procedure Execute; override;
    public
    end;


  TCustomSoundInOut = class(TComponent)
  private
    FDeviceID: UINT;
    FEnabled : boolean;
    procedure SetDeviceID(const Value: UINT);
    procedure SetSamplesPerSec(const Value: LongWord);
    function  GetSamplesPerSec: LongWord;
    procedure SetEnabled(AEnabled: boolean);
    procedure DoSetEnabled(AEnabled: boolean);
    function GetBufCount: LongWord;
    procedure SetBufCount(const Value: LongWord);
  protected
    FThread: TWaitThread;
    rc: MMRESULT;
    DeviceHandle: HWAVEOUT;
    WaveFmt: TPCMWaveFormat;
    Buffers: array of TWaveBuffer;
    FBufsAdded: LongWord;
    FBufsDone: LongWord;

    procedure Loaded; override;
    procedure Err(Txt: string);
    function GetThreadID: THandle;

    //override these
    procedure Start; virtual; abstract;
    procedure Stop; virtual; abstract;
    procedure BufferDone(AHdr: PWaveHdr); virtual; abstract;

    property Enabled: boolean read FEnabled write SetEnabled default false;
    property DeviceID: UINT read FDeviceID write SetDeviceID default WAVE_MAPPER;
    property SamplesPerSec: LongWord read GetSamplesPerSec write SetSamplesPerSec default 48000;
    property BufsAdded: LongWord read FBufsAdded;
    property BufsDone: LongWord read FBufsDone;
    property BufCount: LongWord read GetBufCount write SetBufCount;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;




implementation


{ TWaitThread }

//------------------------------------------------------------------------------
//                               TWaitThread
//------------------------------------------------------------------------------

procedure TWaitThread.Execute;
begin
  Priority := tpTimeCritical;

  while GetMessage(Msg, 0, 0, 0) do
    if Terminated then Exit
    else if Msg.hwnd <> 0 then Continue
    else
      case Msg.Message of
        MM_WIM_DATA, MM_WOM_DONE: Synchronize(ProcessEvent);
        MM_WIM_CLOSE: Terminate;
        end;
end;


procedure TWaitThread.ProcessEvent;
begin
  try
    if Msg.wParam = Owner.DeviceHandle then
      Owner.BufferDone(PWaveHdr(Msg.lParam));
  except on E: Exception do
    begin
    Application.ShowException(E);
    Terminate;
    end;
  end;
end;






{ TCustomSoundInOut }

//------------------------------------------------------------------------------
//                               system
//------------------------------------------------------------------------------
constructor TCustomSoundInOut.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  SetBufCount(DEFAULTBUFCOUNT);

  FDeviceID := WAVE_MAPPER;

  //init WaveFmt
  with WaveFmt do
    begin
    wf.wFormatTag := WAVE_FORMAT_PCM;
    wf.nChannels := 1;             //mono
    wf.nBlockAlign := 2;           //SizeOf(SmallInt) * nChannels;
    wBitsPerSample := 16;          //SizeOf(SmallInt) * 8;
    end;

  //fill nSamplesPerSec, nAvgBytesPerSec in WaveFmt
  SamplesPerSec := 48000;
end;


destructor TCustomSoundInOut.Destroy;
begin
  Enabled := false;
  inherited;
end;


procedure TCustomSoundInOut.Err(Txt: string);
begin
  raise ESoundError.Create(Txt);
end;





//------------------------------------------------------------------------------
//                            enable/disable
//------------------------------------------------------------------------------
//do not enable component at design or load time
procedure TCustomSoundInOut.SetEnabled(AEnabled: boolean);
begin
  if (not (csDesigning in ComponentState)) and
     (not (csLoading in ComponentState)) and
     (AEnabled <> FEnabled)
    then DoSetEnabled(AEnabled);
  FEnabled := AEnabled;
end;


//enable component after all properties have been loaded
procedure TCustomSoundInOut.Loaded;
begin
  inherited Loaded;

  if FEnabled and not (csDesigning in ComponentState) then
    begin
    FEnabled := false;
    SetEnabled(true);
    end;
end;


procedure TCustomSoundInOut.DoSetEnabled(AEnabled: boolean);
begin
  if AEnabled
    then
      begin
      //reset counts
      FBufsAdded := 0;
      FBufsDone := 0;
      //create waiting thread
      FThread := TWaitThread.Create(true);
      FThread.FreeOnTerminate := true;
      FThread.Owner := Self;
      //FThread.Priority := tpTimeCritical;
      //start
      FEnabled := true;
      try Start; except FreeAndNil(FThread); raise; end;
      //device started ok, wait for events
      FThread.Resume;
      end
    else
      begin
      FThread.Terminate;
      Stop;
      end;
end;





//------------------------------------------------------------------------------
//                              get/set
//------------------------------------------------------------------------------

procedure TCustomSoundInOut.SetSamplesPerSec(const Value: LongWord);
begin
  Enabled := false;

  with WaveFmt.wf do
    begin
    nSamplesPerSec := Value;
    nAvgBytesPerSec := nSamplesPerSec * nBlockAlign;
    end;
end;


function TCustomSoundInOut.GetSamplesPerSec: LongWord;
begin
  Result := WaveFmt.wf.nSamplesPerSec;
end;



procedure TCustomSoundInOut.SetDeviceID(const Value: UINT);
begin
  Enabled := false;
  FDeviceID := Value;
end;



function TCustomSoundInOut.GetThreadID: THandle;
begin
  Result := FThread.ThreadID;
end;


function TCustomSoundInOut.GetBufCount: LongWord;
begin
  Result := Length(Buffers);
end;

procedure TCustomSoundInOut.SetBufCount(const Value: LongWord);
begin
  if Enabled then
    raise Exception.Create('Cannot change the number of buffers for an open audio device');
  SetLength(Buffers, Value);
end;







end.

