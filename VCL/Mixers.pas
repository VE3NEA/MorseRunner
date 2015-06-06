//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
unit Mixers;

interface

uses
  SysUtils, Classes, SndTypes, Math;

type
  TDownMixer = class
  private
    Phase: Double;
    TwoPiDt: Single;
    FSamplesPerSec: integer;
    procedure SetSamplesPerSec(const Value: integer);
  public
    Freq: Single;

    constructor Create;
    procedure Reset;
    function Mix(Data: TSingleArray): TComplexArray; overload;
    function Mix(DataRe, DataIm: TSingleArray): TReImArrays; overload;
    function Mix(Data: TComplexArray): TComplexArray; overload;

    property SamplesPerSec: integer read FSamplesPerSec write SetSamplesPerSec;
  end;



  TFastDownMixer = class
  private
    CurrT, HighT: integer;
    Osc: TComplexArray;
    FFrequency: Double;
  public
    constructor Create;
    procedure SetParams(ASamplingRate, AFrequency: Double; ATableSize: integer = 0);
    procedure Reset;

    function Mix(Data: TSingleArray): TComplexArray; overload;
    function Mix(DataRe, DataIm: TSingleArray): TReImArrays; overload;
    function Mix(Data: TComplexArray): TComplexArray; overload;

    property Frequency: Double read FFrequency;
  end;


  TModulator = class
  private
    FSamplesPerSec: integer;
    FCarrierFreq: Single;
    FSampleNo: integer;
    Sn, Cs: TSingleArray;
    FGain: Single;
    procedure SetSamplesPerSec(const Value: integer);
    procedure SetCarrierFreq(const Value: Single);
    procedure CalcSinCos;
    procedure SetGain(const Value: Single);
  public
    constructor Create;
    function Modulate(Data: TSingleArray): TSingleArray; overload;
    function Modulate(Data: TReImArrays): TSingleArray; overload;
    function Modulate(Data: TComplexArray): TSingleArray; overload;
    property SamplesPerSec: integer read FSamplesPerSec write SetSamplesPerSec;
    property CarrierFreq: Single read FCarrierFreq write SetCarrierFreq;
    property Gain: Single read FGain write SetGain;
  end;



implementation


//------------------------------------------------------------------------------
//                              TDownMixer
//------------------------------------------------------------------------------

{ TDownMixer }

constructor TDownMixer.Create;
begin
  SamplesPerSec := 5512;
end;


function TDownMixer.Mix(Data: TSingleArray): TComplexArray;
var
  i: integer;
begin
  Integer(Result) := 0;
  SetLength(Result, Length(Data));
  if Phase > TWO_PI then Phase := Phase - TWO_PI * Trunc(Phase/TWO_PI);

  for i:=0 to High(Data) do
    begin
    Result[i].Re := Data[i] * Cos(Phase);
    Result[i].Im := - Data[i] * Sin(Phase);

    Phase := Phase + Freq * TwoPiDt;
    end;
end;


function TDownMixer.Mix(Data: TComplexArray): TComplexArray;
var
  i: integer;
  Sn, Cs, rr, ii: Single;
begin
  Integer(Result) := 0;
  SetLength(Result, Length(Data));
  if Phase > TWO_PI then Phase := Phase - TWO_PI*Trunc(Phase/TWO_PI);

  //mix with exp(-j*2Pi*Freq[i]), minus shifts spectrum down
  for i:=0 to High(Data) do
    begin
    Sn := Sin(Phase);
    Cs := Cos(Phase);
    rr := Data[i].Re;
    ii := Data[i].Im;

    Result[i].Re := rr * Cs - ii * Sn;
    Result[i].Im := ii * Cs + rr * Sn;

    Phase := Phase + Freq * TwoPiDt;
    end;
end;


function TDownMixer.Mix(DataRe, DataIm: TSingleArray): TReImArrays;
var
  i: integer;
  Sn, Cs, rr, ii: Single;
begin
   SetLengthReIm(Result, Length(DataRe));
  if Phase > TWO_PI then Phase := Phase - TWO_PI*Trunc(Phase/TWO_PI);

  for i:=0 to High(DataRe) do
    begin
    Sn := Sin(Phase);
    Cs := Cos(Phase);
    rr := DataRe[i];
    ii := DataIm[i];

    Result.Re[i] := rr * Cs - ii * Sn;
    Result.Im[i] := ii * Cs + rr * Sn;

    Phase := Phase + Freq * TwoPiDt;
    end;
end;


procedure TDownMixer.Reset;
begin
  Phase := 0;
end;


procedure TDownMixer.SetSamplesPerSec(const Value: integer);
begin
  FSamplesPerSec := Value;
  TwoPiDt := 2* Pi / FSamplesPerSec;
end;




//------------------------------------------------------------------------------
//                              TModulator
//------------------------------------------------------------------------------

{ TModulator }

constructor TModulator.Create;
begin
  FCarrierFreq := 600;
  FSamplesPerSec := 5512;
  FGain := 1;
  CalcSinCos;
  FSampleNo := 0;
end;


procedure TModulator.SetCarrierFreq(const Value: Single);
begin
  FCarrierFreq := Value;
  CalcSinCos;
  FSampleNo := 0;
