{$APPTYPE CONSOLE}

{$R *.res}

uses
  MSXML,
  ActiveX,
  ComObj,
  Variants,
  IdURI,
  IdHttp,
  IdSSLOpenSSL,
  SysUtils;

procedure GetBingInfoXML_Web(const SearchKey : string;Top, Skip : Integer);
const
 ApplicationID= 'put your key here';
 URI='https://api.datamarket.azure.com/Bing/Search/Web?Query=%s&$format=ATOM&$top=%d&$skip=%d';
var
  XMLDOMDocument  : IXMLDOMDocument;
  XMLDOMNode      : IXMLDOMNode;
  cXMLDOMNode     : IXMLDOMNode;
  XMLDOMNodeList  : IXMLDOMNodeList;
  LIdHTTP : TIdHTTP;
  LIOHandler : TIdSSLIOHandlerSocketOpenSSL;
  LIndex          : Integer;
  Response: string;
begin
  LIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    LIOHandler.SSLOptions.Method := sslvTLSv1;
    LIOHandler.SSLOptions.Mode := sslmUnassigned;
    LIOHandler.SSLOptions.VerifyMode := [];
    LIOHandler.SSLOptions.VerifyDepth := 0;
    LIOHandler.host := '';

    LIdHTTP:= TIdHTTP.Create(nil);
    try
      LIdHTTP.Request.ContentEncoding := 'utf-8';
      LIdHTTP.Request.BasicAuthentication:= True;
      LIdHTTP.Request.Username:=ApplicationID;
      LIdHTTP.Request.Password:=ApplicationID;
      LIdHTTP.IOHandler:= LIOHandler;
      Response:=LIdHTTP.Get(Format(URI,[TIdURI.PathEncode(QuotedStr(SearchKey)), Top, Skip]));

      XMLDOMDocument:=CoDOMDocument.Create;
      try
        XMLDOMDocument.loadXML(Response);
        XMLDOMNode := XMLDOMDocument.selectSingleNode('/feed');
        XMLDOMNodeList := XMLDOMNode.selectNodes('//entry');

        if XMLDOMNodeList<>nil then
        for LIndex:=0 to  XMLDOMNodeList.length-1 do
        begin
           cXMLDOMNode:=XMLDOMNode.selectSingleNode(Format('//entry[%d]/content/m:properties/d:ID',[LIndex]));
           Writeln(Format('id    %s',[String(cXMLDOMNode.Text)]));
           cXMLDOMNode:=XMLDOMNode.selectSingleNode(Format('//entry[%d]/content/m:properties/d:Title',[LIndex]));
           Writeln(Format('Title %s',[String(cXMLDOMNode.Text)]));
           cXMLDOMNode:=XMLDOMNode.selectSingleNode(Format('//entry[%d]/content/m:properties/d:Description',[LIndex]));
           Writeln(Format('Description %s',[String(cXMLDOMNode.Text)]));
           cXMLDOMNode:=XMLDOMNode.selectSingleNode(Format('//entry[%d]/content/m:properties/d:DisplayUrl',[LIndex]));
           Writeln(Format('DisplayUrl %s',[String(cXMLDOMNode.Text)]));
           cXMLDOMNode:=XMLDOMNode.selectSingleNode(Format('//entry[%d]/content/m:properties/d:Url',[LIndex]));
           Writeln(Format('Url %s',[String(cXMLDOMNode.Text)]));

           Writeln;
        end;

      finally
       XMLDOMDocument:=nil;
      end;
    finally
       LIdHTTP.Free;
    end;
  finally
     LIOHandler.Free;
  end;
end;

begin
 try
    CoInitialize(nil);
    try
      GetBingInfoXML_Web('delphi programming blogs', 5, 0);
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