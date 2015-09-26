//reference https://theroadtodelphi.wordpress.com/2012/09/07/exploring-delphi-xe3-winapi-additions-winapi-wbem/
{$APPTYPE CONSOLE}

{$R *.res}

uses
  Winapi.Windows,
  System.SysUtils,
  Winapi.ActiveX,
  Winapi.Wbem;

const
  //Impersonation Level Constants
  //http://msdn.microsoft.com/en-us/library/ms693790%28v=vs.85%29.aspx
  RPC_C_AUTHN_LEVEL_DEFAULT   = 0;
  RPC_C_IMP_LEVEL_ANONYMOUS   = 1;
  RPC_C_IMP_LEVEL_IDENTIFY    = 2;
  RPC_C_IMP_LEVEL_IMPERSONATE = 3;
  RPC_C_IMP_LEVEL_DELEGATE    = 4;

  //Authentication Service Constants
  //http://msdn.microsoft.com/en-us/library/ms692656%28v=vs.85%29.aspx
  RPC_C_AUTHN_WINNT      = 10;
  RPC_C_AUTHN_LEVEL_CALL = 3;
  RPC_C_AUTHN_DEFAULT    = Longint($FFFFFFFF);
  EOAC_NONE              = 0;

  //Authorization Constants
  //http://msdn.microsoft.com/en-us/library/ms690276%28v=vs.85%29.aspx
  RPC_C_AUTHZ_NONE       = 0;
  RPC_C_AUTHZ_NAME       = 1;
  RPC_C_AUTHZ_DCE        = 2;
  RPC_C_AUTHZ_DEFAULT    = Longint($FFFFFFFF);

  //Authentication-Level Constants
  //http://msdn.microsoft.com/en-us/library/aa373553%28v=vs.85%29.aspx
  RPC_C_AUTHN_LEVEL_PKT_PRIVACY   = 6;
  SEC_WINNT_AUTH_IDENTITY_UNICODE = 2;

 //COAUTHIDENTITY Structure
 //http://msdn.microsoft.com/en-us/library/ms693358%28v=vs.85%29.aspx
 type
    PCOAUTHIDENTITY    = ^TCOAUTHIDENTITY;
    _COAUTHIDENTITY    = Record
                          User           : PChar;
                          UserLength     : ULONG;
                          Domain         : PChar;
                          DomainLength   : ULONG;
                          Password       : PChar;
                          PassWordLength : ULONG;
                          Flags          : ULONG;
                          End;

   COAUTHIDENTITY      = _COAUTHIDENTITY;
   TCOAUTHIDENTITY     = _COAUTHIDENTITY;



function GetExtendedErrorInfo(hresErr: HRESULT):Boolean;
var
 pStatus    : IWbemStatusCodeText;
 hres       : HRESULT;
 MessageText: WideString;
begin
  Result:=False;
    hres := CoCreateInstance(CLSID_WbemStatusCodeText, nil, CLSCTX_INPROC_SERVER, IID_IWbemStatusCodeText, pStatus);
    if (hres = S_OK) then
    begin
     hres := pStatus.GetErrorCodeText(hresErr, 0, 0, MessageText);
     if(hres <> S_OK) then
       MessageText := 'Get last error failed';

     Result:=(hres = S_OK);
     if Result then
      Writeln(Format( 'ErrorCode %x Description %s',[hresErr,MessageText]));
    end;
end;


procedure  TestWbem;
const
  WbemUser            ='';
  WbemPassword        ='';
  WbemComputer        ='localhost';
  WbemLocale          ='';
  WbemAuthority       ='kERBEROS:'+WbemComputer;
var
  LWbemLocator         : IWbemLocator;
  LWbemServices        : IWbemServices;
  LUnsecuredApartment  : IUnsecuredApartment;
  ppEnum               : IEnumWbemClassObject;
  apObjects            : IWbemClassObject;
  puReturned           : ULONG;
  pVal                 : Variant;
  pType                : PCIMTYPE;
  plFlavor             : PInteger;
  OpResult             : HRESULT;
  LocalConnection      : Boolean;
  AuthInfo             : TCOAUTHIDENTITY;
