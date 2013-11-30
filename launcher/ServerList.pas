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
  procedure addServer(server:TServerData; id:integer); overload;
  procedure addServer(name, adress:string; id:integer); overload;
  procedure addServers(arr:array of TServerData; start:integer);
  function getServer(id:integer):TServerData;
  function getOnlineStatus(id:integer):boolean;
  function getServersCount():integer;
  function getServerByName(name:string):TServerData;
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

function TServerList.getServerByName(name:string):TServerData;
var 
  I:integer;
  foo:boolean;
begin
  foo := false;
  for I := 0 to getServersCount()+1 do
  begin
    if getServer(i).getName = name then
    begin
      result := getServer(i);
      foo := true;
      break;
    end;
  end;
  if foo = false then
    raise Exception.Create('Server "'+ name +'" not found');
    result := getServer(0);
end;

function TServerList.getOnlineStatus(id: integer): boolean;      //true is online
begin
  //IndyMagic(Servers[id]);
  result := true;
end;

function TServerList.getServer(id: integer): TServerData;
begin
  result := Servers[id];
end;

function TServerList.getServersCount: integer;
var
  I, count: Integer;
begin
  result:=0;
  count := 0;
  for I := 0 to Length(servers)-1 do 
  begin
    if servers[i] <> nil then
      Inc(count) 
    else
    begin 
      if i <> 0 then 
      begin 
        result := count;
        break; 
      end; 
    end; 
  end;
end;

procedure TServerList.addServer(server:TServerData; id:integer);
begin
  Servers[id] := server;
end;

procedure TServerList.addServer(name, adress: string; id: integer);
begin
  servers[id] := TServerData.Create(name, adress);
end;

procedure TServerList.addServers(arr: array of TServerData; start: integer);
var i, j:integer;
begin
j := 0;
for I := start to Length(arr) do
  begin
     servers[i] := arr[j];
     Inc(j);
  end;
end;

end.
