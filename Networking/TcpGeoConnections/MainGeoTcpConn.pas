unit MainGeoTcpConn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, IpHelperApi, ImgList, NetHelperFuncs, OleCtrls,
  SHDocVw, StdCtrls, MapsHelper;

type
  TFrmMain = class(TForm)
    PanelMain: TPanel;
    ListViewIPaddress: TListView;
    SplitterMain: TSplitter;
    ImageList1: TImageList;
    PanelMap: TPanel;
    WebBrowser1: TWebBrowser;
    Panel1: TPanel;
    ComboBoxMaps: TComboBox;
    Label1: TLabel;
    LabelType: TLabel;
    ComboBoxTypes: TComboBox;
    ButtonReload: TButton;
    CheckBoxRemote: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListViewIPaddressClick(Sender: TObject);
    procedure ComboBoxMapsChange(Sender: TObject);
    procedure ComboBoxTypesChange(Sender: TObject);
    procedure ButtonReloadClick(Sender: TObject);
  private
    FCurrentMapType: TWebMapTypes;
    FLocalIpAddresses: TStrings;
    FLocalComputerName: string;
    FExtendedTcpTable: PMIB_TCPTABLE_OWNER_PID;
    FExternalIpAddress: string;
    procedure GetMapListItem;
    procedure LoadTCPConnections;
  public
  end;

var
  FrmMain: TFrmMain;

implementation
{$R *.dfm}


uses
   ActiveX,
   MSHTML,
   IdStack,
   TlHelp32,
   Winsock;

const
 COLUMN_APP         =0;
 COLUMN_Protocol    =1;
 COLUMN_LocalServer =2;
 COLUMN_LocalIP     =3;
 COLUMN_LocalPort   =4;
 COLUMN_RemoteServer=5;
 COLUMN_RemoteIP    =6;
 COLUMN_RemotePort  =7;
 COLUMN_Status      =8;
 COLUMN_Country     =9;
 COLUMN_City        =10;
 COLUMN_Longitude   =11;
 COLUMN_Latitude    =12;

type
   TResolveGeoLocation = class(TThread)
   private
     FListItem: TListItem;
     FGeoInfo: TGeoInfoClass;
     FRemoteHostName: string;
     FRemoteIP: string;
     FServer: Cardinal;
     FImageList: TImageList;
     procedure SetData;
   protected
     procedure Execute; override;
     constructor Create(Server: Cardinal;const RemoteIP:string;ImageList:TImageList;ListItem:TListItem);
   end;

{
function BuildUrlStaticMapUrl(const Lat,Lng, MapType,ImgFormat:string;Zoom,Width,Height:Integer;Marker:Boolean): string;
begin
  Result:=Format('%scenter=%s,%s&zoom=%d&size=%dx%d&maptype=%s&sensor=false&format=%s',[UrlPrefix,Lat,Lng,Zoom,Width,Height,MapType,ImgFormat]);
  if Marker then
    Result:=Result+'&markers=color:blue|'+Lat+','+Lng;
end;
}


procedure TFrmMain.ButtonReloadClick(Sender: TObject);
begin
 LoadTCPConnections;
end;

procedure TFrmMain.ComboBoxMapsChange(Sender: TObject);
var
  i: Integer;
begin
  FCurrentMapType:=TWebMapTypes(ComboBoxMaps.ItemIndex);

  ComboBoxTypes.Items.Clear;
  case FCurrentMapType of
   Google_Maps: for i:= Low(GoogleMapsTypes) to High(GoogleMapsTypes) do
                  ComboBoxTypes.Items.Add(GoogleMapsTypes[i]);
   Bing_Map: for i:= Low(BingMapsTypes) to High(BingMapsTypes) do
                  ComboBoxTypes.Items.Add(BingMapsTypes[i]);
   Yahoo_Map: for i:= Low(YahooMapsTypes) to High(YahooMapsTypes) do
                  ComboBoxTypes.Items.Add(YahooMapsTypes[i]);
  end;

  if ComboBoxTypes.Items.Count>0 then
  ComboBoxTypes.ItemIndex:=0;

  ComboBoxTypes.Visible:=ComboBoxTypes.Items.Count>0;
  LabelType.Visible    :=ComboBoxTypes.Items.Count>0;

  GetMapListItem();
