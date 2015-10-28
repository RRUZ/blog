// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
program EnumConnections;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  ActiveX,
  ComObj,
  Windows,
  NETWORKLIST_TLB in 'NETWORKLIST_TLB.pas';


//https://msdn.microsoft.com/en-us/library/windows/desktop/aa370796(v=vs.85).aspx
function GetNetworkDomainType(DomainType : TOleEnum) : string;
begin
 Result:='';
  case DomainType of
    NLM_DOMAIN_TYPE_NON_DOMAIN_NETWORK   : Result := 'Non Domain Network'; //The Network is not an Active Directory Network
    NLM_DOMAIN_TYPE_DOMAIN_NETWORK       : Result := 'Domain Network';//The Network is an Active Directory Network, but this machine is not authenticated against it.
    NLM_DOMAIN_TYPE_DOMAIN_AUTHENTICATED : Result := 'Domain Network Authenticated';//The Network is an Active Directory Network, and this machine is authenticated against it.
  end;
end;


//https://msdn.microsoft.com/en-us/library/windows/desktop/aa370795(v=vs.85).aspx
function GetNetworkConnectivity(Connectivity : TOleEnum) : string;
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


procedure GetConnections;
var
  NetworkListManager: INetworkListManager;
  EnumNetworkConnections: IEnumNetworkConnections;
  NetworkConnection : INetworkConnection;
  pceltFetched: ULONG;
begin
   NetworkListManager := CoNetworkListManager.Create;
   EnumNetworkConnections :=  NetworkListManager.GetNetworkConnections();
   while true do
   begin
     EnumNetworkConnections.Next(1, NetworkConnection, pceltFetched);
     if (pceltFetched>0)  then
     begin
        Writeln(Format('Adapter Id      : %s', [GuidToString(NetworkConnection.GetAdapterId)]));
        Writeln(Format('Connection Id   : %s', [GuidToString(NetworkConnection.GetConnectionId)]));
        Writeln(Format('Domain Type     : %s', [GetNetworkDomainType(NetworkConnection.GetDomainType)]));
        Writeln(Format('Connected       : %s', [boolToStr(NetworkConnection.IsConnected, True)]));
        Writeln(Format('Internet        : %s', [boolToStr(NetworkConnection.IsConnectedToInternet, True)]));
        Writeln(Format('Network         : %s', [NetworkConnection.GetNetwork.GetName]));
        Writeln(Format('Connectivity    : %s', [GetNetworkConnectivity(NetworkConnection.GetConnectivity)]));
     end
     else
     Break;
   end;
end;

begin
 try
   if TOSVersion.Check(6) then
   begin
      CoInitialize(nil);
      try
        GetConnections;
      finally
        CoUninitialize;
      end;
   end
   else
   Writeln('This windows version doesn''t support the Network List API');
 except
    on E:EOleException do
        Writeln(Format('EOleException %s %x', [E.Message,E.ErrorCode]));
    on E:Exception do
        Writeln(E.Classname, ':', E.Message);
 end;
 Writeln('Press Enter to exit');
 Readln;
end.
