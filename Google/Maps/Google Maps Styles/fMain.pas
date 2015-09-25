unit fMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, StdCtrls, ExtCtrls, XPMan, ComCtrls,MSHTML;

type
  TfrmMain = class(TForm)
    WebBrowser1: TWebBrowser;
    LabelAddress: TLabel;
    PanelHeader: TPanel;
    ButtonGotoLocation: TButton;
    XPManifest1: TXPManifest;
    MemoAddress: TMemo;
    ButtonGotoAddress: TButton;
    LabelLatitude: TLabel;
    LabelLongitude: TLabel;
    Longitude: TEdit;
    Latitude: TEdit;
    CheckBoxTraffic: TCheckBox;
    CheckBoxBicycling: TCheckBox;
    CheckBoxStreeView: TCheckBox;
    ComboBoxSkins: TComboBox;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ButtonGotoAddressClick(Sender: TObject);
    procedure ButtonGotoLocationClick(Sender: TObject);
    procedure CheckBoxTrafficClick(Sender: TObject);
    procedure CheckBoxBicyclingClick(Sender: TObject);
    procedure CheckBoxStreeViewClick(Sender: TObject);
    procedure ComboBoxSkinsChange(Sender: TObject);
  private
    { Private declarations }
    HTMLWindow2: IHTMLWindow2;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
   ActiveX;


{$R *.dfm}

const
HTMLStr: String =
'<html> '+
'<head> '+
'<meta name="viewport" content="initial-scale=1.0, user-scalable=yes" /> '+
'<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=true"></script> '+
'<script type="text/javascript"> '+
''+
''+
'  var geocoder; '+
'  var map;  '+
'  var trafficLayer;'+
'  var bikeLayer;'+

