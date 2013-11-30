unit Launch;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Registry, shellapi, AuthManager;

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

procedure PlayMinecraft(servername:string;auth:TAuthManager);

implementation

uses settings;

procedure CheckFolder(Dir: string; Pattern: string; var FileList: TStringList);
var
  SearchRec: TSearchRec;
begin
  if FindFirst(Dir + '*', faDirectory, SearchRec) = 0 then
  begin
    repeat
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      begin
        CheckFolder(Dir + SearchRec.Name + '\', Pattern, FileList);
      end;
    until FindNext(SearchRec) <> 0;
  end;
  FindClose(SearchRec);
  if FindFirst(Dir + Pattern, faAnyFile xor faDirectory, SearchRec) = 0 then
  begin
    repeat
      FileList.Add(Dir + SearchRec.Name);
    until FindNext(SearchRec) <> 0;
  end;
  FindClose(SearchRec);
end;

function GetJavaPath:string;
var
  reg:TRegistry;
begin
  reg := TREgistry.Create;
  reg.RootKey := HKEY_LOCAL_MACHINE;
  reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\javaws.exe', false);
  result := reg.ReadString('Path');
  reg.CloseKey;
  reg.Free;
end;

procedure ExecuteMinecraft(MinecraftData: TMinecraftData);
var
  lpDirectory, lpFile, lpParameters: PWideChar;
begin
  with MinecraftData do
  begin
    lpDirectory := PWideChar(MinePath);
    lpParameters := PWideChar(
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
    lpFile := PWideChar(Java + '\javaw.exe');
  end;
  ShellExecuteW(0,nil,lpFile,lpParameters,lpDirectory,SW_SHOWNORMAL);
end;

procedure PlayMinecraft(servername:string;auth:TAuthManager);
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
  MinecraftData.Java := getJavaPath();
  MinecraftData.Xms := settings.MinMem;
  MinecraftData.Xmx := settings.MaxMem;
  MinecraftData.NativesPath := settings.MinecraftDir + 'dists\' + servername + '\natives';
  MinecraftData.CP := CP;
  MinecraftData.LogonInfo := '--username ' + auth.getLogin() + ' ' +
                             '--session ' + auth.getParams() + ' ' +
                             '--version 1.6.4 ';
  ExecuteMinecraft(MinecraftData);
  FreeAndNil(FileList);
  ExitProcess(0);
end;

end.
