{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit morserunnerpkg;

interface

uses
  SndOut, WavFile, SndTypes, SndCustm, VolmSldr, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('SndOut', @SndOut.Register);
  RegisterUnit('WavFile', @WavFile.Register);
  RegisterUnit('VolmSldr', @VolmSldr.Register);
end;

initialization
  RegisterPackage('morserunnerpkg', @Register);
end.
