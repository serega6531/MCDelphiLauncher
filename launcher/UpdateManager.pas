unit UpdateManager;

interface

uses ServerData, settings, idHTTP, IdBaseComponent, IdAntiFreezeBase, IdComponent, System.Classes, System.SysUtils, FWZipReader;

type
  TUpdateManager = class(TObject)

private
  procedure DownloadFile(filepath, topath:string);
  procedure unpackFiles(arpath, topath:string);
  procedure IdHTTP1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
public
  constructor Create(); overload;
  destructor Destroy; override;
  procedure init(subj:string);
  function GetInetFileSize(const FileUrl:string; idHTTP:TIdHTTP): integer;
end;

var 
  HTTP:TIdHTTP;
  WorkCount:integer;

const updateDir:string = 'http://www.happyminers.ru/MineCraft/MinecraftDownload/';

implementation

{ TServerList }

constructor TUpdateManager.Create;
begin
  inherited;
end;

destructor TUpdateManager.Destroy;
begin
  inherited;
end;

function TUpdateManager.GetInetFileSize(const FileUrl:string; idHTTP:TIdHTTP): integer;
begin
  idHTTP.Head(FileUrl);
  Result:=idHTTP.Response.ContentLength;
end;

function BToMb(bytes:integer):real;
begin
  result:=bytes/(1024*1024);
end;

procedure TUpdateManager.IdHTTP1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  WorkCount:=AWorkCount;
end;

procedure TUpdateManager.DownloadFile(filepath, topath: string);
var
  LoadStream: TMemoryStream;
begin
  HTTP:=TIdHTTP.Create(nil);
  HTTP.OnWork:=IdHTTP1Work;
  try
  begin
    LoadStream := TMemoryStream.Create;
    HTTP.Get(filepath, LoadStream);
    LoadStream.SaveToFile(topath);
    UnpackFiles(topath, MinecraftDir);
    DeleteFile(topath);
  end;
  except
    Raise Exception.Create('Ошибка обновления файлов');
  end;
  HTTP.Free;
end;

procedure TUpdateManager.init(subj: string);
begin
  if (subj = 'base') then DownloadFile(updatedir + 'base.zip', MinecraftDir) else DownloadFile(updateDir + subj + '.zip', MinecraftDir);
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
