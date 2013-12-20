unit crypt;

interface

function cryptString(str: string; key2: integer): string;

//  PHP ������:

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
procedure makeKey2;

const
  key: integer = 7;

var
  key2: integer;

implementation

function cryptString(str: string; key2: integer): string;
var
  I: integer;
begin
  for I := 1 to Length(str) do
  begin
    result := result + chr(ord(str[i]) + key);
  end;
end;

function decryptString(str: string; key2: integer): string;
var
  I: integer;
begin
  for I := 1 to Length(str) do
  begin
    result := result + chr(ord(str[i]) - key);
  end;
end;

function RandomRange(const AFrom, ATo: Integer): Integer;
begin
  if AFrom > ATo then
    Result := Random(AFrom - ATo) + ATo
  else
    Result := Random(ATo - AFrom) + AFrom;
end;

procedure makeKey2;
begin
  key2 := RandomRange((key * -1) + 1, key - 1);
end;

end.