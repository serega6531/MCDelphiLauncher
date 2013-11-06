unit Perimeter;

interface

procedure InitPerimeter(ResistanceType: byte; MainFormHandle: THandle; Interval: integer; Preventive: boolean);
procedure StopPerimeter;
procedure Emulate(Debugger: boolean; Breakpoint: boolean);

type
  HWND = LongWord;
  DWORD = LongWord;

// Структуры с отладочной информацией
type
  TFunctionInfo = record
    Address: pointer;
    Size: DWORD;
    Checksum: DWORD;
    ValidChecksum: DWORD;
  end;

  TFunctions = record
    Main: TFunctionInfo;
    Init: TFunctionInfo;
    Stop: TFunctionInfo;
  end;

  TASMInfo = record
    Value: DWORD;
    IsDebuggerExists: boolean;
  end;

  TDebugInfo = record
    PrivilegesActivated: boolean;
    PreventiveProcessesExists: boolean;
    IsDebuggerPresent: boolean;
    RDTSC_Debugger: TASMInfo;
    Asm_A: TASMInfo;
    Asm_B: TASMInfo;
    Asm_C: TASMInfo;
    ROMFailure: boolean;
  end;

type
  TPerimeterInfo = record
    Functions: TFunctions;
    Debug: TDebugInfo;
  end;

var
  PerimeterInfo: TPerimeterInfo;


implementation

{$R SOUNDS.RES}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
{                                    WINDOWS                                    }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}

const
  ntdll = 'ntdll.dll';
  kernel32 = 'kernel32.dll';
  user32 = 'user32.dll';
  winmm = 'winmm.dll';
  advapi32 = 'advapi32.dll';

const
  VER_PLATFORM_WIN32_NT = 2;
  TOKEN_ADJUST_PRIVILEGES = $0020;
  TOKEN_QUERY = $0008;
  SE_PRIVILEGE_ENABLED = $00000002;
  ERROR_SUCCESS = 0;
  MB_ICONERROR = $00000010;

  STANDARD_RIGHTS_REQUIRED = $000F0000;
  SYNCHRONIZE = $00100000;
  PROCESS_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or $FFF);

  THREAD_PRIORITY_TIME_CRITICAL = 15;

type
  WPARAM = Longint;
  LPARAM = Longint;
  UINT = LongWord;
  BOOL = LongBool;
  TLargeInteger = Int64;
  LPCSTR = PAnsiChar;
  FARPROC = Pointer;
  PULONG = ^Cardinal;

  _LUID_AND_ATTRIBUTES = packed record
    Luid: Int64;
    Attributes: DWORD;
  end;
  TLUIDAndAttributes = _LUID_AND_ATTRIBUTES;

  _TOKEN_PRIVILEGES = record
    PrivilegeCount: DWORD;
    Privileges: array [0..0] of TLUIDAndAttributes;
  end;
  TTokenPrivileges = _TOKEN_PRIVILEGES;
  TOKEN_PRIVILEGES = _TOKEN_PRIVILEGES;

function TerminateProcess(hProcess: THandle; uExitCode: UINT): BOOL; stdcall; external kernel32 name 'TerminateProcess';
function OpenProcess(dwDesiredAccess: DWORD; bInheritHandle: BOOL; dwProcessId: DWORD): THandle; stdcall; external kernel32 name 'OpenProcess';
function OpenProcessToken(ProcessHandle: THandle; DesiredAccess: DWORD; var TokenHandle: THandle): BOOL; stdcall; external advapi32 name 'OpenProcessToken';
function GetCurrentProcess: THandle; stdcall; external kernel32 name 'GetCurrentProcess';
function CloseHandle(hObject: THandle): BOOL; stdcall; external kernel32 name 'CloseHandle';

function LookupPrivilegeValue(lpSystemName, lpName: PChar; var lpLuid: Int64): BOOL; stdcall; external advapi32 name 'LookupPrivilegeValueA';

function AdjustTokenPrivileges(TokenHandle: THandle; DisableAllPrivileges: BOOL;
  const NewState: TTokenPrivileges; BufferLength: DWORD;
  var PreviousState: TTokenPrivileges; var ReturnLength: DWORD): BOOL; stdcall; external advapi32 name 'AdjustTokenPrivileges';

function GetCurrentThreadId: DWORD; stdcall; external kernel32 name 'GetCurrentThreadId';
function SetThreadAffinityMask(hThread: THandle; dwThreadAffinityMask: DWORD): DWORD; stdcall; external kernel32 name 'SetThreadAffinityMask';
function SetThreadPriority(hThread: THandle; nPriority: Integer): BOOL; stdcall; external kernel32 name 'SetThreadPriority';

