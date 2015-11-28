//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------

//grg no Delphi 10 changes needed

unit QrmStn;

interface

uses
  SysUtils, Classes, Station, RndFunc, Ini, CallLst, QuickAvg, SndTypes,
  Math;

type
  TQrmStation = class(TStation)
  private
    Patience: integer;
  public
    constructor CreateStation;
    procedure ProcessEvent(AEvent: TStationEvent); override;
  end;

implementation

constructor TQrmStation.CreateStation;
begin
  inherited Create(nil);

  Patience := 1 + Random(5);
  MyCall := PickCall;
  HisCall := Ini.Call;
  Amplitude := 5000 + 25000 * Random;
  Pitch := Round(RndGaussLim(0, 300));
  Wpm := 30 + Random(20);

  case Random(7) of
    0: SendMsg(MsgQrl);
    1,2: SendMsg(MsgQrl2);
    3,4,5: SendMsg(msgLongCQ);
    6: SendMsg(MsqQsy);
    end;
end;


procedure TQrmStation.ProcessEvent(AEvent: TStationEvent);
begin
  case AEvent of
    evMsgSent:
      begin
      Dec(Patience);
      if Patience = 0
        then Free
        else Timeout := Round(RndGaussLim(SecondsToBlocks(4), 2));
      end;
    evTimeout:
      SendMsg(msgLongCQ);
    end;
end;

end.

