//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------

//grg no Delphi10 changes

unit BaseComp;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms;

type
  {this component adds a window handle to the standard TControl
  in order to receive windows messages and makes sure that
  DoSetEnabled is called only at run time}

  TBaseComponent = class (TComponent)
  private
    FHandle: THandle;
    FEnabled : boolean;
    procedure SetEnabled(AEnabled: boolean);
    procedure WndProc(var Message: TMessage);
    procedure WMQueryEndSession(var Message: TMessage); message WM_QUERYENDSESSION;
  protected
    procedure DoSetEnabled(AEnabled: boolean); virtual;
    procedure Loaded; override;
    property Handle: THandle read FHandle;
  public
    property Enabled: boolean read FEnabled write SetEnabled default false;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;


implementation

 { TBaseComponent }

constructor TBaseComponent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHandle := 0;
  FEnabled := false;
end;


destructor TBaseComponent.Destroy;
begin
  Enabled := false;
  inherited Destroy;
end;


procedure TBaseComponent.Loaded;
begin
  inherited Loaded;

  if FEnabled then
    begin
    FEnabled := false;
    SetEnabled(true);
    end;
end;


procedure TBaseComponent.WndProc(var Message: TMessage);
begin
  try
    Dispatch(Message);
  except
    Application.HandleException(Self);
  end;
end;

procedure TBaseComponent.WMQueryEndSession(var Message: TMessage);
begin
  try Enabled := false; except; end;
  inherited;
  Message.Result := integer(true);
end;

procedure TBaseComponent.SetEnabled (AEnabled: boolean);
begin
  if (not (csDesigning in ComponentState)) and
     (not (csLoading in ComponentState)) and
     (AEnabled <> FEnabled)
    then DoSetEnabled(AEnabled);
  FEnabled := AEnabled;
end;


procedure TBaseComponent.DoSetEnabled (AEnabled: boolean);
begin
  if AEnabled
    then
      FHandle := AllocateHwnd(WndProc)
    else
      begin
      if FHandle <> 0 then DeallocateHwnd(FHandle);
      FHandle := 0;
      end;
end;


end.
