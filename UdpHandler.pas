//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
unit UdpHandler;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Forms, SyncObjs, MMSystem, SndTypes,
  Windows, Station, blcksock;

Type
    TUdpThread = class(TThread)
    private
      rcvdstring: string;
      rcvdmsg: TStationMessage;
      procedure SetCall;
      procedure SetNumber;
      procedure SendEnter;
      procedure SendMessage;
      procedure SendEsc;
      procedure TuneRit;
    protected
      procedure Execute; override;
    public
      Constructor Create(CreateSuspended : boolean);
    end;

Implementation
  uses Main;
   { TUpdThread }
  constructor TUdpThread.Create(CreateSuspended : boolean);
  begin
    FreeOnTerminate := True;
    inherited Create(CreateSuspended);
  end;

  procedure TUdpThread.SetCall;
  // this method is executed by the mainthread and can therefore access all GUI elements.
  begin
     if rcvdstring = 'clear' then
     begin
       MainForm.Edit1.Text := '';
       exit;
     end;
     MainForm.Edit1.Text := rcvdstring;
  end;

  procedure TUdpThread.SetNumber;
  // this method is executed by the mainthread and can therefore access all GUI elements.
  begin
     MainForm.Edit3.Text := rcvdstring;
  end;

  procedure TUdpThread.TuneRIT;
  begin
     if rcvdstring = 'up' then
     begin
       MainForm.IncRit(1)
     end
     else
     begin
       MainForm.IncRit(-1)
     end
  end;

  procedure TUdpThread.SendEnter;
  begin
     MainForm.ProcessEnter;
  end;

  procedure TUdpThread.SendEsc;
  var
    Key:char;
  begin
     Key := #27;
     MainForm.FormKeyPress(Self, Key);
  end;

  procedure TUdpThread.SendMessage;
  begin
     MainForm.SendMsg(rcvdmsg);
  end;

  procedure TUdpThread.Execute;
var
  Sock:TUDPBlockSocket;
  buf:string;
  stringlist: TStringList;
  numparsed: integer;
  token:string;
  i: integer;
  radionr:string;
  socket:integer;
  basesocket:integer;
  tempstr:string;
begin
  basesocket := 13064;
  Sock:=TUDPBlockSocket.Create;
  stringlist := TStringList.Create;
  try
    socket := basesocket + StrToInt(MainForm.Name);
    sock.bind('0.0.0.0', IntToStr(socket));
    if sock.LastError<>0 then exit;
    stringlist.Delimiter := ' ';
    while True do
      begin
        if terminated then break;

	buf := sock.RecvPacket(-1);
	if sock.lasterror=0 then
	  begin
            rcvdstring := buf;
            stringlist.DelimitedText := rcvdstring;
            numparsed := stringlist.Count;
            i := 0;
            while i < (numparsed) do
            begin
                token := stringlist[i];
                if token = '[radionr]' then
                  begin
                    radionr := stringlist[i + 1];
                    if radionr <> MainForm.Name then exit;
                  end;
                if token = '[call]' then
                  begin
                    rcvdstring := stringlist[i + 1];
                    Synchronize(SetCall);
                  end;
                if token = '[rcvdnr]' then
                  begin
                    rcvdstring := stringlist[i + 1];
                    Synchronize(SetNumber);
                  end;
                if token = '[rit]' then
                  begin
                    rcvdstring := stringlist[i + 1];
                    Synchronize(TuneRit);
                  end;
                if LeftStr(token,2) = '[F' then
                  begin
                    tempstr := Copy(token,3,1);
                    //rcvdmsg := TStationMessage.msgTU;
                    rcvdmsg := TStationMessage(strtoint(tempstr));
                    Synchronize(SendMessage);
                  end;
                if token = '[enter]' then
                  begin
                    Synchronize(SendEnter);
                  end;
                if token = '[stop]' then
                  begin
                    Synchronize(SendEsc);
                  end;
                i := i + 2;
            end;
            //lasttoken := stringlist[numparsed - 1];
            //if lasttoken = '[call]' then
            //  begin
            //       rcvdstring := stringlist[0];
            //       Synchronize(SetCall);
            //  end
            //else if lasttoken = '[enter]' then
            //  begin
            //    Synchronize(SendEnter);
            //  end
            //else if lasttoken = '[number]' then
            //  begin
            //    rcvdstring := stringlist[0];
            //    Synchronize(SetNumber);
            //  end

  //        do something with data and prepare response data
            //sock.SendString(Buf);
          end;
        sleep(1);
      end;
    sock.CloseSocket;
  finally
    sock.free;
    stringlist.Free;
  end;
  end;


end.

