unit ServersUtils;

interface

type
  TServerData = class(TObject)
  private
    Name: string;
    Address: string;
  public
    constructor Create(Name, Address: string); overload;
    destructor Destroy; override;
    function GetName: string;
    function GetAdress: string;
  end;

procedure AddServer(Name, Address:string);
function GetServer(ID:integer):TServerData;

var
  Servers: array of TServerData;

implementation

constructor TServerData.Create(Name, Address: string);
begin
	Self.Name := Name;
	Self.Address := Address;
end;

destructor TServerData.Destroy;
begin
  inherited;
end;

function TServerData.getAdress: string;
begin
	Result := Address;
end;

function TServerData.getName: string;
begin
	Result := Name;
end;

procedure AddServer(Name, Address:string);
begin
  SetLength(Servers, Length(Servers) + 1);
  Servers[Length(Servers) - 1] := TServerData.Create(Name, Address);
end;

function GetServer(ID: integer): TServerData;
begin
  Result := Servers[ID];
end;

end.
