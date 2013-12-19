unit Auth;

interface

uses InternetHTTP;

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
  Res, Token: string;
  Size: LongWord;
  PostData: pointer;
begin
  Size := 0;
  Token := GenerateToken;
  AddPOSTField(PostData, Size, 'username', Data.Login);
  AddPOSTField(PostData, Size, 'password', Data.Password);
  AddPOSTField(PostData, Size, 'clientToken', Token);
  Res := HTTPPost('http://www.happyminers.ru/MineCraft/auth16xpost.php', PostData, Size);
  if Res = 'Bad login' then       //проверка не прошла
    Result := false
  else begin
    Authdata.LaunchParams := Token + ':' + Copy(Res, Pos('accessToken":"', Res)+14, 21);
    Authdata.Login := Data.Login;
    Result := true;                    //проверка прошла
  end;
end;

end.
