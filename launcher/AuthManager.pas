unit AuthManager;

interface

uses System.Classes, uJson, IdHTTP, Math;

type
  TAuthManager = class(TObject)

private
  function generateToken():string;
public
  constructor Create(); overload;
  destructor Destroy; override;
  function isAuth(login, password:string):boolean;
  function getParams():string;
end;

var LaunchParams:string;

implementation

{ TServerData }



constructor TAuthManager.Create();
begin
   inherited;
end;

destructor TAuthManager.Destroy;
begin
  inherited;
end;


function TAuthManager.generateToken: string;
 const
   letters: string = 'abcdef1234567890';   //string with all possible chars
   var i:integer;
 begin
   Randomize;
   for i := 1 to 16 do
    result := result + letters[RandomRange(1,Length(letters))];
end;

function TAuthManager.getParams: string;
begin
result:=LaunchParams;
end;

function TAuthManager.isAuth(login, password:string): boolean;
var
  res, jsontext:string;
  json:TStringStream;
  http:TIdHTTP;
begin
  jsontext:='{"username": "'+ login +'","password": "'+ password +'","clientToken": "' + generateToken() +'"}';
  http := TIdHttp.Create(nil);
  http.HandleRedirects := True;
  http.ReadTimeout := 5000;
  http.Request.ContentType := 'application/json';
  json := TStringStream.Create(jsontext);
  json.Position := 0;
  res:=http.Post('http://www.happyminers.ru/MineCraft/auth16x.php', json);   {получение ответа}
  json.free;
  http.Free;
  if (res = 'Bad login') then       //проверка не прошла
    result:=false
  else begin
    LaunchParams := Copy(res, Pos('accessToken":"', res)+Length('accessToken":"'), 21);
    result:=true;                    //проверка прошла
  end;
end;

end.
