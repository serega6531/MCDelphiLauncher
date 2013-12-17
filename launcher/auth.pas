unit Auth;

interface

uses Classes, IdHTTP;

type
  TAuthInputData = record
    Login: string[14];
    Password: string[14];
  end;

  TAuthOutputData = record
    LaunchParams: string[38];
    Login: string[14];
  end;

function IsAuth(Data:TAuthInputData): boolean;

var
  Authdata:TAuthOutputData;

implementation

function GenerateToken: string;
 const
    Letters: string = 'abcdef1234567890';   //string with all possible chars
  var
    I: integer;
 begin
   Randomize;
   for I := 1 to 16 do
    Result := Result + Letters[Random(15) + 1];
end;

function IsAuth(Data: TAuthInputData): boolean;
var
  Res, JSONText, Token: string;
  JSON: TStringStream;
  HTTP: TIdHTTP;
begin
  Token := GenerateToken;
  JSONText:='{"username": "'+ Data.Login +'","password": "'+ Data.Password +'","clientToken": "' + Token +'"}';
  HTTP := TIdHttp.Create(nil);
  HTTP.HandleRedirects := True;
  HTTP.ReadTimeout := 5000;
  HTTP.Request.ContentType := 'application/json';
  JSON := TStringStream.Create(JSONText);
  JSON.Position := 0;
  Res := HTTP.Post('http://www.happyminers.ru/MineCraft/auth16x.php', JSON);   {получение ответа}
  if Res = 'Bad login' then       //проверка не прошла
    Result := false
  else begin
    Authdata.LaunchParams := Token + ':' + Copy(Res, Pos('accessToken":"', Res)+14, 21);
    Authdata.Login := Data.Login;
    Result := true;                    //проверка прошла
  end;
  JSON.free;
  HTTP.Free;
end;

end.