end;

procedure TFrmMain.ComboBoxTypesChange(Sender: TObject);
begin
  GetMapListItem();
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
   libHandle: THandle;
   MapType: TWebMapTypes;
begin
  FLocalIpAddresses :=TStringList.Create;
  TIdStack.IncUsage;
  try
    GStack.AddLocalAddressesToList(FLocalIpAddresses);
  finally
    TIdStack.DecUsage;
  end;
  FLocalComputerName:=GetLocalComputerName;
  libHandle := LoadLibrary(iphlpapi);
  GetExtendedTcpTable := GetProcAddress(libHandle, 'GetExtendedTcpTable');

  for MapType:=Low(TWebMapTypes) to High(TWebMapTypes) do
   ComboBoxMaps.Items.Add(WebMapNames[MapType]);

  ComboBoxMaps.ItemIndex:=0;
  ComboBoxMapsChange(ComboBoxMaps);
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  FLocalIpAddresses.Free;
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  LoadTCPConnections;
end;


function GetPIDName(hSnapShot: THandle; PID: DWORD): string;
var
  ProcInfo: TProcessEntry32;
begin
  ProcInfo.dwSize := SizeOf(ProcInfo);
  if not Process32First(hSnapShot, ProcInfo) then
     Result := 'Unknow'
  else
  repeat
    if ProcInfo.th32ProcessID = PID then
       Result := ProcInfo.szExeFile;
  until not Process32Next(hSnapShot, ProcInfo);
end;

procedure TFrmMain.GetMapListItem();
var
 HTMLWindow2: IHTMLWindow2;
 MemoryStream: TMemoryStream;
 Item: TListItem;
 Lat: AnsiString;
 Lng: AnsiString;
 Title: AnsiString;
 MapType: string;
 MapStr: AnsiString;

//sorry , but tha html pages contains a lot of % (porcent) chars
function ReplaceTag(const PageStr,Tag,NewValue:string):AnsiString;
begin
   Result:=AnsiString(StringReplace(PageStr,Tag,NewValue,[rfReplaceAll]));
end;


begin
    Item:=ListViewIPaddress.Selected;
    if not Assigned(Item) then  exit;
    if Item.SubItems.Count<COLUMN_Latitude then Exit;
    if Item.SubItems[COLUMN_Latitude]='' then Exit;

    Lat:=AnsiString(Item.SubItems[COLUMN_Latitude]);
    Lng:=AnsiString(Item.SubItems[COLUMN_Longitude]);
    Title:=AnsiString(Format('(%s,%s) %s - %s',[Lat,Lng,Item.SubItems[COLUMN_RemoteServer],Item.SubItems[COLUMN_RemoteIP]]));
    MapType:=ComboBoxTypes.Text;

   //WebBrowser1.HandleNeeded;
   WebBrowser1.Navigate('about:blank');
   while WebBrowser1.ReadyState < READYSTATE_INTERACTIVE do
    Application.ProcessMessages;

    if Assigned(WebBrowser1.Document) then
    begin
      MemoryStream := TMemoryStream.Create;
      try
        case FCurrentMapType of
          Google_Maps: MapStr:=GoogleMapsPage;
          Yahoo_Map: MapStr:=YahooMapsPage;
          Bing_Map: MapStr:=BingsMapsPage;
          Open_Streetmap: MapStr:=OpenStreetMapsPage;
        end;

        MapStr:=ReplaceTag(MapStr,'[Lat]',Lat);
        MapStr:=ReplaceTag(MapStr,'[Lng]',Lng);
        MapStr:=ReplaceTag(MapStr,'[Title]',Title);
        MapStr:=ReplaceTag(MapStr,'[Type]',MapType);
        MemoryStream.WriteBuffer(Pointer(MapStr)^, Length(MapStr));

        MemoryStream.Seek(0, soFromBeginning);
        (WebBrowser1.Document as IPersistStreamInit).Load(TStreamAdapter.Create(MemoryStream));
      finally
         MemoryStream.Free;
      end;
      HTMLWindow2 := (WebBrowser1.Document as IHTMLDocument2).parentWindow;
    end;
