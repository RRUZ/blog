// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
program EnumNetworks;

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



function GetNetworkCategory(Category : TOleEnum) : string;
begin
 Result:='';
  case Category of
    NLM_NETWORK_CATEGORY_PUBLIC               : Result := 'Public';
    NLM_NETWORK_CATEGORY_PRIVATE              : Result := 'Private';
    NLM_NETWORK_CATEGORY_DOMAIN_AUTHENTICATED : Result := 'Authenticated';
  end;
end;


procedure GetNetworks;
var
  NetworkListManager: INetworkListManager;
  EnumNetworks: IEnumNetworks;

  EnumNetworksConnections: IEnumNetworkConnections;
  NetworkConnection : INetworkConnection;

  Network: INetwork;
  fetched, pceltFetched: ULONG;

  pdwLowDateTimeCreated: LongWord;
  pdwHighDateTimeCreated: LongWord;
  pdwLowDateTimeConnected: LongWord;
  pdwHighDateTimeConnected: LongWord;

  lpFileTime : TFileTime;
  lpSystemTime: TSystemTime;
  LDateTime : TDateTime;
begin
   NetworkListManager := CoNetworkListManager.Create;
   EnumNetworks :=  NetworkListManager.GetNetworks(NLM_ENUM_NETWORK_CONNECTED);
   while true do
   begin
     EnumNetworks.Next(1, Network, fetched);
     if (fetched>0)  then
     begin
       Writeln(Format('%s - %s', [Network.GetName, Network.GetDescription]));
       Writeln(Format('Network Id  : %s', [GuidToString(Network.GetNetworkId)]));
       Writeln(Format('Domain Type : %s', [GetNetworkDomainType(Network.GetDomainType)]));
       Writeln(Format('Category    : %s', [GetNetworkCategory(Network.GetCategory)]));

       //https://msdn.microsoft.com/en-us/library/windows/desktop/aa370787(v=vs.85).aspx
       Network.GetTimeCreatedAndConnected(pdwLowDateTimeCreated, pdwHighDateTimeCreated, pdwLowDateTimeConnected, pdwHighDateTimeConnected);

       lpFileTime.dwLowDateTime := pdwLowDateTimeCreated;
       lpFileTime.dwHighDateTime := pdwHighDateTimeCreated;
       if FileTimeToSystemTime(lpFileTime, lpSystemTime) then
       begin
          LDateTime := SystemTimeToDateTime(lpSystemTime);
          Writeln('Created         : '+FormatDateTime('dd/mm/yyyy hh:nn', LDateTime));
       end;

       lpFileTime.dwLowDateTime := pdwLowDateTimeConnected;
       lpFileTime.dwHighDateTime := pdwHighDateTimeConnected;
       if FileTimeToSystemTime(lpFileTime, lpSystemTime) then
       begin
          LDateTime := SystemTimeToDateTime(lpSystemTime);
          Writeln('Last Connection : '+FormatDateTime('dd/mm/yyyy hh:nn', LDateTime));
       end;

       Writeln(Format('Connected       : %s', [boolToStr(Network.IsConnected, True)]));
       Writeln(Format('Internet        : %s', [boolToStr(Network.IsConnectedToInternet, True)]));

         EnumNetworksConnections := Network.GetNetworkConnections();

         Writeln;
         Writeln('Connections');
         Writeln('-----------');
         while true do
         begin
            EnumNetworksConnections.Next(1, NetworkConnection, pceltFetched);
              if (pceltFetched>0)  then
              begin
                Writeln(Format('  Adapter Id    : %s', [GuidToString(NetworkConnection.GetAdapterId)]));
                Writeln(Format('  Connection Id : %s', [GuidToString(NetworkConnection.GetConnectionId)]));
              end
              else
              break;
         end;
       Writeln;
     end
     else
     Break;
   end;
end;

begin
 try
    CoInitialize(nil);
    try
      //GetNetworkInfo;
      GetNetworks;
    finally
      CoUninitialize;
    end;
 except
    on E:EOleException do
        Writeln(Format('EOleException %s %x', [E.Message,E.ErrorCode]));
    on E:Exception do
        Writeln(E.Classname, ':', E.Message);
 end;
 Writeln('Press Enter to exit');
 Readln;
end.