function ReadProcessMemory(hProcess: THandle; const lpBaseAddress: Pointer; lpBuffer: Pointer;
  nSize: DWORD; var lpNumberOfBytesRead: DWORD): BOOL; stdcall; external kernel32 name 'ReadProcessMemory';

function GetModuleHandle(lpModuleName: PChar): HMODULE; stdcall; external kernel32 name 'GetModuleHandleA';
function LoadLibrary(lpLibFileName: PChar): HMODULE; stdcall; external kernel32 name 'LoadLibraryA';
function GetProcAddress(hModule: HMODULE; lpProcName: LPCSTR): FARPROC; stdcall; external kernel32 name 'GetProcAddress';
function GetWindowThreadProcessId(hWnd: HWND; dwProcessId: pointer): DWORD; stdcall; external user32 name 'GetWindowThreadProcessId';
function GetCurrentThread: THandle; stdcall; external kernel32 name 'GetCurrentThread';

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
{                                END OF WINDOWS                                 }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
{                                   TLHELP32                                    }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}

const
  TH32CS_SNAPPROCESS  = $00000002;
  MAX_PATH = 260;

type
  tagPROCESSENTRY32 = packed record
    dwSize: DWORD;
    cntUsage: DWORD;
    th32ProcessID: DWORD;       
    th32DefaultHeapID: DWORD;
    th32ModuleID: DWORD;        
    cntThreads: DWORD;
    th32ParentProcessID: DWORD; 
    pcPriClassBase: Longint;    
    dwFlags: DWORD;
    szExeFile: array[0..MAX_PATH - 1] of Char;
  end;
  TProcessEntry32 = tagPROCESSENTRY32;

function CreateToolhelp32Snapshot(dwFlags, th32ProcessID: DWORD): THandle; stdcall; external kernel32 name 'CreateToolhelp32Snapshot';
function Process32First(hSnapshot: THandle; var lppe: TProcessEntry32): BOOL; stdcall; external kernel32 name 'Process32First';
function Process32Next(hSnapshot: THandle; var lppe: TProcessEntry32): BOOL; stdcall; external kernel32 name 'Process32Next';

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
{                               END OF TLHELP32                                 }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
{                                   SYSUTILS                                    }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}

const
  Win32Platform: Integer = 0;

// Переписанный и упрощённый ExtractFileName:
function ExtractFileName(const FileName: string): string;
var
  I: integer;
  Len: integer;
  DelimiterPos: integer;
begin
  Result := '';
  Len := Length(FileName);

  if FileName[1] = '\' then
    DelimiterPos := 1
  else
    DelimiterPos := 0;

  for I := Len downto 1 do
  begin
    if FileName[I] = '\' then
    begin
      DelimiterPos := I;
      Break;
    end;
  end;

  inc(DelimiterPos);

  if DelimiterPos = 1 then
  begin
    Result := FileName;
  end
  else
  begin
    for I := DelimiterPos to Len do
    begin
      Result := Result + FileName[I];
    end;
  end;
end;

// Оригинальный UpperCase от FastCode с комментариями:
function UpperCase(const S: string): string;
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
  sub     eax, $7B7B7B7B         {Set High Bit if Original <= Ord('z')}
  xor     edx, ecx               {80h if Original < 128 else 00h}
  or      eax, $80808080         {Set High Bit}
  sub     eax, $66666666         {Set High Bit if Original >= Ord('a')}
  and     eax, edx               {80h if Orig in 'a'..'z' else 00h}
  shr     eax, 2                 {80h > 20h ('a'-'A')}
  sub     ecx, eax               {Clear Bit 5 if Original in 'a'..'z'}
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
  sub     eax, $7B7B7B7B         {Set High Bit if Original <= Ord('z')}
  xor     edx, ecx               {80h if Original < 128 else 00h}
  or      eax, $80808080         {Set High Bit}
  sub     eax, $66666666         {Set High Bit if Original >= Ord('a')}
  and     eax, edx               {80h if Orig in 'a'..'z' else 00h}
  shr     eax, 2                 {80h > 20h ('a'-'A')}
  sub     ecx, eax               {Clear Bit 5 if Original in 'a'..'z'}
  mov     [edi+ebx], ecx
@@CheckDone:
  sub     ebx, 4
  jnc     @@Loop
  pop     esi
  pop     edi
  pop     ebx
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
{                               END OF SYSUTILS                                 }
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}

const
  ValidInitCRC: DWORD = $6A57733D;
  ValidStopCRC: DWORD = $F0773159;
  ValidMainCRC: DWORD = $D878D611;

const
  Delta: single = 0.5; // Допуск по времени

