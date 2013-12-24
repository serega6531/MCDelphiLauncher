unit crypt;

interface

function cryptString(str: string): string;
function decryptString(str: string): string;

const
  key: Byte = 7;

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
