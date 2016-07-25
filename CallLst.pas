//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
unit CallLst;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Ini, FileUtil;

procedure LoadCallList;
function PickCall: string;

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
  P, Pe: PChar;
  L: TList;

  FileName: string;
  FFileSize: integer;

  FIndex: array[0..INDEXSIZE-1] of integer;
  Data: string;
begin
  Calls.Clear;

  FileName := ExtractFilePath(ParamStr(0)) + 'Master.dta';
  if not FileExistsUTF8(FileName) { *Converted from FileExists* } then Exit;

  with TFileStream.Create(FileName, fmOpenRead) do
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


  L := TList.Create;
  try
    //list pointers to calls
    L.Capacity := 20000;
      P := @Data[1];
    Pe := P + Length(Data);
    while P < Pe do
      begin
      L.Add(TObject(P));
      P := P + StrLen(P) + 1;
      end;
    //delete dupes
    L.Sort(CompareCalls);
    for i:=L.Count-1 downto 1 do
      if StrComp(PChar(L[i]), PChar(L[i-1])) = 0
        then L[i] := nil;
    //put calls to Lst
    Calls.Capacity := L.Count;
    for i:=0 to L.Count-1 do
      if L[i] <> nil then Calls.Add(PChar(L[i]));
  finally
    L.Free;
  end;
end;


function PickCall: string;
var
  Idx: integer;
begin
  if Calls.Count = 0 then begin Result := 'P29SX'; Exit; end;

  Idx := Random(Calls.Count);
  Result := Calls[Idx];

  if Ini.RunMode = rmHst then Calls.Delete(Idx);
end;


initialization
  Calls := TStringList.Create;

finalization
  Calls.Free;

end.

