unit Hash;

interface

const
// CALG_*
  //MAC: LongWord = $8005;
  //HMAC: LongWord = $8009;

  MD2: LongWord = $8001;
  MD4: LongWord = $8002;
  MD5: LongWord = $8003;

  SHA: LongWord = $8004;
  SHA1: LongWord = $8004;
  SHA256: LongWord = $800C;
  SHA384: LongWord = $800D;
  SHA512: LongWord = $800E;

  MD2_SIZE: byte = 16;
  MD4_SIZE: byte = 16;
  MD5_SIZE: byte = 16;

  SHA_SIZE: byte = 20;
  SHA1_SIZE: byte = 20;
  SHA256_SIZE: byte = 32;
  SHA384_SIZE: byte = 48;
  SHA512_SIZE: byte = 64;

procedure InitHash(Algorithm: LongWord; out hHash, {hKey,} hProv: LongWord);
procedure CalculateHash(Data: pointer; DataSize: LongWord; HashSize: LongWord; hHash: LongWord; var ResultHash: string);
procedure FreeHash(var hHash, {hKey,} hProv: LongWord);

function HashString(Data: string; Algorithm: LongWord; HashSize: LongWord): string;

procedure LoadFileToMemory(FilePath: PAnsiChar; out Size: LongWord; out FilePtr: pointer);
function HashFile(Path: string; Algorithm: LongWord; HashSize: LongWord): string;

implementation

const
  Advapi32 = 'Advapi32.dll';
  kernel32 = 'kernel32.dll';

  GENERIC_READ = LongWord($80000000);
  OPEN_EXISTING = 3;
  FILE_ATTRIBUTE_NORMAL = $00000080;

type
  PLPSTR = ^PAnsiChar;

  POverlapped = ^TOverlapped;
  _OVERLAPPED = record
    Internal: LongWord;
    InternalHigh: LongWord;
    Offset: LongWord;
    OffsetHigh: LongWord;
    hEvent: THandle;
  end;

  TOverlapped = _OVERLAPPED;

  PSecurityAttributes = ^TSecurityAttributes;
  _SECURITY_ATTRIBUTES = record
    nLength: LongWord;
    lpSecurityDescriptor: Pointer;
    bInheritHandle: LongBool;
  end;

  TSecurityAttributes = _SECURITY_ATTRIBUTES;

function CreateFile(lpFileName: PChar; dwDesiredAccess, dwShareMode: LongWord;
  lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: LongWord;
  hTemplateFile: THandle): THandle; stdcall; external kernel32 name 'CreateFileA';

function ReadFile(hFile: THandle; var Buffer; nNumberOfBytesToRead: LongWord;
  var lpNumberOfBytesRead: LongWord; lpOverlapped: POverlapped): LongBool; stdcall; external kernel32 name 'ReadFile';

function GetFileSize(hFile: THandle; lpFileSizeHigh: Pointer): LongWord; stdcall; external kernel32 name 'GetFileSize';

function CloseHandle(hObject: THandle): LongBool; stdcall; external kernel32 name 'CloseHandle';

//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH

function CryptAcquireContext(
                              out phProv: LongWord;
                              pszContainer: PAnsiChar;
                              pszProvider: PAnsiChar;
                              dwProvType: LongWord;
                              dwFlags: LongWord
                              ): LongBool; stdcall; external Advapi32 name 'CryptAcquireContextA';
{
function CryptGenKey(
                      hProv: THandle;
                      ALG_ID: LongWord;
                      dwFlags: LongWord;
                      out hKey: LongWord
                      ): LongBool; stdcall; external Advapi32 name 'CryptGenKey';
}
function CryptCreateHash(
                          hProv: THandle;
                          ALG_ID: LongWord;
                          hKey: THandle;
                          dwFlags: LongWord;
                          out hHash: THandle
                          ): LongBool; stdcall; external Advapi32 name 'CryptCreateHash';

function CryptHashData(
                        hHash: THandle;
                        pbData: pointer;
                        dwDataLen: LongWord;
                        dwFlags: LongWord
                        ): LongBool; stdcall; external Advapi32 name 'CryptHashData';

