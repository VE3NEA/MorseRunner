{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit morserunner;

interface

uses
  WavFile, SndOut, SndCustm, VolmSldr, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('WavFile', @WavFile.Register);
  RegisterUnit('SndOut', @SndOut.Register);
end;

initialization
  RegisterPackage('morserunner', @Register);
end.
