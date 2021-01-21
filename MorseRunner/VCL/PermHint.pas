//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------

unit PermHint;
{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, SysUtils, Classes, Graphics, Controls, Forms,
  Windows, interfacebase;

type
  TPermanentHintWindow = class(THintWindow)
  public
    Active: boolean;

    constructor Create(AOwner: TComponent); override;
    procedure ShowHint(Txt: string);
    procedure ShowHintAt(Txt: string; x, y: integer);
    procedure HideHint;
  end;

function GetCursorHeightMargin: Integer;

implementation

{ TPermanentHintWindow }


constructor TPermanentHintWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Color := clInfoBk;
end;


procedure TPermanentHintWindow.ShowHint(Txt: string);
var
  P: TPoint;
begin
//  GetCursorPos(P);
//  ShowHintAt(Txt, P.x, P.y + GetCursorHeightMargin);
end;



procedure TPermanentHintWindow.HideHint;
begin
//  ReleaseHandle;
//  Application.ShowHint := true;
//  Active := false;
end;


procedure TPermanentHintWindow.ShowHintAt(Txt: string; x, y: integer);

var
  R: TRect;
begin
//  Active := true;
//  Application.ShowHint := false;
//  R := CalcHintRect(Screen.Width, Txt, nil);
//  OffsetRect(R, x, y);
//  ActivateHint(R, Txt);
//  Update;
end;



//copied from Forms.pas

function GetCursorHeightMargin: Integer;
var
  IconInfo: TIconInfo;
  BitmapInfoSize, BitmapBitsSize, ImageSize: DWORD;
  Bitmap: PBitmapInfoHeader;
  Bits: Pointer;
  BytesPerScanline: Integer;

    function FindScanline(Source: Pointer; MaxLen: Cardinal;
      Value: Cardinal): Cardinal; assembler;
    asm
            PUSH    ECX
            MOV     ECX,EDX
            MOV     EDX,EDI
            MOV     EDI,EAX
            POP     EAX
            REPE    SCASB
            MOV     EAX,ECX
            MOV     EDI,EDX
    end;

begin
{
  Result := GetSystemMetrics(SM_CYCURSOR);
  if GetIconInfo(GetCursor, IconInfo) then
  try
    GetDIBSizes(IconInfo.hbmMask, BitmapInfoSize, BitmapBitsSize);
    Bitmap := AllocMem(DWORD(BitmapInfoSize) + BitmapBitsSize);
    try
    Bits := Pointer(DWORD(Bitmap) + BitmapInfoSize);
    if GetDIB(IconInfo.hbmMask, 0, Bitmap^, Bits^) and
      (Bitmap^.biBitCount = 1) then
    begin

      with Bitmap^ do
      begin
        BytesPerScanline := ((biWidth * biBitCount + 31) and not 31) div 8;
        ImageSize := biWidth * BytesPerScanline;
        Bits := Pointer(DWORD(Bits) + BitmapBitsSize - ImageSize);

        Result := FindScanline(Bits, ImageSize, $FF);

        if (Result = 0) and (biHeight >= 2 * biWidth) then
          Result := FindScanline(Pointer(DWORD(Bits) - ImageSize),
          ImageSize, $00);
        Result := Result div BytesPerScanline;
      end;
      Dec(Result, IconInfo.yHotSpot);
    end;
    finally
      FreeMem(Bitmap, BitmapInfoSize + BitmapBitsSize);
    end;
  finally
    if IconInfo.hbmColor <> 0 then DeleteObject(IconInfo.hbmColor);
    if IconInfo.hbmMask <> 0 then DeleteObject(IconInfo.hbmMask);
  end;
  }
end;








end.


