unit crypt;

interface

function cryptString(str: string): string;

//  PHP аналог:

//  function cryptStr($str)
//  {
//	  $result = '';
//	  $key = 7;
//	  for ($i=0; $i < strlen($str); $i++) {
//		  $result .= chr(ord($str[$i]) + $key);
//	  }
//	  return $result;
//  }

function decryptString(str: string): string;

const
  key: integer = 7;

implementation

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

end.
