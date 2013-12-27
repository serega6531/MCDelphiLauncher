unit ServersUtils;

interface

type
  TServerData = record
    name, adress: string;
    id, players, slots: integer;
    status: boolean;
  end;

procedure AddServer(data: TServerData);
function GetServer(ID:integer):TServerData;

var
  Servers: array of TServerData;

implementation

procedure AddServer(data: TServerData);
begin
  SetLength(Servers, Length(Servers) + 1);
  Servers[Length(Servers) - 1] := data;
end;

function GetServer(ID: integer): TServerData;
begin
  Result := Servers[ID];
end;

end.
