// reference https://theroadtodelphi.wordpress.com/2011/02/08/determine-when-the-windows-is-a-desktop-or-server-edition-using-delphi/
program ISWindowsServer;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils;

  {$IFDEF UNICODE}
  function VerifyVersionInfo(var LPOSVERSIONINFOEX: OSVERSIONINFOEX; dwTypeMask: DWORD; dwlConditionMask: int64): BOOL; stdcall;
    external kernel32 name 'VerifyVersionInfoW';
  {$ELSE}
  function VerifyVersionInfo(var LPOSVERSIONINFOEX: OSVERSIONINFOEX; dwTypeMask: DWORD; dwlConditionMask: int64): BOOL; stdcall;
    external kernel32 name 'VerifyVersionInfoA';
  {$ENDIF}
  function VerSetConditionMask(dwlConditionMask: int64; dwTypeBitMask: DWORD; dwConditionMask: Byte): int64; stdcall; external kernel32;

function IsWinServer: Boolean;
const
  VER_NT_SERVER = $0000003;
  VER_EQUAL = 1;
  VER_GREATER_EQUAL = 3;
var
  osvi: OSVERSIONINFOEX;
  dwlConditionMask: DWORDLONG;
  op: Integer;
begin
  dwlConditionMask := 0;
  op := VER_GREATER_EQUAL;

  ZeroMemory(@osvi, sizeof(OSVERSIONINFOEX));
  osvi.dwOSVersionInfoSize := sizeof(OSVERSIONINFOEX);
  osvi.dwMajorVersion := 5;
  osvi.dwMinorVersion := 0;
  osvi.wServicePackMajor := 0;
  osvi.wServicePackMinor := 0;
  osvi.wProductType := VER_NT_SERVER;

  dwlConditionMask := VerSetConditionMask(dwlConditionMask, VER_MAJORVERSION, op);
  dwlConditionMask := VerSetConditionMask(dwlConditionMask, VER_MINORVERSION, op);
  dwlConditionMask := VerSetConditionMask(dwlConditionMask, VER_SERVICEPACKMAJOR, op);
  dwlConditionMask := VerSetConditionMask(dwlConditionMask, VER_SERVICEPACKMINOR, op);
  dwlConditionMask := VerSetConditionMask(dwlConditionMask, VER_PRODUCT_TYPE,
    VER_EQUAL);

  Result := VerifyVersionInfo(osvi, VER_MAJORVERSION OR VER_MINORVERSION OR
    VER_SERVICEPACKMAJOR OR VER_SERVICEPACKMINOR OR VER_PRODUCT_TYPE, dwlConditionMask);
end;

const
  WindowsEditionStr: array [Boolean] of string = ('Desktop', 'Server');

begin
  try
    Writeln(Format('Running in Windows %s edition', [WindowsEditionStr[IsWinServer]]));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  readln;

end.
