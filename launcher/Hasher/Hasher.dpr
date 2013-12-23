program Hasher;

{$APPTYPE CONSOLE}

uses
  Hash, SysUtils, Forms;

var
  FileName:string;

begin
  WriteLn('Enter filename:');
  ReadLn(FileName);
  FileName := ExtractFilePath(Application.ExeName) + FileName;
  WriteLn(HashFile(FileName, MD5, MD5_SIZE));
  ReadLn;
end.
