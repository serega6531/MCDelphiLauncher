unit unMD5;
{$I-}
interface
 
uses
    SysUtils; //только IntToHex()
 
type
    TMD5 = array[0..15]of byte;
 
procedure   md5(s:string; var Hash:TMD5); overload;
function    md5(s:string):string; overload;
//вычисляет MD5 от строки
 
function    md5_file(sFileName:string; var Hash:TMD5):boolean; overload;
function    md5_file(sFileName:string):string; overload;
//вычисляет MD5 для файла (если ошибка с файлом, то возвращает '')
 
/////////////////////////////////////////
implementation
/////////////////////////////////////////
 
var
a:TMD5;
 
lenhi, lenlo: longword;
index: cardinal;
hashbuffer: array[0..63] of byte;
currenthash: array[0..3] of cardinal;
 
{---------------------------------}
procedure burn;
begin
    lenhi:= 0; lenlo:= 0; index:= 0;
    fillchar(hashbuffer,sizeof(hashbuffer),0);
    fillchar(currenthash,sizeof(currenthash),0);
end;
{---------------------------------}
procedure init;
begin
    burn;
    currenthash[0]:= $67452301;
    currenthash[1]:= $efcdab89;
    currenthash[2]:= $98badcfe;
    currenthash[3]:= $10325476;
end;
{---------------------------------}
function lrot32(a, b: longword): longword;
begin
    result:= (a shl b) or (a shr (32-b));
end;
{---------------------------------}
procedure compress;
var
    data: array[0..15] of cardinal;
    a, b, c, d: cardinal;
