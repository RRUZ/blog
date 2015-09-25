program SWbemSink2;

{$IFDEF FPC}
 {$MODE DELPHI} {$H+}
{$ENDIF}

{$APPTYPE CONSOLE}

uses
  Windows,
  Variants,
  SysUtils,
  ActiveX,
  JwaWbemCli;

const
  RPC_C_AUTHN_LEVEL_DEFAULT = 0;
  RPC_C_IMP_LEVEL_IMPERSONATE = 3;
  RPC_C_AUTHN_WINNT = 10;
  RPC_C_AUTHZ_NONE = 0;
  RPC_C_AUTHN_LEVEL_CALL = 3;
  EOAC_NONE = 0;

type
  TWmiEventSink = class(TInterfacedObject, IWbemObjectSink)
  public
    function Indicate(lObjectCount: Longint;  var apObjArray: IWbemClassObject): HRESULT; stdcall;
    function SetStatus(lFlags: Longint; hResult: HRESULT; strParam: WideString; pObjParam: IWbemClassObject): HRESULT; stdcall;
  end;

function TWmiEventSink.Indicate(lObjectCount: Longint; var apObjArray: IWbemClassObject): HRESULT; stdcall;
var
  Instance      : IWbemClassObject;
  wszName       : LPCWSTR;
  pVal          : OleVariant;
  pType         : Integer;
  plFlavor      : Integer;
  lFlags        : Longint;
  Caption, Pid  : string;
begin
  wszName:='TargetInstance';
  lFlags :=0;
  Result := WBEM_S_NO_ERROR;
  if lObjectCount > 0 then
    if Succeeded(apObjArray.Get(wszName, lFlags, pVal, pType, plFlavor)) then
    begin
      Instance := IUnknown(pVal) as IWbemClassObject;
      try
        Instance.Get('Caption', 0, pVal, pType, plFlavor);
        Caption:=pVal;
        VarClear(pVal);

        Instance.Get('ProcessId', 0, pVal, pType, plFlavor);
        Pid:=pVal;
        VarClear(pVal);

        Writeln(Format('Process %s started Pid  %s',[Caption,Pid]));

      finally
        Instance := nil;
      end;
    end;
end;

function TWmiEventSink.SetStatus(lFlags: Longint; hResult: HRESULT; strParam: WideString; pObjParam: IWbemClassObject): HRESULT; stdcall;
begin
  Result := WBEM_S_NO_ERROR;
end;

//detect when a key was pressed in the console window
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
  GetNumberOfConsoleInputEvents(nStdHandle,lpNumberOfEvents);
  if lpNumberOfEvents<> 0 then
  begin
    PeekConsoleInput(nStdHandle,lpBuffer,1,lpNumberOfEventsRead);
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

//Wmi async event
procedure Test_IWbemServices_ExecNotificationQueryAsync;
const
  strLocale    = '';
  strUser      = '';
  strPassword  = '';
  strNetworkResource = 'root\cimv2';
  strAuthority       = '';
  WQL                = 'SELECT * FROM __InstanceCreationEvent WITHIN 1 WHERE TargetInstance ISA "Win32_Process"';
var
  FWbemLocator         : IWbemLocator;
  FWbemServices        : IWbemServices;
  FUnsecuredApartment  : IUnsecuredApartment;
  ppStub               : IUnknown;
  FWmiEventSink        : TWmiEventSink;
  StubSink             : IWbemObjectSink;

begin
  // Set general COM security levels --------------------------
  // Note: If you are using Windows 2000, you need to specify -
  // the default authentication credentials for a user by using
  // a SOLE_AUTHENTICATION_LIST structure in the pAuthList ----
  // parameter of CoInitializeSecurity ------------------------
  if Failed(CoInitializeSecurity(nil, -1, nil, nil, RPC_C_AUTHN_LEVEL_DEFAULT, RPC_C_IMP_LEVEL_IMPERSONATE, nil, EOAC_NONE, nil)) then Exit;
  // Obtain the initial locator to WMI -------------------------
  if Succeeded(CoCreateInstance(CLSID_WbemLocator, nil, CLSCTX_INPROC_SERVER, IID_IWbemLocator, FWbemLocator)) then
  try
    // Connect to WMI through the IWbemLocator::ConnectServer method
    if Succeeded(FWbemLocator.ConnectServer(strNetworkResource, strUser, strPassword, strLocale,  WBEM_FLAG_CONNECT_USE_MAX_WAIT, strAuthority, nil, FWbemServices)) then
    try
      // Set security levels on the proxy -------------------------
      if Failed(CoSetProxyBlanket(FWbemServices, RPC_C_AUTHN_WINNT, RPC_C_AUTHZ_NONE, nil, RPC_C_AUTHN_LEVEL_CALL, RPC_C_IMP_LEVEL_IMPERSONATE, nil, EOAC_NONE)) then Exit;
      if Succeeded(CoCreateInstance(CLSID_UnsecuredApartment, nil, CLSCTX_LOCAL_SERVER, IID_IUnsecuredApartment, FUnsecuredApartment)) then
      try
        FWmiEventSink := TWmiEventSink.Create;
        if Succeeded(FUnsecuredApartment.CreateObjectStub(FWmiEventSink, ppStub)) then
        try
          if Succeeded(ppStub.QueryInterface(IID_IWbemObjectSink, StubSink)) then
          try
            if Succeeded(FWbemServices.ExecNotificationQueryAsync('WQL', WQL, WBEM_FLAG_SEND_STATUS, nil, StubSink)) then
            begin
              Writeln('Listening events...Press any key to exit');
               while not KeyPressed do ;
              FWbemServices.CancelAsyncCall(StubSink);
            end;
          finally
            StubSink := nil;
          end;
        finally
          ppStub := nil;
        end;
      finally
        FUnsecuredApartment := nil;
      end;
    finally
      FWbemServices := nil;
    end;
  finally
    FWbemLocator := nil;
  end;
