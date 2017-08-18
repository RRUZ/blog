// reference https://theroadtodelphi.com/2011/07/20/two-ways-to-get-the-command-line-of-another-process-using-delphi/
program GetCmdLineExtProcess;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  ActiveX,
  Variants,
  ComObj;

function GetCommandLineFromPid(ProcessId: DWORD): string;
var
  FSWbemLocator: OLEVariant;
  FWMIService: OLEVariant;
  FWbemObjectSet: OLEVariant;
begin;
  Result := '';
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService := FSWbemLocator.ConnectServer('localhost', 'root\CIMV2', '', '');
  // if the pid not exist a EOleException exception will be raised with the code $80041002 - Object Not Found
  FWbemObjectSet := FWMIService.Get(Format('Win32_Process.Handle="%d"', [ProcessId]));
  Result := FWbemObjectSet.CommandLine;
end;

begin
  try
    CoInitialize(nil);
    try
      Writeln(GetCommandLineFromPid(5140));
    finally
      CoUninitialize;
    end;
  except
    on E: EOleException do
      Writeln(Format('EOleException %s %x', [E.Message, E.ErrorCode]));
    on E: Exception do
      Writeln(E.Classname, ':', E.Message);
  end;
  Writeln('Press Enter to exit');
  Readln;

end.
