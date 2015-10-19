unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, StdCtrls, ExtCtrls, XPMan, ComCtrls,MSHTML;

type
  TFrmMain = class(TForm)
    WebBrowser1: TWebBrowser;
    PanelHeader: TPanel;
    ButtonGotoLocation: TButton;
    XPManifest1: TXPManifest;
    LabelLatitude: TLabel;
    LabelLongitude: TLabel;
    Longitude: TEdit;
    Latitude: TEdit;
    ButtonClearMarkers: TButton;
    ListView1: TListView;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure ButtonClearMarkersClick(Sender: TObject);
    procedure WebBrowser1CommandStateChange(ASender: TObject; Command: Integer;  Enable: WordBool);
    procedure ButtonGotoLocationClick(Sender: TObject);
  private
    HTMLWindow2: IHTMLWindow2;
    procedure AddLatLngToList(const Lat,Lng:string);
  public
  end;

var
  FrmMain: TFrmMain;

implementation


{$R *.dfm}

uses
   ActiveX;


const
HTMLStr: AnsiString =
'<html> '+
'<head> '+
'<meta name="viewport" content="initial-scale=1.0, user-scalable=yes" /> '+
'<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3&sensor=false&language=en"></script> '+
//'<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script> '+
'<script type="text/javascript"> '+
''+
''+
'  var geocoder; '+
'  var map;  '+
'  var markersArray = [];'+
''+
''+
'  function initialize() { '+
'    geocoder = new google.maps.Geocoder();'+
'    var latlng = new google.maps.LatLng(40.714776,-74.019213); '+
'    var myOptions = { '+
'      zoom: 13, '+
'      center: latlng, '+
'      mapTypeId: google.maps.MapTypeId.ROADMAP '+
'    }; '+
'    map = new google.maps.Map(document.getElementById("map_canvas"), myOptions); '+
'    map.set("streetViewControl", false);'+
'    google.maps.event.addListener(map, "click", '+
'         function(event) '+
'                        {'+
'                         document.getElementById("LatValue").value = event.latLng.lat(); '+
'                         document.getElementById("LngValue").value = event.latLng.lng(); '+
'                         PutMarker(document.getElementById("LatValue").value, document.getElementById("LngValue").value,"") '+
'                        } '+
'   ); '+
''+
'  } '+
''+
''+
'  function GotoLatLng(Lat, Lang) { '+
'   var latlng = new google.maps.LatLng(Lat,Lang);'+
'   map.setCenter(latlng);'+
'  }'+
''+
''+
'function ClearMarkers() {  '+
'  if (markersArray) {        '+
'    for (i in markersArray) {  '+
'      markersArray[i].setMap(null); '+
'    } '+
'  } '+
'}  '+
''+
'  function PutMarker(Lat, Lang, Msg) { '+
'   var latlng = new google.maps.LatLng(Lat,Lang);'+
'   var marker = new google.maps.Marker({'+
'      position: latlng, '+
'      map: map,'+
'      title: Msg+" ("+Lat+","+Lang+")"'+
'  });'+
'  markersArray.push(marker); '+
'  index= (markersArray.length % 10);'+
'  if (index==0) { index=10 } '+
'  icon = "http://www.google.com/mapfiles/kml/paddle/"+index+"-lv.png"; '+
'  marker.setIcon(icon); '+
'  }'+
''+
''+
''+'</script> '+
'</head> '+
''+
'<body onload="initialize()"> '+
'  <div id="map_canvas" style="width:100%; height:100%"></div> '+
'  <div id="latlong"> '+
'  <input type="hidden" id="LatValue" >'+
'  <input type="hidden" id="LngValue" >'+
'  </div>  '+
''+
'</body> '+
'</html> ';


procedure TFrmMain.FormCreate(Sender: TObject);
var
  aStream     : TMemoryStream;
begin
   WebBrowser1.Navigate('about:blank');
    if Assigned(WebBrowser1.Document) then
    begin
      aStream := TMemoryStream.Create;
      try
         aStream.WriteBuffer(Pointer(HTMLStr)^, Length(HTMLStr));
         //aStream.Write(HTMLStr[1], Length(HTMLStr));
         aStream.Seek(0, soFromBeginning);
         (WebBrowser1.Document as IPersistStreamInit).Load(TStreamAdapter.Create(aStream));
      finally
         aStream.Free;
      end;
      HTMLWindow2 := (WebBrowser1.Document as IHTMLDocument2).parentWindow;
    end;
end;


procedure TFrmMain.WebBrowser1CommandStateChange(ASender: TObject;  Command: Integer; Enable: WordBool);
var
  ADocument : IHTMLDocument2;
  ABody     : IHTMLElement2;
  Lat : string;
  Lng : string;

      function GetIdValue(const Id : string):string;
      var
        Tag      : IHTMLElement;
        TagsList : IHTMLElementCollection;
        Index    : Integer;
      begin
        Result:='';
        TagsList := ABody.getElementsByTagName('input');
        for Index := 0 to TagsList.length-1 do
        begin
          Tag:=TagsList.item(Index, EmptyParam) As IHTMLElement;
          if CompareText(Tag.id,Id)=0 then
            Result := Tag.getAttribute('value', 0);
        end;
      end;

begin
  if TOleEnum(Command) <> CSC_UPDATECOMMANDS then
    Exit;

  ADocument := WebBrowser1.Document as IHTMLDocument2;
  if not Assigned(ADocument) then
    Exit;

  if not Supports(ADocument.body, IHTMLElement2, ABody) then
    exit;

  Lat :=GetIdValue('LatValue');
  Lng :=GetIdValue('LngValue');
  if  (Lat<>'') and (Lng<>'') and ((Lat<>Latitude.Text) or (Lng<>Longitude.Text)) then
  begin
    Latitude.Text :=Lat;
    Longitude.Text:=Lng;
    AddLatLngToList(Lat, Lng);
  end;
end;

procedure TFrmMain.AddLatLngToList(const Lat, Lng: string);
var
  Item  : TListItem;
begin
   if (Lat<>'') and (Lng<>'') then
   begin
     Item:=ListView1.Items.Add;
     Item.Caption:=Lng;
     Item.SubItems.Add(Lat);
     Item.MakeVisible(False);
   end;
end;

procedure TFrmMain.ButtonClearMarkersClick(Sender: TObject);
begin
  HTMLWindow2.execScript('ClearMarkers()', 'JavaScript');
  ListView1.Items.Clear;
end;

procedure TFrmMain.ButtonGotoLocationClick(Sender: TObject);
begin
  if Assigned(ListView1.Selected) then
    HTMLWindow2.execScript(Format('GotoLatLng(%s,%s)',[ListView1.Selected.SubItems[0],ListView1.Selected.Caption]), 'JavaScript');
end;

end.
