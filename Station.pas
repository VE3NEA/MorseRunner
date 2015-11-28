//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
unit Station;

interface

uses
  SysUtils, Classes, Math, SndTypes, Ini, MorseKey;

const
  NEVER = MAXINT;

type
  TStationMessage =  (msgNone, msgCQ, msgNR, msgTU, msgMyCall, msgHisCall,
    msgB4, msgQm, msgNil, msgGarbage, msgR_NR, msgR_NR2, msgDeMyCall1, msgDeMyCall2,
    msgDeMyCallNr1, msgDeMyCallNr2, msgNrQm, msgLongCQ, msgMyCallNr2,
    msgQrl, msgQrl2, msqQsy, msgAgn);

  TStationMessages = set of TStationMessage;
  TStationState = (stListening, stCopying, stPreparingToSend, stSending);
  TStationEvent = (evTimeout, evMsgSent, evMeStarted, evMeFinished);


  TStation = class (TCollectionItem)
  private
    FBfo: Single;
    dPhi: Single;
    FPitch: integer;
    function GetBfo: Single;
    procedure SetPitch(const Value: integer);
  protected
    SendPos: integer;
    TimeOut: integer;
    NrWithError: boolean;
    function NrAsText: string;
  public
    Amplitude: Single;
    Wpm: integer;
    Envelope: TSingleArray;
    State: TStationState;

    NR, RST: integer;
    MyCall, HisCall: string;

    Msg: TStationMessages;
    MsgText: string;

    constructor CreateStation;

    procedure Tick; 
    function GetBlock: TSingleArray; virtual;
    procedure ProcessEvent(AEvent: TStationEvent); virtual; abstract;

    procedure SendMsg(AMsg: TStationMessage);
    procedure SendText(AMsg: string); virtual;
    procedure SendMorse(AMorse: string);

    property Pitch: integer read FPitch write SetPitch;
    property Bfo: Single read GetBfo;
  end;

implementation

{ TStation }

constructor TStation.CreateStation;
begin
  inherited Create(nil);
end;

function TStation.GetBfo: Single;
begin
  Result := FBfo;
  FBfo := FBfo + dPhi;
  if FBfo > TWO_PI then FBfo := FBfo - TWO_PI;
end;


function TStation.GetBlock: TSingleArray;
begin
  Result := Copy(Envelope, SendPos, Ini.BufSize);

  //advance TX buffer
  Inc(SendPos, Ini.BufSize);
  if SendPos = Length(Envelope) then Envelope := nil;
end;


procedure TStation.SendMsg(AMsg: TStationMessage);
begin
  if Envelope = nil then Msg := [];
  if AMsg = msgNone then begin State := stListening; Exit; End;
  Include(Msg, AMsg);

  case AMsg of
    msgCQ: SendText('CQ <my> TEST');
    msgNR: SendText('<#>');
    msgTU: SendText('TU');
    msgMyCall: SendText('<my>');
    msgHisCall: SendText('<his>');
    msgB4: SendText('QSO B4');
    msgQm: SendText('?');
    msgNil: SendText('NIL');
    msgR_NR: SendText('R <#>');
    msgR_NR2: SendText('R <#> <#>');
    msgDeMyCall1: SendText('DE <my>');
    msgDeMyCall2: SendText('DE <my> <my>');
    msgDeMyCallNr1: SendText('DE <my> <#>');
    msgDeMyCallNr2: SendText('DE <my> <my> <#>');
    msgMyCallNr2: SendText('<my> <my> <#>');
    msgNrQm: SendText('NR?');
    msgLongCQ: SendText('CQ CQ TEST <my> <my> TEST');
    msgQrl: SendText('QRL?');
    msgQrl2: SendText('QRL?   QRL?');
    msqQsy: SendText('<his>  QSY QSY');
    msgAgn: SendText('AGN');
    end;
end;

procedure TStation.SendText(AMsg: string);
begin
  if Pos('<#>', AMsg) > 0 then
    begin
    //with error
    AMsg := StringReplace(AMsg, '<#>', NrAsText, []);
    //error cleared
    AMsg := StringReplace(AMsg, '<#>', NrAsText, [rfReplaceAll]);
    end;

  AMsg := StringReplace(AMsg, '<my>', MyCall, [rfReplaceAll]);

{
  if CallsFromKeyer
     then AMsg := StringReplace(AMsg, '<his>', ' ', [rfReplaceAll])
     else AMsg := StringReplace(AMsg, '<his>', HisCall, [rfReplaceAll]);
}

  if MsgText <> ''
    then MsgText := MsgText + ' ' + AMsg
    else MsgText := AMsg;
  SendMorse(Keyer.Encode(MsgText));
end;


procedure TStation.SendMorse(AMorse: string);
var
  i: integer;
begin
  if Envelope = nil then
    begin
    SendPos := 0;
    FBfo := 0;
    end;
    
  Keyer.Wpm := Wpm;
  Keyer.MorseMsg := AMorse;
  Envelope := Keyer.Envelope;
  for i:=0 to High(Envelope) do Envelope[i] := Envelope[i] * Amplitude;

  State := stSending;
  TimeOut := NEVER;
end;



procedure TStation.SetPitch(const Value: integer);
begin
  FPitch := Value;
  dPhi := TWO_PI * FPitch / DEFAULTRATE;
end;


procedure TStation.Tick;
begin
  //just finished sending
  if (State = stSending) and (Envelope = nil) then
    begin
    MsgText := '';
    State := stListening;
    ProcessEvent(evMsgSent);
    end

  //check timeout
  else if State <> stSending then
    begin
    if TimeOut > -1 then Dec(TimeOut);
    if TimeOut = 0 then ProcessEvent(evTimeout);
    end;
end;


                                                
function TStation.NrAsText: string;
var
  Idx: integer;
begin
  Result := Format('%d%.3d', [RST, NR]);

  if NrWithError then
    begin
    Idx := Length(Result);
    if not CharInSet(Result[Idx], ['2'..'7']) then Dec(Idx); //grg1

    if CharInSet(Result[Idx], ['2'..'7']) then //grg1
      begin
      if Random < 0.5 then Dec(Result[Idx]) else Inc(Result[Idx]);
      Result := Result + Format('EEEEE %.3d', [NR]);
      end;
    NrWithError := false;
    end;

  Result := StringReplace(Result, '599', '5NN', [rfReplaceAll]);

  if Ini.RunMode <> rmHst then
    begin
    Result := StringReplace(Result, '000', 'TTT', [rfReplaceAll]);
    Result := StringReplace(Result, '00', 'TT', [rfReplaceAll]);

    if Random < 0.4
      then Result := StringReplace(Result, '0', 'O', [rfReplaceAll])
    else if Random < 0.97
      then Result := StringReplace(Result, '0', 'T', [rfReplaceAll]);

    if Random < 0.97
      then Result := StringReplace(Result, '9', 'N', [rfReplaceAll]);
    end;
end;




end.

