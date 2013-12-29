library Launch;

{$R *.res}

uses ShellAPI, Windows;

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

procedure ExecuteMinecraft(MinecraftData: TMinecraftData); stdcall;
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
    lpFile := PAnsiChar(Java + '\javaw.exe');
  end;
  ShellExecuteA(0,nil,lpFile,lpParameters,lpDirectory,1);
end;

exports ExecuteMinecraft;

begin
end.
