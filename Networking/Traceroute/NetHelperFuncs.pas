unit NetHelperFuncs;

interface

uses
  Windows,
  Winsock,
  Dialogs,
  SysUtils,
  Classes,
  IdTCPClient;

type
 TGeoInfo   = record
  Status: string;
  CountryCode: string;
  CountryName: string;
  RegionCode: string;
  City: string;
  ZipPostalCode: string;
  Latitude: double;
  Longitude: double;
  TimezoneName: string;
  Gmtoffset: string;
  Isdst: string;
  function LatitudeToString:string;
  function LongitudeToString:string;
 end;

  ProcTraceCallBack    = procedure(const ServerName,ServerIp:string) of object;
  ProcTraceLogCallBack = procedure(const Msg:string) of object;
  TGeoTraceThread = class(TThread)
  private
    DestAddr: in_addr;
    TraceHandle: THandle;
    FDestAddress: string;
    FLogString: string;
    FIcmpTimeOut: Word;
    FMaxHops: Word;
    FResolveHostName: boolean;
    FServerCallBack: string;
    FServerIpCallBack: string;
    FCallBack: ProcTraceCallBack;
    FLogCallBack: ProcTraceLogCallBack;
    FIncludeGeoInfo: boolean;
    FGeoInfo: TGeoInfo;
    function  Trace(const Ttl: Byte): Longint;
    procedure Log;
    procedure IntCallBack;
  public
    procedure Execute; override;
    property  MaxHops: Word read FMaxHops write FMaxHops default 30;
    property  DestAddress: string read FDestAddress write FDestAddress;
    property  IcmpTimeOut: Word read FIcmpTimeOut write FIcmpTimeOut default 5000;
    property  ResolveHostName: boolean read FResolveHostName write FResolveHostName default True;
    property  IncludeGeoInfo: boolean read FIncludeGeoInfo write FIncludeGeoInfo default True;
    property  CallBack: ProcTraceCallBack read FCallBack write FCallBack;
    property  MsgCallBack: ProcTraceLogCallBack read FLogCallBack write FLogCallBack;
  end;


function  GetLocalComputerName: String;
function  GetRemoteHostName(Addr:DWORD): string;   overload;
function  GetRemoteHostName(const Addr: string): string; overload;
function  GetExternalIP: string;
procedure GetGeoInfo(const IpAddress: string;var GeoInfo :TGeoInfo);

implementation

uses
  ActiveX,
  ComObj,
  Variants,
  IdHTTP,
  IdStack;

const
 UrlIpAddress      ='http://dynupdate.no-ip.com/ip.php';
 UrlIpAddress2     ='http://www.whatismyip.com/automation/n09230945.asp';
 UrlGeoLookupInfo  ='http://api.ipinfodb.com/v2/ip_query.php?key=a069ef201ef4c1b61231b3bdaeb797b5488ef879effb23d269bda3a572dc704c&ip=%s&timezone=true';

type

  PIP_option_information = ^TIPOptionInformation;
  TIPOptionInformation   = packed record
    Ttl: Byte;
    Tos: Byte;
    Flags: Byte;
    OptionsSize: Byte;
    OptionsData: Pointer;
  end;


  PIcmpEchoReply= ^TIcmpEchoReply;
  TIcmpEchoReply = packed record
    Address: Longint;
    Status: Longint;
    RoundTripTime: Longint;
    DataSize: Word;
    Reserved: Word;
    Data: Pointer;
    Options: TIPOptionInformation;
  end;

function IcmpCreateFile: THandle; stdcall; external 'ICMP.DLL' name 'IcmpCreateFile';
function IcmpCloseHandle(IcmpHandle: THandle): BOOL; stdcall;  external 'ICMP.DLL' name 'IcmpCloseHandle';
function IcmpSendEcho(IcmpHandle: THandle; DestinationAddress: Longint;  RequestData: Pointer; RequestSize: Word; RequestOptions: PIP_option_information; ReplyBuffer: Pointer; ReplySize, Timeout: DWORD): DWORD; stdcall;  external 'ICMP.DLL' name 'IcmpSendEcho';


{ TGeoInfo }

function TGeoInfo.LatitudeToString: string;
var
  FormatSettings: TFormatSettings;
begin
  FormatSettings.DecimalSeparator:='.';
  result:=FloatToStr(Latitude,FormatSettings);
end;

function TGeoInfo.LongitudeToString: string;
var
  FormatSettings: TFormatSettings;
begin
  FormatSettings.DecimalSeparator:='.';
  result:=FloatToStr(Longitude,FormatSettings);
end;

procedure GetGeoInfo(const IpAddress: string;var GeoInfo :TGeoInfo);
var
  lHTTP: TIdHTTP;
  lStream: TStringStream;
  XMLDoc: OleVariant;
  ANode: OleVariant;
  FormatSettings: TFormatSettings;
  d: Double;
  Success: HResult;
