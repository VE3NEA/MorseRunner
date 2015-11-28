unit VolmSldr;

//grg 26112015 1524 Delphi 10 Changes


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Math, PermHint, System.Types; //grg System.Types added

type
  TVolumeSlider = class(TGraphicControl)
  private
    FHintWin: TPermanentHintWindow;
    FMargin: integer;
    FValue: Single;
    FOnChange: TNotifyEvent;

    FDownValue: Single;
    FDownX: integer;
    FOverloaded: boolean;
    FShowHint: boolean;
    FDbMax: Single;
    FDbScale: Single;

    procedure SetMargin(const Value: integer);
    procedure SetValue(const Value: Single);
    function ThumbRect: TRect;
    procedure SetOverloaded(const Value: boolean);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure SetShowHint(const Value: boolean);
    procedure SetDbMax(const Value: Single);
    procedure SetDbScale(const Value: Single);
    function GetDb: Single;
    procedure UpdateHint;
    procedure SetDb(const AdB: Single);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property ShowHint: boolean read FShowHint write SetShowHint;
    property Margin: integer read FMargin write SetMargin;
    property Value: Single read FValue write SetValue;
    property Enabled;
    property Overloaded: boolean read FOverloaded write SetOverloaded;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnDblClick;

    property DbMax: Single read FDbMax write SetDbMax;
    property DbScale: Single read FDbScale write SetDbScale;
    property Db: Single read GetDb write SetDb;
  end;

procedure Register;



implementation

const
  VMargin = 6;


procedure Register;
begin
  RegisterComponents('Snd', [TVolumeSlider]);
end;

{ TVolumeSlider }

constructor TVolumeSlider.Create(AOwner: TComponent);
begin
  inherited;
  FMargin := 5;
  FValue := 0.75;
  Width := 60;
  Height := 20;
  ControlStyle := [csCaptureMouse, csClickEvents, csDoubleClicks, csOpaque];
  FHintWin := TPermanentHintWindow.Create(Self);
  FShowHint := true;

  FDbMax := 0;
  FDbScale := 60;
  UpdateHint;
end;


function TVolumeSlider.ThumbRect: TRect;
var
  x: integer;
begin
  x := FMargin + Round((Width - 2 * FMargin) * FValue);
  Result := Rect(x-4, VMargin div 2, x+5, Height - (VMargin div 2) + 1);
end;


procedure TVolumeSlider.Paint;
var
  R: TRect;
  Bmp: TBitMap;
begin
  Bmp := TBitMap.Create;
  try
    with Bmp.Canvas do
      begin
      Bmp.Width := Width;
      Bmp.Height := Height;
      //background
      Brush.Color := clBtnFace;
      FillRect(Rect(0, 0, Width, Height));
      //triangle
      Pen.Color := clWhite;
      MoveTo(FMargin, Height-VMargin);
      LineTo(Width-FMargin, Height-VMargin);
      LineTo(Width-FMargin, VMargin);
      Pen.Color := clBtnShadow;
      LineTo(FMargin-1, Height-VMargin-1);
      //overload
      R := Bounds(FMargin+1, VMargin-2, 7, 5);
      DrawEdge(Handle, R, BDR_SUNKENOUTER, BF_MIDDLE or BF_RECT);

      if FOverloaded then
        begin
        Brush.Color := clRed;
        InflateRect(R, -1, -1);
        FillRect(R);
        end;
      //thumb
      R := ThumbRect;
      if Enabled
        then DrawFrameControl(Handle, R, DFC_BUTTON, DFCS_BUTTONPUSH)
        else DrawEdge(Handle, R, BDR_SUNKENOUTER, BF_MIDDLE or BF_RECT);

      Canvas.Draw(0, 0, Bmp);
      end;
    finally
      Bmp.Free;
    end;
end;


procedure TVolumeSlider.SetMargin(const Value: integer);
begin
  FMargin := Max(5, Min((Width div 2) - 5, Value));
  Invalidate;
end;


procedure TVolumeSlider.SetValue(const Value: Single);
begin
  FValue := Max(0, Min(1, Value));
  UpdateHint;
  Invalidate;
end;


procedure TVolumeSlider.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if (Button = mbLeft) and PtInRect(ThumbRect, POINT(X,Y))
    then begin FDownValue := FValue; FDownX := X; end
    else ControlState := ControlState - [csClicked];
end;


procedure TVolumeSlider.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  //D5 bug: WM_LBUTTONUP is never received if the mouse button is released
  //over TToolButton with tbsDropDown, thus we have to remove csClicked manually
  if not (ssLeft in Shift) then
    begin
    ControlState := ControlState - [csClicked];
    MouseCapture := false;
    end;

  if (PtInRect(ClientRect, POINT(X,Y)) or (csClicked in ControlState)) and FShowHint
    then FHintWin.ShowHint(Hint)
    else FHintWin.HideHint;

  if not (csClicked in ControlState) then Exit;

  Value := FDownValue + (X - FDownX) / (Width - 2 * FMargin);
  Repaint;
  if Assigned(FOnChange) then FOnChange(Self);

end;



procedure TVolumeSlider.SetOverloaded(const Value: boolean);
begin
  if FOverloaded = Value then Exit;
  FOverloaded := Value;
  Repaint;
end;

procedure TVolumeSlider.CMMouseLeave(var Message: TMessage);
begin
  if not (csClicked in ControlState)
    then FHintWin.HideHint;
end;

procedure TVolumeSlider.SetShowHint(const Value: boolean);
begin
  FShowHint := Value;
end;

procedure TVolumeSlider.SetDbMax(const Value: Single);
begin
  FDbMax := Value;
  UpdateHint;
end;

procedure TVolumeSlider.SetDbScale(const Value: Single);
begin
  FDbScale := Value;
  UpdateHint;
end;

function TVolumeSlider.GetDb: Single;
begin
  Result := DbMax + (FValue - 1) * DbScale;
end;

procedure TVolumeSlider.UpdateHint;
begin
  Hint := Format('%.1f dB', [dB]);
end;

procedure TVolumeSlider.SetDb(const AdB: Single);
begin
  Value := (AdB - DbMax) / DbScale + 1;
end;

procedure TVolumeSlider.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  FHintWin.HideHint;
  inherited;
end;



end.