end;

{
procedure TFrmMain.GetMapListItem(Item: TListItem);
var
  StreamData: TMemoryStream;
  JPEGImage: TJPEGImage;
  UrlImage: string;
  lHTTP: TIdHTTP;
  Server: Cardinal;
  IsLocal: Boolean;
begin

  if Item.SubItems.Count<COLUMN_Latitude then Exit;
  if Item.SubItems[COLUMN_Latitude]='' then Exit;

  UrlImage := BuildUrlStaticMapUrl(Item.SubItems[COLUMN_Latitude],Item.SubItems[COLUMN_Longitude],'hybrid','jpg',FCurrentZoom,400,400,True);
  Server := Cardinal(Item.SubItems.Objects[COLUMN_RemoteServer]);
  IsLocal := (FLocalIpAddresses.IndexOf(Item.SubItems[COLUMN_RemoteIP])>=0) or (Server=0) or (Server=16777343);

  if Assigned(Item.Data) then
  begin
     JPEGImage := TJPEGImage(Item.Data);
     ImageMap.Picture.Assign(JPEGImage);
  end
  else
  begin
      StreamData := TMemoryStream.Create;
      JPEGImage := TJPEGImage.Create;
      lHTTP := TIdHTTP.Create(nil);
      lHTTP.Request.UserAgent:='Mozilla/3.0';
      try
        try
         lHTTP.Get(UrlImage, StreamData);
         StreamData.Seek(0,soFromBeginning);
         JPEGImage.LoadFromStream(StreamData);
         ImageMap.Picture.Assign(JPEGImage);
         //Item.Data:=JPEGImage;
        except on E: Exception Do
         MessageDlg('Exception: '+E.Message,mtError, [mbOK], 0);
        end;
      finally
        StreamData.free;
        JPEGImage.Free;
        lHTTP.Free;
      end;
  end;
end;
}

procedure TFrmMain.ListViewIPaddressClick(Sender: TObject);
begin
   GetMapListItem();
end;

procedure TFrmMain.LoadTCPConnections;
var
   Server: Cardinal;
   Error: DWORD;
   TableSize: DWORD;
   Snapshot: THandle;
   i: integer;
   ListItem: TListItem;
   IpAddress: in_addr;
   FCurrentPid: Cardinal;
   IsLocal: Boolean;
   RemoteIp: string;
