program Events;

{$APPTYPE CONSOLE}

uses
  Winapi.Windows,
  {$IF CompilerVersion > 18.5}
  Vcl.Forms,
  {$IFEND }
  System.SysUtils,
  Winapi.ActiveX,
  System.Win.ComObj,
  NETWORKLIST_TLB in 'NETWORKLIST_TLB.pas';

 type
  TNetworkEvents = class(TInterfacedObject, INetworkEvents)
  private
   NetworkListManager :  INetworkListManager;
   dwCookie : Integer;
  public
    function NetworkAdded(networkId: TGUID): HResult; stdcall;
    function NetworkDeleted(networkId: TGUID): HResult; stdcall;
    function NetworkConnectivityChanged(networkId: TGUID; newConnectivity: NLM_CONNECTIVITY): HResult; stdcall;
    function NetworkPropertyChanged(networkId: TGUID; Flags: NLM_NETWORK_PROPERTY_CHANGE): HResult; stdcall;
    constructor Create;
    procedure Start;
    procedure Stop;
  end;

//Detect when a key was pressed in the console window
function KeyPressed:Boolean;
var
  lpNumberOfEvents     : DWORD;
  lpBuffer             : TInputRecord;
  lpNumberOfEventsRead : DWORD;
  nStdHandle           : THandle;
begin
  Result:=false;
  nStdHandle := GetStdHandle(STD_INPUT_HANDLE);
  lpNumberOfEvents:=0;
  GetNumberOfConsoleInputEvents(nStdHandle, lpNumberOfEvents);
  if (lpNumberOfEvents<> 0) then
  begin
    PeekConsoleInput(nStdHandle, lpBuffer, 1, lpNumberOfEventsRead);
    if lpNumberOfEventsRead <> 0 then
    begin
      if lpBuffer.EventType = KEY_EVENT then
      begin
        if lpBuffer.Event.KeyEvent.bKeyDown then
          Result:=true
        else
          FlushConsoleInputBuffer(nStdHandle);
      end
      else
      FlushConsoleInputBuffer(nStdHandle);
    end;
  end;
end;

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

//https://msdn.microsoft.com/en-us/library/windows/desktop/aa370801(v=vs.85).aspx
function GetNetworkPropertyChange(PropertyChange : NLM_NETWORK_PROPERTY_CHANGE) : string;
begin
 Result:='';
    if NLM_NETWORK_PROPERTY_CHANGE_CONNECTION and PropertyChange <> 0 then  Result := Result+ 'Connection, ';
    if NLM_NETWORK_PROPERTY_CHANGE_DESCRIPTION and PropertyChange <> 0 then  Result := Result+ 'Description, ';
    if NLM_NETWORK_PROPERTY_CHANGE_NAME  and PropertyChange <> 0 then  Result := Result+  'Name, ';
    if NLM_NETWORK_PROPERTY_CHANGE_ICON  and PropertyChange <> 0 then  Result := Result+  'Icon, ';
    if NLM_NETWORK_PROPERTY_CHANGE_CATEGORY_VALUE  and PropertyChange <> 0 then  Result := Result+  'Category value, ';

    Result:= StringReplace('['+Result+']', ', ]', ']', [rfReplaceAll]);

end;

{ TNetworkEvents }
const
  IID_IConnectionPointContainer: TGUID = (
    D1:$B196B284;D2:$BAB4;D3:$101A;D4:($B6,$9C,$00,$AA,$00,$34,$1D,$07));

constructor TNetworkEvents.Create;
begin
  dwCookie := 0;
end;

function TNetworkEvents.NetworkAdded(networkId: TGUID): HResult;
begin
  Writeln(Format('Network Added : %s', [GuidToString(networkId)]));
  Result := S_OK;
end;

function TNetworkEvents.NetworkConnectivityChanged(networkId: TGUID;
  NewConnectivity: NLM_CONNECTIVITY): HResult;
begin
  Writeln(Format('Network Connectivity Changed : %s - %s', [GuidToString(networkId), GetNetworkConnectivity(NewConnectivity)]));
  Result := S_OK;
end;

function TNetworkEvents.NetworkDeleted(networkId: TGUID): HResult;
begin
  Writeln(Format('Network Deleted : %s', [GuidToString(networkId)]));
  Result := S_OK;
end;

function TNetworkEvents.NetworkPropertyChanged(networkId: TGUID; Flags: NLM_NETWORK_PROPERTY_CHANGE): HResult;
begin
  Writeln(Format('Network Property Changed : %s - %s', [GuidToString(networkId), GetNetworkPropertyChange(Flags)]));
  Result := S_OK;
end;

procedure TNetworkEvents.Start;
var
  LConnectionPointContainer: IConnectionPointContainer;
  LConnectionPoint: IConnectionPoint;
begin
  if dwCookie > 0 then exit;
   NetworkListManager := CoNetworkListManager.Create;
    if Succeeded(NetworkListManager.QueryInterface(IID_IConnectionPointContainer, LConnectionPointContainer)) then
    begin
      if Succeeded(LConnectionPointContainer.FindConnectionPoint(IID_INetworkEvents, LConnectionPoint)) then
      begin
        LConnectionPoint.Advise(Self as IUnknown, dwCookie);
        LConnectionPoint := nil;
      end;
    end;
end;

procedure TNetworkEvents.Stop;
var
  LConnectionPointContainer: IConnectionPointContainer;
  LConnectionPoint: IConnectionPoint;
begin
  if dwCookie = 0 then exit;
  if Succeeded(NetworkListManager.QueryInterface(IID_IConnectionPointContainer, LConnectionPointContainer)) then
    if Succeeded(LConnectionPointContainer.FindConnectionPoint(IID_INetworkEvents, LConnectionPoint)) then
    begin
      LConnectionPoint.Unadvise(dwCookie);
      LConnectionPoint := nil;
    end;
end;

var
   NLMEvents : TNetworkEvents;
begin
 try
    //Check is Windows Vista at least
   if TOSVersion.Check(6) then
   begin
    NLMEvents:=TNetworkEvents.Create;
    try
      NLMEvents.Start;
      Writeln('Listening NLM events - press any key to stop');
      //The next loop is only necessary on this sample console App
      //In VCL forms Apps you don't need use a loop
      while not KeyPressed do
      begin
          Sleep(100);
          Application.ProcessMessages;
      end;
    finally
      NLMEvents.Stop;
      Writeln('NLM events - Done');
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

 Readln;
end.
