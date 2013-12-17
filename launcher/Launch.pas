unit Launch;

interface

uses
  Windows, Classes, ShellAPI, Auth, Registry, Settings;

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

procedure PlayMinecraft(Servername: string; Auth: TAuthOutputData);

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

procedure ExecuteMinecraft(MinecraftData: TMinecraftData);
var
  lpDirectory, lpFile, lpParameters: PAnsiChar;
begin
  with MinecraftData do
  begin
    lpDirectory := PAnsiChar(MinePath);
    lpParameters := PAnsiChar(
                               //'-Dfml.ignoreInvalidMinecraftCertificates=true -Dfml.ignorePatchDiscrepancies=true ' +
                               '-Xms' + Xms + 'm ' +
                               '-Xmx' + Xmx + 'm ' +
                               '-Djava.library.path="' + NativesPath + '" ' +
                               '-cp "' + CP + '" ' +
                               'net.minecraft.client.main.Main ' + LogonInfo
                              {
                               'net.minecraft.launchwrapper.Launch' + LogonInfo +
                               ' --tweakClass cpw.mods.fml.common.launcher.FMLTweaker'
                              }
                              );
    lpFile := PAnsiChar(Java + '\java.exe');
  end;
  ShellExecuteA(0,nil,lpFile,lpParameters,lpDirectory,SW_SHOWNORMAL);
end;

procedure PlayMinecraft(servername:string;auth:TAuthOutputData);
var
  FileList: TStringList;
  I: Word;
  CP: string;
  MinecraftData: TMinecraftData;
begin
  FileList := TStringList.Create;
  CheckFolder(settings.MinecraftDir+'libraries\', '*.jar', FileList);
  CheckFolder(settings.MinecraftDir+'dists\' + servername + '\', '*.jar', FileList);
  CP := '';
  for I := 0 to FileList.Count - 1 do
  begin
    CP := CP + FileList.Strings[I] + ';';
  end;
  MinecraftData.Minepath := settings.MinecraftDir;
  MinecraftData.Java := getJavaPath;
  MinecraftData.Xms := settings.GameMemory;
  MinecraftData.Xmx := settings.GameMemory;
  MinecraftData.NativesPath := settings.MinecraftDir + 'dists\' + servername + '\natives';
  MinecraftData.CP := CP;
  MinecraftData.LogonInfo := '--username ' + auth.login + ' ' +
                             '--session ' + auth.LaunchParams + ' ' +
                             '--version 1.6.4 ';
  ExecuteMinecraft(MinecraftData);
  FileList.Free;
  //ExitProcess(0);
end;

end.
