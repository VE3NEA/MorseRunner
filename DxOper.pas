//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------

//grg 26112015 1445 Delphi 10 Changes done

unit DxOper;

interface

uses
  SysUtils, RndFunc, Station, Ini, Math, Log;

const
  FULL_PATIENCE = 5;

type
  TOperatorState = (osNeedPrevEnd, osNeedQso, osNeedNr, osNeedCall,
    osNeedCallNr, osNeedEnd, osDone, osFailed);

  TCallCheckResult = (mcNo, mcYes, mcAlmost);


  TDxOperator = class
  private
    procedure DecPatience;
    function IsMyCall: TCallCheckResult;
  public
    Call: string;
    Skills: integer;
    Patience: integer;
    RepeatCnt: integer;
    State: TOperatorState;
    function GetSendDelay: integer;
    function GetReplyTimeout: integer;
    function GetWpm: integer;
    function GetNR: integer;
    procedure MsgReceived(AMsg: TStationMessages);
    procedure SetState(AState: TOperatorState);
    function GetReply: TStationMessage;
  end;


implementation

uses
  Contest;

{ TDxOperator }


//Delay before reply, keying speed and exchange number are functions
//of the operator's skills

function TDxOperator.GetSendDelay: integer;
begin
//  Result := Max(1, SecondsToBlocks(1 / Sqr(4*Skills)));
//  Result := Round(RndGaussLim(Result, 0.7 * Result));

  if State = osNeedPrevEnd
    then Result := NEVER
  else if RunMode = rmHst
    then Result := SecondsToBlocks(0.05 + 0.5*Random * 10/Wpm)
  else
    Result := SecondsToBlocks(0.1 + 0.5*Random);
end;

function TDxOperator.GetWpm: integer;
begin
  if RunMode = rmHst
    then Result := Ini.Wpm
    else Result := Round(Ini.Wpm * 0.5 * (1 + Random));
end;

function TDxOperator.GetNR: integer;
begin
  Result := 1 + Round(Random * Tst.Minute * Skills);
end;

function TDxOperator.GetReplyTimeout: integer;
begin
  if RunMode = rmHst
    then  Result := SecondsToBlocks(60/Wpm)
    else Result := SecondsToBlocks(6-Skills);
  Result := Round(RndGaussLim(Result, Result/2));
end;



procedure TDxOperator.DecPatience;
begin
  if State = osDone then Exit;

  Dec(Patience);
  if Patience < 1 then State := osFailed;
end;


procedure TDxOperator.SetState(AState: TOperatorState);
begin
  State := AState;
  if AState = osNeedQso
    then Patience := Round(RndRayleigh(4))
    else Patience := FULL_PATIENCE;

  if (AState = osNeedQso) and (not (RunMode in [rmSingle, RmHst])) and (Random < 0.1)
    then RepeatCnt := 2
    else RepeatCnt := 1;
end;


function TDxOperator.IsMyCall: TCallCheckResult;
const
  W_X = 2; W_Y = 2; W_D = 2;
var
  C, C0: string;
  M: array of array of integer;
  x, y: integer;
  T, L, D: integer;
begin
  C0 := Call;
  C := Tst.Me.HisCall;

  SetLength(M, Length(C)+1, Length(C0)+1);

  //dynamic programming algorithm

  for y:=0 to High(M[0]) do M[0,y] := 0;
  for x:=1 to High(M) do M[x,0] := M[x-1,0] + W_X;

  for x:=1 to High(M) do
    for y:=1 to High(M[0]) do
      begin
      T := M[x,y-1];
      //'?' can match more than one char
      //end may be missing
      if (x < High(M)) and (C[x] <> '?') then Inc(T, W_Y);

      L := M[x-1,y];
      //'?' can match no chars
      if C[x] <> '?' then Inc(L, W_X);

      D := M[x-1,y-1];
      //'?' matches any char
      if not CharInSet(C[x], [C0[y], '?']) then Inc(D, W_D); //grg1

      M[x,y] := MinIntValue([T,D,L]);
      end;

  //classify by penalty
  case M[High(M), High(M[0])] of
    0:   Result := mcYes;
    1,2: Result := mcAlmost;             
    else Result := mcNo;
  end;


  //callsign-specific corrections

  if (not Ini.Lids) and (Length(C) = 2) and (Result = mcAlmost) then Result := mcNo;

  //partial and wildcard match result in 0 penalty but are not exact matches
  if (Result = mcYes) then
    if (Length(C) <> Length(C0)) or (Pos('?', C) > 0)
      then Result := mcAlmost;

  //partial match too short
  if Length(StringReplace(C, '?', '', [rfReplaceAll])) < 2 then Result := mcNo;

  //accept a wrong call, or reject the correct one
  if Ini.Lids and (Length(C) > 3) then
    case Result of
      mcYes: if Random < 0.01 then Result := mcAlmost;
      mcAlmost: if Random < 0.04 then Result := mcYes;
      end;
