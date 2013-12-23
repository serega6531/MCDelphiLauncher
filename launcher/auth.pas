unit Auth;

interface

uses InternetHTTP, crypt, Dialogs, SysUtils, hwid_impl;

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
  r: tresults_array_dv;
  key2, hid: integer;
begin
  key2 := makeKey2;
  Size := 0;
  Token := GenerateToken;
  hid := getHardDriveComputerID(r);
  AddPOSTField(PostData, Size, 'username', CryptString(Data.Login, key2));
  AddPOSTField(PostData, Size, 'password', CryptString(Data.Password, key2));
  AddPOSTField(PostData, Size, 'clientToken', CryptString(Token, key2));
  AddPOSTField(PostData, Size, 'hid', CryptString(IntToStr(hid), key2));
  AddPOSTField(PostData, Size, 'key2', IntToStr(key2));
  Res := HTTPPost('http://www.happyminers.ru/MineCraft/auth16xpost.php', PostData, Size);
  if (Res = 'Bad login') OR (Res = '') then       //проверка не прошла
    Result := false
  else begin
    Authdata.LaunchParams := Token + ':' + decryptString(Copy(Res, Pos('accessToken":"', Res)+14, 21), key2);
    Authdata.Login := Data.Login;
    Result := true;                    //проверка прошла
  end;
end;

end.
