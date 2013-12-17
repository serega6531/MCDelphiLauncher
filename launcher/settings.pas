unit settings;

interface

uses
  Windows, SysUtils, Forms,
  sSkinProvider, StdCtrls, sLabel, sEdit, sButton, Registry, ServersUtils, SHFolder,
  Controls, Classes;

type
  TSettingsForm = class(TForm)
    TitleLabel: TsLabel;
    SkinProvider: TsSkinProvider;
    MemoryEdit: TsEdit;
    MemoryLabel: TsLabel;
    SaveButton: TsButton;
    CancelButton: TsButton;
    VersionLabel: TsLabel;
    procedure CancelButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  end;

procedure InitServers;
procedure CheckFolder(Dir: string; Pattern: string; var FileList: TStringList);

const
  LauncherVer: string = '1';
  RootDir: string = '.happyminers';

var
  SettingsForm: TSettingsForm;
  Reg: TRegIniFile;
  MinecraftDir: string;
  GameMemory: string;
  AppData: string;

implementation

{$R *.dfm}

procedure TSettingsForm.CancelButtonClick(Sender: TObject);
begin
  Self.Close;
end;

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

function GetSpecialFolderPath(folder : integer) : string;    {Полуаем системные пути}
const
  SHGFP_TYPE_CURRENT = 0;
var
  Path: array [0..MAX_PATH] of char;
begin
  if SUCCEEDED(SHGetFolderPath(0,folder,0,SHGFP_TYPE_CURRENT,@Path[0])) then
    Result := Path
  else
    Raise Exception.Create('Can''t find AppData dir');
end;

procedure TSettingsForm.FormCreate(Sender: TObject);
begin
  Reg := TRegIniFile.Create('Software\happyminers.ru');
  VersionLabel.Caption := 'Версия лаунчера: ' + LauncherVer;
  AppData := GetSpecialFolderPath(CSIDL_APPDATA);
  MinecraftDir := AppData + '\' + RootDir + '\';
  GameMemory := IntToStr(Reg.ReadInteger('Settings', 'Memory', 512));
  MemoryEdit.Text := GameMemory;
end;

procedure InitServers;
begin
  ServersUtils.AddServer('Classic', 'localhost');
  ServersUtils.AddServer('Another Server', '127.0.0.1');
end;

procedure TSettingsForm.SaveButtonClick(Sender: TObject);
begin
  Reg.WriteInteger('Settings', 'Memory', StrToInt(MemoryEdit.Text));
  Reg.CloseKey;
  Self.Close;
end;

end.
