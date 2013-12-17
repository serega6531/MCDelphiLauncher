unit Main;

interface

uses
  Windows, Controls, Forms, SysUtils,
  Dialogs, sSkinManager, SHDocVw, sPanel, sLabel,
  acPNG, acImage, sEdit, sComboBox, Perimeter, sButton, ShellAPI, Registry,
  sCheckBox, idHTTP, StdCtrls, OleCtrls, ExtCtrls, Classes;

type
  TMainForm = class(TForm)
    SkinManager: TsSkinManager;
    NewsBrowser: TWebBrowser;
    NewsLabel: TsLabel;
    LoginLabel: TsLabel;
    PasswordLabel: TsLabel;
    ServerLabel: TsLabel;
    LogoImg: TsImage;
    PasswordEdit: TsEdit;
    LoginEdit: TsEdit;
    ServersDropDownList: TsComboBox;
    LoginBtn: TsButton;
    SiteBtn: TsButton;
    SettingsBtn: TsButton;
    ExitBtn: TsButton;
    UpdateCheckbox: TsCheckBox;
    RememberCheckbox: TsCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure SiteBtnClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure SettingsBtnClick(Sender: TObject);
    procedure OnServersListChanged(Sender: TObject);
    procedure LoginBtnClick(Sender: TObject);
  end;

var
  MainForm: TMainForm;
  ChosenServerId: integer;
  Reg: TRegIniFile;

implementation

uses ServersUtils, Auth, Settings, UpdateA;

{$R *.dfm}

procedure TMainForm.ExitBtnClick(Sender: TObject);
begin
  ExitProcess(0);
end;

function NeedUpdate: boolean;
var
  HTTP:TIdHTTP;
begin
  HTTP := TIdHTTP.Create(nil);
  if HTTP.Get('http://www.happyminers.ru/MineCraft/launcherver.php') = settings.LauncherVer then
    Result := false
  else
    Result := true;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  I: integer;
  PData: TPerimeterInputData;
begin
  PData.ResistanceType := 3;
  PData.CheckingsType := 1004;
  PData.ExternalType := 0;
  PData.MainFormHandle := MainForm.Handle;
  PData.Interval := 20;
  PData.ExtProcOnEliminating := GetProcAddress(GetModuleHandle('ntdll.dll'), 'LdrShutdownProcess');
  //InitPerimeter(PData);
  if NeedUpdate then
  begin
    MessageDlg('Требуется обновление лаунчера!', mtWarning, [mbOk], 0);
    ShellExecute(Self.Handle, nil, 'http://www.happyminers.ru/?mode=start', nil, nil, SW_SHOW);
    ExitProcess(0);
  end;
  Reg := TRegIniFile.Create('Software\happyminers.ru');
  if (Reg.ReadString('Auth','Login','def') <> 'def') AND (Reg.ReadString('Auth','Password','def') <> 'def') then
  begin
    if (MessageDlg('Обнаружены данные прошлой авторизации? Использовать их?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      LoginEdit.Text := Reg.ReadString('Auth','Login','');
      PasswordEdit.Text := Reg.ReadString('Auth','Password','');
    end else begin
      Reg.WriteString('Auth', 'Login', 'def');
      Reg.WriteString('Auth', 'Password', 'def');
    end;
  end;
  Settings.initServers;
  for I := 0 to Length(ServersUtils.Servers) - 1 do
  begin
    ServersDropDownList.Items.Add(ServersUtils.GetServer(I).GetName);
  end;
  ServersDropDownList.ItemIndex := 0;
  NewsBrowser.Navigate('http://www.happyminers.ru/MineCraft/news.php');
end;

procedure TMainForm.LoginBtnClick(Sender: TObject);
var
  AuthData: TAuthInputData;
begin
  with AuthData do
  begin
    Login := LoginEdit.Text;
    Password := PasswordEdit.Text;
  end;
  if (Length(AuthData.Login) > 3) and (Length(AuthData.Password) > 3) and (Auth.IsAuth(AuthData)) then
  begin
    if (RememberCheckbox.Checked = true) then
    begin
      Reg.WriteString('Auth', 'Login', AuthData.Login);
      Reg.WriteString('Auth', 'Password', AuthData.Password);
    end;
    UpdateA._Update(GetServer(ChosenServerId).GetName, UpdateCheckbox.Checked);
  end
  else
  begin
    MessageBox(Self.Handle, 'Неправильный логин или пароль', 'Ошибка авторизации', MB_ICONERROR);
  end;
end;

procedure TMainForm.OnServersListChanged(Sender: TObject);
begin
  ChosenServerId := ServersDropDownList.ItemIndex;
end;

procedure TMainForm.SettingsBtnClick(Sender: TObject);
begin
  Settings.SettingsForm.ShowModal;
end;

procedure TMainForm.SiteBtnClick(Sender: TObject);
begin
  ShellExecute(Self.Handle, nil, 'http://www.happyminers.ru/', nil, nil, SW_SHOW);
end;

end.
