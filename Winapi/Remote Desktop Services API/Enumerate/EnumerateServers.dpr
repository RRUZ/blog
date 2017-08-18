// reference https://theroadtodelphi.wordpress.com/2010/10/16/delphi-enumerating-remote-desktop-servers-in-a-network-domain/
{$APPTYPE CONSOLE}

uses
  Classes,
  SysUtils,
  Windows;

type
  PWTS_SERVER_INFO = ^WTS_SERVER_INFO;

  _WTS_SERVER_INFO = packed record
    pServerName: LPTSTR;
  end;

  WTS_SERVER_INFO = _WTS_SERVER_INFO;
  WTS_SERVER_INFO_Array = Array [0 .. 0] of WTS_SERVER_INFO;
  PWTS_SERVER_INFO_Array = ^WTS_SERVER_INFO_Array;

{$IFDEF UNICODE}
function WTSEnumerateServers(pDomainName: LPTSTR; Reserved: DWORD; Version: DWORD; ppServerInfo: PWTS_SERVER_INFO; pCount: PDWORD): BOOLEAN;
  stdcall; external 'wtsapi32.dll' name 'WTSEnumerateServersW';
{$ELSE}
function WTSEnumerateServers(pDomainName: LPTSTR; Reserved: DWORD; Version: DWORD; ppServerInfo: PWTS_SERVER_INFO; pCount: PDWORD): BOOLEAN;
  stdcall; external 'wtsapi32.dll' name 'WTSEnumerateServersA';
{$ENDIF}
procedure WTSFreeMemory(pMemory: Pointer); stdcall; external 'wtsapi32.dll' name 'WTSFreeMemory';

procedure GetRemoteDesktopsList(const Domain: PChar; const Servers: TStrings);
var
  ppServerInfo: PWTS_SERVER_INFO_Array; // PWTS_SERVER_INFO;
  pCount: DWORD;
  i: integer;
begin
  Servers.Clear;
  ppServerInfo := nil;
  try
    if WTSEnumerateServers(Domain, 0, 1, PWTS_SERVER_INFO(@ppServerInfo),
      @pCount) then
      for i := 0 to pCount - 1 do
        Servers.Add(ppServerInfo^[i].pServerName)
    else
      Raise Exception.Create(SysErrorMessage(GetLastError));
  finally
    if ppServerInfo <> nil then
      WTSFreeMemory(ppServerInfo);
  end;

end;
