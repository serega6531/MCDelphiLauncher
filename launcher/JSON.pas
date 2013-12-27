unit JSON;

interface

uses SysUtils;

function getJsonStr(key, str: string):string;
function getJsonInt(key, str: string):integer;
function getJsonBool(key, str: string):boolean;

implementation

function getJsonStr(key, str: string):string;
begin
  result := Copy(str, Pos(key, str) + Length(key) + 3, MaxInt);
  result := Copy(result, 0, Pos('"', result) - 1);
end;

function getJsonInt(key, str: string):integer;
var
  res: string;
begin
  res := Copy(str, Pos(key, str) + Length(key) + 2, MaxInt);
  if Pos(',', res) > 0 then
    res := Copy(res, 0, Pos(',', res) - 1)
  else if Pos('}', res) > 0 then
    res := Copy(res, 0, Pos('}', res) - 1)
  else if Pos(']', res) > 0 then
    res := Copy(res, 0, Pos(']', res) - 1)
  else
    result := -1;

  result := StrToInt(res);
end;

function getJsonBool(key, str: string):boolean;
var
  res: string;
begin
  result := false;
  res := Copy(str, Pos(key, str) + Length(key) + 2, MaxInt);
  if Pos(',', res) > 0 then
    res := Copy(res, 0, Pos(',', res) - 1)
  else if Pos('}', res) > 0 then
    res := Copy(res, 0, Pos('}', res) - 1)
  else if Pos(']', res) > 0 then
    res := Copy(res, 0, Pos(']', res) - 1);
  if res = 'true' then
    result := true;
end;

end.
