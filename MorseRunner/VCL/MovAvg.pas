//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
unit MovAvg;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  SndTypes, Math;

type
  TMovingAverage = class(TComponent)
  private
    FPasses: integer;
    FPoints: integer;
    FSamplesInInput: integer;

    BufRe, BufIm: array of TSingleArray;
    FNorm: Single;
    FDecimateFactor: integer;
    FGainDb: Single;

    procedure SetPasses(const Value: integer);
    procedure SetPoints(const Value: integer);
    procedure SetSamplesInInput(const Value: integer);
    procedure SetDecimateFactor(const Value: integer);
    procedure PushArray(const Src: TSingleArray; var Dst: TSingleArray);
    procedure ShiftArray(var Dst: TSingleArray; Count: integer);
    procedure Pass(const Src: TSingleArray; var Dst: TSingleArray);
    function GetResult(const Src: TSingleArray): TSingleArray;
    function DoFilter(AData: TSingleArray;
      var ABuf: array of TSingleArray): TSingleArray;
    procedure SetGainDb(const Value: Single);
    procedure CalcScale;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Reset;
    function Filter(AData: TSingleArray): TSingleArray; overload;
    function Filter(AData: TReImArrays): TReImArrays; overload;
  published
    property Points: integer read FPoints write SetPoints;
    property Passes: integer read FPasses write SetPasses;
    property SamplesInInput: integer read FSamplesInInput write SetSamplesInInput;
    property DecimateFactor: integer read FDecimateFactor write SetDecimateFactor;
    property GainDb: Single read FGainDb write SetGainDb;
  end;

procedure Register;




implementation

procedure Register;
begin
  RegisterComponents('Snd', [TMovingAverage]);
end;

{ TMovingAverage }

//------------------------------------------------------------------------------
//                                 init
//------------------------------------------------------------------------------
constructor TMovingAverage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FPasses := 3;
  FPoints := 129;
  FSamplesInInput := 512;
  FDecimateFactor := 1;
  FGainDb := 0;
  Reset;
end;


procedure TMovingAverage.Reset;
begin
  //resize buffers and init them with 0's
  BufRe := nil;
  BufIm := nil;
  //one buf for the input data and one for each pass
  SetLength(BufRe, FPasses+1, FSamplesInInput + FPoints);
  SetLength(BufIm, FPasses+1, FSamplesInInput + FPoints);

  //recalculate scaling factor
  CalcScale;
end;


procedure TMovingAverage.CalcScale;
begin
  //(gain, db to linear) * (averaging factor)
  FNorm := Power(10, 0.05*FGainDb) * IntPower(FPoints, -FPasses);
end;





//------------------------------------------------------------------------------
//                                 get/set
//------------------------------------------------------------------------------
procedure TMovingAverage.SetPasses(const Value: integer);
begin
  FPasses := Value;
  Reset;
end;

procedure TMovingAverage.SetPoints(const Value: integer);
begin
  FPoints := Value;
  Reset;
end;

procedure TMovingAverage.SetSamplesInInput(const Value: integer);
begin
  FSamplesInInput := Value;
  Reset;
end;


procedure TMovingAverage.SetDecimateFactor(const Value: integer);
begin
  FDecimateFactor := Value;
  Reset;
end;


procedure TMovingAverage.SetGainDb(const Value: Single);
begin
  FGainDb := Value;
  CalcScale;
end;





//------------------------------------------------------------------------------
//                                 filter
//------------------------------------------------------------------------------
function TMovingAverage.Filter(AData: TSingleArray): TSingleArray;
begin
  Result := DoFilter(AData, BufRe);
end;


function TMovingAverage.Filter(AData: TReImArrays): TReImArrays;
begin
  Result.Re := DoFilter(AData.Re, BufRe);
  Result.Im := DoFilter(AData.Im, BufIm);
end;


//called internally
function TMovingAverage.DoFilter(AData: TSingleArray; var ABuf: array of TSingleArray): TSingleArray;
var
  i: integer;
begin
  //put new data at the end of the 0-th buffer
  PushArray(AData, ABuf[0]);
  //multi-pass
  for i:=1 to FPasses do Pass(ABuf[i-1], ABuf[i]);
  //the sums are in the last buffer now, normalize and decimate result
  Result := GetResult(ABuf[FPasses]);
end;





//------------------------------------------------------------------------------
//                               low level
//------------------------------------------------------------------------------
procedure TMovingAverage.PushArray(const Src: TSingleArray; var Dst: TSingleArray);
var
  Len: integer;
begin
  //shift existing data to the left and append new data
  Len := Length(Dst)-Length(Src);
  Move(Dst[Length(Src)], Dst[0], Len * SizeOf(Single));
  Move(Src[0], Dst[Len], Length(Src) * SizeOf(Single));
end;


procedure TMovingAverage.ShiftArray(var Dst: TSingleArray; Count: integer);
begin
  //shift data to the left
  Move(Dst[Count], Dst[0], (Length(Dst)-Count) * SizeOf(Single));
end;


procedure TMovingAverage.Pass(const Src: TSingleArray; var Dst: TSingleArray);
var
  i: integer;
begin
  //make some free space in the buffer
  ShiftArray(Dst, FSamplesInInput);
  //calculate moving average recursively
  for i:=FPoints to High(Src) do
    Dst[i] := Dst[i-1] - Src[i-FPoints] + Src[i];
end;


function TMovingAverage.GetResult(const Src: TSingleArray): TSingleArray;
var
  i: integer;
begin
  if FDecimateFactor = 1 //save a few cycles on Decimation
    then
      begin
      SetLength(Result, FSamplesInInput);
      for i:=0 to High(Result) do
        Result[i] := Src[FPoints + i] * FNorm;
      end
    else
      begin
      SetLength(Result, FSamplesInInput div FDecimateFactor);
      for i:=0 to High(Result) do
        Result[i] := Src[FPoints + i * FDecimateFactor] * FNorm;
      end;
end;




end.

