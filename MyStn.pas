//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------

//grg no Delphi10 changes needed

unit MyStn;

interface

uses
  SysUtils, Classes, Station, RndFunc, Ini, SndTypes, MorseKey;

type
  TMyStation = class(TStation)
  private
    Pieces: TStringList;
    procedure AddToPieces(AMsg: string);
    procedure SendNextPiece;
  public
    constructor CreateStation;
    destructor Destroy; override;
    procedure Init;
    procedure ProcessEvent(AEvent: TStationEvent); override;
    procedure AbortSend;
    procedure SendText(AMsg: string); override;
    function GetBlock: TSingleArray; override;
    function UpdateCallInMessage(ACall: string): boolean;
  end;


implementation

uses
  Contest, Main;

{ TMyStation }

constructor TMyStation.CreateStation;
begin
  inherited Create(nil);
  Pieces := TStringList.Create;
  Init;
end;


destructor TMyStation.Destroy;
begin
  Pieces.Free;
  inherited;
end;


procedure TMyStation.Init;
begin
  MyCall := Ini.Call;
  NR := 1;
  RST := 599;
  Pitch := Ini.Pitch;
  Wpm := Ini.Wpm;
  Amplitude := 300000;
end;


procedure TMyStation.ProcessEvent(AEvent: TStationEvent);
begin
  if AEvent = evMsgSent then Tst.OnMeFinishedSending;
end;


procedure TMyStation.AbortSend;
begin
  Envelope := nil;
  Msg := [msgGarbage];
  MsgText := '';
  Pieces.Clear;
  State := stListening;
  ProcessEvent(evMsgSent);
end;


procedure TMyStation.SendText(AMsg: string);
begin
  AddToPieces(AMsg);
  if State <> stSending then
    begin
    SendNextPiece;
    Tst.OnMeStartedSending;
    end;
end;


procedure TMyStation.AddToPieces(AMsg: string);
var
  p, i: integer;
begin
  //split into pieces
  //special processing of callsign
  p := Pos('<his>', AMsg);
  while p > 0 do
    begin
    Pieces.Add(Copy(AMsg, 1, p-1));
    Pieces.Add('@');  //his callsign indicator
    Delete(AMsg, 1, p+4);
    p := Pos('<his>', AMsg);
    end;
  Pieces.Add(AMsg);

  for i:= Pieces.Count-1 downto 0 do
    if Pieces[i] = '' then Pieces.Delete(i);
end;


procedure TMyStation.SendNextPiece;
begin
  MsgText := '';

  if Pieces[0] <> '@' then inherited SendText(Pieces[0])
  else if CallsFromKeyer and (not (RunMode in [rmHst, rmWpx])) then inherited SendText(' ')
  else inherited SendText(HisCall);
end;



function TMyStation.GetBlock: TSingleArray;
begin
  Result := inherited GetBlock;
  if Envelope = nil then
    begin
    Pieces.Delete(0);
    if Pieces.Count > 0 then SendNextPiece;
    //cursor to exchange field
    MainForm.Advance;
    end;
end;


function TMyStation.UpdateCallInMessage(ACall: string): boolean;
var
  NewEnvelope: TSingleArray;
  i: integer;
begin
  Result := false;
  if ACall = '' then Exit;
  NewEnvelope := nil;

  //are we sending call now?
  Result := (Pieces.Count > 0) and (Pieces[0] = '@');

  //is the already sent part of the call the same as in the new call?
  if Result then
    begin
    //create new envelope
    Keyer.Wpm := Wpm;
    Keyer.MorseMsg := Keyer.Encode(ACall);
    NewEnvelope := Keyer.Envelope;
    for i:=0 to High(NewEnvelope) do
      NewEnvelope[i] := NewEnvelope[i] * Amplitude;
      
    //compare to the old one
    Result := Length(NewEnvelope) >= SendPos;
    if Result then
      for i:=0 to SendPos-1 do
        begin
        Result := Envelope[i] = NewEnvelope[i];
        if not Result then Break;
        end;

    //update
    if Result then
      begin
      Envelope := NewEnvelope;
      HisCall := ACall;
      end;
    end;


  //could not correct the current message
  //but another call is scheduled for sending
  if not Result then
    for i:=1 to Pieces.Count-1 do
      if Pieces[i] = '@' then
        begin
        Result := true;
        HisCall := ACall;
        Exit;
        end;
end;



end.