begin
  lHTTP := TIdHTTP.Create(nil);
  lStream := TStringStream.Create('');
  Success := CoInitializeEx(nil, COINIT_MULTITHREADED);
  try
      lHTTP.Get(Format(UrlGeoLookupInfo,[IpAddress]), lStream);
      lStream.Seek(0,soFromBeginning);
      XMLDoc := CreateOleObject('Msxml2.DOMDocument.6.0');
      XMLDoc.async := false;
      XMLDoc.LoadXML(lStream.ReadString(lStream.Size));
      XMLDoc.setProperty('SelectionLanguage','XPath');
      ANode:=XMLDoc.selectSingleNode('/Response/Status');
      if not VarIsNull(ANode) then GeoInfo.Status:=ANode.Text;
      ANode:=XMLDoc.selectSingleNode('/Response/CountryCode');
      if not VarIsNull(ANode) then GeoInfo.CountryCode:=ANode.Text;
      ANode:=XMLDoc.selectSingleNode('/Response/CountryName');
      if not VarIsNull(ANode) then GeoInfo.CountryName:=ANode.Text;
      ANode:=XMLDoc.selectSingleNode('/Response/RegionCode');
      if not VarIsNull(ANode) then GeoInfo.RegionCode:=ANode.Text;
      ANode:=XMLDoc.selectSingleNode('/Response/City');
      if not VarIsNull(ANode) then GeoInfo.City:=ANode.Text;
      ANode:=XMLDoc.selectSingleNode('/Response/ZipPostalCode');
      if not VarIsNull(ANode) then GeoInfo.ZipPostalCode:=ANode.Text;


      ANode:=XMLDoc.selectSingleNode('/Response/Latitude');
      if not VarIsNull(ANode) then
      begin
        FormatSettings.DecimalSeparator:='.';
        d:=StrToFloat(ANode.Text,FormatSettings);
        GeoInfo.Latitude:=d;
      end;

      ANode:=XMLDoc.selectSingleNode('/Response/Longitude');
      if not VarIsNull(ANode) then
      begin
        FormatSettings.DecimalSeparator:='.';
        d:=StrToFloat(ANode.Text,FormatSettings);
        GeoInfo.Longitude:=d;
      end;

      ANode:=XMLDoc.selectSingleNode('/Response/TimezoneName');
      if not VarIsNull(ANode) then GeoInfo.TimezoneName:=ANode.Text;
      ANode:=XMLDoc.selectSingleNode('/Response/Gmtoffset');
      if not VarIsNull(ANode) then GeoInfo.Gmtoffset:=ANode.Text;
      ANode:=XMLDoc.selectSingleNode('/Response/Isdst');
      if not VarIsNull(ANode) then GeoInfo.Isdst:=ANode.Text;
  finally
    lHTTP.Free;
    lStream.Free;
    case Success of
      S_OK, S_FALSE: CoUninitialize;
    end;
  end;
end;

function GetLocalComputerName: String;
var
  Buffer: array[0..255] of Char;
  Size: DWORD;
begin
  size := 256;
  if GetComputerName(Buffer, Size) then
    Result := Buffer
  else
    Result := '';
end;

function GetRemoteHostName(Addr:DWORD): string;  overload;
var
  HostEnt: PHostEnt;
begin
  Result:='';
   HostEnt := GetHostByAddr(PChar(@Addr), SizeOf(DWORD), AF_INET);
   if HostEnt <> nil then
      Result := string(HostEnt^.h_name);
end;

function GetRemoteHostName(const Addr: string): string; overload;
begin
   Result:=GetRemoteHostName(inet_addr(PAnsiChar(Addr)));
end;



function GetExternalIP: string;
var
  lHTTP: TIdHTTP;
  lStream: TStringStream;
begin
  lHTTP := TIdHTTP.Create(nil);
  lStream := TStringStream.Create(Result);
  try
    try
      lHTTP.Get(UrlIpAddress, lStream);
      lStream.Seek(0,0);
      Result := lStream.ReadString(lStream.Size);
    except
      Result:='';
    end;
  finally
    FreeAndNil(lHTTP);
    FreeAndNil(lStream);
  end;
end;


{ TTraceThread }

procedure TGeoTraceThread.Execute;
const
  MaxPings = 3;
var
  HostName: String;
  HostReply: Boolean;
  HostIP: LongInt;
  HostEnt: PHostEnt;
  WSAData: TWSAData;
  WsaErr: DWORD;
  OldTick: DWORD;
  PingTime: DWORD;
  TraceResp: Longint;
  Index: Word;
  FCurrentTTL: Word;
  sValue: string;
  FGeoInfoStr: string;
  IpAddress: in_addr;