function CryptGetHashParam(
                            hHash: THandle;
                            dwParam: LongWord;
                            pbData: pointer;
                            var pbDataLen: LongWord;
                            dwFlags: LongWord
                            ): LongBool; stdcall; external Advapi32 name 'CryptGetHashParam';

//function CryptDestroyKey(hKey: THandle): LongBool; stdcall; external Advapi32 name 'CryptDestroyKey';
function CryptDestroyHash(hHash: THandle): LongBool; stdcall; external Advapi32 name 'CryptDestroyHash';
function CryptReleaseContext(hProv: THandle; dwFlags: LongWord): LongBool; stdcall; external Advapi32 name 'CryptReleaseContext';

const
  PROV_RSA_FULL: LongWord = 1;


//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH

//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH


function LowerCase(const S: string): string;
asm {Size = 134 Bytes}
  push    ebx
  push    edi
  push    esi
  test    eax, eax               {Test for S = NIL}
  mov     esi, eax               {@S}
  mov     edi, edx               {@Result}
  mov     eax, edx               {@Result}
  jz      @@Null                 {S = NIL}
  mov     edx, [esi-4]           {Length(S)}
  test    edx, edx
  je      @@Null                 {Length(S) = 0}
  mov     ebx, edx
  call    system.@LStrSetLength  {Create Result String}
  mov     edi, [edi]             {@Result}
  mov     eax, [esi+ebx-4]       {Convert the Last 4 Characters of String}
  mov     ecx, eax               {4 Original Bytes}
  or      eax, $80808080         {Set High Bit of each Byte}
  mov     edx, eax               {Comments Below apply to each Byte...}
  sub     eax, $5B5B5B5B         {Set High Bit if Original <= Ord('Z')}
  xor     edx, ecx               {80h if Original < 128 else 00h}
  or      eax, $80808080         {Set High Bit}
  sub     eax, $66666666         {Set High Bit if Original >= Ord('A')}
  and     eax, edx               {80h if Orig in 'A'..'Z' else 00h}
  shr     eax, 2                 {80h > 20h ('a'-'A')}
  add     ecx, eax               {Set Bit 5 if Original in 'A'..'Z'}
  mov     [edi+ebx-4], ecx
  sub     ebx, 1
  and     ebx, -4
  jmp     @@CheckDone
@@Null:
  pop     esi
  pop     edi
  pop     ebx
  jmp     System.@LStrClr
@@Loop:                          {Loop converting 4 Character per Loop}
  mov     eax, [esi+ebx]
  mov     ecx, eax               {4 Original Bytes}
  or      eax, $80808080         {Set High Bit of each Byte}
  mov     edx, eax               {Comments Below apply to each Byte...}
  sub     eax, $5B5B5B5B         {Set High Bit if Original <= Ord('Z')}
  xor     edx, ecx               {80h if Original < 128 else 00h}
  or      eax, $80808080         {Set High Bit}
  sub     eax, $66666666         {Set High Bit if Original >= Ord('A')}
  and     eax, edx               {80h if Orig in 'A'..'Z' else 00h}
  shr     eax, 2                 {80h > 20h ('a'-'A')}
  add     ecx, eax               {Set Bit 5 if Original in 'A'..'Z'}
  mov     [edi+ebx], ecx
@@CheckDone:
  sub     ebx, 4
  jnc     @@Loop
  pop     esi
  pop     edi
  pop     ebx
end;

procedure CvtInt;
{ IN:
    EAX:  The integer value to be converted to text
    ESI:  Ptr to the right-hand side of the output buffer:  LEA ESI, StrBuf[16]
    ECX:  Base for conversion: 0 for signed decimal, 10 or 16 for unsigned
    EDX:  Precision: zero padded minimum field width
  OUT:
    ESI:  Ptr to start of converted text (not start of buffer)
    ECX:  Length of converted text
}
asm
        OR      CL,CL
        JNZ     @CvtLoop
@C1:    OR      EAX,EAX
        JNS     @C2
        NEG     EAX
        CALL    @C2
        MOV     AL,'-'
        INC     ECX
        DEC     ESI
        MOV     [ESI],AL
        RET
@C2:    MOV     ECX,10

@CvtLoop:
        PUSH    EDX
        PUSH    ESI