begin
    move(hashbuffer,data,sizeof(data));
    a:= currenthash[0];
    b:= currenthash[1];
    c:= currenthash[2];
    d:= currenthash[3];
        
    a:= b + lrot32(a + (d xor (b and (c xor d))) + data[ 0] + $d76aa478, 7);
    d:= a + lrot32(d + (c xor (a and (b xor c))) + data[ 1] + $e8c7b756,12);
    c:= d + lrot32(c + (b xor (d and (a xor b))) + data[ 2] + $242070db,17);
    b:= c + lrot32(b + (a xor (c and (d xor a))) + data[ 3] + $c1bdceee,22);
    a:= b + lrot32(a + (d xor (b and (c xor d))) + data[ 4] + $f57c0faf, 7);
    d:= a + lrot32(d + (c xor (a and (b xor c))) + data[ 5] + $4787c62a,12);
    c:= d + lrot32(c + (b xor (d and (a xor b))) + data[ 6] + $a8304613,17);
    b:= c + lrot32(b + (a xor (c and (d xor a))) + data[ 7] + $fd469501,22);
    a:= b + lrot32(a + (d xor (b and (c xor d))) + data[ 8] + $698098d8, 7);
    d:= a + lrot32(d + (c xor (a and (b xor c))) + data[ 9] + $8b44f7af,12);
    c:= d + lrot32(c + (b xor (d and (a xor b))) + data[10] + $ffff5bb1,17);
    b:= c + lrot32(b + (a xor (c and (d xor a))) + data[11] + $895cd7be,22);
    a:= b + lrot32(a + (d xor (b and (c xor d))) + data[12] + $6b901122, 7);
    d:= a + lrot32(d + (c xor (a and (b xor c))) + data[13] + $fd987193,12);
    c:= d + lrot32(c + (b xor (d and (a xor b))) + data[14] + $a679438e,17);
    b:= c + lrot32(b + (a xor (c and (d xor a))) + data[15] + $49b40821,22);
 
    a:= b + lrot32(a + (c xor (d and (b xor c))) + data[ 1] + $f61e2562, 5);
    d:= a + lrot32(d + (b xor (c and (a xor b))) + data[ 6] + $c040b340, 9);
    c:= d + lrot32(c + (a xor (b and (d xor a))) + data[11] + $265e5a51,14);
    b:= c + lrot32(b + (d xor (a and (c xor d))) + data[ 0] + $e9b6c7aa,20);
    a:= b + lrot32(a + (c xor (d and (b xor c))) + data[ 5] + $d62f105d, 5);
    d:= a + lrot32(d + (b xor (c and (a xor b))) + data[10] + $02441453, 9);
    c:= d + lrot32(c + (a xor (b and (d xor a))) + data[15] + $d8a1e681,14);
    b:= c + lrot32(b + (d xor (a and (c xor d))) + data[ 4] + $e7d3fbc8,20);
    a:= b + lrot32(a + (c xor (d and (b xor c))) + data[ 9] + $21e1cde6, 5);
    d:= a + lrot32(d + (b xor (c and (a xor b))) + data[14] + $c33707d6, 9);
    c:= d + lrot32(c + (a xor (b and (d xor a))) + data[ 3] + $f4d50d87,14);
    b:= c + lrot32(b + (d xor (a and (c xor d))) + data[ 8] + $455a14ed,20);
    a:= b + lrot32(a + (c xor (d and (b xor c))) + data[13] + $a9e3e905, 5);
    d:= a + lrot32(d + (b xor (c and (a xor b))) + data[ 2] + $fcefa3f8, 9);
    c:= d + lrot32(c + (a xor (b and (d xor a))) + data[ 7] + $676f02d9,14);
    b:= c + lrot32(b + (d xor (a and (c xor d))) + data[12] + $8d2a4c8a,20);
 
    a:= b + lrot32(a + (b xor c xor d) + data[ 5] + $fffa3942, 4);
    d:= a + lrot32(d + (a xor b xor c) + data[ 8] + $8771f681,11);
    c:= d + lrot32(c + (d xor a xor b) + data[11] + $6d9d6122,16);
    b:= c + lrot32(b + (c xor d xor a) + data[14] + $fde5380c,23);
    a:= b + lrot32(a + (b xor c xor d) + data[ 1] + $a4beea44, 4);
    d:= a + lrot32(d + (a xor b xor c) + data[ 4] + $4bdecfa9,11);
    c:= d + lrot32(c + (d xor a xor b) + data[ 7] + $f6bb4b60,16);
    b:= c + lrot32(b + (c xor d xor a) + data[10] + $bebfbc70,23);
    a:= b + lrot32(a + (b xor c xor d) + data[13] + $289b7ec6, 4);
    d:= a + lrot32(d + (a xor b xor c) + data[ 0] + $eaa127fa,11);
    c:= d + lrot32(c + (d xor a xor b) + data[ 3] + $d4ef3085,16);
    b:= c + lrot32(b + (c xor d xor a) + data[ 6] + $04881d05,23);
    a:= b + lrot32(a + (b xor c xor d) + data[ 9] + $d9d4d039, 4);
    d:= a + lrot32(d + (a xor b xor c) + data[12] + $e6db99e5,11);
    c:= d + lrot32(c + (d xor a xor b) + data[15] + $1fa27cf8,16);
    b:= c + lrot32(b + (c xor d xor a) + data[ 2] + $c4ac5665,23);
 
    a:= b + lrot32(a + (c xor (b or (not d))) + data[ 0] + $f4292244, 6);
    d:= a + lrot32(d + (b xor (a or (not c))) + data[ 7] + $432aff97,10);
    c:= d + lrot32(c + (a xor (d or (not b))) + data[14] + $ab9423a7,15);
    b:= c + lrot32(b + (d xor (c or (not a))) + data[ 5] + $fc93a039,21);
    a:= b + lrot32(a + (c xor (b or (not d))) + data[12] + $655b59c3, 6);
    d:= a + lrot32(d + (b xor (a or (not c))) + data[ 3] + $8f0ccc92,10);
    c:= d + lrot32(c + (a xor (d or (not b))) + data[10] + $ffeff47d,15);
    b:= c + lrot32(b + (d xor (c or (not a))) + data[ 1] + $85845dd1,21);
    a:= b + lrot32(a + (c xor (b or (not d))) + data[ 8] + $6fa87e4f, 6);
    d:= a + lrot32(d + (b xor (a or (not c))) + data[15] + $fe2ce6e0,10);
    c:= d + lrot32(c + (a xor (d or (not b))) + data[ 6] + $a3014314,15);
    b:= c + lrot32(b + (d xor (c or (not a))) + data[13] + $4e0811a1,21);
    a:= b + lrot32(a + (c xor (b or (not d))) + data[ 4] + $f7537e82, 6);
    d:= a + lrot32(d + (b xor (a or (not c))) + data[11] + $bd3af235,10);
    c:= d + lrot32(c + (a xor (d or (not b))) + data[ 2] + $2ad7d2bb,15);
    b:= c + lrot32(b + (d xor (c or (not a))) + data[ 9] + $eb86d391,21);
        
    inc(currenthash[0],a);
    inc(currenthash[1],b);
    inc(currenthash[2],c);
    inc(currenthash[3],d);
    index:= 0;
    fillchar(hashbuffer,sizeof(hashbuffer),0);
