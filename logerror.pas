unit LogErrorx;

{$mode delphi}

interface

uses
  SysUtils;
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
  Fn := userdir + 'Documents\N1MM Logger+\debug.txt';
  // Fn := 'debug.txt';
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


