//Delphi launcher by serega6531

unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, md5, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, Vcl.OleCtrls, SHDocVw, IdHTTP,
  System.Classes, IdIcmpClient, IdRawBase, IdRawClient, wininet, shellapi, system.UITypes,
  Vcl.Menus, Math, AuthManager, PerimeterUnicode;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Edit2: TEdit;
    Label2: TLabel;
    Button2: TButton;
    Button3: TButton;
    CheckBox1: TCheckBox;
    Image1: TImage;
    Edit1: TEdit;
    CheckBox2: TCheckBox;
    Button4: TButton;
    ServersDropdownList: TComboBox;
    Label3: TLabel;
    Button1: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure closeLauncher;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Login:string;
  password:string;
  LaunchParams:string;
  token:string;
  auth:TAuthManager;



implementation

{$R *.dfm}

uses settings, update, enter, IdHashMessageDigest, RegExpr, uJSON, ServerList, ServerData;

function md5(SourceString: string): string;
var
md5: TIdHashMessageDigest5;
begin
// получаем md5-хэш для строки
Result := '';
md5 := TIdHashMessageDigest5.Create;
try
Result := AnsiLowerCase(md5.HashStringAsHex(SourceString));
finally
FreeAndNil(md5);
end;
end;

function CheckMd5():boolean;                      //проверка md5
var
FileMd5, md5Return:string;
http:TIdHTTP;
begin
if FileExists(appdata + '\' + RootDir + '\' + 'bin\minecraft.jar') then
begin
FileMd5:=(MD5DigestToStr(MD5File(appdata + '\' + RootDir + '\' + 'bin\minecraft.jar')));   //получение md5 и запись в fileMd5
//блаблабла
result:=true;
end
else
begin
result:=false;
end;
end;

function IsSetFiles(servername:string):boolean;
begin
result:=false;
if not (DirectoryExists(appdata + '/' + rootdir)) then          {если есть папка}
begin
CreateDir(appdata + '/' + rootdir);                  {создаём папку}
end;
if FileExists(appdata + '/' + rootdir + '/' + servername + '/minecraft.jar') then                  {если есть файл(1-14)}
begin
result:=true;                                                {true если файла нет}
end;
if not FileExists('launcher_profiles.json') then
begin
result:=false;
end;
end;

function IsConnectedToInternet: Boolean;               //WARNING! WORKING BADLY!
var
  dwConnectionTypes : DWORD;
begin
  dwConnectionTypes := INTERNET_CONNECTION_MODEM + INTERNET_CONNECTION_LAN + INTERNET_CONNECTION_PROXY;
  Result := InternetGetConnectedState (@dwConnectionTypes, 0);
end;


function CheckJava:boolean;
var
dialog:integer;
begin
  if not ShellExecute(0,'open','java',nil,nil,0) = 42 then begin
   result:=false;
   dialog:= MessageDlg('Java не найдена! Скачать?',mtError,[mbYes,mbNo], 0);
if dialog = mrYes then ShellExecute(0, 'open', 'http://www.java.com/ru/', nil, nil, SW_SHOW);
  end
  else
  result:=true;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
closeLauncher();
end;

procedure TForm1.Button2Click(Sender: TObject);         {кнопка ИГРАТЬ}
begin
if CheckJava then
begin
Login:=Edit1.Text;              {логин}
Password:=Edit2.Text;           {пароль}
if (Length(Login) in [4..14]) AND (Length(Password) in [4..14]) AND auth.isAuth(login, password) then
begin {проверка логина, длины логина,   длины пароля,                    проверка пользователя}
Form3.processUpdate((IsSetFiles({servername}'test')) OR (CheckMd5()) OR (CheckBox1.Checked = true), settings.servers.getServerByName(serversDropdownList.Items[serversDropdownList.ItemIndex]));        {загрузка файлов}
end
else
ShowMessage('Неправильный логин или пароль');        {тут всё понято}
end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
Form2.ShowModal;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
ShellExecute(Handle, nil, 'http://www.happyminers.ru', nil, nil, SW_SHOW);
end;



procedure TForm1.closeLauncher;
begin
  auth.Destroy;
  servers.Destroy;
  stopPerimeter;
  Application.Terminate;
end;

procedure initServerList;
var
i:integer;
begin
i:=0;
Form2.initServers();
servers:=settings.servers;
while i < servers.getServersCount do
begin
  Form1.ServersDropdownList.Items.Add(servers.getServer(i).getName);
  Inc(i);
end;
Form1.ServersDropdownList.ItemIndex:=0;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
closeLauncher();
end;

function ExternalChecking: LongWord;
begin
  MessageBox(0, 'Функция при проверках', 'Info', MB_ICONASTERISK);
end;

procedure ExternalEliminating;
begin
  MessageBox(0, 'Функция при противодействии', 'Info', MB_ICONASTERISK);
end;


procedure TForm1.FormCreate(Sender: TObject);
var PerimeterInputData: TPerimeterInputData;
begin
PerimeterInputData.ResistanceType := 5;
PerimeterInputData.CheckingsType := 8;PerimeterInputData.ExternalType := 0;PerimeterInputData.MainFormHandle := Form1.Handle;PerimeterInputData.Interval := 20;InitPerimeter(PerimeterInputData);
{if not IsConnectedToInternet then         //NEED CHANGE!
begin
  ShowMessage('Нет соединения с интернетом.');
  //Application.Terminate;
end;}
initServerList();
auth:=TAuthManager.Create();
end;

end.
