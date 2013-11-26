unit enter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Registry, shellapi;

    procedure LaunchGame();

implementation

uses main, settings;


Function GetJavaPath:string;
var 
  reg:TRegistry;
begin
  reg := TREgistry.Create;
  reg.RootKey := HKEY_LOCAL_MACHINE;
  reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\javaws.exe',false);
  result := reg.ReadString('Path');
  reg.CloseKey;
  reg.Free;
end;

procedure StartGame(JavaPath, Launch, MinecraftPath:string);
var
  lpDirectory, lpFile, lpParameters: PANSIChar;begin
  {lpDirectory := PAnsiChar(MinePath + '\bin\');

  lpFile := PAnsiChar(Java + '\javaw.exe');
  lpParameters := PAnsiChar(' -Xms' + Xms + 'm ' + '-Xmx' + Xmx + 'm ' + '-Djava.library.path=natives ' +                            '-cp "minecraft.jar;jinput.jar;lwjgl.jar;lwjgl_util.jar;" '+                            'net.minecraft.client.Minecraft ' +
                              Login + ' ' + Pass);  ShellExecuteA(0,nil,lpFile,lpParameters,lpDirectory,SW_SHOWNORMAL);}end;

procedure LaunchGame();
var
    Launch:string;
begin
MinMem:=settings.Form2.sEdit1.Text;
MaxMem:=settings.Form2.sEdit2.Text;
  begin
StartGame(GetJavaPath(), Launch, (appdata + '\' + RootDir));
end;

end;
end.
