//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------

//grg no Delphi 10 changes needed

unit ScoreDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TScoreDialog = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    Label2: TLabel;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  end;

var
  ScoreDialog: TScoreDialog;

implementation

uses Main;

{$R *.DFM}

procedure TScoreDialog.Button1Click(Sender: TObject);
begin
  MainForm.ViewScoreBoardMNU.Click;
end;

procedure TScoreDialog.Button2Click(Sender: TObject);
begin
  Close;
end;

end.

