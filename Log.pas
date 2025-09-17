//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------

//grg 26112015 1450 Delphi 10 Changes done

unit Log;

interface

uses
  Windows, SysUtils, Classes, Graphics, RndFunc, Math;


procedure SaveQso;
procedure LastQsoToScreen;
procedure Clear;
procedure UpdateStats;
procedure UpdateStatsHst;
procedure CheckErr;
procedure PaintHisto;
procedure ShowRate;



type
  PQso = ^TQso;
  TQso = record
    T: TDateTime;
    Call, TrueCall: string;
    Rst, TrueRst: integer;
    Nr, TrueNr: integer;
    Pfx: string;
    Dupe: boolean;
    Err: string;
  end;


var
  QsoList: array of TQso;
  PfxList: TStringList;
  CallSent, NrSent: boolean;



implementation

uses
  Contest, Main, DxStn, DxOper, Ini, MorseKey;

procedure Clear;
var
  Empty: string;
begin
  QsoList := nil;
  Tst.Stations.Clear;
  MainForm.RichEdit1.Lines.Clear;

  if Ini.RunMode = rmHst
    then MainForm.RichEdit1.Lines.Add(' UTC       Call          Recv      Sent      Score  Chk')
    else MainForm.RichEdit1.Lines.Add(' UTC       Call          Recv      Sent      Pref   Chk');
  MainForm.RichEdit1.SelStart := 1;
  MainForm.RichEdit1.SelLength := Length(MainForm.RichEdit1.Lines[0]);
  MainForm.RichEdit1.SelAttributes.Style := [fsUnderline];
  MainForm.RichEdit1.SelAttributes.Color := clBlue;

  if Ini.RunMode = rmHst then Empty := '' else Empty := '0';

  MainForm.ListView1.Items[0].SubItems[0] := Empty;
  MainForm.ListView1.Items[1].SubItems[0] := Empty;
  MainForm.ListView1.Items[0].SubItems[1] := Empty;
  MainForm.ListView1.Items[1].SubItems[1] := Empty;
  MainForm.ListView1.Items[2].SubItems[0] := '0';
  MainForm.ListView1.Items[2].SubItems[1] := '0';

  MainForm.PaintBox1.Invalidate;
end;


function CallToScore(S: string): integer;
var
  i: integer;
begin
  S := Keyer.Encode(S);
  Result := -1;
  for i:=1 to Length(S) do
    case S[i] of
      '.': Inc(Result, 2);
      '-': Inc(Result, 4);
      ' ': Inc(Result, 2);
    end;
end;

procedure UpdateStatsHst;
var
  CallScore, RawScore, Score: integer;
  i: integer;
begin
  RawScore := 0;
  Score := 0;

  for i:=0 to High(QsoList) do
      begin
      CallScore := CallToScore(QsoList[i].Call);
      Inc(RawScore, CallScore);
      if QsoList[i].Err = '   ' then Inc(Score, CallScore);
      end;

  MainForm.ListView1.Items[0].SubItems[0] := '';
  MainForm.ListView1.Items[1].SubItems[0] := '';
  MainForm.ListView1.Items[2].SubItems[0] := IntToStr(RawScore);

  MainForm.ListView1.Items[0].SubItems[1] := '';
  MainForm.ListView1.Items[1].SubItems[1] := '';
  MainForm.ListView1.Items[2].SubItems[1] := IntToStr(Score);

  MainForm.PaintBox1.Invalidate;

  MainForm.Panel11.Caption := IntToStr(Score);
end;


procedure UpdateStats;
var
  i, Pts, Mul: integer;
