unit MapsHelper;

interface

type
 TWebMapTypes=(Google_Maps,Yahoo_Map,Bing_Map,Open_Streetmap);
const
 WebMapNames : Array[TWebMapTypes] of string =('Google Maps','Yahoo Maps','Bing Maps','OpenStreetMaps');

 GoogleMapsTypes : Array[0..3] of string =(
 'HYBRID',
 'ROADMAP',
 'SATELLITE',
 'TERRAIN');

 BingMapsTypes : Array[0..4] of string =(
 'Hybrid',
 'Road',
 'Aerial',
 'Oblique',
 'Birdseye'
 );

 YahooMapsTypes : Array[0..2] of string =(
 'HYB',
 'SAT',
 'REG'
 );

const
GoogleMapsPage: AnsiString =
'<html> '+
'<head> '+
'<meta name="viewport" content="initial-scale=1.0, user-scalable=yes" /> '+
'<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=true"></script> '+
'<script type="text/javascript"> '+
'  var map;'+
'  function initialize() { '+
'    geocoder = new google.maps.Geocoder();'+
'    var latlng = new google.maps.LatLng([Lat],[Lng]); '+
'    var myOptions = { '+
'      zoom: 12, '+
'      center: latlng, '+
'      mapTypeId: google.maps.MapTypeId.[Type] '+
'    }; '+
'    map = new google.maps.Map(document.getElementById("map_canvas"), myOptions); '+
'    var marker = new google.maps.Marker({'+
'      position: latlng, '+
'      title: "[Title]", '+
'      map: map '+
'  });'+
'  } '+
''+'</script> '+
'</head> '+
'<body onload="initialize()"> '+
'  <div id="map_canvas" style="width:100%; height:100%"></div> '+
'</body>'+
'</html>';

YahooMapsPage: AnsiString =
'<html> '+
'<head> '+
'<meta name="viewport" content="initial-scale=1.0, user-scalable=yes" /> '+
'<script type="text/javascript" src="http://api.maps.yahoo.com/ajaxymap?v=3.8&amp;appid=08gJIU7V34H9WlTSGrIyEIb73GLT5TpAaF2HzOSJIuTO2AVn6qzftRPDQtcQyynObIG8"></script> '+
'<script type="text/javascript"> '+
'  function initialize() '+
'{'+
'  var map = new YMap ( document.getElementById ( "map_canvas" ) );'+
'  map.addTypeControl();'+
'  map.addZoomLong(); '+
'  map.addPanControl();'+
'	 map.setMapType ( YAHOO_MAP_[Type] );'+
'	 var geopoint = new YGeoPoint ( [Lat] , [Lng] ); '+
'	 map.drawZoomAndCenter ( geopoint , 5 );'+
'  var newMarker= new YMarker(geopoint); '+
'  var markerMarkup = "[Title]";'+
'	 newMarker.openSmartWindow(markerMarkup);'+
'	 map.addOverlay(newMarker);'+
'}'+
''+'</script> '+
'</head> '+
'<body onload="initialize()"> '+
'  <div id="map_canvas" style="width:100%; height:100%"></div> '+
'</body>'+
'</html>';


BingsMapsPage: AnsiString =
'<html> '+
'<head> '+
'<meta name="viewport" content="initial-scale=1.0, user-scalable=yes" /> '+
'<script type="text/javascript" src="http://dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=6.2"></script> '+
'<script type="text/javascript"> '+
'var map = null; '+
'  function initialize() '+
'{'+
'        map = new VEMap("map_canvas"); '+
'        map.LoadMap(new VELatLong([Lat],[Lng]), 10 ,"h" ,false);'+
'        map.SetMapStyle(VEMapStyle.[Type]);'+
'        map.ShowMiniMap((document.getElementById("map_canvas").offsetWidth - 180), 200, VEMiniMapSize.Small);'+
'        map.SetZoomLevel (12);'+
'	       shape = new VEShape(VEShapeType.Pushpin, map.GetCenter()); '+
'	       shape.SetTitle("[Title]");'+
'	       map.AddShape ( shape );'+
'}'+
''+'</script> '+
'</head> '+
'<body onload="initialize()"> '+
'  <div id="map_canvas" style="width:100%; height:100%"></div> '+
'</body>'+
'</html>';

OpenStreetMapsPage: AnsiString =
'<html> '+
'<head> '+
'<meta name="viewport" content="initial-scale=1.0, user-scalable=yes" /> '+
'<script src="http://www.openlayers.org/api/OpenLayers.js"></script> '+
'<script type="text/javascript"> '+
'  function initialize() '+
'{'+
'    map = new OpenLayers.Map("map_canvas");'+
'    map.addLayer(new OpenLayers.Layer.OSM()); '+
'    var lonLat = new OpenLayers.LonLat( [Lng] , [Lat] ) '+
'          .transform( '+
'            new OpenLayers.Projection("EPSG:4326"), '+
'            map.getProjectionObject() '+
'          ); '+
'    var zoom=16; '+
'    var markers = new OpenLayers.Layer.Markers( "Markers" );  '+
'    map.addLayer(markers); '+
'    markers.addMarker(new OpenLayers.Marker(lonLat)); '+
'    map.setCenter (lonLat, zoom); '+
'}'+
''+'</script> '+
'</head> '+
'<body onload="initialize()"> '+
'  <div id="map_canvas" style="width:100%; height:100%"></div> '+
'</body>'+
'</html>';


implementation

end.
