//reference https://theroadtodelphi.wordpress.com/2011/07/11/using-the-google-safe-browsing-api-from-delphi/
{$APPTYPE CONSOLE}
uses
  Classes,
  Windows,
  WinInet,
  SysUtils;

const
  sUserAgent = 'Mozilla/5.001 (windows; U; NT4.0; en-US; rv:1.0) Gecko/25250101';
  //¡¡¡¡¡¡¡¡¡¡Please be nice and use your own API key, get a key from here http://code.google.com/apis/safebrowsing/key_signup.html ¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡
  sApiKey    = 'ABQIAAAAzY4CKjsBFYV4Rxx0ZQaKlxQL2a1oqOk9I7UVXAZVtWa6uSA2XA';
  sServer    = 'sb-ssl.google.com';
  sPostSafeBrowsing  = '/safebrowsing/api/lookup?client=delphi&apikey=%s&appver=1.5.2&pver=3.0';

function GetWinInetError(ErrorCode:Cardinal): string;
const
   winetdll = 'wininet.dll';
var
  Len: Integer;
  Buffer: PChar;
begin
  Len := FormatMessage(
  FORMAT_MESSAGE_FROM_HMODULE or FORMAT_MESSAGE_FROM_SYSTEM or
  FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_IGNORE_INSERTS or  FORMAT_MESSAGE_ARGUMENT_ARRAY,
  Pointer(GetModuleHandle(winetdll)), ErrorCode, 0, @Buffer, SizeOf(Buffer), nil);
  try
    while (Len > 0) and {$IFDEF UNICODE}(CharInSet(Buffer[Len - 1], [#0..#32, '.'])) {$ELSE}(Buffer[Len - 1] in [#0..#32, '.']) {$ENDIF} do Dec(Len);
    SetString(Result, Buffer, Len);
  finally
    LocalFree(HLOCAL(Buffer));
  end;
end;

function Https_Post(const ServerName,Resource: String;const PostData : AnsiString;Var Response:AnsiString): Integer;
const
  BufferSize=1024*64;
var
  hInet    : HINTERNET;
  hConnect : HINTERNET;
  hRequest : HINTERNET;
  ErrorCode : Integer;
  lpdwBufferLength: DWORD;
  lpdwReserved    : DWORD;
  dwBytesRead     : DWORD;
  lpdwNumberOfBytesAvailable: DWORD;
begin
  Result  :=0;
  Response:='';
  hInet := InternetOpen(PChar(sUserAgent), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);

  if hInet=nil then
  begin
    ErrorCode:=GetLastError;
    raise Exception.Create(Format('InternetOpen Error %d Description %s',[ErrorCode,GetWinInetError(ErrorCode)]));
  end;

  try
    hConnect := InternetConnect(hInet, PChar(ServerName), INTERNET_DEFAULT_HTTPS_PORT, nil, nil, INTERNET_SERVICE_HTTP, 0, 0);
    if hConnect=nil then
    begin
      ErrorCode:=GetLastError;
      raise Exception.Create(Format('InternetConnect Error %d Description %s',[ErrorCode,GetWinInetError(ErrorCode)]));
    end;

    try
      hRequest := HttpOpenRequest(hConnect, 'POST', PChar(Resource), HTTP_VERSION, '', nil, INTERNET_FLAG_SECURE, 0);
      if hRequest=nil then
      begin
        ErrorCode:=GetLastError;
        raise Exception.Create(Format('HttpOpenRequest Error %d Description %s',[ErrorCode,GetWinInetError(ErrorCode)]));
      end;

      try
        //send the post request
        if not HTTPSendRequest(hRequest, nil, 0, @PostData[1], Length(PostData)) then
        begin
          ErrorCode:=GetLastError;
          raise Exception.Create(Format('HttpSendRequest Error %d Description %s',[ErrorCode,GetWinInetError(ErrorCode)]));
        end;

          lpdwBufferLength:=SizeOf(Result);
          lpdwReserved    :=0;
          //get the response code
          if not HttpQueryInfo(hRequest, HTTP_QUERY_STATUS_CODE or HTTP_QUERY_FLAG_NUMBER, @Result, lpdwBufferLength, lpdwReserved) then
          begin
            ErrorCode:=GetLastError;
            raise Exception.Create(Format('HttpQueryInfo Error %d Description %s',[ErrorCode,GetWinInetError(ErrorCode)]));
          end;

         //if the response code =200 then get the body
         if Result=200 then
          if InternetQueryDataAvailable(hRequest, lpdwNumberOfBytesAvailable, 0, 0) then
          begin
            SetLength(Response,lpdwNumberOfBytesAvailable);
            InternetReadFile(hRequest, @Response[1], lpdwNumberOfBytesAvailable, dwBytesRead);
          end
          else
          begin
            ErrorCode:=GetLastError;
            raise Exception.Create(Format('InternetQueryDataAvailable Error %d Description %s',[ErrorCode,GetWinInetError(ErrorCode)]));
          end;

      finally
        InternetCloseHandle(hRequest);
      end;
    finally
      InternetCloseHandle(hConnect);
    end;
  finally
    InternetCloseHandle(hInet);
  end;
end;

function URLEncode(const Url: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Url) do
  begin
    case Url[i] of
      'A'..'Z', 'a'..'z', '0'..'9', '-', '_', '.':
        Result := Result + Url[i];
    else
        Result := Result + '%' + IntToHex(Ord(Url[i]), 2);
    end;
  end;
end;

Procedure TestPost(const UrlList : Array of AnsiString);
var
 Response     : AnsiString;
 ResponseCode : Integer;
 Data         : AnsiString;
 i            : integer;
 LstUrl       : TStringList;
begin
   //create the body request with the url to lookup
   Data:=AnsiString(IntToStr(Length(UrlList)))+#10;
   for i:= low(UrlList) to high(UrlList) do
     Data:=Data+UrlList[i]+#10;

   //make the post request
   ResponseCode:=Https_Post(sServer,Format(sPostSafeBrowsing,[sApiKey]), Data, Response);

   //process the response
   case ResponseCode of
     200:
          begin
             LstUrl:=TStringList.Create;
             try
               LstUrl.Text:=string(Response);
                for i:=0 to  LstUrl.Count-1  do
                 Writeln(Format('The queried URL (%s) is %s',[UrlList[i],LstUrl[i]]));

             finally
               LstUrl.Free;
             end;
          end;
     204: Writeln('NONE of the queried URLs matched the phishing or malware lists, no response body returned');
     400: Writeln('Bad Request — The HTTP request was not correctly formed.');
     401: Writeln('Not Authorized — The apikey is not authorized');
     503: Writeln('Service Unavailable — The server cannot handle the request.');
   else
         Writeln(Format('Unknow response Code (%d)',[ResponseCode]));
   end;
end;

begin
  try
     //check these three urls at once
     TestPost(['orgsite.info','http://www.google.com','http://malware.testing.google.test/testing/malware/']);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.