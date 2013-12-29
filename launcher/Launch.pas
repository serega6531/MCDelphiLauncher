unit Launch;

interface

uses
  Windows, ShellAPI, Auth, Registry, Settings, ServersUtils;

type
  TMinecraftData = record
    Minepath: string;
    Java: string;
    Xms: string;
    Xmx: string;
    NativesPath: string;
    CP: string;
    LogonInfo: string;
  end;

procedure PlayMinecraft(server: TServerData;auth: TAuthOutputData);

implementation

function GetJavaPath:string;
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  reg.RootKey := HKEY_LOCAL_MACHINE;
  reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\javaws.exe');
  Result := reg.ReadString('Path');
  reg.CloseKey;
  reg.Free;
end;

function getCP(server:string):string;
begin
  CheckFolder(settings.MinecraftDir+'libraries\', '*.jar');
  CheckFolder(settings.MinecraftDir+'dists\' + server + '\', '*.jar');
  result := settings.tCP;
end;

procedure PlayMinecraft(server: TServerData;auth: TAuthOutputData);
var
  MinecraftData: TMinecraftData;
  LibraryHandle: THandle;
  ExecuteMinecraft: procedure(MinecraftData: TMinecraftData); stdcall;
begin
  MinecraftData.Minepath := MinecraftDir;
  MinecraftData.Java := getJavaPath;
  MinecraftData.Xms := GameMemory;
  MinecraftData.Xmx := GameMemory;
  MinecraftData.NativesPath := MinecraftDir + 'dists\' + server.name + '\natives';
  MinecraftData.CP := getCP(server.name);
  MinecraftData.LogonInfo := '--username ' + auth.Login + ' ' +
                             '--session ' + auth.LaunchParams + ' ' +
                             '--version 1.6.4 ' +
                             '--gameDir ' + MinecraftDir + ' ' +
                             '--assetsDir ' + MinecraftDir + 'assets ';
  @ExecuteMinecraft := nil;
  LibraryHandle := LoadLibrary(PAnsiChar(AnsiString(MinecraftDir + 'dists\' + server.name + '\Launch.dll')));
  if LibraryHandle <> 0 then
  begin
    @ExecuteMinecraft := GetProcAddress(LibraryHandle, 'ExecuteMinecraft');
    if @ExecuteMinecraft <> nil then
    begin
      ExecuteMinecraft(MinecraftData);
    end;
  end;
  ExitProcess(0);
end;

end.
