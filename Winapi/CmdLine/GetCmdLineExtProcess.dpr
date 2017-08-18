
//reference https://theroadtodelphi.com/2011/07/20/two-ways-to-get-the-command-line-of-another-process-using-delphi/
program GetCmdLineExtProcess;


{$APPTYPE CONSOLE}
{$R *.res}

uses
  SysUtils,
  Windows;

type
  _UNICODE_STRING = record
    Length: Word;
    MaximumLength: Word;
    Buffer: LPWSTR;
  end;

  UNICODE_STRING = _UNICODE_STRING;

  PROCESS_BASIC_INFORMATION = packed record
    ExitStatus: DWORD;
    PebBaseAddress: Pointer;
    AffinityMask: DWORD;
    BasePriority: DWORD;
    UniqueProcessId: DWORD;
    InheritedUniquePID: DWORD;
  end;

function NtQueryInformationProcess(ProcessHandle: THandle;
  ProcessInformationClass: DWORD; ProcessInformation: Pointer;
  ProcessInformationLength: ULONG; ReturnLength: PULONG): LongInt; stdcall;
  external 'ntdll.dll';

function GetCommandLineFromPid(PID: THandle): string;
const
  STATUS_SUCCESS = $00000000;
  SE_DEBUG_NAME = 'SeDebugPrivilege';
  OffsetProcessParametersx32 = $10; // 16
  OffsetCommandLinex32 = $40; // 64
var
  ProcessHandle: THandle;
  rtlUserProcAddress: Pointer;
  CommandLine: UNICODE_STRING;
  CommandLineContents: WideString;
  ProcessBasicInfo: PROCESS_BASIC_INFORMATION;
  lpNumberOfBytesRead: SIZE_T;
  ReturnLength: DWORD;
  TokenHandle: THandle;
  lpLuid: TOKEN_PRIVILEGES;
  OldlpLuid: TOKEN_PRIVILEGES;
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

      ProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,
        False, PID);
      if ProcessHandle = 0 then
        RaiseLastOSError
      else
        try
          // get the PROCESS_BASIC_INFORMATION to access to the PEB Address
          if (NtQueryInformationProcess(ProcessHandle, 0 { =>ProcessBasicInformation } , @ProcessBasicInfo,
            SizeOf(ProcessBasicInfo), @ReturnLength) = STATUS_SUCCESS) and
            (ReturnLength = SizeOf(ProcessBasicInfo)) then
          begin
            // get the address of the RTL_USER_PROCESS_PARAMETERS struture
            if not ReadProcessMemory(ProcessHandle, Pointer(LongInt(ProcessBasicInfo.PebBaseAddress) +
              OffsetProcessParametersx32), @rtlUserProcAddress, SizeOf(Pointer), lpNumberOfBytesRead) then
              RaiseLastOSError
            else if ReadProcessMemory(ProcessHandle, Pointer(LongInt(rtlUserProcAddress) + OffsetCommandLinex32),
              @CommandLine, SizeOf(CommandLine), lpNumberOfBytesRead) then
            begin
              SetLength(CommandLineContents, CommandLine.Length);
              // get the CommandLine field
              if ReadProcessMemory(ProcessHandle, CommandLine.Buffer, @CommandLineContents[1], CommandLine.Length, lpNumberOfBytesRead) then
                Result := WideCharLenToString(PWideChar(CommandLineContents),CommandLine.Length div 2)
              else
                RaiseLastOSError;
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

begin
  try
    Writeln(GetCommandLineFromPid(5140));
  except
    on E: Exception do
      Writeln(E.Classname, ':', E.Message);
  end;
  Readln;

end.
