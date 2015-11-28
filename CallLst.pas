//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------

//grg 26112015 1439 Delphi 10 Changes done

unit CallLst;

interface

uses
  SysUtils, Classes, Ini, StrUtils, Windows;

procedure LoadCallList;
function PickCall: AnsiString;

var
  Calls: TStringList;




implementation


function CompareCalls(Item1, Item2: Pointer): Integer;
begin
  Result := StrComp(PChar(Item1), PChar(Item2));
end;

procedure LoadCallList;
const
  Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/';
  CHRCOUNT = Length(Chars);
  INDEXSIZE = Sqr(CHRCOUNT) + 1;
  INDEXBYTES = INDEXSIZE * SizeOf(Integer);
var
  i: integer;
  P, Pe, myP: PAnsiChar;
  L: TStringList;
  mystring: string;
  myansichar : AnsiChar;
  mychar : char;
  mypstring : ^string;

  FileName: TFileName; //grg ve3nea FileName: AnsiString;
  FFileSize: integer;

  FIndex: array[0..INDEXSIZE-1] of integer;
  Data: AnsiString;
begin
  Calls.Clear;

  //grg ve3nea FileName := AnsiString(ExtractFilePath(ParamStr(0)) + 'Master.dta'); //grg1 typecast
  FileName := TFileName(ExtractFilePath(ParamStr(0)) + 'Master.dta');
  if not FileExists(string(FileName)) then Exit;    //grg1 typecast

  with TFileStream.Create(string(FileName), fmOpenRead) do   //grg1 typecast
    try
      FFileSize := Size;
      if FFileSize < INDEXBYTES then Exit;
      ReadBuffer(FIndex, INDEXBYTES);

      if (FIndex[0] <> INDEXBYTES) or (FIndex[INDEXSIZE-1] <> FFileSize)
        then Exit;
      SetLength(Data, Size - Position);
      ReadBuffer(Data[1], Length(Data));
    finally
      Free;
    end;


  L := TStringList.Create;
  try
    //list pointers to calls
    //grg L.Capacity := 20000;
    P := @Data[1];
    Pe := P + Length(Data);
    while P < Pe do
      begin
        myP := P;
        myansichar := myP^;
        mystring := '';
        while myansichar <> #0 do
          begin
            mychar := widechar(myansichar);
            mystring := mystring + mychar;
            myP := myP + 1;
            myansichar := myP^;
          end;
        L.Add(mystring); //grg test L.Add(@mystring); //grg
        P := P + length(mystring) + 1; //grg test P := P + StrLen(P) + 1;
      end;
//grg fix later    //delete dupes
//grg fix later    L.Sort(CompareCalls);
//grg fix later    for i:=L.Count-1 downto 1 do
//grg fix later      if StrComp(PChar(L[i]), PChar(L[i-1])) = 0
//grg fix later        then L[i] := nil;
// grg Since we now use TStringlist the Dupe removal should be done using TStringlist means, not as above..
    //put calls to Lst
    Calls.Capacity := L.Count;
    for i:=0 to L.Count-1 do
      begin
        mystring := L.Strings[i];
        mypstring := @mystring;
        if mypstring <> nil then
          begin
            //grg Calls.Add(PChar(L[i]));
            Calls.Add(mypstring^);
          end;
      end;
  finally
    L.Free;
  end;
end;


function PickCall: AnsiString;
var
  Idx: integer;
begin
  if Calls.Count = 0 then begin Result := 'P29SX'; Exit; end;

  Idx := Random(Calls.Count);
  Result := AnsiString(Calls[Idx]);

  if Ini.RunMode = rmHst then Calls.Delete(Idx);
end;


initialization
  Calls := TStringList.Create;

finalization
  Calls.Free;

end.

