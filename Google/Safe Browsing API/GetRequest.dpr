// reference https://theroadtodelphi.wordpress.com/2011/07/11/using-the-google-safe-browsing-api-from-delphi/
{$APPTYPE CONSOLE}

uses
  Classes,
  Windows,
  WinInet,
  SysUtils;

const
  sUserAgent = 'Mozilla/5.001 (windows; U; NT4.0; en-US; rv:1.0) Gecko/25250101';
  // ¡¡¡¡¡¡¡¡¡¡Please be nice and use your own API key, get a key from here http://code.google.com/apis/safebrowsing/key_signup.html ¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡
  sApiKey = 'ABQIAAAAzY4CKjsBFYV4Rxx0ZQaKlxQL2a1oqOk9I7UVXAZVtWa6uSA2XA';
  sServer = 'sb-ssl.google.com';
  sGetSafeBrowsing = '/safebrowsing/api/lookup?client=delphi&apikey=%s&appver=1.5.2&pver=3.0&url=%s';

  // this function translate a WinInet Error Code to a description of the error.
function GetWinInetError(ErrorCode: Cardinal): string;
const
  winetdll = 'wininet.dll';
var
  Len: Integer;
  Buffer: PChar;
begin
  Len := FormatMessage(FORMAT_MESSAGE_FROM_HMODULE or
    FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_ALLOCATE_BUFFER or
    FORMAT_MESSAGE_IGNORE_INSERTS or FORMAT_MESSAGE_ARGUMENT_ARRAY,
    Pointer(GetModuleHandle(winetdll)), ErrorCode, 0, @Buffer,
    SizeOf(Buffer), nil);
  try
    while (Len > 0) and
    {$IFDEF UNICODE}(CharInSet(Buffer[Len - 1], [#0 .. #32, '.']))
    {$ELSE}(Buffer[Len - 1] in [#0 .. #32, '.']) {$ENDIF} do
      Dec(Len);
    SetString(Result, Buffer, Len);
  finally
    LocalFree(HLOCAL(Buffer));
  end;
end;

// make a GET request using the WinInet functions
function Https_Get(const ServerName, Resource: string;
  Var Response: AnsiString): Integer;
const
  BufferSize = 1024 * 64;
var
  hInet: HINTERNET;
  hConnect: HINTERNET;
  hRequest: HINTERNET;
  ErrorCode: Integer;
  lpvBuffer: PAnsiChar;
  lpdwBufferLength: DWORD;
  lpdwReserved: DWORD;
  dwBytesRead: DWORD;
  lpdwNumberOfBytesAvailable: DWORD;
begin
  Result := 0;
  Response := '';
  hInet := InternetOpen(PChar(sUserAgent), INTERNET_OPEN_TYPE_PRECONFIG,
    nil, nil, 0);

  if hInet = nil then
  begin
    ErrorCode := GetLastError;
    raise Exception.Create(Format('InternetOpen Error %d Description %s',
      [ErrorCode, GetWinInetError(ErrorCode)]));
  end;

  try
    hConnect := InternetConnect(hInet, PChar(ServerName), INTERNET_DEFAULT_HTTPS_PORT, nil, nil, INTERNET_SERVICE_HTTP, 0, 0);
    if hConnect = nil then
    begin
      ErrorCode := GetLastError;
      raise Exception.Create(Format('InternetConnect Error %d Description %s', [ErrorCode, GetWinInetError(ErrorCode)]));
    end;

    try
      // make the request
      hRequest := HttpOpenRequest(hConnect, 'GET', PChar(Resource), HTTP_VERSION, '', nil, INTERNET_FLAG_SECURE, 0);
      if hRequest = nil then
      begin
        ErrorCode := GetLastError;
        raise Exception.Create(Format('HttpOpenRequest Error %d Description %s', [ErrorCode, GetWinInetError(ErrorCode)]));
      end;

      try
        // send the GET request
        if not HttpSendRequest(hRequest, nil, 0, nil, 0) then
        begin
          ErrorCode := GetLastError;
          raise Exception.Create(Format('HttpSendRequest Error %d Description %s', [ErrorCode, GetWinInetError(ErrorCode)]));
        end;

        lpdwBufferLength := SizeOf(Result);
        lpdwReserved := 0;
        // get the status code
        if not HttpQueryInfo(hRequest, HTTP_QUERY_STATUS_CODE or
          HTTP_QUERY_FLAG_NUMBER, @Result, lpdwBufferLength, lpdwReserved) then
        begin
          ErrorCode := GetLastError;
          raise Exception.Create(Format('HttpQueryInfo Error %d Description %s',
            [ErrorCode, GetWinInetError(ErrorCode)]));
        end;

        if Result = 200 then
        // read the body response in case which the status code is 200
          if InternetQueryDataAvailable(hRequest, lpdwNumberOfBytesAvailable,
            0, 0) then
          begin
            GetMem(lpvBuffer, lpdwBufferLength);
            try
              SetLength(Response, lpdwNumberOfBytesAvailable);
              InternetReadFile(hRequest, @Response[1], lpdwNumberOfBytesAvailable, dwBytesRead);
            finally
              FreeMem(lpvBuffer);
            end;
          end
          else
          begin
            ErrorCode := GetLastError;
            raise Exception.Create(Format('InternetQueryDataAvailable Error %d Description %s', [ErrorCode, GetWinInetError(ErrorCode)]));
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

// encode a Url
function URLEncode(const Url: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Url) do
  begin
    case Url[i] of
      'A' .. 'Z', 'a' .. 'z', '0' .. '9', '-', '_', '.':
        Result := Result + Url[i];
    else
      Result := Result + '%' + IntToHex(Ord(Url[i]), 2);
    end;
  end;
end;

// Send The GET request and process the returned body
Procedure TestGet(const AUrl: string);
var
  Response: AnsiString;
  ResponseCode: Integer;
begin
  ResponseCode := Https_Get(sServer, Format(sGetSafeBrowsing,
    [sApiKey, URLEncode(AUrl)]), Response);
  case ResponseCode of
    200: Writeln(Format('The queried URL (%s) is %s', [AUrl, Response]));
    204: Writeln(Format('The queried URL (%s) is %s', [AUrl, 'legitimate']));
    400: Writeln('Bad Request — The HTTP request was not correctly formed.');
    401: Writeln('Not Authorized — The apikey is not authorized');
    503: Writeln('Service Unavailable — The server cannot handle the request.');
  else
    Writeln('Unknow response');
  end;
end;

begin
  try
    // Now check some urls.
    TestGet('http://malware.testing.google.test/testing/malware/');
    TestGet('orgsite.info');
    TestGet('http://www.google.com');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;

end.
