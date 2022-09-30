                                                    //------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
unit Ini;

{$MODE Delphi}

interface

uses
  SysUtils, IniFiles, SndTypes, Math;

const
  SEC_STN = 'Station';
  SEC_BND = 'Band';
  SEC_TST = 'Contest';
  SEC_SYS = 'System';

  DEFAULTBUFCOUNT = 8;
  DEFAULTBUFSIZE = 512;
  DEFAULTRATE = 11025;


type
  TRunMode = (rmStop, rmPileup, rmSingle, rmWpx, rmHst);

var
  Call: string = 'N2IC';
  NR: string = '8';
  HamName: string;
  Wpm: integer = 30;
  BandWidth: integer = 500;
  Pitch: integer = 600;
  Qsk: boolean = true;
  Rit: integer = 0;
  BufSize: integer = DEFAULTBUFSIZE;

  Activity: integer = 2;
  Qrn: boolean = true;
  Qrm: boolean = true;
  Qsb: boolean = true;
  Flutter: boolean = true;
  Lids: boolean = true;
  Sidetone: integer = 400;

  Duration: integer = 30;
  RunMode: TRunMode = rmStop;
  HiScore: integer;
  CompDuration: integer = 60;

  SaveWav: boolean = false;
  CallsFromKeyer: boolean = false;
  RadioAudio: integer = 0;
  Messagecq: string = 'CQ';
  Messagehiscall: string;
  Messagenr: string;
  Messagetu: string = 'TU';
  Standalone: boolean = true;
  ContestName: string = 'cqww';


procedure FromIni;
procedure ToIni;



implementation

uses
  Main, Contest, logerrorx;

procedure FromIni;
var
  V: integer;