begin
  //raw

  Pts := Length(QsoList);
  PfxList.Clear;
  for i:=0 to High(QsoList) do PfxList.Add(QsoList[i].Pfx);
  Mul := PfxList.Count;

  MainForm.ListView1.Items[0].SubItems[0] := IntToStr(Pts);
  MainForm.ListView1.Items[1].SubItems[0] := IntToStr(Mul);
  MainForm.ListView1.Items[2].SubItems[0] := IntToStr(Pts*Mul);

  //verified

  Pts := 0;
  PfxList.Clear;
  for i:=0 to High(QsoList) do
    if QsoList[i].Err = '   ' then
    begin
    Inc(Pts);
    PfxList.Add(QsoList[i].Pfx);
    end;
  Mul := PfxList.Count;

  MainForm.ListView1.Items[0].SubItems[1] := IntToStr(Pts);
  MainForm.ListView1.Items[1].SubItems[1] := IntToStr(Mul);
  MainForm.ListView1.Items[2].SubItems[1] := IntToStr(Pts*Mul);

  MainForm.PaintBox1.Invalidate;
end;


function ExtractPrefix(Call: string): string;
const
  DIGITS = ['0'..'9'];
  LETTERS = ['A'..'Z'];
var
  p: integer;
  S1, S2, Dig: string;
begin
  //kill modifiers
  Call := Call + '|';
  Call := StringReplace(Call, '/QRP|', '', []);
  Call := StringReplace(Call, '/MM|', '', []);
  Call := StringReplace(Call, '/M|', '', []);
  Call := StringReplace(Call, '/P|', '', []);
  Call := StringReplace(Call, '|', '', []);
  Call := StringReplace(Call, '//', '/', [rfReplaceAll]);
  if Length(Call) < 2 then begin Result := ''; Exit; end;

  Dig := '';

  //select shorter piece
  p := Pos('/', Call);
  if p = 0 then Result := Call
  else if p = 1 then Result := Copy(Call, 2, MAXINT)
  else if p = Length(Call) then Result := Copy(Call, 1, p-1)
  else
    begin
    S1 := Copy(Call, 1, p-1);
    S2 := Copy(Call, p+1, MAXINT);

    if (Length(S1) = 1) and CharInSet(S1[1], DIGITS) then begin Dig := S1; Result := S2; end //grg1
    else if (Length(S2) = 1) and CharInSet(S2[1], DIGITS) then begin Dig := S2; Result := S1; end //grg1
    else if Length(S1) <= Length(S2) then Result := S1
    else Result := S2;
    end;
  if Pos('/', Result) > 0 then begin Result := ''; Exit; end;

  //delete trailing letters, retain at least 2 chars
  for p:= Length(Result) downto 3 do
    if CharInSet(Result[p], DIGITS) then Break //grg1
    else Delete(Result, p, 1);

  //ensure digit
  if not CharInSet(Result[Length(Result)], DIGITS) then Result := Result + '0'; //grg1
  //replace digit
  if Dig <> '' then Result[Length(Result)] := Dig[1];

  Result := Copy(Result, 1, 5);
end;


procedure SaveQso;
var
  i: integer;
  Qso: PQso;
begin
  with MainForm do
    begin
    if (Length(Edit1.Text) < 3) or (Length(Edit2.Text) <> 3) or (Edit3.Text = '')
      then begin Beep; Exit; end;

    //add new entry to log
    SetLength(QsoList, Length(QsoList)+1);
    Qso := @QsoList[High(QsoList)];
    //save data
    Qso.T := BlocksToSeconds(Tst.BlockNumber) /  86400;
    Qso.Call := StringReplace(Edit1.Text, '?', '', [rfReplaceAll]);
    Qso.Rst := StrToInt(Edit2.Text);
    Qso.Nr := StrToInt(Edit3.Text);
    Qso.Pfx := ExtractPrefix(Qso.Call);
    {if PfxList.Find(Qso.Pfx, Idx) then Qso.Pfx := '' else }PfxList.Add(Qso.Pfx);
    if Ini.RunMode = rmHst then Qso.Pfx := IntToStr(CallToScore(Qso.Call));


    //mark if dupe
    Qso.Dupe := false;
    for i:=0 to High(QsoList)-1 do
      with QsoList[i] do
        if (Call = Qso.Call) and (Err = '   ')
          then Qso.Dupe := true;

    //what's in the DX's log?
    for i:=Tst.Stations.Count-1 downto 0 do
      if Tst.Stations[i] is TDxStation then
        with Tst.Stations[i] as TDxStation do
          if (Oper.State = osDone) and (MyCall = Qso.Call)
            then begin DataToLastQso; Break; end; //deletes the dx station!
    CheckErr;
    end;

  LastQsoToScreen;
  if Ini.RunMode = rmHst
    then UpdateStatsHst
    else UpdateStats;

  //wipe
  MainForm.WipeBoxes;
  //inc NR
  Inc(Tst.Me.NR);
