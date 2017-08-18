// reference https://theroadtodelphi.wordpress.com/2012/05/26/getting-the-environment-variables-of-an-external-x86-process/
program NtQueryInformationProcess_EnvVars;
// Author Rodrigo Ruz (RRUZ)
// 2012-05-26
{$APPTYPE CONSOLE}
{$IFDEF CPUX64} Sorry only 32 bits support{$ENDIF}
{$R *.res}
  uses Classes, SysUtils, Windows;

type
  _UNICODE_STRING = record
    Length: Word;
    MaximumLength: Word;
    Buffer: LPWSTR;
  end;

  UNICODE_STRING = _UNICODE_STRING;

  // http://msdn.microsoft.com/en-us/library/windows/desktop/ms684280%28v=vs.85%29.aspx
  PROCESS_BASIC_INFORMATION = record
    Reserved1: Pointer;
    PebBaseAddress: Pointer;
    Reserved2: array [0 .. 1] of Pointer;
    UniqueProcessId: ULONG_PTR;
    Reserved3: Pointer;
  end;

  // http://undocumented.ntinternals.net/UserMode/Structures/RTL_DRIVE_LETTER_CURDIR.html
  _RTL_DRIVE_LETTER_CURDIR = record
    Flags: Word;
    Length: Word;
    TimeStamp: ULONG;
    DosPath: UNICODE_STRING;
  end;

  RTL_DRIVE_LETTER_CURDIR = _RTL_DRIVE_LETTER_CURDIR;

  _CURDIR = record
    DosPath: UNICODE_STRING;
    Handle: THANDLE;
  end;

  CURDIR = _CURDIR;

  // http://undocumented.ntinternals.net/UserMode/Structures/RTL_USER_PROCESS_PARAMETERS.html
  _RTL_USER_PROCESS_PARAMETERS = record
    MaximumLength: ULONG;
    Length: ULONG;
    Flags: ULONG;
    DebugFlags: ULONG;
    ConsoleHandle: THANDLE;
    ConsoleFlags: ULONG;
    StandardInput: THANDLE;
    StandardOutput: THANDLE;
    StandardError: THANDLE;
    CurrentDirectory: CURDIR;
    DllPath: UNICODE_STRING;
    ImagePathName: UNICODE_STRING;
    CommandLine: UNICODE_STRING;
    Environment: Pointer;
    StartingX: ULONG;
    StartingY: ULONG;
    CountX: ULONG;
    CountY: ULONG;
    CountCharsX: ULONG;
    CountCharsY: ULONG;
    FillAttribute: ULONG;
    WindowFlags: ULONG;
    ShowWindowFlags: ULONG;
    WindowTitle: UNICODE_STRING;
    DesktopInfo: UNICODE_STRING;
    ShellInfo: UNICODE_STRING;
    RuntimeData: UNICODE_STRING;
    CurrentDirectories: array [0 .. 31] of RTL_DRIVE_LETTER_CURDIR;
  end;

  RTL_USER_PROCESS_PARAMETERS = _RTL_USER_PROCESS_PARAMETERS;
  PRTL_USER_PROCESS_PARAMETERS = ^RTL_USER_PROCESS_PARAMETERS;

  _PEB = record
    Reserved1: array [0 .. 1] of Byte;
    BeingDebugged: Byte;
    Reserved2: Byte;
    Reserved3: array [0 .. 1] of Pointer;
    Ldr: Pointer;
    ProcessParameters: PRTL_USER_PROCESS_PARAMETERS;
    Reserved4: array [0 .. 102] of Byte;
    Reserved5: array [0 .. 51] of Pointer;
    PostProcessInitRoutine: Pointer;
    Reserved6: array [0 .. 127] of Byte;
    Reserved7: Pointer;
    SessionId: ULONG;
  end;

  PEB = _PEB;

function NtQueryInformationProcess(ProcessHandle: THANDLE; ProcessInformationClass: DWORD; ProcessInformation: Pointer;
  ProcessInformationLength: ULONG; ReturnLength: PULONG): LongInt; stdcall; external 'ntdll.dll';

type
  TIsWow64Process = function(Handle: THANDLE; var IsWow64: BOOL): BOOL; stdcall;

var
  _IsWow64Process: TIsWow64Process;

procedure Init_IsWow64Process;
var
  hKernel32: Integer;
begin
  hKernel32 := LoadLibrary(kernel32);
  if (hKernel32 = 0) then
    RaiseLastOSError;
  try
    _IsWow64Process := GetProcAddress(hKernel32, 'IsWow64Process');
  finally
    FreeLibrary(hKernel32);
  end;
end;

function ProcessIsX64(hProcess: DWORD): Boolean;
var
  IsWow64: BOOL;
begin
  Result := False;
  if not Assigned(_IsWow64Process) then
    Init_IsWow64Process;

  if Assigned(_IsWow64Process) then
  begin
    // check if the current app is running under WOW
    if _IsWow64Process(GetCurrentProcess(), IsWow64) then
      Result := IsWow64
    else
      RaiseLastOSError;