const
  SE_SHUTDOWN_NAME = 'SeShutdownPrivilege'; // привилегия, необходимая для
                                            // выполнения функций BSOD и
                                            // отключения питания

// Список параметров для первого способа выключения питания
type SHUTDOWN_ACTION = (
                         ShutdownNoReboot,
                         ShutdownReboot,
                         ShutdownPowerOff
                         );

// Список ВХОДНЫХ опций для функции BSOD'a: для генерации синего экрана
// нужна последняя (OptionShutdownSystem). Если в вызове функции указать не её, а другую -
// будет сгенерирован MessageBox с сообщением об ошибке, код которой
// будет указан первым параметром этой функции.
type HARDERROR_RESPONSE_OPTION = (
                                  OptionAbortRetryIgnore,
                                  OptionOk,
                                  OptionOkCancel,
                                  OptionRetryCancel,
                                  OptionYesNo,
                                  OptionYesNoCancel,
                                  OptionShutdownSystem
                                  );

// Список ВЫХОДНЫХ опций для функции BSOD'a:
type HARDERROR_RESPONSE = (
                            ResponseReturnToCaller,
                            ResponseNotHandled,
                            ResponseAbort,
                            ResponseCancel,
                            ResponseIgnore,
                            ResponseNo,
                            ResponseOk,
                            ResponseRetry,
                            ResponseYes
                           );


type
  PSYSTEM_HANDLE_INFORMATION = ^SYSTEM_HANDLE_INFORMATION;
  SYSTEM_HANDLE_INFORMATION = packed record
    ProcessId: DWORD;
    ObjectTypeNumber: Byte;
    Flags: Byte;
    Handle: Word;
    pObject: Pointer;
    GrantedAccess: DWORD;
  end;

type
  PSYSTEM_HANDLE_INFORMATION_EX = ^SYSTEM_HANDLE_INFORMATION_EX;
  SYSTEM_HANDLE_INFORMATION_EX = packed record
    NumberOfHandles: dword;
    Information: array [0..0] of SYSTEM_HANDLE_INFORMATION;
  end;

type // Объявление типов из NTDDK
  POWER_ACTION = integer;
  SYSTEM_POWER_STATE = integer;
  ULONG = cardinal;
  NTStatus = DWORD;
  PVoid = pointer;

const // Номера ошибок, с которыми вызывается синий экран.
  TRUST_FAILURE = $C0000250;
  LOGON_FAILURE = $C000006C;
  HOST_DOWN = $C0000350;
  FAILED_DRIVER_ENTRY = $C0000365;
  NT_SERVER_UNAVAILABLE = $C0020017;
  NT_CALL_FAILED = $C002001B;
  CLUSTER_POISONED = $C0130017;

const // Создаём массив из кодов ошибок чтобы удобнее было ими оперировать
  ErrorCode: array [0..6] of DWORD =    (
                                          TRUST_FAILURE,
                                          LOGON_FAILURE,
                                          HOST_DOWN,
                                          FAILED_DRIVER_ENTRY,
                                          NT_SERVER_UNAVAILABLE,
                                          NT_CALL_FAILED,
                                          CLUSTER_POISONED
                                          );

// Делаем заготовки для импортируемых функций и пишем вспомогательные переменные:
var
  // 1й способ отключения питания:
  NTShutdownSystem: procedure (Action: SHUTDOWN_ACTION); stdcall;

  // 2й способ отключения питания:
  NTInitiatePowerAction: procedure (
                                     SystemAction: POWER_ACTION;
                                     MinSystemState: SYSTEM_POWER_STATE;
                                     Flags: ULONG;
                                     Asynchronous: BOOL
                                                        ); stdcall;

  // BSOD:
  HR: HARDERROR_RESPONSE;
  NtRaiseHardError: procedure (
                                ErrorStatus: NTStatus;
                                NumberOfParameters: ULong;
                                UnicodeStringParameterMask: PChar;
                                Parameters: PVoid;
                                ResponseOption: HARDERROR_RESPONSE_OPTION;
                                PHardError_Response: pointer
                                                             ); stdcall;

  // Завершение процесса из ядра
  LdrShutdownProcess: procedure; stdcall;

  //  Отключение клавиатуры и мыши:
  BlockInput: function (Block: BOOL): BOOL; stdcall;

  // Проверка наличия отладчика:
  IsDebuggerPresent: function: boolean; stdcall;
  OutputDebugStringA: procedure (lpOutputString: string); stdcall;

  ZwSetInformationThread: procedure; stdcall;


  // Маскируем стандартные функции, используем "ручной" вызов:
  MsgBox: procedure (hWnd: HWND; lpText: PAnsiChar; lpCaption: PAnsiChar; uType: Cardinal); stdcall;
  PlaySound: procedure (pszSound: string; hMod: HModule; fdwSound: DWORD); stdcall;
  QueryPerformanceFrequency: procedure (var lpFrequency: Int64); stdcall;
  QueryPerformanceCounter: procedure (var lpPerformanceCount: Int64); stdcall;
  SendMessage: procedure (hWnd: HWND; Msg: LongWord; wParam: WPARAM; lParam: LPARAM); stdcall;
  Sleep: procedure (SuspendTime: DWORD); stdcall;
  OpenThread: function (dwDesiredAccess: DWORD; bInheritHandle: boolean; dwThreadId: DWORD): THandle; stdcall;

