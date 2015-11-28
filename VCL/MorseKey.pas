//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------

//grg 26112015 1516 Delphi 10 Changes

unit MorseKey;

interface

uses
  SysUtils, Classes, SndTypes, MorseTbl, Math, Ini;


type
  TKeyer = class
  private
    Morse: array[Char] of string;
    RampLen: integer;
    RampOn, RampOff: TSingleArray;
    FRiseTime: Single;

    function GetEnvelope: TSingleArray;
    procedure LoadMorseTable;
    procedure MakeRamp;
    function BlackmanHarrisKernel(x: Single): Single;
    function BlackmanHarrisStepResponse(Len: integer): TSingleArray;
    procedure SetRiseTime(const Value: Single);
  public
    Wpm: integer;
    BufSize: integer;
    Rate: integer;
    MorseMsg: string;
    TrueEnvelopeLen: integer;

    constructor Create;
    function Encode(Txt: string): string;

    property RiseTime: Single read FRiseTime write SetRiseTime;
    property Envelope: TSingleArray read GetEnvelope;
  end;


procedure MakeKeyer;
procedure DestroyKeyer;

var
  Keyer: TKeyer;


implementation

procedure MakeKeyer;
begin
  Keyer := TKeyer.Create;
end;


procedure DestroyKeyer;
begin
  Keyer.Free;
end;



{ TKeyer }

constructor TKeyer.Create;
begin
  LoadMorseTable;
  Rate := 11025;
  RiseTime := 0.005;
end;


procedure TKeyer.SetRiseTime(const Value: Single);
begin
  FRiseTime := Value;
  MakeRamp;
end;


procedure TKeyer.LoadMorseTable;
var
  i: integer;
  S: string;
  Ch: Char;
begin
  for i:=0 to High(MorseTable) do
    begin
    S := MorseTable[i];
    if S[2] <> '[' then Continue;
    Ch := S[1];
    Morse[Ch] := Copy(S, 3, Pos(']', S)-3) + ' ';
    end;
end;


function TKeyer.BlackmanHarrisKernel(x: Single): Single;
const
  a0 = 0.35875; a1 = 0.48829;	a2 = 0.14128;	a3 = 0.01168;
begin
  Result := a0 - a1*Cos(2*Pi*x) + a2*Cos(4*Pi*x) - a3*Cos(6*Pi*x);
end;


function TKeyer.BlackmanHarrisStepResponse(Len: integer): TSingleArray;
var
  i: integer;
  Scale: Single;
begin
  SetLength(Result, Len);
  //generate kernel
  for i:=0 to High(Result) do Result[i] := BlackmanHarrisKernel(i/Len);
  //integrate
  for i:=1 to High(Result) do Result[i] := Result[i-1] + Result[i];
  //normalize
  Scale := 1 / Result[High(Result)];
  for i:=0 to High(Result) do Result[i] := Result[i] * Scale;
end;


procedure TKeyer.MakeRamp;
var
  i: integer;
begin
  RampLen := Round(2.7 * FRiseTime * Rate);
  RampOn := BlackmanHarrisStepResponse(RampLen);

  SetLength(RampOff, RampLen);
  for i:=0 to RampLen-1 do RampOff[High(RampOff)-i] := RampOn[i];
end;


function TKeyer.Encode(Txt: string): string;
var
  i: integer;
begin
  Result := '';
  for i:=1 to Length(Txt) do
    if CharInSet(Txt[i], [' ', '_']) //grg1
      then Result := Result + ' '
      else Result := Result + Morse[Txt[i]];
  if Result <> '' then Result[Length(Result)] := '~';
end;


function TKeyer.GetEnvelope: TSingleArray;
var
  UnitCnt, Len, i, p: integer;
  SamplesInUnit: integer;

  procedure AddRampOn;
  begin
    Move(RampOn[0], Result[p], RampLen * SizeOf(Single));
    Inc(p, Length(RampOn));
  end;

  procedure AddRampOff;
  begin
    Move(RampOff[0], Result[p], RampLen * SizeOf(Single));
    Inc(p, Length(RampOff));
  end;

  procedure AddOn(Dur: integer);
  var
    i: integer;
  begin
    for i:=0 to Dur * SamplesInUnit - RampLen - 1 do Result[p+i] := 1;
    Inc(p, Dur * SamplesInUnit - RampLen);
  end;

  procedure AddOff(Dur: integer);
  begin
    Inc(p, Dur * SamplesInUnit - RampLen);
  end;

begin
  //count units
  UnitCnt := 0;
  for i:=1 to Length(MorseMsg) do
    case MorseMsg[i] of
      '.': Inc(UnitCnt, 2);
      '-': Inc(UnitCnt, 4);
      ' ': Inc(UnitCnt, 2);
      '~': Inc(UnitCnt, 1);
      end;

  //calc buffer size
  SamplesInUnit := Round(0.1 * Rate * 12 / Wpm);
  TrueEnvelopeLen := UnitCnt * SamplesInUnit + RampLen;
  Len := BufSize * Ceil(TrueEnvelopeLen / BufSize);
  Result := nil;
  SetLength(Result, Len);

  //fill buffer
  p := 0;
  for i:=1 to Length(MorseMsg) do
    case MorseMsg[i] of
      '.': begin AddRampOn; AddOn(1); AddRampOff; AddOff(1); end;
      '-': begin AddRampOn; AddOn(3); AddRampOff; AddOff(1); end;
      ' ': AddOff(2);
      '~': AddOff(1);
      end;
end;


end.

