unit enter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Registry, shellapi;

type
  TForm4 = class(TForm)
    Label1: TLabel;
    Memo1: TMemo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure LaunchGame(OnlineMode:boolean);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations}
  public
    { Public declarations }
  end;

var
  Form4: TForm4;
  login:string;
  DoOnce:boolean;

implementation

{$R *.dfm}

uses main, settings;


procedure TForm4.FormActivate(Sender: TObject);
begin
Label1.Caption:='Добро пожаловать на сервер happyminers.ru, ' + Login + '! Игра серчас будет запущена.';
LaunchGame();
end;

procedure TForm4.FormClose(Sender: TObject; var Action: TCloseAction);  {если закрыть окно}
begin
Application.Terminate;
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
DoOnce:=false;
MinMem:=settings.Form2.Edit1.Text;
MaxMem:=settings.Form2.Edit2.Text;
end;

Function GetJavaPath:string;
var
a: TRegistry;
begin
a := TRegistry.Create;
a.RootKey := HKEY_LOCAL_MACHINE;
If a.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\javaws.exe', false) then
begin
    result:=a.ReadString('Path') + 'javaw.exe';
end
else
ShowMessage('Не могу запустить игру! Проблемы с обнаружением java!');
end;

procedure StartGame(JavaPath, Launch, MinecraftPath:string);
var
    si : TStartupInfo;
    pi : TProcessInformation;
begin
//CreateProcess(nil,PWideChar(WideString('"' + JavaPath + '"' + Launch)),nil,nil,True,NORMAL_PRIORITY_CLASS,nil,nil,si,pi);
MinecraftPath := MinecraftPath +'\bin\';
ShellExecuteA(0,nil,PAnsiChar(JavaPath);,lpParameters,lpDirectory,SW_SHOWNORMAL);

end;

procedure TForm4.LaunchGame(OnlineMode: boolean);
var
    Launch:string;
begin
if DoOnce = false then
begin
  begin
  Launch:=PAnsiChar(' -Xms' + MinMem + 'm' +
            ' -Xmx' + MaxMem + 'm' +
            ' -Djava.library.path=natives' +                                   {This all for minecraft down 1.6}
            ' -cp "'+ "minecraft.jar;jinput.jar;lwjgl.jar;lwjgl_util.jar;" +
            ' net.minecraft.client.Minecraft '+ main.LaunchParams;)    {Параметры + автоподключение}
  end
  end;
  DoOnce:=true;
end;
enter.Form4.Memo1.Lines.Add(GetJavaPath + Launch);
StartGame(GetJavaPath(), Launch, (appdata + '\' + RootDir));
end;

end.
