$APPTYPE CONSOLE}

{$R *.res}

uses
  MSXML,
  ActiveX,
  ComObj,
  Variants,
  IdURI,
  SysUtils;

procedure GetBingInfoXML_Web(const SearchKey : string;Top, Skip : Integer);
const
 ApplicationID= 'put your key here';
 URI='https://api.datamarket.azure.com/Bing/Search/Web?Query=%s&$format=ATOM&$top=%d&$skip=%d';
 COMPLETED=4;
 OK       =200;
var
  XMLHTTPRequest  : IXMLHTTPRequest;
  XMLDOMDocument  : IXMLDOMDocument;
  XMLDOMNode      : IXMLDOMNode;
  cXMLDOMNode     : IXMLDOMNode;
  XMLDOMNodeList  : IXMLDOMNodeList;
  LIndex          : Integer;
begin
    XMLHTTPRequest := CreateOleObject('MSXML2.XMLHTTP') As IXMLHTTPRequest;
    XMLHTTPRequest.open('GET',Format(URI,[TIdURI.PathEncode(QuotedStr(SearchKey)), Top, Skip]), False, ApplicationID, ApplicationID);
    XMLHTTPRequest.send('');
    if (XMLHTTPRequest.readyState = COMPLETED) and (XMLHTTPRequest.status = OK) then
    begin
      XMLDOMDocument:=CoDOMDocument.Create;
      try
      XMLDOMDocument.loadXML(XMLHTTPRequest.responseText);
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