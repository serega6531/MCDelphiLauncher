unit AuthManager;

interface

uses System.Classes, IdHTTP, Math;

type
  TAuthManager = class(TObject)

private
  LaunchParams:string;
  username:string;
  function generateToken():string;
public
  constructor Create(); overload;
  destructor Destroy; override;
  function isAuth(login, password:string):boolean;
  function getParams():string;
  function getLogin():string;
end;


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
  var
    i:integer;
 begin
   Randomize;
   for i := 1 to 16 do
    result := result + letters[RandomRange(1,16)];
end;

function TAuthManager.getLogin: string;
begin
  result := username;
end;

function TAuthManager.getParams: string;
begin
  result:=LaunchParams;
end;

function TAuthManager.isAuth(login, password:string): boolean;
var
  res, jsontext, token:string;
  json:TStringStream;
  http:TIdHTTP;
begin
  token := generateToken();
  jsontext:='{"username": "'+ login +'","password": "'+ password +'","clientToken": "' + token +'"}';
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
    LaunchParams := token + ':' + Copy(res, Pos('accessToken":"', res)+14, 21);
    username := login;
    result:=true;                    //проверка прошла
  end;
end;

end.
