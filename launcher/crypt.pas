unit crypt;

interface

function cryptString(str: string; key2: integer): string;

//  PHP аналог:

//  function cryptStr($str, $key2 = 0)
//  {
//	  $result = '';
//	  $key = 7;
//	  for ($i=0; $i < strlen($str); $i++) {
//		  $result .= chr(ord($str[$i]) + $key - $key2);
//	  }
//	  return $result;
//  }

function decryptString(str: string; key2: integer): string;
function makeKey2: integer;

const
  key: integer = 7;

implementation

function cryptString(str: string; key2: integer): string;
var
  I: integer;
begin
  for I := 1 to Length(str) do
  begin
    result := result + chr(ord(str[i]) + key - key2);
  end;
end;

function decryptString(str: string; key2: integer): string;
var
  I: integer;
begin
  for I := 1 to Length(str) do
  begin
    result := result + chr(ord(str[i]) - key + key2);
  end;
end;

function RandomRange(const AFrom, ATo: Integer): Integer;
begin
  if AFrom > ATo then
    Result := Random(AFrom - ATo) + ATo
  else
    Result := Random(ATo - AFrom) + AFrom;
end;

function makeKey2: integer;
begin
  result := RandomRange(0, key - 1);
end;

end.
