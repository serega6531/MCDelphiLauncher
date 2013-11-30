//Delphi launcher by serega6531

unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, IdBaseComponent, IdComponent, Vcl.OleCtrls, IdHTTP, IdIcmpClient,
  System.Classes, IdRawBase, IdRawClient, shellapi, system.UITypes,
  Vcl.Menus, Math, AuthManager, PerimeterUnicode, sSkinManager, sButton,
  sComboBox, sEdit, sLabel, sCheckBox, registry;

type
  TForm1 = class(TForm)
    LogoImg: TImage;
    sSkinManager1: TsSkinManager;
    ExitBtn: TsButton;
    SiteBtn: TsButton;
    ServersDropdownList: TsComboBox;
    LoginEdit: TsEdit;
    PasswordEdit: TsEdit;
    LoginLabel: TsLabel;
    PasswordLabel: TsLabel;
    ServerLabel: TsLabel;
    UpdateCheckbox: TsCheckBox;
    RememberCheckbox: TsCheckBox;
    SettingsBtn: TsButton;
    LoginBtn: TsButton;

    procedure FormCreate(Sender: TObject);

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SiteBtnClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure SettingsBtnClick(Sender: TObject);
    procedure LoginBtnClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Login:string;
  password:string;
  token:string;
  auth:TAuthManager;
  pingtime:cardinal;
  reg:TRegIniFile;



implementation

{$R *.dfm}

uses settings, update, IdHashMessageDigest, ServerList, ServerData;

function IsConnectedToInternet: Boolean;
begin
  //later
  result := true;
end;

procedure TForm1.SiteBtnClick(Sender: TObject);
begin
  ShellExecute(Handle, nil, 'http://www.happyminers.ru/', nil, nil, SW_SHOW);
end;

procedure TForm1.SettingsBtnClick(Sender: TObject);
begin
  Form2.ShowModal;
end;

function CheckJava:boolean;
begin
  //later
  result := true;
end;

procedure closeLauncher; forward;


procedure TForm1.ExitBtnClick(Sender: TObject);
begin
  closeLauncher();
end;

procedure CloseLauncher;
begin
  Auth.Destroy;
  Servers.Destroy;
  reg.Destroy;
  StopPerimeter;
  ExitProcess(0);
end;

procedure initServerList;
var
  i:integer;
begin
  i := 0;
  Form2.initServers();
  servers := settings.servers;
  while i < servers.getServersCount do
  begin
    Form1.ServersDropdownList.Items.Add(servers.getServer(i).getName);
    Inc(i);
  end;
  Form1.ServersDropdownList.ItemIndex := 0;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CloseLauncher();
end;

function _auth(login, password:string):boolean;
begin
  result := auth.isAuth(login, password);
  if result = true AND Form1.rememberCheckbox.Checked = true then
  begin
    reg.WriteString('Auth','Login',login);
    reg.WriteString('Auth','Password',password);
  end;
end;

function needUpdate():boolean;
var
  _http:TIdHTTP;
begin
  _http := TidHTTP.Create(nil);
  if _http.Get('http://www.happyminers.ru/MineCraft/launcherver.php') <> settings.LauncherVer then result := true else result := false;
  _http.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  PerimeterInputData: TPerimeterInputData;
begin
  PerimeterInputData.ResistanceType := 3;
  PerimeterInputData.CheckingsType := 1004;
  PerimeterInputData.ExternalType := 0;
  PerimeterInputData.MainFormHandle := Form1.Handle;
  PerimeterInputData.Interval := 20;
  //PerimeterInputData.ExtProcOnEliminating := @closeLauncher;
  InitPerimeter(PerimeterInputData);
  if not IsConnectedToInternet then
  begin
    ShowMessage('Нет соединения с интернетом.');
    Application.Terminate;
  end;
  auth := TAuthManager.Create();
  initServerList();
  Reg := TRegIniFile.Create('Software\happyminers');
  if (reg.ReadString('Auth', 'Login', 'def') <> 'def') AND (reg.ReadString('Auth', 'Password', 'def') <> 'def') then
  begin
    if MessageDlg('Обнаружены данные прошлой авторизации? Использовать их?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      self.LoginEdit.Text := reg.ReadString('Auth', 'Login', 'def');
      self.PasswordEdit.Text := reg.ReadString('Auth', 'Password', 'def');
    end
    else
    begin
      reg.WriteString('Auth', 'Login', 'def'); reg.WriteString('Auth', 'Password', 'def');
    end;
  end;
  if needUpdate() then
  begin
    MessageDlg('Необходимо обновить лаунчер!', mtError, [mbOk], 0);
    ShellExecute(Handle, nil, 'http://www.happyminers.ru/?mode=start', nil, nil, SW_SHOW);
    closeLauncher();
  end;
end;

procedure TForm1.LoginBtnClick(Sender: TObject);
begin
  if CheckJava then
  begin
    Login := LoginEdit.Text;              {логин}
    Password := PasswordEdit.Text;           {пароль}
    if (Length(Login) in [4..14]) AND (Length(Password) in [4..14]) AND _auth(login, password) then
    begin {проверка логина, длины логина,   длины пароля,                    проверка пользователя}
      Form3.processUpdate(UpdateCheckbox.Checked, settings.servers.getServerByName(serversDropdownList.Items[serversDropdownList.ItemIndex]));        {загрузка файлов}
    end else
      MessageDlg('Неправильный логин или пароль',mtError, [mbOK], 0);
  end;
end;

end.