// Константы названий процессов для уничтожения:
const
  Debuggers: array [0..1] of string = (
                                         'ollydbg.exe',
                                         'idaq.exe'
                                                       );

  AdditionalProcesses: array [0..1] of string = (
                                                   'java.exe',
                                                   'javaw.exe'
                                                                );

  Csrss: string = 'csrss.exe';
  Smss: string = 'smss.exe';

// Имена библиотек и вызываемых функций:
const
  // Из ntdll:
  sNTRaiseHardError: PAnsiChar = 'ZwRaiseHardError';
  sNTShutdownSystem: PAnsiChar = 'ZwShutdownSystem';
  sNTInitiatePowerAction: PAnsiChar = 'ZwInitiatePowerAction';
  sLdrShutdownProcess: PAnsiChar = 'LdrShutdownProcess';
  sZwSetInformationThread: PAnsiChar = 'ZwSetInformationThread';

  // Из kernel32:
  sIsDebuggerPresent: PAnsiChar = 'IsDebuggerPresent';
  sQueryPerformanceFrequency: PAnsiChar = 'QueryPerformanceFrequency';
  sQueryPerformanceCounter: PAnsiChar = 'QueryPerformanceCounter';
  sSleep: PAnsiChar = 'Sleep';
  sOutputDebugStringA: PAnsiChar = 'OutputDebugStringA';
  sOpenThread: PAnsiChar = 'OpenThread';

  // Из user32:
  sMessageBox: PAnsiChar = 'MessageBoxA';
  sBlockInput: PAnsiChar = 'BlockInput';
  sSendMessage: PAnsiChar = 'SendMessageA';

  // Из winmm:
  sPlaySound: PAnsiChar = 'PlaySoundA';

  SND_RESOURCE        = $00040004;
  SND_LOOP            = $0008;
  SND_ASYNC           = $0001;

// Константы механизма противодействия:
const
  Nothing = 0;
  KillProcesses = 1;
  Notify = 2;
  BlockIO = 4;
  ShutdownPrimary = 8;
  ShutdownSecondary = 16;
  GenerateBSOD = 32;
  HardBSOD = 64;

// Рабочие переменные:
var
  TypeOfResistance: byte;

  ThreadID: DWORD;
  ThreadHandle: integer;
  FormHandle: THandle; // Хэндл формы, которой будут посылаться сообщения
  Active: boolean = false;
  Delay: integer;
  IsPrevented: boolean;

// Переменные эмуляции отладчика и брейкпоинта:
  EmuDebugger: boolean = false;
  EmuBreakpoint: boolean = false;

// Переменные сканирования памяти:
  Process: THandle;
  InitAddress, StopAddress, MainAddress: pointer;
  InitSize, StopSize, MainSize: integer;


var
  CRCtable: array[0..255] of cardinal;

function CRC32(InitCRC32: cardinal; StPtr: pointer; StLen: integer): cardinal;
asm
  test edx,edx;
  jz @ret;
  neg ecx;
  jz @ret;
  sub edx,ecx;

  push ebx;
  mov ebx,0;
@next:
  mov bl,al;
  xor bl,byte [edx+ecx];
  shr eax,8;
  xor eax,cardinal [CRCtable+ebx*4];
  inc ecx;
  jnz @next;
  pop ebx;
  xor eax, $FFFFFFFF
@ret:
end;

procedure CRCInit;
var
  c: cardinal;
  i, j: integer;
begin
  for i := 0 to 255 do
  begin
    c := i;
    for j := 1 to 8 do
      if odd(c) then
        c := (c shr 1) xor $EDB88320
      else
        c := (c shr 1);
    CRCtable[i] := c;
  end;
end;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}

function IsProcLaunched(ProcessName: string): boolean;
var
  hSnap: THandle;
  PE: TProcessEntry32;
