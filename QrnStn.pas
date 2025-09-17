//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------

//grg no Delphi 10 changes needed

unit QrnStn;

interface

uses
  SysUtils, Classes, Station, RndFunc, Ini, CallLst, QuickAvg, SndTypes,
  Math;

type
  TQrnStation = class(TStation)
  public
    constructor CreateStation;
    procedure ProcessEvent(AEvent: TStationEvent); override;
  end;

implementation

constructor TQrnStation.CreateStation;
var
  i: integer;
  Dur: integer;
begin
  inherited Create(nil);

  Dur := SecondsToBlocks(Random) * Ini.BufSize;
  SetLength(Envelope, Dur);
  Amplitude := 1E5*Power(10, 2*Random);
  for i:=0 to High(Envelope) do
    if Random < 0.01 then Envelope[i] := (Random-0.5) * Amplitude;

  State := stSending;
end;


procedure TQrnStation.ProcessEvent(AEvent: TStationEvent);
begin
  if AEvent = evMsgSent then Free;
end;

end.

