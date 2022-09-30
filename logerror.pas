unit LogErrorx;

{$mode delphi}

interface

uses
  SysUtils, Ini;
procedure LogError(msg:string);

implementation
procedure LogError(msg:string);
{SI+} //check for IO errors
var
  Fn: String;
  F: TextFile;
  userdir: string;
begin
  userdir := GetUserDir;
  // if Ini.Wpm < 40 then Fn := userdir + 'Documents\N1MM Logger+\debug1.txt'
  // else Fn := userdir + 'Documents\N1MM Logger+\debug2.txt';

  // Fn := 'debug.txt';
  Fn := userdir + 'Documents\N1MM Logger+\mrdebug.txt';
  AssignFile(F, Fn);
  if FileExists(Fn) then
     Append(F)
  else
    Rewrite(F);
  //do stuff with the file
  writeln(F, msg);
  CloseFile(F);
end;
end.


