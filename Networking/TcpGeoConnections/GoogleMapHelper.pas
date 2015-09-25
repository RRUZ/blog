unit GoogleMapHelper;

interface


const
HTMLStr: AnsiString =
'<html> '+
'<head> '+
'<meta name="viewport" content="initial-scale=1.0, user-scalable=yes" /> '+
'<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=true"></script> '+
'<script type="text/javascript"> '+
''+
''+
//'  var geocoder; '+
''+
'  var markersArray = [];'+
'  var points = [];'+
'  var map;'+
'  var line = null;'+
''+
'  function initialize() { '+
'    geocoder = new google.maps.Geocoder();'+
'    var latlng = new google.maps.LatLng(40.714776,-74.019213); '+
'    var myOptions = { '+
'      zoom: 3, '+
'      center: latlng, '+
'      mapTypeId: google.maps.MapTypeId.HYBRID '+
'    }; '+
'    map = new google.maps.Map(document.getElementById("map_canvas"), myOptions); '+
'  poly = new google.maps.Polyline(polyOptions);'+
'  '+
'  } '+
''+
'function addPoint(Lat, Lang) {  '+
' points.push(new google.maps.LatLng(Lat,Lang)); '+
'} '+
''+
''+
''+
'function DrawTraceRoute() {  '+
'  line = new google.maps.Polyline({ '+
'  map: map, '+
'  path: points, '+
'  strokeColor: "#00FF00", '+
'  strokeWeight: 2, '+
'  strokeOpacity: 1.0 '+
'  }); '+
' line.setMap(map);'+
'}'+
''+
''+
'function ClearTraceRoute() {  '+
' points = [];'+
' if (line !== null) {line.setPath(points); }'+
'}'+
''+


(*
''+
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
*)
''+
'function ClearMarkers() {  '+
'  if (markersArray) {        '+
'    for (i in markersArray) {  '+
'      markersArray[i].setMap(null); '+
'    } '+
'  } '+
'}  '+


''+
'  function PutMarker(Lat, Lang, Msg, image) { '+
'   var latlng = new google.maps.LatLng(Lat,Lang);'+
'   var marker = new google.maps.Marker({'+
'      position: latlng, '+
'      map: map,'+
'      icon: image, '+
'      title: Msg+" ("+Lat+","+Lang+")"'+
'  });'+
' markersArray.push(marker); '+
'  }'+
''+
''+'</script> '+
'</head> '+
'<body onload="initialize()"> '+
'  <div id="map_canvas" style="width:100%; height:100%"></div> '+
'</body> '+
'</html> ';


UrlGooleMapsImageArrow ='http://maps.google.com/mapfiles/arrow.png';
UrlGooleMapsImageLetter='http://www.google.com/mapfiles/marker%s.png';
UrlGooleMapsImage_Purple='http://labs.google.com/ridefinder/images/mm_20_purple.png';
UrlGooleMapsImage_Yellow='http://labs.google.com/ridefinder/images/mm_20_yellow.png';
UrlGooleMapsImage_blue='http://labs.google.com/ridefinder/images/mm_20_blue.png';
UrlGooleMapsImage_white='http://labs.google.com/ridefinder/images/mm_20_white.png';
UrlGooleMapsImage_green='http://labs.google.com/ridefinder/images/mm_20_green.png';
UrlGooleMapsImage_red='http://labs.google.com/ridefinder/images/mm_20_red.png';
UrlGooleMapsImage_black='http://labs.google.com/ridefinder/images/mm_20_black.png';
UrlGooleMapsImage_orange='http://labs.google.com/ridefinder/images/mm_20_orange.png';
UrlGooleMapsImage_gray='http://labs.google.com/ridefinder/images/mm_20_gray.png';
UrlGooleMapsImage_brown='http://labs.google.com/ridefinder/images/mm_20_brown.png';

function GetUrlGooleMapsImageLetter(Letter: Char) : string;

implementation
uses
 SysUtils;

function GetUrlGooleMapsImageLetter(Letter: Char) : string;
begin
 Result:=Format(UrlGooleMapsImageLetter,[Letter]);

end;

end.