begin
  Result := false;
  PE.dwSize := SizeOf(PE);
  hSnap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Process32First(hSnap, PE) then
  begin
    if PE.szExeFile = ProcessName then
    begin
      Result := true;
    end
    else
    begin
      while Process32Next(hSnap, PE) do
      begin
        if PE.szExeFile = ProcessName then
        begin
          Result := true;
          Break;
        end;
      end;
    end;
  end;
end;

// Функция, убивающая процесс по его имени:
function KillTask(ExeFileName: string): integer;
const
  PROCESS_TERMINATE = $0001;
var
  Co: BOOL;
  FS: THandle;
  FP: TProcessEntry32;
begin
  result := 0;
  FS := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
  FP.dwSize := Sizeof(FP);
  Co := Process32First(FS,FP);

  while integer(Co) <> 0 do
    begin
      if
          ((UpperCase(ExtractFileName(FP.szExeFile)) = UpperCase(ExeFileName))
        or
          (UpperCase(FP.szExeFile) = UpperCase(ExeFileName)))
      then
      begin
        Result := Integer(TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), FP.th32ProcessID), 0));
      end;
      Co := Process32Next(FS, FP);
    end;
  CloseHandle(FS);
end;

// Функция, изменяющая привилегии процесса:
function NTSetPrivilege(sPrivilege: string; bEnabled: Boolean): Boolean;
var
  hToken: THandle;
  TokenPriv: TOKEN_PRIVILEGES;
  PrevTokenPriv: TOKEN_PRIVILEGES;
  ReturnLength: Cardinal;
begin
  Result := True;
  if not (Win32Platform = VER_PLATFORM_WIN32_NT) then Exit;

  if OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
  begin
    try

      if LookupPrivilegeValue(nil, PChar(sPrivilege), TokenPriv.Privileges[0].Luid) then
      begin
        TokenPriv.PrivilegeCount := 1;
        case bEnabled of
          True: TokenPriv.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
          False: TokenPriv.Privileges[0].Attributes := 0;
        end;
        ReturnLength := 0;
        PrevTokenPriv := TokenPriv;
        AdjustTokenPrivileges(hToken, False, TokenPriv, SizeOf(PrevTokenPriv),
        PrevTokenPriv, ReturnLength);
      end;
    finally
      CloseHandle(hToken);
    end;
  end;
  Result := GetLastError = ERROR_SUCCESS;
end;


// Основной поток: проверка на наличие отладчика, проверка на брейкпоинты
procedure MainThread;
const
  DebuggerMsg: byte = 0;
  BreakpointMsg: byte = 1;

var
  MessageType: byte; // Тип текста в оповещении:
                     // 0 = Отладчик
                     // 1 = Брейкпоинт
                     // 2 = Несовпадение контрольных сумм
  ProcLength: byte;

  procedure EliminateThreat;
  var
    NotifyMessage: PAnsiChar;
    CaptionMessage: PAnsiChar;
    BSODErrorCode: byte;
    I: byte;
    AdditionalLength: byte;
  begin
    // Убиваем процессы:
    if (TypeOfResistance and KillProcesses) = KillProcesses then
    begin
      for I := 0 to ProcLength do
      begin
        KillTask(Debuggers[I]);
      end;

      AdditionalLength := Length(AdditionalProcesses);
      Dec(AdditionalLength);

      for I := 0 to AdditionalLength do
      begin
        KillTask(AdditionalProcesses[I]);
      end;  
    end;

    // Выводим сообщение и закрываем программу:
    if (TypeOfResistance and Notify) = Notify then
    begin
      PlaySound('ALERT', 0, SND_RESOURCE or SND_ASYNC or SND_LOOP);

      CaptionMessage := 'Угроза внутренней безопасности!';
      NotifyMessage := 'Внутренняя ошибка! Продолжение невозможно!';
      case MessageType of
        0: NotifyMessage := 'Обнаружен отладчик! Продолжение невозможно!';
        1: NotifyMessage := 'Обнаружен брейкпоинт! Продолжение невозможно!';
        2:
          begin
            NotifyMessage := 'ROM damaged!';
            CaptionMessage := 'System Failure';
          end;
      end;
      MsgBox(FormHandle, NotifyMessage, CaptionMessage, MB_ICONERROR);
      LdrShutdownProcess;
    end;

    // Блокируем клавиатуру и мышь:
    if (TypeOfResistance and BlockIO) = BlockIO then
    begin
      BlockInput(true);
    end;

    // Выключаем питание первым способом:
    if (TypeOfResistance and ShutdownPrimary) = ShutdownPrimary then
    begin
      NtShutdownSystem(SHUTDOWN_ACTION(0));
    end;

    // Выключаем питание вторым способом:
    if (TypeOfResistance and ShutdownSecondary) = ShutdownSecondary then
    begin
      NTInitiatePowerAction(4, 6, 0, true);
    end;

    // Выводим BSOD:
    if (TypeOfResistance and GenerateBSOD) = GenerateBSOD then
    begin
      BSODErrorCode := Random(6);
      NtRaiseHardError(ErrorCode[BSODErrorCode], 0, nil, nil, HARDERROR_RESPONSE_OPTION(6), @HR);
    end;

    // Тяжёлый BSOD - убиваем csrss.exe и smss.exe
    if (TypeOfResistance and HardBSOD) = HardBSOD then
    begin
      KillTask(Csrss);
      KillTask(Smss);
    end;
  end;

