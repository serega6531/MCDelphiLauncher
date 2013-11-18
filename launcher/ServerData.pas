unit ServerData;

interface

type
TServerData = class(TObject)

private
name:string;
adress:string;

public
constructor Create(name, adress:string); overload;
destructor Destroy; override;
function getName():string;
function getAdress():string;
end;

implementation

{ TServerData }



constructor TServerData.Create(name, adress: string);
begin
self.name:=name;
self.adress:=adress;
end;

destructor TServerData.Destroy;
begin
  inherited;
end;

function TServerData.getAdress: string;
begin
result:=adress;
end;

function TServerData.getName: string;
begin
result:=name;
end;

end.