end;
{---------------------------------}
procedure update(const buffer; size: longword);
var pbuf: ^byte;
begin
    inc(lenhi,size shr 29); //Int64(lenhi,lenlo) := Int64(size) shl 3;
    inc(lenlo,size shl 3);
    if lenlo<(size shl 3) then inc(lenhi);
    pbuf:= @buffer;
    while size> 0 do begin
        if (size)>=(sizeof(hashbuffer)-index) then begin
            move(pbuf^,hashbuffer[index],sizeof(hashbuffer)-index);
            dec(size,sizeof(hashbuffer)-index);
            inc(pbuf,sizeof(hashbuffer)-index);
            compress;
        end else begin
            move(pbuf^,hashbuffer[index],size);
            inc(index,size);
            size:= 0;
        end;
    end;
end;
{---------------------------------}
 
function update_f(var sFileName:string):boolean;
var f:file;
    size :cardinal;
begin
    result := false;
    AssignFile(f, sFileName);
    FileMode := fmOpenRead;
    Reset(f, 1);
    if IOResult()<>0 then exit;
    size := FileSize(f);
    inc(lenhi,size shr 29); //Int64(lenhi,lenlo) := Int64(size) shl 3;
    inc(lenlo,size shl 3);
    if lenlo<(size shl 3) then inc(lenhi);
    while size>0 do begin
        if (size)>=(sizeof(hashbuffer)-index) then begin
            BlockRead(f,hashbuffer[index],sizeof(hashbuffer)-index);
            dec(size,sizeof(hashbuffer)-index);
            compress;
        end else begin
            BlockRead(f,hashbuffer[index],size);
            inc(index,size);
            size:= 0;
        end;
    end;
    CloseFile(f);
    result := true;
end;
 
{---------------------------------}
procedure final(var digest);
begin
    hashbuffer[index]:= $80;
    if index>= 56 then compress;
    pcardinal(@hashbuffer[56])^:= lenlo;
    pcardinal(@hashbuffer[60])^:= lenhi;
    compress;
    move(currenthash,digest,sizeof(currenthash));
    burn;
end;
{---------------------------------}
 
procedure md5(s:string; var Hash:TMD5);
begin
    init;
    update(s[1],length(s));
    final(a);
    Hash := a;
    burn;
end;
 
function md5(s:string):string;
var i:integer;
    m:TMD5;
begin
    md5(s,m);
    for i:=0 to 15 do
        result:=result+inttohex(m[i],2);
end;
 
function md5_file(sFileName:string; var Hash:TMD5):boolean;
begin
    result:=false;
    init;
    if (sFileName='') or (not update_f(sFileName)) then exit;
    final(a);
    Hash := a; 
    burn;
    result := true;
end;
 
function md5_file(sFileName:string):string;
var i:integer;
    m:TMD5;
begin
    if not md5_file(sFileName,m) then
        result := ''
    else
        for i:=0 to 15 do
            result:=result+inttohex(m[i],2);
end;
 
end.