var
  iCounterPerSec: TLargeInteger;
  T1, T2: TLargeInteger;
  ElapsedTime: single;

  DebuggerState, BreakpointState: byte;

// Для проверки памяти:
  Buffer: array [0..4095] of byte;
  ByteReaded: Cardinal;

// Список процессов:
  IsProcExists: boolean;
  I: byte;

// Отладочные переменные:
  FullState: boolean;

// Перенос на отдельное ядро:
  ThreadID: DWORD;
  ThreadHandle: THandle;

// Проверка на отладчик через RDTSC:
  Timer: DWORD;
  FirstIteration: boolean;

const
  DbgString: string = '"PLLDS" - Веха #1';

begin
// Выполняем на нулевом ядре:
  ThreadID := GetCurrentThreadId;
  ThreadHandle := OpenThread(PROCESS_ALL_ACCESS, false, ThreadId);
  SetThreadAffinityMask(ThreadHandle, 1);

// Задаём максимальный приоритет потока:
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);

  QueryPerformanceFrequency(iCounterPerSec);

  ProcLength := Length(Debuggers) - 1;

  // DebuggerState := $0D // не инициализируем, т.к. он инициализируется в первом условии
  BreakpointState := $0B;

  IsProcExists := false;

  FirstIteration := true; // Первый прогон вхолостую для разогрева CPU

  while Active do
  begin
    asm
      rdtsc
      mov Timer, eax

      lea eax, [PerimeterInfo]
      prefetchnta [eax]
    end;

    QueryPerformanceCounter(T1);

    if IsPrevented = true then
    begin
      IsProcExists := false;
      for I := 0 to ProcLength do
      begin
        IsProcExists := IsProcExists or IsProcLaunched(Debuggers[I]);
      end;
      PerimeterInfo.Debug.PreventiveProcessesExists := IsProcExists;
    end;

    ReadProcessMemory(Process, InitAddress, @Buffer, InitSize, ByteReaded);
    PerimeterInfo.Functions.Init.Checksum := CRC32($FFFFFFFF, @Buffer, ByteReaded);

    ReadProcessMemory(Process, StopAddress, @Buffer, StopSize, ByteReaded);
    PerimeterInfo.Functions.Stop.Checksum := CRC32($FFFFFFFF, @Buffer, ByteReaded);

    ReadProcessMemory(Process, MainAddress, @Buffer, MainSize, ByteReaded);
    PerimeterInfo.Functions.Main.Checksum := CRC32($FFFFFFFF, @Buffer, ByteReaded);

    if (PerimeterInfo.Functions.Main.Checksum <> ValidMainCRC) or
       (PerimeterInfo.Functions.Init.Checksum <> ValidInitCRC) or
       (PerimeterInfo.Functions.Stop.Checksum <> ValidStopCRC)
    then
    begin
      PerimeterInfo.Debug.ROMFailure := true;
    end
    else
    begin
      PerimeterInfo.Debug.ROMFailure := false;
    end;

    asm
    // Anti-Debugging A:
      mov eax, fs:[30h]
      mov eax, [eax+2]
      add eax, 65536
      mov PerimeterInfo.Debug.Asm_A.Value, eax
      test eax, eax
      jnz @A_Debugger

      mov PerimeterInfo.Debug.Asm_A.IsDebuggerExists, false
      jmp @Continue_A

@A_Debugger:
      mov PerimeterInfo.Debug.Asm_A.IsDebuggerExists, true

@Continue_A:

    // Anti-Debugging B:
      mov eax, fs:[30h]
      mov eax, [eax+68h]
      mov PerimeterInfo.Debug.Asm_B.Value, eax
      and eax, 70h
      test eax, eax
      jnz @B_Debugger

      mov PerimeterInfo.Debug.Asm_B.IsDebuggerExists, false
      jmp @Continue_B

@B_Debugger:
      mov PerimeterInfo.Debug.Asm_B.IsDebuggerExists, true

