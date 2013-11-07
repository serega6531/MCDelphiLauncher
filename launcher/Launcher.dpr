program Launcher;

uses
  Vcl.Forms,
  main in 'main.pas' {Form1},
  settings in 'settings.pas' {Form2},
  update in 'update.pas' {Form3},
  MD5 in 'MD5.pas',
  FWZipConsts in 'FWZipConsts.pas',
  FWZipCrc32 in 'FWZipCrc32.pas',
  FWZipCrypt in 'FWZipCrypt.pas',
  FWZipReader in 'FWZipReader.pas',
  FWZipStream in 'FWZipStream.pas',
  FWZipWriter in 'FWZipWriter.pas',
  enter in 'enter.pas',
  RegExpr in 'RegExpr.pas',
  Perimeter in 'Perimeter.pas',
  uJSON in 'uJSON.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  Application.Title := 'Minecraft launcher';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