begin
   ListViewIPaddress.Items.BeginUpdate;
   try
     ListViewIPaddress.Items.Clear;
     FCurrentPid:=GetCurrentProcessId();
     FExternalIpAddress:=GetExternalIP;
      TableSize := 0;
      Error := GetExtendedTcpTable(nil, @TableSize, False, AF_INET, TCP_TABLE_OWNER_PID_ALL, 0);
      if Error <> ERROR_INSUFFICIENT_BUFFER then
         Exit;
      try
         GetMem(FExtendedTcpTable, TableSize);
         SnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
         if GetExtendedTcpTable(FExtendedTcpTable, @TableSize, TRUE, AF_INET, TCP_TABLE_OWNER_PID_ALL, 0) = NO_ERROR then
            for i := 0 to FExtendedTcpTable.dwNumEntries - 1 do
            if (FExtendedTcpTable.Table[i].dwOwningPid<>0) and (FExtendedTcpTable.Table[i].dwOwningPid<>FCurrentPid) and (FExtendedTcpTable.Table[i].dwRemoteAddr<>0) then
            begin
               IpAddress.s_addr := FExtendedTcpTable.Table[i].dwRemoteAddr;
               RemoteIp := string(inet_ntoa(IpAddress));
               Server :=  FExtendedTcpTable.Table[i].dwRemoteAddr;
               IsLocal := (FLocalIpAddresses.IndexOf(RemoteIp)>=0) or (Server=0) or (Server=16777343);// or IpAddressIsLAN(RemoteIp);

               if CheckBoxRemote.Checked and IsLocal then Continue;
               if FExtendedTcpTable.Table[i].dwRemoteAddr = 0 then
               FExtendedTcpTable.Table[i].dwRemotePort := 0;

               ListItem:=ListViewIPaddress.Items.Add;

               ListItem.ImageIndex:=-1;
               ListItem.Caption:=IntToStr(FExtendedTcpTable.Table[i].dwOwningPid);
               ListItem.SubItems.Add(GetPIDName(SnapShot,FExtendedTcpTable.Table[i].dwOwningPid));
               ListItem.SubItems.Add('TCP');
               ListItem.SubItems.Add(FLocalComputerName);

               IpAddress.s_addr := FExtendedTcpTable.Table[i].dwLocalAddr;
               ListItem.SubItems.Add(string(inet_ntoa(IpAddress)));
               ListItem.SubItems.Add(IntToStr(FExtendedTcpTable.Table[i].dwLocalPort));

               ListItem.SubItems.AddObject('',Pointer(FExtendedTcpTable.Table[i].dwRemoteAddr));

               IpAddress.s_addr := FExtendedTcpTable.Table[i].dwRemoteAddr;
               ListItem.SubItems.Add(RemoteIp);
               ListItem.SubItems.Add(IntToStr(FExtendedTcpTable.Table[i].dwRemotePort));
               ListItem.SubItems.Add(MIB_TCP_STATE[FExtendedTcpTable.Table[i].dwState]);

               ListItem.SubItems.Add('');
               ListItem.SubItems.Add('');
               ListItem.SubItems.Add('');
               ListItem.SubItems.Add('');
            end;

      finally
         FreeMem(FExtendedTcpTable);
      end;

   finally
    ListViewIPaddress.Items.EndUpdate;
   end;

    for i:= 0 to ListViewIPaddress.Items.Count-1 do
    begin
      Server:=Cardinal(ListViewIPaddress.Items.Item[i].SubItems.Objects[COLUMN_RemoteServer]);
      IsLocal := (FLocalIpAddresses.IndexOf(ListViewIPaddress.Items.Item[i].SubItems[COLUMN_RemoteIP])>=0) or (Server=0) or (Server=16777343);
      if not IsLocal then
        TResolveGeoLocation.Create(Server,ListViewIPaddress.Items.Item[i].SubItems[COLUMN_RemoteIP],ImageList1,ListViewIPaddress.Items.Item[i]);
    end;
end;


{ TResolveServerName }
constructor TResolveGeoLocation.Create(Server: Cardinal;const RemoteIP:string;ImageList:TImageList;ListItem:TListItem);
begin
   inherited Create(False);
   FServer   :=Server;
   FRemoteIP :=RemoteIP;
   FImageList:=ImageList;
   FListItem :=ListItem;
   FreeOnTerminate := True;
end;

procedure TResolveGeoLocation.Execute;
begin
  FreeOnTerminate := True;
  FRemoteHostName := GetRemoteHostName(FServer);
  FGeoInfo:=TGeoInfoClass.Create(FRemoteIP);
  try
   Synchronize(SetData);
  finally
   FGeoInfo.Free;
  end;
end;

procedure TResolveGeoLocation.SetData;
var
   Bitmap: TBitmap;
begin
    FListItem.SubItems[COLUMN_RemoteServer]:=FRemoteHostName;
    FListItem.SubItems[COLUMN_Country]     :=FGeoInfo.GeoInfo.CountryName;
    FListItem.SubItems[COLUMN_City]        :=FGeoInfo.GeoInfo.City;
    FListItem.SubItems[COLUMN_Latitude]    :=FGeoInfo.GeoInfo.LatitudeToString;
    FListItem.SubItems[COLUMN_Longitude]   :=FGeoInfo.GeoInfo.LongitudeToString;

    if Assigned(FGeoInfo.GeoInfo.FlagImage) then
    begin
       Bitmap := TBitmap.Create;
      try
        Bitmap.Assign(FGeoInfo.GeoInfo.FlagImage);
        if (Bitmap.Width=FImageList.Width) and ((Bitmap.Height=FImageList.Height)) then
         FListItem.ImageIndex:=FImageList.Add(Bitmap,nil)
        else
         Bitmap.Width;
      finally
        Bitmap.Free;
      end;
    end;

    FListItem.MakeVisible(False);
end;


end.