end;


procedure Test_IWbemServices_ExecQuery;
const
  strLocale    = '';
  strUser      = '';
  strPassword  = '';
  strNetworkResource = 'root\cimv2';
  strAuthority       = '';
  WQL                = 'SELECT * FROM Win32_Volume';
var
  FWbemLocator         : IWbemLocator;
  FWbemServices        : IWbemServices;
  FUnsecuredApartment  : IUnsecuredApartment;
  ppEnum               : IEnumWbemClassObject;
  apObjects            : IWbemClassObject;
  puReturned           : ULONG;
  pVal                 : OleVariant;
  pType                : Integer;
  plFlavor             : Integer;
  Succeed              : HRESULT;
begin
  // Set general COM security levels --------------------------
  // Note: If you are using Windows 2000, you need to specify -
  // the default authentication credentials for a user by using
  // a SOLE_AUTHENTICATION_LIST structure in the pAuthList ----
  // parameter of CoInitializeSecurity ------------------------
  if Failed(CoInitializeSecurity(nil, -1, nil, nil, RPC_C_AUTHN_LEVEL_DEFAULT, RPC_C_IMP_LEVEL_IMPERSONATE, nil, EOAC_NONE, nil)) then Exit;
  // Obtain the initial locator to WMI -------------------------
  if Succeeded(CoCreateInstance(CLSID_WbemLocator, nil, CLSCTX_INPROC_SERVER, IID_IWbemLocator, FWbemLocator)) then
  try
    // Connect to WMI through the IWbemLocator::ConnectServer method
    if Succeeded(FWbemLocator.ConnectServer(strNetworkResource, strUser, strPassword, strLocale,  WBEM_FLAG_CONNECT_USE_MAX_WAIT, strAuthority, nil, FWbemServices)) then
    try
      // Set security levels on the proxy -------------------------
      if Failed(CoSetProxyBlanket(FWbemServices, RPC_C_AUTHN_WINNT, RPC_C_AUTHZ_NONE, nil, RPC_C_AUTHN_LEVEL_CALL, RPC_C_IMP_LEVEL_IMPERSONATE, nil, EOAC_NONE)) then Exit;
      if Succeeded(CoCreateInstance(CLSID_UnsecuredApartment, nil, CLSCTX_LOCAL_SERVER, IID_IUnsecuredApartment, FUnsecuredApartment)) then
      try
        // Use the IWbemServices pointer to make requests of WMI
        //Succeed := FWbemServices.ExecQuery('WQL', WQL, WBEM_FLAG_FORWARD_ONLY OR WBEM_FLAG_RETURN_IMMEDIATELY, nil, ppEnum);
        Succeed := FWbemServices.ExecQuery('WQL', WQL, WBEM_FLAG_FORWARD_ONLY, nil, ppEnum);
        if Succeeded(Succeed) then
        begin
          Writeln('Running Wmi Query..Press Enter to exit');
           // Get the data from the query
           while (ppEnum.Next(WBEM_INFINITE, 1, apObjects, puReturned)=0) do
           begin
             apObjects.Get('Caption', 0, pVal, pType, plFlavor);
             Writeln(pVal);
             VarClear(pVal);
           end;
        end
        else
        Writeln(Format('Error executing WQL sentence %x',[Succeed]));
      finally
        FUnsecuredApartment := nil;
      end;
    finally
      FWbemServices := nil;
    end;
  finally
    FWbemLocator := nil;
  end;
end;


begin
  // Initialize COM. ------------------------------------------
  if Succeeded(CoInitializeEx(nil, COINIT_MULTITHREADED)) then
  try
    Test_IWbemServices_ExecNotificationQueryAsync;
    //Test_IWbemServices_ExecQuery;
  finally
    CoUninitialize();
  end;
  Readln;
end.
