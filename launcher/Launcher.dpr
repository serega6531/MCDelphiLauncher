program Launcher;

uses
  Forms,
  main in 'main.pas' {MainForm},
  Perimeter in 'Perimeter.pas',
  ServersUtils in 'ServersUtils.pas',
  settings in 'settings.pas' {SettingsForm},
  Auth in 'Auth.pas',
  updateA in 'updateA.pas' {UpdateForm},
  Launch in 'Launch.pas',
  InternetHTTP in 'InternetHTTP.pas',
  unMD5 in 'unMD5.pas',
  crypt in 'crypt.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Minecraft Launcher';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSettingsForm, SettingsForm);
  Application.CreateForm(TUpdateForm, UpdateForm);
  Application.Run;
end.