end;


procedure TModulator.SetGain(const Value: Single);
begin
  CalcSinCos;
  FGain := Value;
end;

procedure TModulator.SetSamplesPerSec(const Value: integer);
begin
  FSamplesPerSec := Value;
  CalcSinCos;
  FSampleNo := 0;
end;


procedure TModulator.CalcSinCos;
var
  Cnt: integer;
  dFi: Single;
  i: integer;
begin
  Cnt := Round(FSamplesPerSec / FCarrierFreq);
  FCarrierFreq := FSamplesPerSec / Cnt;
  dFi := TWO_PI / Cnt;

  SetLength(Sn, Cnt);
  SetLength(Cs, Cnt);

  Sn[0] := 0; Sn[1] := Sin(dFi);
  Cs[0] := 1; Cs[1] := Cos(dFi);

  //phase
  for i:=2 to Cnt-1 do
    begin
    Cs[i] := Cs[1] * Cs[i-1] - Sn[1] * Sn[i-1];
    Sn[i] := Cs[1] * Sn[i-1] + Sn[1] * Cs[i-1];
    end;

  //gain
  for i:=0 to Cnt-1 do
    begin
    Cs[i] := Cs[i] * FGain;
    Sn[i] := Cs[i] * FGain;
    end;
end;


function TModulator.Modulate(Data: TReImArrays): TSingleArray;
var
  i: integer;
begin
  Integer(Result) := 0;
  SetLength(Result, Length(Data.Re));
  for i:=0 to High(Result) do
    begin
    Result[i] := Data.Re[i] * Sn[FSampleNo] - Data.Im[i] * Cs[FSampleNo];
    FSampleNo := (FSampleNo+1) mod Length(Cs);
    end;
end;


function TModulator.Modulate(Data: TSingleArray): TSingleArray;
var
  i: integer;
begin
  Integer(Result) := 0;
  SetLength(Result, Length(Data));
  for i:=0 to High(Result) do
    begin
    Result[i] := Data[i] * Cs[FSampleNo];
    FSampleNo := (FSampleNo+1) mod Length(Cs);
    end;
end;


function TModulator.Modulate(Data: TComplexArray): TSingleArray;
var
  i: integer;
begin
  Integer(Result) := 0;
  SetLength(Result, Length(Data));
  for i:=0 to High(Result) do
    begin
    Result[i] := Data[i].Re * Sn[FSampleNo] - Data[i].Im * Cs[FSampleNo];
    FSampleNo := (FSampleNo+1) mod Length(Cs);
    end;
end;





{ TFastDownMixer }

constructor TFastDownMixer.Create;
begin
  SetParams(48000, 0, 2048);
end;

function TFastDownMixer.Mix(Data: TComplexArray): TComplexArray;
var
  i: integer;
begin
  Integer(Result) := 0;
  SetLength(Result, Length(Data));

  for i:=0 to High(Data) do
    begin
    Result[i].Re := Data[i].Re * Osc[CurrT].Re - Data[i].Im * Osc[CurrT].Im;
    Result[i].Im := Data[i].Im * Osc[CurrT].Re + Data[i].Re * Osc[CurrT].Im;

    Inc(CurrT);
    if CurrT > HighT then CurrT := 0;
    end;
end;


function TFastDownMixer.Mix(DataRe, DataIm: TSingleArray): TReImArrays;
var
  i: integer;
begin
  SetLengthReIm(Result, Length(DataRe));

  for i:=0 to High(DataRe) do
    begin
    Result.Re[i] := DataRe[i] * Osc[CurrT].Re - DataIm[i] * Osc[CurrT].Im;
    Result.Im[i] := DataIm[i] * Osc[CurrT].Re + DataRe[i] * Osc[CurrT].Im;

    Inc(CurrT);
    if CurrT > HighT then CurrT := 0;
    end;
end;


function TFastDownMixer.Mix(Data: TSingleArray): TComplexArray;
var
  i: integer;
begin
  Integer(Result) := 0;
  SetLength(Result, Length(Data));

  for i:=0 to High(Data) do
    begin
    Result[i].Re := Data[i] * Osc[CurrT].Re;
    Result[i].Im := Data[i] * Osc[CurrT].Im;

    Inc(CurrT);
    if CurrT > HighT then CurrT := 0;
    end;
end;


procedure TFastDownMixer.Reset;
begin
  CurrT := 0;
end;


procedure TFastDownMixer.SetParams(ASamplingRate, AFrequency: Double; ATableSize: integer = 0);
var
  t, Periods: integer;
  Omega: Single;
begin
  FFrequency := AFrequency;
  if ATableSize = 0 then ATableSize := Round(ASamplingRate);

  HighT := ATableSize-1;

  SetLength(Osc, ATableSize);
  Periods := Round(ATableSize * (AFrequency / ASamplingRate));
  Omega := 2*Pi * Periods / ATableSize;

  for t:=0 to High(Osc) do
    begin
    Osc[t].Re := Cos(Omega * t);
    Osc[t].Im := -Sin(Omega * t);
    end;

  Reset;

{
  if Omega <> 0
    then CurrT := Round(CurrPhi / Omega)
    else CurrT := 0;
}
end;


end.

