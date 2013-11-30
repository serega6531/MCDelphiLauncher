unit UpdateManager;

interface

uses settings, idHTTP, IdBaseComponent, IdAntiFreezeBase, IdComponent, System.Classes, System.SysUtils, FWZipReader,
 update, idAntiFreeze, Forms, IdHashMessageDigest, IdGlobal, FileCtrl, Registry;

type
  TUpdateManager = class(TObject)

private
  HTTP:TIdHTTP;
  WorkCount:integer;
  filesize:integer;
  LoadStream: TMemoryStream;
  procedure DownloadFile(filename: string);
  procedure unpackFiles(arpath, topath:string);
  procedure IdHTTP1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
  function CheckMd5(servername:string):boolean;
  procedure FindFiles(Dir: string; Pattern: string; var FileList: TStringList);
public
  constructor Create(); overload;
  destructor Destroy; override;
  procedure init(server:string;force:boolean);
  function Md5File(filename:string): string;
end;

const updateDir:string = 'http://www.happyminers.ru/MineCraft/MinecraftDownload/';

implementation

{ TServerList }

constructor TUpdateManager.Create;
begin
  HTTP := TIdHTTP.Create(nil);
  HTTP.OnWork:=IdHTTP1Work;
  HTTP.Request.UserAgent := 'Minecraft launcher';
  TIdAntiFreeze.Create(nil);
  LoadStream := TMemoryStream.Create;
  inherited;
end;

destructor TUpdateManager.Destroy;
begin
    HTTP.Free;
    LoadStream.Destroy;
  inherited;
end;

procedure RemoveAll(path: string);
var
  sr: TSearchRec;
begin
  if FindFirst(path + '\*.*', faAnyFile, sr) = 0 then
  begin
    repeat
      if sr.Attr and faDirectory = 0 then
      begin
        DeleteFile(path + '\' + sr.name);
      end
      else
      begin
        if pos('.', sr.name) <= 0 then
          RemoveAll(path + '\' + sr.name);
      end;
    until
      FindNext(sr) <> 0;
  end;
  FindClose(sr);
  //RemoveDir(PChar(path));
end;

function BToMb(bytes:integer):real;
begin
  result:=bytes/(1048576);    //1048576 is 1024*1024
  if result < 1 then result := 1;   //if number too small
end;

procedure TUpdateManager.IdHTTP1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  WorkCount:=AWorkCount;
  update.Form3.progressbar.position := AWorkCount;
  update.Form3.LoadingLabel.Caption := 'Загрузка... ('+ IntToStr(AWorkCount) + '/' + IntToStr(FileSize) +' байт('+ FloatToStr(Round(BToMb(AWorkCount))) + '/' + FloatToStr(Round(BToMb(FileSize))) +' Мб))';
end;

procedure TUpdateManager.FindFiles(Dir: string; Pattern: string; var FileList: TStringList);
var
  SearchRec: TSearchRec;
begin
  if FindFirst(Dir + '*', faDirectory, SearchRec) = 0 then
  begin
    repeat
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      begin
        FindFiles(Dir + SearchRec.Name + '\', Pattern, FileList);
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

function TUpdateManager.CheckMd5(servername:string): boolean;
var
  files:TStringList;
  clientmd5, servermd5:string;
  I: Integer;
begin
  files := TStringList.Create;
  files.Add(MinecraftDir + 'dists\' + servername + '\' + servername + '.jar');
  FindFiles(settings.MinecraftDir+'mods\', '*.jar', files);
  clientmd5 := '';
  for I := 0 to files.Count-1 do
  begin
    clientmd5 := clientmd5 + Md5File(files.Strings[i]);
  end;
  servermd5 := http.Get(updateDir + servername + '.md5');
  if clientmd5 = servermd5 then result := true else result := false;
end;

procedure TUpdateManager.init(server:string;force:boolean);
var
  BaseFile:TextFile;
  reg:TRegIniFile;
  ver:string;
begin
  if not DirectoryExists(MinecraftDir) then
    CreateDir(MinecraftDir);
  if not (FileExists(MinecraftDir + 'BaseFile')) OR (force = true) then
  begin
    RemoveAll(MinecraftDir);
    DownloadFile('base.zip');
  end;
  reg := TRegIniFile.Create('Software\happyminers');
  if not (FileExists(MinecraftDir + 'dists\' + server + '\BaseFile')) OR (reg.ReadInteger('Version', server, -1) <> StrToInt(http.Get('http://www.happyminers.ru/MineCraft/clientver.php?of='+server))) OR not (checkMd5(server)) then
    DownloadFile(server + '.zip');
    AssignFile(BaseFile, MinecraftDir + 'dists\' + server + '\BaseFile');
    Reset(BaseFile);
    ReadLn(BaseFile, ver);
    CloseFile(BaseFile);
    try
      reg.WriteInteger('Version', server, StrToInt(ver));
    except
      on E:Exception do
      begin
        if E.ClassName = 'EConvertError' then
        if ver = '' then
          raise Exception.Create('Ошибка обновления файлов: BaseFileEmpty')
        else
          raise Exception.Create('Ошибка обновления файлов: BaseFileConvertError');
      end;
    end;
end;

procedure TUpdateManager.DownloadFile(filename: string);
begin
  HTTP.Head(updateDir + filename);
  filesize := HTTP.Response.ContentLength;
  if filesize <> -1 then
  begin
  try begin
    update.Form3.ProgressBar.Max := filesize;
    LoadStream.Clear;
    HTTP.Get(updateDir + filename, LoadStream);
    LoadStream.SaveToFile(MinecraftDir + filename);
    UnpackFiles(MinecraftDir + filename, MinecraftDir);
    DeleteFile(MinecraftDir + filename);
  end;
  except
  on E:Exception do
  begin
    Raise Exception.Create('Ошибка обновления файлов: ' + E.Message);
    Application.Terminate;
  end;
  end;
  end else begin
    Raise Exception.Create('Ошибка обновления файлов: FileNotFound');
    Application.Terminate;
  end;
end;

function TUpdateManager.Md5File(filename: string): string;
var
  md5: TIdHashMessageDigest5;
  fs: TfileStream;
begin
  md5 := TIdHashMessageDigest5.Create;
  fs := TFileStream.Create(filename, fmOpenRead);
  result := AnsiLowerCase(md5.HashStreamAsHex(fs));
  fs.Free;
  md5.Free;
end;

procedure TUpdateManager.unpackFiles(arpath, topath: string);
var
  DataStream:TMemoryStream;
  Read: TFWZipReader;
  i:integer;
begin
  update.Form3.Title.Caption := 'Идет распаковка файлов...';
  DataStream:=TMemoryStream.Create;
  DataStream.LoadFromFile(arpath);
  DataStream.Read(i,SizeOf(i));
  Read := TFWZipReader.Create;
  Read.LoadFromStream(DataStream);
  Read.ExtractAll(topath);
end;

end.
