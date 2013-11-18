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
procedure addServers(newservers:array of TServerData; startid:integer);
function getServer(id:integer):TServerData;
function getOnlineStatus(id:integer):boolean;
function getServersCount():integer;
function getServerIdByName(name:string):integer;
end;


implementation

{ TServerList }

procedure TServerList.addServers(newservers: array of TServerData; startid:integer);
var
  I: Integer;
begin
for I := 0 to Length(newservers)-1 do
addServer(newservers[i],startid);
Inc(startid);
end;

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
var
  I, count: Integer;
begin
count:=1;
for I := 0 to Length(servers)-1 do begin if servers[i] <> nil then Inc(count) else begin if i <> 0 then begin result:=i; break; end else result:=0; end; end;
end;

procedure TServerList.addServer(server:TServerData; id:integer);
begin
Servers[id]:=server;
end;

end.