@Continue_B:

    // Anti-Debugging C:

      xor eax, eax
      push offset DbgString
      call OutputDebugStringA
      mov PerimeterInfo.Debug.Asm_C.Value, eax

      // Если IsPrevented = true, надо отнимать 18
      // Если IsPrevented = false, надо отнимать 87
      cmp IsPrevented, true
      je @IsPrevented
      sub eax, 87
      jmp @@Continue

@IsPrevented:
      sub eax, 18

@@Continue:
      test eax, eax
      jnz @C_Debugger

      mov PerimeterInfo.Debug.Asm_C.IsDebuggerExists, false
      jmp @Continue_C

@C_Debugger:
      mov PerimeterInfo.Debug.Asm_C.IsDebuggerExists, true

@Continue_C:

      push 0
      push 0
      push 11h
      push -2
      call ZwSetInformationThread

      rdtsc
      sub eax, Timer

      cmp FirstIteration, false
      jne @FirstIteration

      mov PerimeterInfo.Debug.RDTSC_Debugger.Value, eax
      cmp IsPrevented, false
      jne @IsPreventedTSC

      cmp   eax, 50000000d
      jmp @TSCDecision

@IsPreventedTSC:
      cmp   eax, 150000000d

@TSCDecision:
      jnbe  @RDTSC_Debugger

@FirstIteration:
      mov PerimeterInfo.Debug.RDTSC_Debugger.IsDebuggerExists, false
      jmp @Exit

@RDTSC_Debugger:
      mov PerimeterInfo.Debug.RDTSC_Debugger.IsDebuggerExists, true

@Exit:
    end;

    with PerimeterInfo.Debug do
    begin
      FullState := Asm_A.IsDebuggerExists or
                   Asm_B.IsDebuggerExists or
                   Asm_C.IsDebuggerExists or
                   RDTSC_Debugger.IsDebuggerExists;
    end;

    PerimeterInfo.Debug.IsDebuggerPresent := IsDebuggerPresent;

    if (PerimeterInfo.Debug.IsDebuggerPresent = true) or
       (EmuDebugger = true) or
       ((IsProcExists = true) and (IsPrevented = true)) or
       (FullState = true) or
       (PerimeterInfo.Debug.ROMFailure = true)
    then
    begin
      if EmuDebugger = false then
      begin
        DebuggerState := $FD;
      end
      else
      begin
        DebuggerState := $ED;
      end;

      SendMessage(FormHandle, $FFF, DebuggerState, BreakpointState);

      if PerimeterInfo.Debug.ROMFailure = true then
        MessageType := 2
      else
        MessageType := 0;

      EliminateThreat;
    end
    else
    begin
      DebuggerState := $0D;
      SendMessage(FormHandle, $FFF, DebuggerState, BreakpointState);
    end;

    sleep(Delay);

    QueryPerformanceCounter(T2);
    ElapsedTime := (T2 - T1) / iCounterPerSec;

    if (ElapsedTime > Delay + Delta) or (EmuBreakpoint = true) or (ElapsedTime <= 0) then
    begin
      if EmuBreakpoint = false then
      begin
        BreakpointState := $FB;
      end
      else
      begin
        BreakpointState := $EB;
      end;

      SendMessage(FormHandle, $FFF, DebuggerState, BreakpointState);
      MessageType := 1;
      EliminateThreat
    end
    else
    begin
      BreakpointState := $0B;
      SendMessage(FormHandle, $FFF, DebuggerState, BreakpointState);
    end;

    FirstIteration := false;
  end;

// Посылаем сообщение о завершении работы:
  SendMessage(FormHandle, $FFF, $00, $00);

// Чистим память от адресов функций:
  asm
    xor eax, eax

    mov IsDebuggerPresent, eax;
    mov BlockInput, eax;
    mov NTRaiseHardError, eax;
    mov NTShutdownSystem, eax;
    mov NTInitiatePowerAction, eax;
    mov LdrShutdownProcess, eax;
    mov ZwSetInformationThread, eax;

    mov OutputDebugStringA, eax;
    mov OpenThread, eax;

    mov MsgBox, eax;

    mov QueryPerformanceCounter, eax;
    mov QueryPerformanceFrequency, eax;

    mov PlaySound, eax;
    mov Sleep, eax;

    mov SendMessage, eax;
  end;

  EndThread(0);
end;


procedure InitPerimeter(ResistanceType: byte; MainFormHandle: THandle; Interval: integer; Preventive: boolean);
var
  hUser32: THandle;
  hKernel32: THandle;
  hNtdll: THandle;
  hWinMM: THandle;

