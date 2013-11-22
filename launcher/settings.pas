unit settings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, main, SHFolder, ServerList, ServerData;

type
  TForm2 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure initServers();
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  LauncherVer:string = '1';
  RootDir:string = '.happyminers.ru';

var
  Form2: TForm2;
  MinMem, MaxMem:string;
  appdata:string;
  MinecraftDir:string;
  servers:TServerList;

implementation

{$R *.dfm}

function GetSpecialFolderPath(folder : integer) : string;    {Полуаем системные пути}
const
SHGFP_TYPE_CURRENT = 0;
var
path: array [0..MAX_PATH] of char;
begin
if SUCCEEDED(SHGetFolderPath(0,folder,0,SHGFP_TYPE_CURRENT,@path[0])) then
Result := path
else
Raise Exception.Create('Cant find appdata');
end;

procedure TForm2.Button1Click(Sender: TObject);     {кнопка сохранить}
begin
if (StrToInt(Edit1.Text) > 256) AND (StrToInt(Edit2.Text) > StrToInt(Edit1.text)) then       {проверка правильности данных}
begin
MinMem:=Edit1.Text;
MaxMem:=Edit2.Text;
end
else
ShowMessage('Ошибка! Проверьте правильность введённых данных');
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
Form2.Close;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
Label1.Caption:='Версия лаунчера: '+ LauncherVer;   {вывод версии}
appdata:=GetSpecialFolderPath(CSIDL_APPDATA);      {получаем appdata/roaming}
MinecraftDir:=appdata + '\' + RootDir + '\';
end;

procedure TForm2.initServers();
begin
servers:=TServerList.Create;
servers.addServer(TServerData.Create('Test Server 1', '127.0.0.1'), 0);
servers.addServer(TServerData.Create('Test Server 2', '127.0.0.2'), 1);
end;

end.
