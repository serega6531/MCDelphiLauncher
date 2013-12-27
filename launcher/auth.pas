unit Auth;

interface

uses InternetHTTP, Dialogs, SysUtils, hwid_impl, JSON;

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

const
  key: Byte = 7;

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

function cryptString(str: string): string;
var
  I: integer;
begin
  for I := 1 to Length(str) do
  begin
    result := result + chr(ord(str[i]) + key);
  end;
end;

function decryptString(str: string): string;
var
  I: integer;
begin
  for I := 1 to Length(str) do
  begin
    result := result + chr(ord(str[i]) - key);
  end;
end;

function IsAuth(Data: TAuthInputData): boolean;
var
  Res, Token: string;
  Size: LongWord;
  PostData: pointer;
  r: tresults_array_dv;
begin
  Size := 0;
  Token := GenerateToken;
  AddPOSTField(PostData, Size, 'username', CryptString(Data.Login));
  AddPOSTField(PostData, Size, 'password', CryptString(Data.Password));
  AddPOSTField(PostData, Size, 'clientToken', CryptString(Token));
  AddPOSTField(PostData, Size, 'hid', CryptString(IntToStr(getHardDriveComputerID(r))));
  Res := HTTPPost('http://www.happyminers.ru/MineCraft/auth16xpost.php', PostData, Size);
  if (Res = 'Bad login') OR (Res = '') then       //проверка не прошла
    Result := false
  else begin
    Authdata.LaunchParams := Token + ':' + getJsonStr('accessToken', Res);
    Authdata.Login := Data.Login;
    Result := true;                    //проверка прошла
  end;
end;

end.