end;


procedure LastQsoToScreen;
const
  EM_SCROLLCARET = $B7;
  EM_SCROLL = $B5; //grg test
  SB_LINEDOWN = $01; //grg test
var
  S: string;
begin
  with QsoList[High(QsoList)] do
    begin
    S := FormatDateTime(' hh:nn:ss  ', t) +
         Format('%-12s  %.3d %.4d  %.3d %.4d  %-5s  %-3s', // grg for Nr changed '%.4d' to %4s, was wrong type see TQSO, access violation

         [Call, Rst, Nr, Tst.Me.Rst,
         //Tst.Me.NR,
         MainForm.RichEdit1.Lines.Count,
         Pfx, Err]);
	end;
  MainForm.RichEdit1.Lines.Add(S);
//grg fix later    MainForm.RichEdit1.SelStart := Length(MainForm.RichEdit1.Text) - 5;
//grg fix later    MainForm.RichEdit1.SelLength := 3;
//grg fix later    MainForm.RichEdit1.SelAttributes.Color := clRed;
// grg broken in Delphi 10   MainForm.RichEdit1.Perform(EM_SCROLLCARET, 0, 0); //grg This original line does not scroll down in Delphi 10 anymore after logscreen care at bottom of RichEdit1
  MainForm.RichEdit1.Perform(EM_SCROLL, SB_LINEDOWN, 0); //grg this scolls down when cursor at bottom line and new QSO logged
end;


procedure CheckErr;
begin
  with QsoList[High(QsoList)] do
    begin
    if TrueCall = '' then Err := 'NIL'
    else if Dupe then Err := 'DUP'
    else if TrueRst <> Rst then Err := 'RST'
    else if TrueNr <> NR then Err := 'NR '
    else Err := '   ';
    end;
end;


procedure PaintHisto;
var
  Histo: array[0..47] of integer;
  i: integer;
  x, y: integer;
begin
  FillChar(Histo, SizeOf(Histo), 0);

  for i:=0 to High(QsoList) do
    begin
    x := Trunc(QsoList[i].T * 1440) div 5;
    Inc(Histo[x]);
    end;

  with MainForm.PaintBox1, MainForm.PaintBox1.Canvas do
    begin
    Brush.Color := Color;
    FillRect(RECT(0,0, Width, Height));
    for i:=0 to High(Histo) do
      begin
      Brush.Color := clGreen;
      x := i * 4 + 1;
      y := Height - 3 - Histo[i] * 2;
      FillRect(Rect(x, y, x+3, Height-2));
      end;
    end;
end;


procedure ShowRate;
var
  i, Cnt: integer;
  T, D: Single;
begin
  T := BlocksToSeconds(Tst.BlockNumber) / 86400;
  if T = 0 then Exit;
  D := Min(5/1440, T);

  Cnt := 0;
  for i:=High(QsoList) downto 0 do
    if QsoList[i].T > (T-D) then Inc(Cnt) else Break;


  MainForm.Panel7.Caption := Format('%d  qso/hr.', [Round(Cnt / D / 24)]);
end;



initialization
  PfxList := TStringList.Create;
  PfxList.Sorted := true;
  PfxList.Duplicates := dupIgnore;

finalization
  PfxList.Free;

end.

