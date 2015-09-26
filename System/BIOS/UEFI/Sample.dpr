//reference https://theroadtodelphi.wordpress.com/2013/02/19/how-distinguish-when-windows-was-installed-in-legacy-bios-or-uefi-mode-using-delphi/
{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils;

function GetFirmwareEnvironmentVariableA(lpName, lpGuid: LPCSTR; pBuffer: Pointer;
  nSize: DWORD): DWORD; stdcall; external kernel32 name 'GetFirmwareEnvironmentVariableA';

begin
  try
    GetFirmwareEnvironmentVariableA('','{00000000-0000-0000-0000-000000000000}', nil,0);
    if (GetLastError = ERROR_INVALID_FUNCTION) then
      Writeln('Legacy BIOS')
    else
      Writeln('UEFI Boot Mode');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.