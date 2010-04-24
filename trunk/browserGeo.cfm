<cfparam name="vairables.a" default="40.69847032728747">
<cfparam name="variables.o" default="-73.9514422416687">
<cfparam name="URL.d" default="The current position is">
<html>
<head>
<meta name="viewport" content="initial-scale=1.0, user-scalable=yes" />
<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
<title>Google Maps JavaScript API v3 Demo: Browser Geolocation & URL Geolocation</title>
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=true"></script>
<script type="text/javascript" src="http://code.google.com/apis/gears/gears_init.js"></script>
<cfoutput>
<script type="text/javascript">

var initialLocation;
var newyork = new google.maps.LatLng(#vairables.a#,#variables.o#);
var browserSupportFlag =  new Boolean();
var map;
var infowindow = new google.maps.InfoWindow();
  
function initialize() {
  var myOptions = {
    zoom: 10,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
  <cfif NOT isDefined("URL.a") AND NOT isDefined("URL.o")>
  // Using W3C Geolocation (Browser Geo)
  if(navigator.geolocation) {
    browserSupportFlag = true;
    navigator.geolocation.getCurrentPosition(function(position) {
    	var co_lat=position.coords.latitude;
    	var co_long=position.coords.longitude;
      initialLocation = new google.maps.LatLng(co_lat,co_long);
  var marker = new google.maps.Marker({
      position: initialLocation, 
      map: map
  });
      contentString = "<br />Here is your current location:" + "<br />" + "Latitude: " + co_lat + "<br />" + "Longitude: " + co_long;
      map.setCenter(initialLocation);
      infowindow.setContent(contentString);
      infowindow.setPosition(initialLocation);
      infowindow.open(map);
    }, function() {
      handleNoGeolocation(browserSupportFlag);
    });
  }  else {
    // Browser doesn't support Geolocation
    browserSupportFlag = false;
    handleNoGeolocation(browserSupportFlag);
  }
}

function handleNoGeolocation(errorFlag) {
  if (errorFlag == true) {
    initialLocation = newyork;
    contentString = "Error: Cannot initialize browser geolocation feature. Set to the default location: New York";
  } else {
    initialLocation = newyork;
    contentString = "Error: Your browser doesn't support geolocation. Set to New York";
  }
  map.setCenter(initialLocation);
  infowindow.setContent(contentString);
  infowindow.setPosition(initialLocation);
  infowindow.open(map);
}
<cfelse>
    	var co_lat=#URL.a#;
    	var co_long=#URL.o#;
      initialLocation = new google.maps.LatLng(co_lat,co_long);
  var marker = new google.maps.Marker({
      position: initialLocation, 
      map: map
  });
      contentString = "<br />#URL.d#:" + "<br />" + "Latitude: " + co_lat + "<br />" + "Longitude: " + co_long;
      map.setCenter(initialLocation);
      infowindow.setContent(contentString);
      infowindow.setPosition(initialLocation);
      infowindow.open(map);
    }
</cfif>
</script>
</cfoutput>
</head>
<body style="margin:0px; padding:0px; background-color:#000;" onload="initialize()">
  <div id="map_canvas" style="width:80%; height:100%;margin:0 auto;"></div>
</body>

</html>