// Переменные для инициализации основного процесса:
  ProcessID: DWORD;
  InitInt, StopInt, EmulateInt, MainInt: integer;
  EmulateAddress: pointer;

begin
  CRCInit;

// Получаем хэндлы библиотек:
  hUser32 := GetModuleHandle(user32);
  hKernel32 := GetModuleHandle(kernel32);
  hNtdll := GetModuleHandle(ntdll);
  hWinMM := LoadLibrary(winmm);

// Получаем адреса функций в библиотеках:
  // kernel32:
  IsDebuggerPresent := GetProcAddress(hKernel32, sIsDebuggerPresent);
  QueryPerformanceFrequency := GetProcAddress(hKernel32, sQueryPerformanceFrequency);
  QueryPerformanceCounter := GetProcAddress(hKernel32, sQueryPerformanceCounter);
  Sleep := GetProcAddress(hKernel32, sSleep);
  OutputDebugStringA := GetProcAddress(hKernel32, sOutputDebugStringA);
  OpenThread := GetProcAddress(hKernel32, sOpenThread);

  // user32:
  BlockInput := GetProcAddress(hUser32, sBlockInput);
  MsgBox := GetProcAddress(hUser32, sMessageBox);
  SendMessage := GetProcAddress(hUser32, sSendMessage);

  // winmm:
  PlaySound := GetProcAddress(hWinMM, sPlaySound);

  // ntdll:
  NTRaiseHardError := GetProcAddress(hNtdll, sNtRaiseHardError);
  NTShutdownSystem := GetProcAddress(hNtdll, sNtShutdownSystem);
  NTInitiatePowerAction := GetProcAddress(hNtdll, sNtInitiatePowerAction);
  LdrShutdownProcess := GetProcAddress(hNtdll, sLdrShutdownProcess);
  ZwSetInformationThread := GetProcAddress(hNtdll, sZwSetInformationThread);

// Присваиваем процессу привилегию SE_SHUTDOWN_NAME:
  PerimeterInfo.Debug.PrivilegesActivated := NTSetPrivilege(SE_SHUTDOWN_NAME, true);

// Инициализируем наш процесс для возможности чтения памяти:
  GetWindowThreadProcessID(MainFormHandle, @ProcessID);
  Process := OpenProcess(PROCESS_ALL_ACCESS, FALSE, ProcessID);

// Получаем адреса и размеры функций:
  InitAddress := @InitPerimeter;
  StopAddress := @StopPerimeter;
  EmulateAddress := @Emulate;
  MainAddress := @KillTask;

  InitInt := Integer(InitAddress);
  StopInt := Integer(StopAddress);
  EmulateInt := Integer(EmulateAddress);
  MainInt := Integer(MainAddress);

  InitSize := StopInt - InitInt;
  StopSize := EmulateInt - StopInt;
  MainSize := InitInt - MainInt;

  PerimeterInfo.Functions.Main.Address := MainAddress;
  PerimeterInfo.Functions.Main.Size := MainSize;
  PerimeterInfo.Functions.Main.ValidChecksum := ValidMainCRC;

  PerimeterInfo.Functions.Init.Address := InitAddress;
  PerimeterInfo.Functions.Init.Size := InitSize;
  PerimeterInfo.Functions.Init.ValidChecksum := ValidInitCRC;

  PerimeterInfo.Functions.Stop.Address := StopAddress;
  PerimeterInfo.Functions.Stop.Size := StopSize;
  PerimeterInfo.Functions.Stop.ValidChecksum := ValidStopCRC;

// Сбрасываем генератор псевдослучайных чисел:
  Randomize;

// Получаем директивы противодействия:
  TypeOfResistance := ResistanceType;

// Получаем интервал между сканированием:
  Delay := Interval;

// Запускаем защиту:
  Active := true;
  FormHandle := MainFormHandle;

// Убеждаемся в выключении эмуляции:
  //EmuDebugger := false;
  //EmuBreakpoint := false;

  IsPrevented := Preventive;

  ThreadHandle := BeginThread(nil, 0, Addr(MainThread), nil, 0, ThreadID);
  CloseHandle(ThreadHandle);

// Посылаем сообщение об успешном запуске:
  SendMessage(FormHandle, $FFF, $FF, $FF);
end;

procedure StopPerimeter;
begin
  Active := false; // Сигнал к завершению основного потока

// Очистка адресов функций перенесена в MainThread

// Выключаем эмуляцию отладчика и брейкпоинта:
  //EmuDebugger := false;
  //EmuBreakpoint := false;
end;

procedure Emulate(Debugger: boolean; Breakpoint: boolean);
begin
  EmuDebugger := Debugger;
  EmuBreakpoint := Breakpoint;
end;

end.
