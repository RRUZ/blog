//reference  https://theroadtodelphi.wordpress.com/2013/05/29/enabling-xpath-selectnode-selectnodes-methods-in-vcl-and-firemonkey-apps/

{$APPTYPE CONSOLE}

uses
  {$IFDEF MSWINDOWS}
  System.Win.ComObj,
  Winapi.ActiveX,
  {$ENDIF}
  System.SysUtils,
  Xml.XMLIntf,
  Xml.adomxmldom,
  Xml.XMLDom,
  Xml.XMLDoc;

function selectSingleNode(ADOMDocument: IDOMDocument; const nodePath: WideString): IDOMNode;
var
  LDomNodeSelect : IDomNodeSelect;
begin
  if not Assigned(ADOMDocument) or not Supports(ADOMDocument.documentElement, IDomNodeSelect, LDomNodeSelect) then
   Exit;
  //or just LDomNodeSelect:= (ADOMDocument.documentElement as IDOMNodeSelect);
  if (DefaultDOMVendor = OpenXML4Factory.Description) then
    Tox4DOMNode(LDomNodeSelect).WrapperDocument.WrapperDOMImpl.InitParserAgent;
  Result:=LDomNodeSelect.selectNode(nodePath);
end;

function SelectNodes(ADOMDocument: IDOMDocument; const nodePath: WideString): IDOMNodeList;
var
  LDomNodeSelect : IDomNodeSelect;
begin
  if not Assigned(ADOMDocument) or not Supports(ADOMDocument.documentElement, IDomNodeSelect, LDomNodeSelect) then
   Exit;
  //or just LDomNodeSelect:= (ADOMDocument.documentElement as IDOMNodeSelect);
  if (DefaultDOMVendor = OpenXML4Factory.Description) then
    Tox4DOMNode(LDomNodeSelect).WrapperDocument.WrapperDOMImpl.InitParserAgent;
  Result:=LDomNodeSelect.selectNodes(nodePath);
end;

procedure  TestXPath;
var
  XmlDoc: IXMLDocument;
  Root, Book, Author, Publisher : IXMLNode;
  LNodeList : IDOMNodeList;
  LNode : IDOMNode;
  i : Integer;
begin
  XmlDoc := TXMLDocument.Create(nil);
  XmlDoc.Active := True;
  XmlDoc.Options := XmlDoc.Options + [doNodeAutoIndent];
  XmlDoc.Version := '1.0';

  Root := XmlDoc.CreateNode('BookStore');
  Root.Attributes['url'] := 'http://www.amazon.com';
  XmlDoc.DocumentElement := Root;

  Book := XmlDoc.CreateNode('Book');
  Book.Attributes['Name'] := 'Steve Jobs';
  Author := XmlDoc.CreateNode('Author');
  Author.Text := 'Walter Isaacson';
  Publisher := XmlDoc.CreateNode('Publisher');
  Publisher.Text := 'Simon Schuster (October 24, 2011)';
  Root.ChildNodes.Add(Book);
  Book.ChildNodes.Add(Author);
  Book.ChildNodes.Add(Publisher);

  Book := XmlDoc.CreateNode('Book');
  Book.Attributes['Name'] := 'Clean Code: A Handbook of Agile Software Craftsmanship';
  Author := XmlDoc.CreateNode('Author');
  Author.Text := 'Robert C. Martin';
  Publisher := XmlDoc.CreateNode('Publisher');
  Publisher.Text := 'Prentice Hall; 1 edition (August 11, 2008)';
  Root.ChildNodes.Add(Book);
  Book.ChildNodes.Add(Author);
  Book.ChildNodes.Add(Publisher);

  Book := XmlDoc.CreateNode('Book');
  Book.Attributes['Name'] := 'Paradox Lost';
  Author := XmlDoc.CreateNode('Author');
  Author.Text := 'Kress, Peter';
  Publisher := XmlDoc.CreateNode('Publisher');
  Publisher.Text := 'Prentice Hall; 1 edition (February 2, 2000)';
  Root.ChildNodes.Add(Book);
  Book.ChildNodes.Add(Author);
  Book.ChildNodes.Add(Publisher);

  Writeln(XmlDoc.XML.Text);

  Writeln('selectSingleNode');
  LNode:=selectSingleNode(XmlDoc.DOMDocument,'/BookStore/Book[2]/Author["Robert C. Martin"]');
  if LNode<>nil then
   Writeln(LNode.firstChild.nodeValue);

  Writeln;

  Writeln('SelectNodes');
  LNodeList:=SelectNodes(XmlDoc.DOMDocument,'//BookStore/Book/Author');
  if LNodeList<>nil then
    for i := 0 to LNodeList.length-1 do
      Writeln(LNodeList[i].firstChild.nodeValue);
end;

begin
 try
    ReportMemoryLeaksOnShutdown:=True;
    DefaultDOMVendor := OpenXML4Factory.Description;
    {$IFDEF MSWINDOWS}CoInitialize(nil);{$ENDIF}
    try
      TestXPath;
    finally
    {$IFDEF MSWINDOWS}CoUninitialize;{$ENDIF}
    end;
 except
    {$IFDEF MSWINDOWS}
    on E:EOleException do
        Writeln(Format('EOleException %s %x', [E.Message,E.ErrorCode]));
    {$ENDIF}
    on E:Exception do
        Writeln(E.Classname, ':', E.Message);
 end;
 Writeln;
 Writeln('Press Enter to exit');
 Readln;
end.