begin

  WsaErr := WSAStartup($101, WSAData);
  if WsaErr <> 0 then
  begin
    FLogString := SysErrorMessage(WSAGetLastError);
    if Assigned(FLogCallBack)then Synchronize(Log);
    Exit;
  end;

  try
    HostEnt := gethostbyname(PAnsiChar(AnsiString(FDestAddress)));
    if not Assigned(HostEnt) then
    begin
      FLogString := SysErrorMessage(WSAGetLastError);
      if Assigned(FLogCallBack) then Synchronize(Log);
      Exit;
    end;

    DestAddr := PInAddr(in_addr(HostEnt.h_addr_list^))^;
    TraceHandle := IcmpCreateFile;

    if TraceHandle = INVALID_HANDLE_VALUE then
    begin
      FLogString := SysErrorMessage(GetLastError);
      if Assigned(FLogCallBack) then Synchronize(Log);
      Exit;
    end;

    try

      if Assigned(FLogCallBack)then
      begin
        //FLogString := Format('Tracing route to %s [%s]',[FDestAddress,AddrToIPStr(DestAddr.S_addr)]);
        FLogString := Format('Tracing route to %s [%s]',[FDestAddress,string(inet_ntoa(DestAddr))]);
        Synchronize(Log);
        FLogString := Format('over a maximum of %d hops ',[FMaxHops]);
        Synchronize(Log);
      end;

      TraceResp := 0;
      FCurrentTTL := 0;

      while (TraceResp <> DestAddr.S_addr) and (FCurrentTTL < FMaxHops) do
      begin
        Inc(FCurrentTTL);
        HostReply := False;
        sValue:='';
        for Index := 0 to MaxPings-1 do
        begin
          OldTick := GetTickCount;
          TraceResp := Trace(FCurrentTTL);

          if TraceResp = -1 then
            FLogString := '    *    '
          else
          begin
            PingTime   :=GetTickCount - OldTick;

            if PingTime>0 then
             FLogString := Format('%6d ms', [PingTime])
            else
             FLogString := Format('    <%d ms', [1]);

            HostReply := True;
            HostIP := TraceResp;
          end;

          if Index = 0 then
            FLogString := Format('%3d %s', [FCurrentTTL, FLogString]);

          sValue:=sValue+FLogString;
        end;

        FLogString:=sValue+' ';

        if HostReply then
        begin
          IpAddress.s_addr :=HostIP;
          sValue :=string(inet_ntoa(IpAddress));

          FGeoInfoStr:='';
          if FIncludeGeoInfo then
          begin
            GetGeoInfo(sValue,FGeoInfo);
            FGeoInfoStr:=Format('(%s,%s) %s-%s TimeZone %s',[FGeoInfo.LongitudeToString,FGeoInfo.LatitudeToString,FGeoInfo.CountryName,FGeoInfo.City,FGeoInfo.TimezoneName]);
          end;

          FServerCallBack  :='';
          FServerIpCallBack:=sValue;
          if FResolveHostName then
          begin
            HostName := GetRemoteHostName(HostIP);
            FServerCallBack := HostName;
            if HostName <> '' then
              FLogString := FLogString + HostName + ' [' + sValue + '] '+FGeoInfoStr
            else
              FLogString := FLogString + sValue +' '+ FGeoInfoStr;
          end
          else
          FLogString := FLogString + sValue+' '+ FGeoInfoStr;

          if Assigned(FCallBack) then Synchronize(IntCallBack);
        end
        else
          FLogString := FLogString+' Request timed out.';

        FLogString := '  ' + FLogString;
        if Assigned(FLogCallBack) then Synchronize(Log);
      end;

    finally
      IcmpCloseHandle(TraceHandle);
    end;

    if Assigned(FLogCallBack) then
    begin
      FLogString := 'Trace complete';
      Synchronize(Log);
    end;

  finally
    WSACleanup;
  end;
end;

function TGeoTraceThread.Trace(const Ttl: Byte): Longint;
var
  IPOptionInfo: TIPOptionInformation;
  IcmpEcho: PIcmpEchoReply;
  IcpmErr: Integer;
begin
  GetMem(IcmpEcho, SizeOf(TIcmpEchoReply));
  try
    IPOptionInfo.Ttl := Ttl;
    IPOptionInfo.Tos := 0;
    IPOptionInfo.Flags := 0;
    IPOptionInfo.OptionsSize := 0;
    IPOptionInfo.OptionsData := nil;

    IcpmErr := IcmpSendEcho(TraceHandle,DestAddr.S_addr,nil,0,@IPOptionInfo,IcmpEcho,SizeOf(TIcmpEchoReply),FIcmpTimeOut);
    if IcpmErr = 0 then
    begin
      Result := -1;
      Exit;
    end;
    Result := IcmpEcho.Address;
  finally
    FreeMem(IcmpEcho);
  end;
end;

procedure TGeoTraceThread.IntCallBack;
begin
  FCallBack(FServerCallBack,FServerIpCallBack);
end;

procedure TGeoTraceThread.Log;
begin
  FLogCallBack(FLogString);
end;



end.
