unit ServersUtils;

interface

type
  TServerData = record
    name: string;
    adress: string;
  end;

procedure AddServer(nName, nAddress:string);
function GetServer(ID:integer):TServerData;

var
  Servers: array of TServerData;

implementation

procedure AddServer(nName, nAddress:string);
var
  tmp: TServerData;
begin
  with tmp do
  begin
    name := nName;
    adress := nAddress;
  end;
  SetLength(Servers, Length(Servers) + 1);
  Servers[Length(Servers) - 1] := tmp;
end;

function GetServer(ID: integer): TServerData;
begin
  Result := Servers[ID];
end;

end.
