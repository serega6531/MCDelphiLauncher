program Launcher;

uses
  Forms,
  main in 'main.pas' {MainForm},
  Perimeter in 'Perimeter.pas',
  ServersUtils in 'ServersUtils.pas',
  settings in 'settings.pas' {SettingsForm},
  auth in 'auth.pas',
  updateA in 'updateA.pas' {UpdateForm},
  Launch in 'Launch.pas',
  InternetHTTP in 'InternetHTTP.pas',
  unMD5 in 'unMD5.pas',
  crypt in 'crypt.pas',
  crtdll_wrapper in 'hid\crtdll_wrapper.pas',
  hwid_impl in 'hid\hwid_impl.pas',
  isctype in 'hid\isctype.pas',
  winioctl in 'hid\winioctl.pas';

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