end;


procedure TDxOperator.MsgReceived(AMsg: TStationMessages);
begin
  //if CQ received, we can call no matter what else was sent
  if msgCQ in AMsg then
    begin
    case State of
      osNeedPrevEnd: SetState(osNeedQso);
      osNeedQso: DecPatience;
      osNeedNr, osNeedCall, osNeedCallNr: State := osFailed;
      osNeedEnd: State := osDone;
      end;
    Exit;
    end;

  if msgNil in AMsg then
    begin
    case State of
      osNeedPrevEnd: SetState(osNeedQso);
      osNeedQso: DecPatience;
      osNeedNr, osNeedCall, osNeedCallNr, osNeedEnd: State := osFailed;
     end;
    Exit;
    end;  


  if msgHisCall in AMsg then
    case IsMyCall of
      mcYes:
        if State in [osNeedPrevEnd, osNeedQso] then SetState(osNeedNr)
        else if State = osNeedCallNr then SetState(osNeedNr)
        else if State = osNeedCall then SetState(osNeedEnd);

      mcAlmost:
        if State in [osNeedPrevEnd, osNeedQso] then SetState(osNeedCallNr)
        else if State = osNeedNr then SetState(osNeedCallNr)
        else if State = osNeedEnd then SetState(osNeedCall);

      mcNo:
        if State = osNeedQso then State := osNeedPrevEnd
        else if State in [osNeedNr, osNeedCall, osNeedCallNr] then State := osFailed
        else if State = osNeedEnd then State := osDone;
      end;


  if msgB4 in AMsg then
    case State of
      osNeedPrevEnd, osNeedQso: SetState(osNeedQso);
      osNeedNr, osNeedEnd: State := osFailed;
      osNeedCall, osNeedCallNr: ; //same state: correct the call
      end;


  if msgNR in AMsg then
    case State of
      osNeedPrevEnd: ;
      osNeedQso: State := osNeedPrevEnd;
      osNeedNr: if (Random < 0.9) or (RunMode = rmHst) then SetState(osNeedEnd);
      osNeedCall: ;
      osNeedCallNr: if (Random < 0.9) or (RunMode = rmHst) then SetState(osNeedCall);
      osNeedEnd: ;
      end;

  if msgTU in AMsg then
    case State of
      osNeedPrevEnd: SetState(osNeedQso);
      osNeedQso: ;
      osNeedNr: ;
      osNeedCall: ;
      osNeedCallNr: ;
      osNeedEnd: State := osDone;
      end;

  if (not Ini.Lids) and (AMsg = [msgGarbage]) then State := osNeedPrevEnd;


  if State <> osNeedPrevEnd then DecPatience;
end;


function TDxOperator.GetReply: TStationMessage;
begin
  case State of
    osNeedPrevEnd, osDone, osFailed: Result := msgNone;
    osNeedQso: Result := msgMyCall;
    osNeedNr:
      if (Patience = (FULL_PATIENCE-1)) or (Random < 0.3)
        then Result := msgNrQm
        else Result := msgAgn;


    osNeedCall:
      if (RunMode = rmHst) or (Random > 0.5) then Result := msgDeMyCallNr1
      else if Random > 0.25 then Result := msgDeMyCallNr2
      else Result := msgMyCallNr2;

    osNeedCallNr:
      if (RunMode = rmHst) or (Random > 0.5)
        then Result := msgDeMyCall1
        else Result := msgDeMyCall2;

    else //osNeedEnd:
      if Patience < (FULL_PATIENCE-1) then Result := msgNR
      else if (RunMode = rmHst) or (Random < 0.9) then Result := msgR_NR
      else Result := msgR_NR2;
    end;
end;

end.

