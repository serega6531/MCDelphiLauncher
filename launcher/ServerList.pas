unit ServerList;

interface

uses ServerData, System.SysUtils;

type
TServerList = class(TObject)

private
Servers:array[0..2] of TServerData;
public
constructor Create(); overload;
destructor Destroy; override;
procedure addServer(server:TServerData; id:integer);
function getServer(id:integer):TServerData;
function getOnlineStatus(id:integer):boolean;
function getServersCount():integer;
function getServerIdByName(name:string):integer;
end;


implementation

{ TServerList }

constructor TServerList.Create();
begin
  inherited;
end;

destructor TServerList.Destroy;
begin
  inherited;
end;

function TServerList.getOnlineStatus(id: integer): boolean;      //true is online
begin
//IndyMagic(Servers[id]);
result:=true;
end;

function TServerList.getServer(id: integer): TServerData;
begin
result:=Servers[id];
end;

function TServerList.getServerIdByName(name: string): integer;
var
  i: Integer;
begin
result:=-1;
for i := 0 to getServersCount - 1 do
begin
  if servers[i].getName = name then
  begin
  result:=i;
  break;
  end;
end;
if result = -1 then
raise Exception.Create('Server doesn''t exists');
end;

function TServerList.getServersCount: integer;
begin
if Length(Servers) > 0 then result:=Length(Servers) else raise Exception.Create('Server''s not exists');
end;

procedure TServerList.addServer(server:TServerData; id:integer);
begin
Servers[id]:=server;
end;

end.
