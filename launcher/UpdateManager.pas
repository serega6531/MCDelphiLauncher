unit UpdateManager;

interface

uses ServerData, settings, idHTTP, IdBaseComponent, IdAntiFreezeBase, IdComponent, System.Classes, System.SysUtils, FWZipReader,
 update, idAntiFreeze, Forms;

type
  TUpdateManager = class(TObject)

private
  HTTP:TIdHTTP;
  WorkCount:integer;
  filesize:integer;
  LoadStream: TMemoryStream;
  procedure DownloadFile(filepath, filename: string);
  procedure unpackFiles(arpath, topath:string);
  procedure IdHTTP1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
public
  constructor Create(); overload;
  destructor Destroy; override;
  procedure init(subj:string);
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

function BToMb(bytes:integer):real;
begin
  result:=bytes/(1048576);    //1048576 is 1024*1024
  if result < 1 then result := 1;   //if number too small
end;

procedure TUpdateManager.IdHTTP1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  WorkCount:=AWorkCount;
  update.Form3.progressbar.position := AWorkCount;
  update.Form3.LoadingLabel.Caption := 'Загрузка... ('+ IntToStr(AWorkCount) + '/' + IntToStr(FileSize) +' байт('+ FloatToStr(Round(BToMb(FileSize))) + '/' + FloatToStr(Round(BToMb(AWorkCount))) +' Мб))';
end;

function md5(SourceString: string): string;
var md5: TIdHashMessageDigest5;
begin
// получаем md5-хэш для строки
  Result := '';
  md5 := TIdHashMessageDigest5.Create;
  try
    Result := AnsiLowerCase(md5.HashStringAsHex(SourceString));
  finally
    FreeAndNil(md5);
  end;
end;

procedure TUpdateManager.DownloadFile(filepath, filename: string);
begin
  HTTP.Head(filepath + filename);
  filesize := HTTP.Response.ContentLength;
  if filesize <> -1 then
  begin
  try begin
    update.Form3.ProgressBar.Max := filesize;
    LoadStream.Clear;
    HTTP.Get(filepath + filename, LoadStream);
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

procedure TUpdateManager.init(subj: string);
begin
  if (subj = 'base') then DownloadFile(updatedir, 'base.zip') else DownloadFile(updateDir, subj + '.zip');
end;

procedure TUpdateManager.unpackFiles(arpath, topath: string);
var
  DataStream:TMemoryStream;
  Read: TFWZipReader;
  i:integer;
begin
  DataStream:=TMemoryStream.Create;
  DataStream.LoadFromFile(arpath);
  DataStream.Read(i,SizeOf(i));
  Read := TFWZipReader.Create;
  Read.LoadFromStream(DataStream);
  Read.ExtractAll(topath);
end;

end.