'var styles = {' +
  '''Red'': [' +
    '{' +
      'featureType: ''all'',' +
      'stylers: [{hue: ''#ff0000''}]' +
    '}' +
  '],' + 
  '''Green'': [' + 
    '{' + 
      'featureType: ''all'',' + 
      'stylers: [{hue: ''#00ff00''}]' + 
    '}' +
  '],' + 
  '''Countries'': [' + 
    '{' +  
      'featureType: ''all'',' +  
      'stylers: [' +  
        '{visibility: ''off''}' + 
      ']' +  
    '},' +  
    '{' +  
      'featureType: ''water'',' +
      'stylers: [' +  
        '{visibility: ''on''},' +  
        '{lightness: -100 }' +  
      ']' +  
    '}' + 
  '],' +  
  '''Night'': [' +  
    '{' +  
      'featureType: ''all'',' +  
      'stylers: [{invert_lightness: ''true''}]' +
    '}        ' +  
  '],' +  
  '''Blue'': [' +  
    '{' +  
      'featureType: ''all'',' +  
      'stylers: [' +  
        '{hue: ''#0000b0''},' +  
        '{invert_lightness: ''true''},' +  
        '{saturation: -30}' +  
      ']' +
    '}' +  
  '],' +  
  '''Greyscale'': [' + 
    '{              ' +  
      'featureType: ''all'',' +  
      'stylers: [' +  
        '{saturation: -100},' +  
        '{gamma: 0.50}' +
      ']' +
    '}' +  
  '],' + 
  '''No roads'': [' +  
    '{' +  
      'featureType: ''road'',' +  
      'stylers: [' +  
        '{visibility: ''off''}' +  
      ']' +  
    '}' +
  '],' +  
  '''Mixed'': [' +  
    '{' +  
      'featureType: ''landscape'',' +  
      'stylers: [{hue: ''#00dd00''}]' +  
    '}, {' +  
      'featureType: ''road'',' +  
      'stylers: [{hue: ''#dd0000''}]' +  
    '}, {' +
      'featureType: ''water'',' +  
      'stylers: [{hue: ''#000040''}]' +  
    '}, {' +  
      'featureType: ''poi.park'',' +  
      'stylers: [{visibility: ''off''}]' + 
    '}, {' +  
      'featureType: ''road.arterial'',' +  
      'stylers: [{hue: ''#ffff00''}]' +
    '}, {' +
      'featureType: ''road.local'',' +  
      'stylers: [{visibility: ''off''}]' +  
    '}            ' +  
  '],' +  
  '''Chilled'': [' +  
    '{' +
      'featureType: ''road'',' +  
      'elementType: ''geometry'',' +  
      'stylers: [{''visibility'': ''simplified''}]' +  
    '}, {' +  
      'featureType: ''road.arterial'',' +
      'stylers: [' +
       '{hue: 149},' +  
       '{saturation: -78},' +  
       '{lightness: 0}' +
      ']' +  
    '}, {' +  
      'featureType: ''road.highway'',' +
      'stylers: [' +  
        '{hue: -31},' +  
        '{saturation: -40},' +
        '{lightness: 2.8}' +  
      ']' +
    '}, {' +  
      'featureType: ''poi'',' +
      'elementType: ''label'',' +
      'stylers: [{''visibility'': ''off''}]' +  
    '}, {' +  
      'featureType: ''landscape'',' +
      'stylers: [' +  
        '{hue: 163},' +  
        '{saturation: -26},' +
        '{lightness: -1.1}' + 
      ']' +  
    '}, {' +  
      'featureType: ''transit'',' +
      'stylers: [{''visibility'': ''off''}]' +  
    '}, {' +  
      'featureType: ''water'',' +  
        'stylers: [' +
        '{hue: 3},' +  
        '{saturation: -24.24},' +  
        '{lightness: -38.57}' +
      ']' +
    '}' +
  ']' +  
'};'   +


''+
''+
'  function initialize() { '+
'    geocoder = new google.maps.Geocoder();'+
'    var latlng = new google.maps.LatLng(40.714776,-74.019213); '+
'    var myOptions = { '+
'      zoom: 13, '+
'      center: latlng, '+
//'      mapTypeId: google.maps.MapTypeId.ROADMAP '+
'      mapTypeIds: [google.maps.MapTypeId.ROADMAP, "skin"] '+
'    }; '+
'    map = new google.maps.Map(document.getElementById("map_canvas"), myOptions); '+
'    trafficLayer = new google.maps.TrafficLayer();'+
'    bikeLayer = new google.maps.BicyclingLayer();'+
'    var styledMapOptions = { name: "Skin" };'+
'    var TheMapType = new google.maps.StyledMapType(styles["Red"], styledMapOptions);'+
'    map.mapTypes.set("skin", TheMapType);'+
'    map.setMapTypeId("skin"); '+
'  } '+
''+
''+

'  function SetMapSkin(nameskin) {'+
'  var styledMapOptions = { name: "Skin"};'+
//'  for (var s in styles) {'+
//'    if (s==nameskin) {'+
//'    var TheMapType = new google.maps.StyledMapType(styles[s], styledMapOptions);'+
'    var TheMapType = new google.maps.StyledMapType(styles[nameskin], styledMapOptions);'+
'    map.mapTypes.set("skin", TheMapType);'+
'    map.setMapTypeId("skin"); '+
//'    }'+
//'  };'+

'}'+

'  function codeAddress(address) { '+
'    if (geocoder) {'+
'      geocoder.geocode( { address: address}, function(results, status) { '+
'        if (status == google.maps.GeocoderStatus.OK) {'+
'          map.setCenter(results[0].geometry.location);'+
'          var marker = new google.maps.Marker({'+
'              map: map,'+
'              position: results[0].geometry.location'+
'          });'+
'        } else {'+
'          alert("Geocode was not successful for the following reason: " + status);'+
'        }'+
'      });'+
'    }'+
'  }'+
''+
''+
'  function GotoLatLng(Lat, Lang) { '+
'   var latlng = new google.maps.LatLng(Lat,Lang);'+
'   map.setCenter(latlng);'+
'   var marker = new google.maps.Marker({'+
'      position: latlng,map: map,title:Lat+","+Lang'+
'  });'+
'  }'+
''+
''+
'  function TrafficOn()   { trafficLayer.setMap(map); }'+
''+
'  function TrafficOff()  { trafficLayer.setMap(null); }'+
''+''+
'  function BicyclingOn() { bikeLayer.setMap(map); }'+
''+
'  function BicyclingOff(){ bikeLayer.setMap(null);}'+
''+
'  function StreetViewOn() { map.set("streetViewControl", true); }'+
''+
'  function StreetViewOff() { map.set("streetViewControl", false); }'+
''+
''+'</script> '+
'</head> '+
'<body onload="initialize()"> '+
'  <div id="map_canvas" style="width:100%; height:100%"></div> '+
'</body> '+
'</html> ';


procedure TfrmMain.FormCreate(Sender: TObject);
var
  aStream     : TMemoryStream;
begin
   WebBrowser1.Navigate('about:blank');
    if Assigned(WebBrowser1.Document) then
    begin
      aStream := TMemoryStream.Create;
      try
         aStream.WriteBuffer(Pointer(HTMLStr)^, Length(HTMLStr));
         aStream.Seek(0, soFromBeginning);
         (WebBrowser1.Document as IPersistStreamInit).Load(TStreamAdapter.Create(aStream));
      finally
         aStream.Free;
      end;
      HTMLWindow2 := (WebBrowser1.Document as IHTMLDocument2).parentWindow;
    end;
end;


procedure TfrmMain.ButtonGotoLocationClick(Sender: TObject);
begin
   HTMLWindow2.execScript(Format('GotoLatLng(%s,%s)',[Latitude.Text,Longitude.Text]), 'JavaScript');
end;

procedure TfrmMain.ButtonGotoAddressClick(Sender: TObject);
var
   address    : string;
begin
   address := MemoAddress.Lines.Text;
   address := StringReplace(StringReplace(Trim(address), #13, ' ', [rfReplaceAll]), #10, ' ', [rfReplaceAll]);
   HTMLWindow2.execScript(Format('codeAddress(%s)',[QuotedStr(address)]), 'JavaScript');
end;

procedure TfrmMain.CheckBoxStreeViewClick(Sender: TObject);
begin
    if CheckBoxStreeView.Checked then
     HTMLWindow2.execScript('StreetViewOn()', 'JavaScript')
    else
     HTMLWindow2.execScript('StreetViewOff()', 'JavaScript');

end;

procedure TfrmMain.CheckBoxBicyclingClick(Sender: TObject);
begin
    if CheckBoxBicycling.Checked then
     HTMLWindow2.execScript('BicyclingOn()', 'JavaScript')
    else
     HTMLWindow2.execScript('BicyclingOff()', 'JavaScript');
 end;


procedure TfrmMain.CheckBoxTrafficClick(Sender: TObject);
begin
    if CheckBoxTraffic.Checked then
     HTMLWindow2.execScript('TrafficOn()', 'JavaScript')
    else
     HTMLWindow2.execScript('TrafficOff()', 'JavaScript');
 end;


procedure TfrmMain.ComboBoxSkinsChange(Sender: TObject);
begin
  HTMLWindow2.execScript(Format('SetMapSkin(%s)',[QuotedStr(ComboBoxSkins.Text)]), 'JavaScript');
end;

end.
