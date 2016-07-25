//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
unit QuickAvg;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Math, SndTypes;

type
  TDoubleArray2D = array of array of Double;

  TQuickAverage = class(TComponent)
  private
    FPasses: integer;
    FPoints: integer;
    FScale: Single;

    ReBufs, ImBufs: TDoubleArray2D;
    Idx, PrevIdx: integer;

    procedure SetPasses(const Value: integer);
    procedure SetPoints(const Value: integer);
    function DoFilter(V: Single; Bufs: TDoubleArray2D): Single;
  protected
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    procedure Reset;
    function Filter(V: Single): Single; overload;
    function Filter(ARe, AIm: Single): TComplex; overload;
    function Filter(V: TComplex): TComplex; overload;
    function FilteredModule(ARe, AIm: Single): Single;
  published
    property Passes: integer read FPasses write SetPasses;
    property Points: integer read FPoints write SetPoints;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Snd', [TQuickAverage]);
end;

{ TQuickAverage }

//------------------------------------------------------------------------------
//                                 init
//------------------------------------------------------------------------------
constructor TQuickAverage.Create(AOwner: TComponent);
begin
  inherited;
  FPoints := 128;
  FPasses := 4;
  Reset;
end;


procedure TQuickAverage.SetPasses(const Value: integer);
begin
  FPasses := Max(1, Min(8, Value));
  Reset;
end;


procedure TQuickAverage.SetPoints(const Value: integer);
begin
  FPoints := Max(1, Value);
  Reset;
end;


procedure TQuickAverage.Reset;
begin
  ReBufs := nil;
  SetLength(ReBufs, FPasses+1, FPoints);

  ImBufs := nil;
  SetLength(ImBufs, FPasses+1, FPoints);

  FScale := IntPower(FPoints, -FPasses);
  Idx := 0;
  PrevIdx := FPoints-1;
end;







//------------------------------------------------------------------------------
//                                 filter
//------------------------------------------------------------------------------
function TQuickAverage.Filter(V: Single): Single;
begin
  Result := DoFilter(V, ReBufs);
  PrevIdx := Idx;

  Idx := (Idx + 1) mod FPoints;
end;


function TQuickAverage.Filter(ARe, AIm: Single): TComplex;
begin
  Result.Re := DoFilter(ARe, ReBufs);
  Result.Im := DoFilter(AIm, ImBufs);

  PrevIdx := Idx;
  Idx := (Idx + 1) mod FPoints;
end;


function TQuickAverage.Filter(V: TComplex): TComplex;
begin
  Result.Re := DoFilter(V.Re, ReBufs);
  Result.Im := DoFilter(V.Im, ImBufs);

  PrevIdx := Idx;
  Idx := (Idx + 1) mod FPoints;
end;


function TQuickAverage.FilteredModule(ARe, AIm: Single): Single;
begin
  with Filter(ARe, AIm) do
    Result := Sqrt(Sqr(Re) + Sqr(Im));
end;

function TQuickAverage.DoFilter(V: Single; Bufs: TDoubleArray2D): Single;
var
  p: integer;
begin
  Result := V;
  for p:=1 to FPasses do
    begin
    V := Result;
    Result := Bufs[p][PrevIdx] - Bufs[p-1][Idx] + V;
    Bufs[p-1][Idx] := V;
    end;
  Bufs[FPasses,Idx] := Result;
  Result := Result * FScale;
end;




end.

