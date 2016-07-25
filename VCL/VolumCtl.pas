//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
unit VolumCtl;

{$MODE Delphi}

interface

//{$DEFINE DEBUG}

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  SndTypes, Math;

type
  TVolumeControl = class(TComponent)
  private
    FNoiseIn: Single;
    FNoiseOut: Single;

    FBeta: Single;
    FEnvelope: Single;
    FDefaultGain: Single;

    FComplexBuf: TReImArrays; //complex samples
    FRealBuf: TSingleArray;   //real samples
    FMagBuf: TSingleArray;    //log magnitude
    FLen, FBufIdx: integer;

    FAgcEnabled: boolean;
    FAttackShape: TSingleArray;
    FIsOverload: boolean;

    {$IFDEF DEBUG} DebugArr: TSingleArray; {$ENDIF}
    FAttackSamples: integer;
    FHoldSamples: integer;
    FMaxOut: Single;

    function GetNoiseInDb: Single;
    function GetNoiseOutDb: Single;
    procedure SetNoiseInDb(const Value: Single);
    procedure SetNoiseOutDb(const Value: Single);
    procedure SetAttackSamples(const Value: integer);
    procedure SetHoldSamples(const Value: integer);
    procedure SetAgcEnabled(const Value: boolean);

    procedure CalcBeta;
    procedure MakeAttackShape;
    function CalcAgcGain: Single;

    function ApplyAgc(V: Single): Single; overload;
    function ApplyAgc(Re, Im: Single): TComplex;  overload;
    function ApplyDefaultGain(V: Single): Single;  overload;
    function ApplyDefaultGain(Re, Im: Single): TComplex;  overload;
    procedure SetMaxOut(const Value: Single);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Reset;
    function Process(Data: TSingleArray): TSingleArray; overload;
    function Process(Data: TReImArrays): TReImArrays; overload;
    property IsOverload: boolean read FIsOverload;
  published
    property MaxOut: Single read FMaxOut write SetMaxOut;
    property NoiseInDb: Single read GetNoiseInDb write SetNoiseInDb;
    property NoiseOutDb: Single read GetNoiseOutDb write SetNoiseOutDb;
    property AttackSamples: integer read FAttackSamples write SetAttackSamples default 28;
    property HoldSamples: integer read FHoldSamples write SetHoldSamples default 28;
    property AgcEnabled: boolean read FAgcEnabled write SetAgcEnabled;
  end;

procedure Register;



implementation

procedure Register;
begin
  RegisterComponents('Snd', [TVolumeControl]);
end;


{ TVolumeControl }


//------------------------------------------------------------------------------
//                                 system
//------------------------------------------------------------------------------
constructor TVolumeControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FMaxOut := 20000;
  FNoiseIn := 1;
  FNoiseOut := 2000;
  CalcBeta;

  FAttackSamples := 28; //5 ms if SampleRate=5512
  FHoldSamples := 28;
  MakeAttackShape;
end;


procedure TVolumeControl.Reset;
begin
  FRealBuf := nil;
  SetLength(FRealBuf, FLen);

  ClearReIm(FComplexBuf);
  SetLengthReIm(FComplexBuf, FLen);

  FMagBuf := nil;
  SetLength(FMagBuf, FLen);

  FBufIdx := 0;
end;







//------------------------------------------------------------------------------
//                                 get/set
//------------------------------------------------------------------------------
function TVolumeControl.GetNoiseInDb: Single;
begin
  Result := 20 * Log10(FNoiseIn);
end;

function TVolumeControl.GetNoiseOutDb: Single;
begin
  Result := 20 * Log10(FNoiseOut);
end;

procedure TVolumeControl.SetNoiseInDb(const Value: Single);
begin
  FNoiseIn := Power(10, 0.05 * Value);
  CalcBeta;
end;

procedure TVolumeControl.SetNoiseOutDb(const Value: Single);
begin
  FNoiseOut := Min(0.25 * FMaxOut, Power(10, 0.05 * Value));
  CalcBeta;
end;

procedure TVolumeControl.SetMaxOut(const Value: Single);
begin
  FMaxOut := Value;
  CalcBeta;
end;

procedure TVolumeControl.SetAttackSamples(const Value: integer);
begin
  FAttackSamples := Max(1, Value);
  MakeAttackShape;
end;


procedure TVolumeControl.SetHoldSamples(const Value: integer);
begin
  FHoldSamples := Max(1, Value);
  MakeAttackShape;
end;


procedure TVolumeControl.SetAgcEnabled(const Value: boolean);
begin
  if Value and not FAgcEnabled then Reset;
  FAgcEnabled := Value;
end;







//------------------------------------------------------------------------------
//                                 params
//------------------------------------------------------------------------------
procedure TVolumeControl.MakeAttackShape;
var
  i: integer;
begin
  FLen := 2 * (FAttackSamples + FHoldSamples) + 1;

  FAttackShape := nil;
  SetLength(FAttackShape, FLen);

  //attack shape
  for i:=0 to FAttackSamples-1 do
    begin
    FAttackShape[i] := Ln(0.5 - 0.5 * Cos((i+1) * Pi / (FAttackSamples+1)));
    FAttackShape[FLen-1-i] := FAttackShape[i];
    end;

  Reset;
end;


