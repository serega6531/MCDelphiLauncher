unit enter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Registry, shellapi;

type
  TForm4 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Memo1: TMemo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure LaunchGame(OnlineMode:boolean);
    procedure Button1Click(Sender: TObject);
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


procedure TForm4.Button1Click(Sender: TObject);
begin
LaunchGame(true);
end;

procedure TForm4.FormActivate(Sender: TObject);
begin
Label1.Caption:='ƒобро пожаловать на сервер happyminers.ru, ' + Login + '!';
if main.OnlineMode = false then
LaunchGame(false);
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


procedure StartGame(Launch:string);
begin
  //ShellExecute(0, 'open', 'cmd.exe', PWideChar('/c javaw ' + Launch), nil, SW_SHOW);
  //ShellExecute(0, 'open', 'javaw.exe', PWideChar(Launch), nil, 0);
  //WinExec(PAnsiChar(AnsiString('javaw' + Launch)), SW_SHOW);
  //WinExec(PAnsiChar('javaw' + Launch), SW_SHOW);
  //CreateProcess();
end;

procedure TForm4.LaunchGame(OnlineMode: boolean);
var
    Launch, GameFiles:string;
begin
if DoOnce = false then
begin
 GameFiles := appdata + '\' + RootDir +'\bin\minecraft.jar;';
  GameFiles := GameFiles + appdata + '\' + RootDir +'\bin\lwjgl.jar;';
  GameFiles := GameFiles + appdata + '\' + RootDir +'\bin\lwjgl_util.jar;';
  GameFiles := GameFiles + appdata + '\' + RootDir +'\bin\jinput.jar;';
if (OnlineMode = True) then          {если авторизирован}
  begin
  Launch := ' -Xms' + MinMem + 'm' +
            ' -Xmx' + MaxMem + 'm' +
            ' -Djava.library.path="'+ appdata + '\' + RootDir + '\bin\natives"' +
            ' -cp "'+ GameFiles +'"' +
            ' net.minecraft.client.Minecraft '+ main.LaunchParams;    {ѕараметры + автоподключение}
  end
  else if (OnlineMode = false) then

  begin
  Launch := ' -Xms' + MinMem +
            ' -Xmx' + MaxMem +
            ' -Djava.library.path="'+appdata + '\' + RootDir + '\bin\natives"' +         {если не авторизирован}
            ' -cp "'+ GameFiles +'"' +
            ' net.minecraft.client.Minecraft '+ Login;                                         {+ логин}
  end;
  DoOnce:=true;
end;
enter.Form4.Memo1.Lines.Add(Launch);
StartGame(Launch);
end;

end.