begin
  if Standalone = true then
  begin
  //LogError('standalone');
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
    try
      MainForm.SetMyCall(ReadString(SEC_STN, 'Call', Call));
      MainForm.SetMyZone(ReadString(SEC_STN, 'NR', NR));
      MainForm.SetPitch(ReadInteger(SEC_STN, 'Pitch', 3));
      MainForm.SetBw(ReadInteger(SEC_STN, 'BandWidth', 9));

      //HamName := ReadString(SEC_STN, 'Radio', '');
      //if HamName <> '' then
      //  begin
      //  MainForm.Caption := MainForm.Caption + ':  ' + HamName;
      //  MainForm.Name := HamName;
      //  end;
      //
      Wpm := ReadInteger(SEC_STN, 'Wpm', Wpm);
      Wpm := Max(10, Min(120, Wpm));
      MainForm.SpinEdit1.Value := Wpm;
      Tst.Me.Wpm := Wpm;

      MainForm.SetQsk(ReadBool(SEC_STN, 'Qsk', Qsk));
      CallsFromKeyer := ReadBool(SEC_STN, 'CallsFromKeyer', CallsFromKeyer);

      MainForm.NoRepeats := ReadBool(SEC_STN, 'NoRepeats', false);

      Activity := ReadInteger(SEC_BND, 'Activity', Activity);
      MainForm.SpinEdit3.Value := Activity;

      MainForm.CheckBox4.Checked := ReadBool(SEC_BND, 'Qrn', Qrn);
      MainForm.CheckBox3.Checked := ReadBool(SEC_BND, 'Qrm', Qrm);
      MainForm.CheckBox2.Checked := ReadBool(SEC_BND, 'Qsb', Qsb);
      MainForm.CheckBox5.Checked := ReadBool(SEC_BND, 'Flutter', Flutter);
      MainForm.CheckBox6.Checked := ReadBool(SEC_BND, 'Lids', Lids);
      MainForm.ReadCheckBoxes;

      Duration := ReadInteger(SEC_TST, 'Duration', Duration);
      MainForm.SpinEdit2.Value := Duration;
      HiScore := ReadInteger(SEC_TST, 'HiScore', HiScore);
      CompDuration := Max(1, Min(60, ReadInteger(SEC_TST, 'CompetitionDuration', CompDuration)));

      //buffer size
      V := ReadInteger(SEC_SYS, 'BufSize', 0);
      if V = 0 then
        begin V := 3; WriteInteger(SEC_SYS, 'BufSize', V); end;
      V := Max(1, Min(5, V));
      BufSize := 64 shl V;
      Tst.Filt.SamplesInInput := BufSize;
      Tst.Filt2.SamplesInInput := BufSize;

      V := ReadInteger(SEC_STN, 'SelfMonVolume', 0);
      MainForm.VolumeSlider1.Value := V / 80 + 0.75;

      V := ReadInteger(SEC_SYS, 'SoundDevice', -1);
      MainForm.AlSoundOut1.DeviceID := V;

      SaveWav := ReadBool(SEC_STN, 'SaveWav', SaveWav);
    finally
      Free;
    end;
  end
  else
  begin
      //MainForm.SetMyCall(ReadString(SEC_STN, 'Call', Call));
      //MainForm.SetMyZone(ReadString(SEC_STN, 'NR', NR));
      //MainForm.SetPitch(ReadInteger(SEC_STN, 'Pitch', 3));
      MainForm.SetPitch(3);
      //MainForm.SetBw(ReadInteger(SEC_STN, 'BandWidth', 9));
      //LogError('calling SetBW');
      MainForm.SetBW(3);

      //HamName := ReadString(SEC_STN, 'Radio', '');
      //if HamName <> '' then
      //  begin
      //  MainForm.Caption := MainForm.Caption + ':  ' + HamName;
      //  MainForm.Name := HamName;
      //  end;
      //
      //Wpm := ReadInteger(SEC_STN, 'Wpm', Wpm);
      //Wpm := Max(10, Min(120, Wpm));
      //MainForm.SpinEdit1.Value := Wpm;
      //Tst.Me.Wpm := Wpm;

      // MainForm.SetQsk(ReadBool(SEC_STN, 'Qsk', Qsk));
      MainForm.SetQSK(false);
      //CallsFromKeyer := ReadBool(SEC_STN, 'CallsFromKeyer', CallsFromKeyer);

      //MainForm.NoRepeats := ReadBool(SEC_STN, 'NoRepeats', false);
      MainForm.NoRepeats := true;

      //Activity := ReadInteger(SEC_BND, 'Activity', Activity);
      //MainForm.SpinEdit3.Value := Activity;

      //MainForm.CheckBox4.Checked := ReadBool(SEC_BND, 'Qrn', Qrn);
      //MainForm.CheckBox3.Checked := ReadBool(SEC_BND, 'Qrm', Qrm);
      //MainForm.CheckBox2.Checked := ReadBool(SEC_BND, 'Qsb', Qsb);
      //MainForm.CheckBox5.Checked := ReadBool(SEC_BND, 'Flutter', Flutter);
      //MainForm.CheckBox6.Checked := ReadBool(SEC_BND, 'Lids', Lids);
      //MainForm.ReadCheckBoxes;

      // Duration := ReadInteger(SEC_TST, 'Duration', Duration);
      MainForm.SpinEdit2.Value := Duration;
      // HiScore := ReadInteger(SEC_TST, 'HiScore', HiScore);
      // CompDuration := Max(1, Min(60, ReadInteger(SEC_TST, 'CompetitionDuration', CompDuration)));

      //buffer size
      //V := ReadInteger(SEC_SYS, 'BufSize', 0);
      //if V = 0 then
      //  begin V := 3; WriteInteger(SEC_SYS, 'BufSize', V); end;
      //V := Max(1, Min(5, V));
      V := 3;
      BufSize := 64 shl V;
      Tst.Filt.SamplesInInput := BufSize;
      Tst.Filt2.SamplesInInput := BufSize;

     // V := ReadInteger(SEC_STN, 'SelfMonVolume', 0);
     // MainForm.VolumeSlider1.Value := V / 80 + 0.75;
      MainForm.VolumeSlider1.Value := 0.125;

      // V := ReadInteger(SEC_SYS, 'SoundDevice', -1);
      MainForm.AlSoundOut1.DeviceID := -1;

      // SaveWav := ReadBool(SEC_STN, 'SaveWav', SaveWav);
  end;
end;


procedure ToIni;
var
  V: integer;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
    try
      WriteString(SEC_STN, 'Call', Call);
      WriteString(SEC_STN, 'NR', NR);
      WriteInteger(SEC_STN, 'Pitch', MainForm.ComboBox1.ItemIndex);
      WriteInteger(SEC_STN, 'BandWidth', MainForm.ComboBox2.ItemIndex);
      WriteInteger(SEC_STN, 'Wpm', Wpm);
      WriteBool(SEC_STN, 'Qsk', Qsk);

      WriteInteger(SEC_BND, 'Activity', Activity);
      WriteBool(SEC_BND, 'Qrn', Qrn);
      WriteBool(SEC_BND, 'Qrm', Qrm);
      WriteBool(SEC_BND, 'Qsb', Qsb);
      WriteBool(SEC_BND, 'Flutter', Flutter);
      WriteBool(SEC_BND, 'Lids', Lids);

      WriteInteger(SEC_TST, 'Duration', Duration);
      WriteInteger(SEC_TST, 'HiScore', HiScore);
      WriteInteger(SEC_TST, 'CompetitionDuration', CompDuration);

      V := Round(80 * (MainForm.VolumeSlider1.Value - 0.75));
      WriteInteger(SEC_STN, 'SelfMonVolume', V);

      WriteBool(SEC_STN, 'SaveWav', SaveWav);
    finally
      Free;
    end;
end;




end.


