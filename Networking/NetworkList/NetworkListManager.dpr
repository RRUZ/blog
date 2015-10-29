// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
program NetworkListManager;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  ActiveX,
  ComObj,
  Windows,
  NETWORKLIST_TLB in 'NETWORKLIST_TLB.pas';


//https://msdn.microsoft.com/en-us/library/windows/desktop/aa370795(v=vs.85).aspx
function GetNetworkConnectivity(Connectivity : NLM_CONNECTIVITY) : string;
begin
 Result:='';
    if NLM_CONNECTIVITY_DISCONNECTED and Connectivity <> 0 then  Result := Result+ 'Disconnected, ';
    if NLM_CONNECTIVITY_IPV4_NOTRAFFIC and Connectivity <> 0 then  Result := Result+ 'Connected but not ipv4 traffic, ';
    if NLM_CONNECTIVITY_IPV6_NOTRAFFIC  and Connectivity <> 0 then  Result := Result+  'Connected but not ipv6 traffic, ';
    if NLM_CONNECTIVITY_IPV4_SUBNET  and Connectivity <> 0 then  Result := Result+  'Subnet ipv4, ';
    if NLM_CONNECTIVITY_IPV4_LOCALNETWORK  and Connectivity <> 0 then  Result := Result+  'LocalNetwork ipv4, ';
    if NLM_CONNECTIVITY_IPV4_INTERNET  and Connectivity <> 0 then  Result := Result+  'Internet ipv4, ';
    if NLM_CONNECTIVITY_IPV6_SUBNET  and Connectivity <> 0 then  Result := Result+  'Subnet ipv6, ';
    if NLM_CONNECTIVITY_IPV6_LOCALNETWORK  and Connectivity <> 0 then  Result := Result+ 'LocalNetwork ipv6, ';
    if NLM_CONNECTIVITY_IPV6_INTERNET  and Connectivity <> 0 then  Result := Result+'Internet ipv6, ';

    Result:= StringReplace('['+Result+']', ', ]', ']', [rfReplaceAll]);
end;


procedure GetNetworkListManagerInfo;
var
  NetworkListManager: INetworkListManager;
begin
  NetworkListManager := CoNetworkListManager.Create;
  Writeln(Format('Connected       : %s', [boolToStr(NetworkListManager.IsConnected, True)]));
  Writeln(Format('Internet        : %s', [boolToStr(NetworkListManager.IsConnectedToInternet, True)]));
  Writeln(Format('Connectivity    : %s', [GetNetworkConnectivity(NetworkListManager.GetConnectivity)]));
end;

begin
 try
  //Check is Windows Vista at least
  if TOSVersion.Check(6) then
   begin
      CoInitialize(nil);
      try
        GetNetworkListManagerInfo;
      finally
        CoUninitialize;
      end;
   end
   else
   Writeln('This windows version doesn''t support the Network List API');
 except
    on E:EOleException do
        Writeln(Format('EOleException %s %x', [E.Message, E.ErrorCode]));
    on E:Exception do
        Writeln(E.Classname, ':', E.Message);
 end;
 Writeln('Press Enter to exit');
 Readln;
end.