// Amplitude characteristic of AGC:
// Out = FMaxOut * (1 - Exp(-In / FBeta))
//
// find FBeta that maps FNoiseIn to FNoiseOut

procedure TVolumeControl.CalcBeta;
begin
  FBeta := FNoiseIn / Ln(FMaxOut / (FMaxOut - FNoiseOut));

  FDefaultGain := FNoiseOut / FNoiseIn;
end;








//------------------------------------------------------------------------------
//                                   gain
//------------------------------------------------------------------------------
function TVolumeControl.CalcAgcGain: Single;
var
  Sample, Envel: Single;
  Di, Wi: integer;
begin
  //look at both sides of the sample
  //and find the max. magnitude, weighed by FAttackShape
  Envel := 1E-10;
  Di := FBufIdx;
  for Wi:=0 to FLen-1 do
    begin
    Sample := FMagBuf[Di] + FAttackShape[Wi];
    if Sample > Envel then Envel := Sample;
    Inc(Di);
    if Di = FLen then Di := 0;
    end;

  //envelope
  FEnvelope := Envel;
  Envel := Exp(Envel);

  //gain
  Result := FMaxOut * (1 - Exp(-Envel / FBeta))  /  Envel;
end;


function TVolumeControl.ApplyAgc(V: Single): Single;
begin
  //store data
  FRealBuf[FBufIdx] := V;
  FMagBuf[FBufIdx] := Ln(Abs(V + 1E-10));

  //increment index
  FBufIdx := (FBufIdx+1) mod FLen;

  //output
  Result := FRealBuf[(FBufIdx + (FLen div 2)) mod FLen] * CalcAgcGain;
end;


function TVolumeControl.ApplyAgc(Re, Im: Single): TComplex;
var
  Gain: Single;
  Mid: integer;
begin
  //store data
  FComplexBuf.Re[FBufIdx] := Re;
  FComplexBuf.Im[FBufIdx] := Im;
  FMagBuf[FBufIdx] := 0.5 * Ln(Sqr(Re) + Sqr(Im));

  //increment index
  FBufIdx := (FBufIdx+1) mod FLen;

  //output
  Mid := (FBufIdx + (FLen div 2)) mod FLen;
  Gain := CalcAgcGain;
  Result.Re := FComplexBuf.Re[Mid] * Gain;
  Result.Im := FComplexBuf.Im[Mid] * Gain;
end;



function TVolumeControl.ApplyDefaultGain(V: Single): Single;
begin
  Result := Min(FMaxOut, Max(-FMaxOut, V * FDefaultGain));
  FIsOverload := FIsOverload or (Abs(Result) = FMaxOut);
end;



function TVolumeControl.ApplyDefaultGain(Re, Im: Single): TComplex;
begin
  Result.Re := Min(FMaxOut, Max(-FMaxOut, Re * FDefaultGain));
  Result.Im := Min(FMaxOut, Max(-FMaxOut, Im * FDefaultGain));

  FIsOverload := FIsOverload or
    (Abs(Result.Re) = FMaxOut) or (Abs(Result.Im) = FMaxOut);
end;







//------------------------------------------------------------------------------
//                                   AGC
//------------------------------------------------------------------------------
function TVolumeControl.Process(Data: TSingleArray): TSingleArray;
var
  i: integer;
begin
{$IFDEF DEBUG} SetLength(DebugArr, Length(Data)); {$ENDIF}

  FIsOverload := false;
  Result := nil;
  SetLength(Result, Length(Data));

  if FAgcEnabled
    then for i:=0 to High(Result) do
      begin
      Result[i] := ApplyAgc(Data[i]);
      {$IFDEF DEBUG} DebugArr[i] := FEnvelope; {$ENDIF}
      end
    else for i:=0 to High(Result) do
      Result[i] := ApplyDefaultGain(Data[i]);


{$IFDEF DEBUG}
  with TStringList.Create do
    try
      for i:=0 to High(Result) do Add(Format('%d, %f', [i+(FLen div 2), Data[i]]));
      SaveToFile('c:\in.txt');
      Clear;
      for i:=0 to High(FAttackShape) do Add(Format('%d, %f', [i, 1000*Exp(FAttackShape[i])]));
      SaveToFile('c:\shp.txt');
      Clear;
      for i:=0 to High(Result) do Add(Format('%d, %f', [i, Exp(DebugArr[i])]));
      SaveToFile('c:\env.txt');
      Clear;
      for i:=0 to High(Result) do Add(Format('%d, %f', [i, 0.05*Result[i]]));
      SaveToFile('c:\out.txt');
    finally
      Free;
    end;
{$ENDIF}
end;


function TVolumeControl.Process(Data: TReImArrays): TReImArrays;
var
  i: integer;
begin
  FIsOverload := false;

  ClearReIm(Result);
  SetLengthReIm(Result, Length(Data.Re));

  if FAgcEnabled
    then
      for i:=0 to High(Result.Re) do
        with ApplyAgc(Data.Re[i], Data.Im[i]) do
          begin Result.Re[i] := Re; Result.Im[i] := Im; end
    else
      for i:=0 to High(Result.Re) do
        with ApplyDefaultGain(Data.Re[i], Data.Im[i]) do
          begin Result.Re[i] := Re; Result.Im[i] := Im; end;
end;


{$UNDEF DEBUG}






end.


