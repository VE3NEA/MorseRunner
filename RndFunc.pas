//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------

//grg no Delphi 10 changes needed

unit RndFunc;

interface

uses
  SysUtils, Math, SndTypes, Ini;

function RndNormal: Single;
function RndGaussLim(AMean, ALim: Single): Single;
function RndRayleigh(AMean: Single): Single;
function BlocksToSeconds(Blocks: Single): Single;
function SecondsToBlocks(Sec: Single): integer;
function RndUniform: Single;
function RndUShaped: Single;
function RndPoisson(AMean: Single): integer;


implementation

function RndNormal: Single;
begin
  repeat
    try
      Result := Sqrt(-2 * Ln(Random)) * Cos(TWO_PI * Random);
      Exit;
    except
    end;
  until
    False;
end;


function RndGaussLim(AMean, ALim: Single): Single;
begin
  Result := AMean + RndNormal * 0.5 * ALim;
  Result := Max(AMean-ALim, Min(AMean+ALim, Result));
end;


function RndRayleigh(AMean: Single): Single;
begin
  Result := AMean * Sqrt(-Ln(Random) - Ln(Random));
end;


function SecondsToBlocks(Sec: Single): integer;
begin
  Result := Round(DEFAULTRATE / Ini.BufSize * Sec);
end;

function BlocksToSeconds(Blocks: Single): Single;
begin
  Result := Blocks * Ini.BufSize / DEFAULTRATE;
end;

function RndUniform: Single;
begin
  Result := 2*Random - 1;
end;


function RndUShaped: Single;
begin
  Result := Sin(Pi*(Random-0.5));
end;


//http://www.library.cornell.edu/nr/bookcpdf/c7-3.pdf
function RndPoisson(AMean: Single): integer;
var
  g, t: Single;
begin
  g := Exp(-AMean);
  t := 1;
  for Result:=0 to 30 do
    begin
    t := t * Random;
    if t <= g then Break;
    end;
end;

{
//http://www.esbconsult.com.au/
function RndPoisson(AMean: Single): integer;
var
  p,q,p0,u: Extended;
  l,m,j,k: integer;
     pp: array [1..35] of Extended;
begin
  // C A S E  B.    mu < 10
  // START NEW TABLE AND CALCULATE P0 IF NECESSARY

  m := Max(1, Trunc (AMean));
  l := 0;
  p := Exp(-AMean);
  q := p;
  p0 := p;

  //  STEP U. UNIFORM SAMPLE FOR INVERSION METHOD

  repeat
    u := Random;
    Result := 0;
    if (u <= p0) then Exit;

    // STEP T. TABLE COMPARISON UNTIL THE END PP(L) OF THE
    // PP-TABLE OF CUMULATIVE POISSON PROBABILITIES
    // (0.458=PP(9) FOR MU=10)
    if l <> 0 then
      begin
      j := 1;
      if (u > 0.458) then j := Min(l, m);
      for k := j to l do
       if (u <= pp [k]) then
         begin Result := K; Exit; end;

      if l = 35 then Continue;
      end;

    // STEP C. CREATION OF NEW POISSON PROBABILITIES P
    // AND THEIR CUMULATIVES Q=PP(K)
    l := l + 1; // 150
    for k := l to 35 do
      begin
      p := p * AMean / k;
      q := q + p;
      pp [k] := q;
      if (u <= q) then begin Result := K; Exit; end;
      end;
    l := 35;
  until False;
end;
}


end.