begin
  ZeroMemory(@AuthInfo, 0);
  with AuthInfo do
  begin
    User           := PChar(WbemUser);
    UserLength     := Length(WbemUser);
    Domain         := '';
    DomainLength   := 0;
    Password       := PChar(WbemPassword);
    PasswordLength := Length(WbemPassword);
    Flags          := SEC_WINNT_AUTH_IDENTITY_UNICODE;
  end;

  LocalConnection:=WbemComputer.IsEmpty or (WbemComputer.CompareTo('localhost')=0);
  if LocalConnection then
   if Failed(CoInitializeSecurity(nil, -1, nil, nil, RPC_C_AUTHN_LEVEL_DEFAULT, RPC_C_IMP_LEVEL_IMPERSONATE, nil, EOAC_NONE, nil)) then Exit
   else
  else
   if Failed(CoInitializeSecurity(nil, -1, nil, nil, RPC_C_AUTHN_LEVEL_DEFAULT, RPC_C_IMP_LEVEL_IDENTIFY, nil, EOAC_NONE, nil)) then Exit;


  OpResult:=CoCreateInstance(CLSID_WbemLocator, nil, CLSCTX_INPROC_SERVER, IID_IWbemLocator, LWbemLocator);
  if Succeeded(OpResult) then
  begin
    try
      Writeln('Connecting to the WMI Service');
      if LocalConnection then
        OpResult:=LWbemLocator.ConnectServer(Format('\\%s\root\CIMV2',[WbemComputer]), WbemUser, WbemPassword, WbemLocale,  WBEM_FLAG_CONNECT_USE_MAX_WAIT, '', nil, LWbemServices)
      else
        OpResult:=LWbemLocator.ConnectServer(Format('\\%s\root\CIMV2',[WbemComputer]), WbemUser, WbemPassword, WbemLocale,  WBEM_FLAG_CONNECT_USE_MAX_WAIT, '', nil, LWbemServices);


      if Succeeded(OpResult) then
      begin
        Writeln('Connected');
        try
          // Set security levels on a WMI connection
          if LocalConnection then
            if Failed(CoSetProxyBlanket(LWbemServices, RPC_C_AUTHN_WINNT, RPC_C_AUTHZ_NONE, nil, RPC_C_AUTHN_LEVEL_CALL, RPC_C_IMP_LEVEL_IMPERSONATE, nil, EOAC_NONE)) then Exit
             else
          else
            if Failed(CoSetProxyBlanket(LWbemServices, RPC_C_AUTHN_DEFAULT, RPC_C_AUTHZ_DEFAULT, PWideChar(Format('\\%s',[WbemComputer])), RPC_C_AUTHN_LEVEL_PKT_PRIVACY, RPC_C_IMP_LEVEL_IMPERSONATE, @AuthInfo, EOAC_NONE)) then Exit;

          if Succeeded(CoCreateInstance(CLSID_UnsecuredApartment, nil, CLSCTX_LOCAL_SERVER, IID_IUnsecuredApartment, LUnsecuredApartment)) then
          try
            Writeln('Running Wmi Query');
            OpResult := LWbemServices.ExecQuery('WQL', 'SELECT Name, ProcessId FROM Win32_Process', WBEM_FLAG_FORWARD_ONLY, nil, ppEnum);
            if Succeeded(OpResult) then
            begin
               // Set security for the enumerator proxy
               if not LocalConnection then
                if Failed(CoSetProxyBlanket(ppEnum, RPC_C_AUTHN_DEFAULT, RPC_C_AUTHZ_DEFAULT, PWideChar(Format('\\%s',[WbemComputer])), RPC_C_AUTHN_LEVEL_PKT_PRIVACY, RPC_C_IMP_LEVEL_IMPERSONATE, @AuthInfo, EOAC_NONE)) then Exit;

               while (ppEnum.Next(Integer(WBEM_INFINITE), 1, apObjects, puReturned)=0) do
               begin
                 pType:=nil;
                 plFlavor:=nil;

                 apObjects.Get('Name', 0, pVal, pType, plFlavor);// String
                 Writeln(Format('Name         %s',[String(pVal)]));//String
                 VarClear(pVal);

                 apObjects.Get('ProcessId', 0, pVal, pType, plFlavor);// Uint32
                 Writeln(Format('ProcessId    %d',[Integer(pVal)]));//Uint32
                 VarClear(pVal);
               end;
            end
            else
            if not GetExtendedErrorInfo(OpResult) then
            Writeln(Format('Error executing WQL sentence %x',[OpResult]));
          finally
            LUnsecuredApartment := nil;
          end;
        finally
          LWbemServices := nil;
        end;
      end
      else
        if not GetExtendedErrorInfo(OpResult) then
        Writeln(Format('Error Connecting to the Server %x',[OpResult]));
    finally
      LWbemLocator := nil;
    end;
  end
  else
   if not GetExtendedErrorInfo(OpResult) then
     Writeln(Format('Failed to create IWbemLocator object %x',[OpResult]));

end;


begin
 try
    if Succeeded(CoInitializeEx(nil, COINIT_MULTITHREADED)) then
    try
      TestWbem;
    finally
      CoUninitialize;
    end;
 except
    on E:Exception do
        Writeln(E.Classname, ':', E.Message);
 end;
 Writeln('Press Enter to exit');
 Readln;
end.