{$IFNDEF CPUX64}
    // the current delphi App is not running under wow64, so the current Window OS is 32 bit
    // and obviously all the apps are 32 bits.
    if not Result then
      Exit;
{$ENDIF}
    if (_IsWow64Process(hProcess, IsWow64)) then
      Result := not IsWow64
    else
      RaiseLastOSError;
  end;
end;

function GetEnvVarsPid(dwProcessId: DWORD): string;
const
  STATUS_SUCCESS = $00000000;
  SE_DEBUG_NAME = 'SeDebugPrivilege';
  OffsetProcessParametersx32 = $10;
var
  ProcessHandle: THANDLE;
  ProcessBasicInfo: PROCESS_BASIC_INFORMATION;
  ReturnLength: DWORD;
  lpNumberOfBytesRead: ULONG_PTR;
  TokenHandle: THANDLE;
  lpLuid: TOKEN_PRIVILEGES;
  OldlpLuid: TOKEN_PRIVILEGES;

  Rtl: RTL_USER_PROCESS_PARAMETERS;
  Mbi: TMemoryBasicInformation;
  PEB: _PEB;
  EnvStrBlock: TBytes;
  EnvStrLength: ULONG;
{$IFNDEF UNICODE}
  WS: WideString;
{$ENDIF}
begin
  Result := '';
  if OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or
    TOKEN_QUERY, TokenHandle) then
  begin
    try
      if not LookupPrivilegeValue(nil, SE_DEBUG_NAME, lpLuid.Privileges[0].Luid)
      then
        RaiseLastOSError
      else
      begin
        lpLuid.PrivilegeCount := 1;
        lpLuid.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
        ReturnLength := 0;
        OldlpLuid := lpLuid;
        // Set the SeDebugPrivilege privilege
        if not AdjustTokenPrivileges(TokenHandle, False, lpLuid,
          SizeOf(OldlpLuid), OldlpLuid, ReturnLength) then
          RaiseLastOSError;
      end;

      ProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, dwProcessId);
      if ProcessHandle = 0 then
        RaiseLastOSError
      else
        try
          if ProcessIsX64(ProcessHandle) then
            raise Exception.Create('Only 32 bits processes are supported');

          // get the PROCESS_BASIC_INFORMATION to access to the PEB Address
          if (NtQueryInformationProcess(ProcessHandle, 0 { =>ProcessBasicInformation } , @ProcessBasicInfo,
            SizeOf(ProcessBasicInfo), @ReturnLength) = STATUS_SUCCESS) and
            (ReturnLength = SizeOf(ProcessBasicInfo)) then
          begin
            // read the PEB struture
            if not ReadProcessMemory(ProcessHandle, ProcessBasicInfo.PebBaseAddress, @PEB, SizeOf(PEB), lpNumberOfBytesRead) then
              RaiseLastOSError
            else
            begin
              // read the RTL_USER_PROCESS_PARAMETERS structure
              if not ReadProcessMemory(ProcessHandle, PEB.ProcessParameters, @Rtl, SizeOf(Rtl), lpNumberOfBytesRead) then
                RaiseLastOSError
              else
              begin
                // get the size of the Env. variables block
                if VirtualQueryEx(ProcessHandle, Rtl.Environment, Mbi, SizeOf(Mbi)) = 0 then
                  RaiseLastOSError
                else
                  EnvStrLength := (Mbi.RegionSize - (ULONG_PTR(Rtl.Environment) - ULONG_PTR(Mbi.BaseAddress)));

                SetLength(EnvStrBlock, EnvStrLength);
                // read the content of the env. variables block
                if not ReadProcessMemory(ProcessHandle, Rtl.Environment, @EnvStrBlock[0], EnvStrLength, lpNumberOfBytesRead) then
                  RaiseLastOSError
                else
                {$IFDEF UNICODE}
                  Result := TEncoding.Unicode.GetString(EnvStrBlock);
                {$ELSE}
                  {
                    SetLength(Result, Length(EnvStrBlock) div 2);
                    WideCharToMultiByte( CP_ACP , 0, PWideChar(@EnvStrBlock[0]), -1, @Result[1], Rtl.EnvironmentSize, nil, nil );
                  }
                  SetString(WS, PWideChar(@EnvStrBlock[0]), Length(EnvStrBlock) div 2);
                Result := WS;
                {$ENDIF}
              end;
            end;
          end
          else
            RaiseLastOSError;
        finally
          CloseHandle(ProcessHandle);
        end;
    finally
      CloseHandle(TokenHandle);
    end;
  end
  else
    RaiseLastOSError;
end;

function GetEnvVarsPidList(dwProcessId: DWORD): TStringList;
var
  PEnvVars: PChar;
  PEnvEntry: PChar;
begin
  Result := TStringList.Create;
  PEnvVars := PChar(GetEnvVarsPid(dwProcessId));
  PEnvEntry := PEnvVars;
  while PEnvEntry^ <> #0 do
  begin
    Result.Add(PEnvEntry);
    Inc(PEnvEntry, StrLen(PEnvEntry) + 1);
  end;
end;

Var
  EnvVars: TStringList;

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    EnvVars := GetEnvVarsPidList(5140);
    try
      Writeln(EnvVars.Text);
    finally
      EnvVars.Free;
    end;
  except
    on E: Exception do
      Writeln(E.Classname, ':', E.Message);
  end;
  Readln;

end.