@D1:    XOR     EDX,EDX
        DIV     ECX
        DEC     ESI
        ADD     DL,'0'
        CMP     DL,'0'+10
        JB      @D2
        ADD     DL,('A'-'0')-10
@D2:    MOV     [ESI],DL
        OR      EAX,EAX
        JNE     @D1
        POP     ECX
        POP     EDX
        SUB     ECX,ESI
        SUB     EDX,ECX
        JBE     @D5
        ADD     ECX,EDX
        MOV     AL,'0'
        SUB     ESI,EDX
        JMP     @z
@zloop: MOV     [ESI+EDX],AL
@z:     DEC     EDX
        JNZ     @zloop
        MOV     [ESI],AL
@D5:
end;

function IntToHex(Value: Integer; Digits: Integer): string;
//  FmtStr(Result, '%.*x', [Digits, Value]);
asm
        CMP     EDX, 32        // Digits < buffer length?
        JBE     @A1
        XOR     EDX, EDX
@A1:    PUSH    ESI
        MOV     ESI, ESP
        SUB     ESP, 32
        PUSH    ECX            // result ptr
        MOV     ECX, 16        // base 16     EDX = Digits = field width
        CALL    CvtInt
        MOV     EDX, ESI
        POP     EAX            // result ptr
        CALL    System.@LStrFromPCharLen
        ADD     ESP, 32
        POP     ESI
end;


//==============================================================================

procedure InitHash(Algorithm: LongWord; out hHash, {hKey,} hProv: LongWord);
begin
  CryptAcquireContext(hProv, nil, nil, PROV_RSA_FULL, $0);
  //CryptGenKey(hProv, Algorithm, 1024, hKey);
  CryptCreateHash(hProv, Algorithm, 0, 0, hHash);
end;

procedure CalculateHash(Data: pointer; DataSize: LongWord; HashSize: LongWord; hHash: LongWord; var ResultHash: string);
var
  pbData: array of byte;
  I: byte;
begin
  SetLength(pbData, HashSize);

  CryptHashData(hHash, Data, DataSize, 0);
  CryptGetHashParam(hHash, $2, @pbData[0], HashSize, 0);

  ResultHash := '';
  for I := 0 to HashSize - 1 do
  begin
    ResultHash := ResultHash + IntToHex(pbData[I], 2);
  end;
  ResultHash := LowerCase(ResultHash);
end;

procedure FreeHash(var hHash, {hKey,} hProv: LongWord);
begin
  CryptDestroyHash(hHash);
  //CryptDestroyKey(hKey);
  CryptReleaseContext(hProv, 0);

  asm
    xor eax, eax
    mov hHash, eax
    mov hProv, eax
  end;
end;

//==============================================================================

function HashString(Data: string; Algorithm: LongWord; HashSize: LongWord): string;
var
  hProv: LongWord;
  hHash: LongWord;
begin
  InitHash(Algorithm, hHash, hProv);
  Result := '';
  CalculateHash(@Data[1], Length(Data), HashSize, hHash, Result);
  FreeHash(hHash, hProv);
end;

procedure LoadFileToMemory(FilePath: PAnsiChar; out Size: LongWord; out FilePtr: pointer);
var
  hFile: THandle;
  BytesRead: LongWord;
begin
  hFile := CreateFile(
                       FilePath,
                       GENERIC_READ,
                       0,
                       nil,
                       OPEN_EXISTING,
                       FILE_ATTRIBUTE_NORMAL,
                       0
                      );


  Size := GetFileSize(hFile, nil);
  GetMem(FilePtr, Size);
  ReadFile(hFile, FilePtr^, Size, BytesRead, nil);
  CloseHandle(hFile);
end;

function HashFile(Path: string; Algorithm: LongWord; HashSize: LongWord): string;
var
  Buffer: pointer;
  Size: LongWord;
  hHash, hProv: LongWord;
begin
  LoadFileToMemory(@Path[1], Size, Buffer);
  InitHash(Algorithm, hHash, hProv);
  CalculateHash(Buffer, Size, HashSize, hHash, Result);
  FreeHash(hHash, hProv);
  FreeMem(Buffer);
end;

end.
