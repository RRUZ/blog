{$APPTYPE CONSOLE}

uses
  SysUtils,
  ActiveX,
  ComObj,
  Variants;

function GetStatusCodeStr(statusCode: integer) : string;
begin
  case statusCode of
    0     : Result := 'Success';
    11001 : Result := 'Buffer Too Small';
    11002 : Result := 'Destination Net Unreachable';
    11003 : Result := 'Destination Host Unreachable';
    11004 : Result := 'Destination Protocol Unreachable';
    11005 : Result := 'Destination Port Unreachable';
    11006 : Result := 'No Resources';
    11007 : Result := 'Bad Option';
    11008 : Result := 'Hardware Error';
    11009 : Result := 'Packet Too Big';
    11010 : Result := 'Request Timed Out';
    11011 : Result := 'Bad Request';
    11012 : Result := 'Bad Route';
    11013 : Result := 'TimeToLive Expired Transit';
    11014 : Result := 'TimeToLive Expired Reassembly';
    11015 : Result := 'Parameter Problem';
    11016 : Result := 'Source Quench';
    11017 : Result := 'Option Too Big';
    11018 : Result := 'Bad Destination';
    11032 : Result := 'Negotiating IPSEC';
    11050 : Result := 'General Failure'
  else
    Result := 'Unknow';
  end;
end;


// The form of the Address parameter can be either the computer name (wxyz1234), IPv4 address (192.168.177.124),
//or IPv6 address (2010:836B:4179::836B:4179).
procedure Ping(const Address: string; Retries, BufferSize: Word);
var
  LSWbemLocator : OLEVariant;
  LWMIService  : OLEVariant;
  LWbemObjectSet : OLEVariant;
  LWbemObject : OLEVariant;
  LEnum : IEnumvariant;
  LValue : LongWord;
  i : Integer;
  PacketsReceived : Integer;
  LMin : Integer;
  LMax : Integer;
  LAvg : Integer;
begin;
  PacketsReceived := 0;
  LMin := 0;
  LMax := 0;
  LAvg := 0;
  Writeln('');
  Writeln(Format('Pinging %s with %d bytes of data:',[Address,BufferSize]));
  LSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  LWMIService := LSWbemLocator.ConnectServer('localhost', 'root\CIMV2', '', '');
  //LWMIService   := LSWbemLocator.ConnectServer('192.168.52.130', 'root\CIMV2', 'user', 'password');
  for i := 0 to Retries-1 do
  begin
    LWbemObjectSet:= LWMIService.ExecQuery(Format('SELECT * FROM Win32_PingStatus where Address=%s AND BufferSize=%d',[QuotedStr(Address),BufferSize]),'WQL',0);
    LEnum  := IUnknown(LWbemObjectSet._NewEnum) as IEnumVariant;
    if LEnum.Next(1, LWbemObject, LValue) = 0 then
    begin
      if LWbemObject.StatusCode = 0 then
      begin
        if LWbemObject.ResponseTime > 0 then
          Writeln(Format('Reply from %s: bytes=%s time=%sms TTL=%s', [LWbemObject.ProtocolAddress,
          LWbemObject.ReplySize, LWbemObject.ResponseTime, LWbemObject.TimeToLive]))
        else
          Writeln(Format('Reply from %s: bytes=%s time=<1ms TTL=%s', [LWbemObject.ProtocolAddress,
          LWbemObject.ReplySize, LWbemObject.TimeToLive]));

        Inc(PacketsReceived);

        if LWbemObject.ResponseTime > LMax then
        LMax := LWbemObject.ResponseTime;

        if LMin = 0 then
        LMin := LMax;

        if LWbemObject.ResponseTime < LMin then
        LMin := LWbemObject.ResponseTime;

        LAvg := LAvg + LWbemObject.ResponseTime;
      end
      else
      if not VarIsNull(LWbemObject.StatusCode) then
        Writeln(Format('Reply from %s: %s', [LWbemObject.ProtocolAddress, GetStatusCodeStr(LWbemObject.StatusCode)]))
      else
        Writeln(Format('Reply from %s: %s', [Address, 'Error processing request']));
    end;
    LWbemObject:=Unassigned;
    LWbemObjectSet:=Unassigned;
    //Sleep(500);
  end;

  Writeln('');
  Writeln(Format('Ping statistics for %s:', [Address]));
  Writeln(Format('    Packets: Sent = %d, Received = %d, Lost = %d (%d%% loss),', [Retries, PacketsReceived, Retries-PacketsReceived,Round((Retries-PacketsReceived)*100/Retries)]));
  if PacketsReceived > 0 then
  begin
   Writeln('Approximate round trip times in milli-seconds:');
   Writeln(Format('    Minimum = %dms, Maximum = %dms, Average = %dms', [LMin, LMax, Round(LAvg / PacketsReceived)]));
  end;
end;


begin
 try
    CoInitialize(nil);
    try
      //Ping('192.168.52.130',4,32);
      Ping('theroadtodelphi.wordpress.com',4,32);
    finally
      CoUninitialize;
    end;
 except
    on E:Exception do
      Writeln(E.Classname, ':', E.Message);
 end;
 Readln;
end.
