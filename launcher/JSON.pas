unit JSON;

interface

uses SysUtils;

function getJsonStr(key, str: string):string;
function getJsonInt(key, str: string):integer;
function getJsonBool(key, str: string):boolean;
function getJsonArray(key, str: string):string;

implementation

function getJsonStr(key, str: string):string;
var
  keypos: byte;
begin
  keypos := Pos(key, str);
  if keypos <> 0 then
  begin
    result := Copy(str, keypos + Length(key) + 3, MaxInt);
    result := Copy(result, 0, Pos('"', result) - 1);
  end else result := '';
end;

function getJsonInt(key, str: string):integer;
var
  res: string;
  keypos: byte;
begin
   keypos := Pos(key, str);
  if keypos <> 0 then
  begin
    res := Copy(str, Pos(key, str) + Length(key) + 2, MaxInt);
    if Pos(',', res) > 0 then
      res := Copy(res, 0, Pos(',', res) - 1)
    else if Pos('}', res) > 0 then
      res := Copy(res, 0, Pos('}', res) - 1)
    else if Pos(']', res) > 0 then
      res := Copy(res, 0, Pos(']', res) - 1);
    result := StrToInt(res);
  end else result := 0;
end;

function getJsonBool(key, str: string):boolean;
var
  res: string;
  keypos: byte;
begin
  result := false;
  keypos := Pos(key, str);
  if keypos <> 0 then
  begin
    res := Copy(str, Pos(key, str) + Length(key) + 2, MaxInt);
    if Pos(',', res) > 0 then
      res := Copy(res, 0, Pos(',', res) - 1)
    else if Pos('}', res) > 0 then
      res := Copy(res, 0, Pos('}', res) - 1)
    else if Pos(']', res) > 0 then
      res := Copy(res, 0, Pos(']', res) - 1);
    if res = 'true' then
      result := true;
  end else result := false;
end;

function getJsonArray(key, str: string):string;
var
  keypos: Byte;
begin
  keypos := Pos(key, str);
  if keypos <> 0 then
  begin
    result := Copy(str, keypos + Length(key) + 3, MaxInt);
    result := Copy(result, 0, Pos(']', result) - 1);
  end else result := '';
end;

end.
