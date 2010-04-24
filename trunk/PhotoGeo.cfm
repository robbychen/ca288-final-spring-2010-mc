<cfparam name="URL.address" default="Addo National Elephant Park">
<cfparam name="URL.number" default="10">
<cfparam name="URL.zoom" default="13">
<cfparam name="variables.point" default="">
<cfif URL.address EQ "Addo National Elephant Park">
	<cfset variables.point = "new GLatLng(-30,25)">
</cfif>

<!DOCTYPE html>
<!--
 Copyright 2008 Google Inc. 
 Licensed under the Apache License, Version 2.0: 
 http://www.apache.org/licenses/LICENSE-2.0 
 -->
<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
    <title>Google Maps API Panoramio layer</title>
    <script src="http://maps.google.com/maps?file=api&amp;v=2.98&amp;key=ABQIAAAAPT9xbOtNHgt7EN6HIEQDmxROqpW9pAvYKK_O7cOFTBUSPpOaERSIthqD0YI6oMBVKWV9bkOhvsERwg" type="text/javascript"></script>
    <script src="http://gmaps-utility-library.googlecode.com/svn/trunk/markermanager/release/src/markermanager.js" type="text/javascript"></script>
<cfoutput>
	<script type="text/javascript">
	function PanoramioLayerCallback(json, panoLayer) {
  this.panoLayer = panoLayer;
  for (var i = 0; i < json.photos.length; i++) {
    var photo = json.photos[i];
    if (!panoLayer.ids[photo.photo_id]) {
      var marker = this.createMarker(photo, panoLayer.markerIcon);
      panoLayer.mgr.addMarker(marker, 0);
      panoLayer.ids[photo.photo_id] = "exists";
      panoLayer.mgr.addMarker(marker, panoLayer.map.getZoom());
    }
  }
}

PanoramioLayerCallback.prototype.formImgUrl = function(photoId, imgType) {
  return 'http://www.panoramio.com/photos/' + imgType + '/' + photoId + '.jpg';
}
 
PanoramioLayerCallback.prototype.formPageUrl = function(photoId) {
  return 'http://www.panoramio.com/photo/' + photoId;
}

PanoramioLayerCallback.prototype.createMarker = function(photo, baseIcon) {
  var me = this;
  var markerIcon = new GIcon(baseIcon);
  markerIcon.image = this.formImgUrl(photo.photo_id, "mini_square");
  var marker = new GMarker(new GLatLng(photo.latitude, photo.longitude), {icon: markerIcon, title: photo.photo_title});

  if (photo.photo_title.length > 33) {
    photo.photo_title = photo.photo_title.substring(0, 33) + "&##8230;";
  }
  var html = "<div id='infowin' style='height:320px; width:240px;'>" +
            "<p><a href='http://www.panoramio.com/' target='_blank'>" + 
             "<img src='http://www.panoramio.com/img/logo-small.gif' border='0' width='119px' height='25px' alt='Panoramio logo' /><\/a></p>" +
             "<a id='photo_infowin' target='_blank' href='" + photo.photo_url + "'>" +                
             "<img border='0' width='" + photo.width + "' height='" + photo.height + "' src='" + photo.photo_file_url + "'/><\/a>" +
             "<div style='overflow: hidden; width: 240px;'>" +
             "<p><a target='_blank' class='photo_title' href='" + photo.photo_url +
             "'><strong>" + photo.photo_title + "<\/strong><\/a></p>" +
             "<p>Posted by <a target='_blank' href='" + photo.owner_url + "'>" +
             photo.owner_name + "<\/a></p><\/div>" +
             "<\/div>";

  marker.html = html;

  GEvent.addListener(marker, "click", function() {
    me.panoLayer.map.openInfoWindow(marker.getLatLng(), marker.html, {noCloseOnClick: true});
  });
 
  return marker;
}


function PanoramioLayer(map, opt_opts) {
  var me = this;
  me.map = map;
  me.ids = {};
  me.mgr = new MarkerManager(map, {maxZoom: 19});

  var icon = new GIcon();
  icon.image = "http://www.panoramio.com/img/panoramio-marker.png"; 
  icon.shadow = "";  
  icon.iconSize = new GSize(24, 24); 
  icon.shadowSize = new GSize(22, 22); 
  icon.iconAnchor = new GPoint(9, 9);  
  icon.infoWindowAnchor = new GPoint(9, 0); 

  me.markerIcon = icon;
  me.enabled = false;

  GEvent.addListener(map, "moveend", function() {
    if (me.enabled) {
      var bounds = map.getBounds();
      var southWest = bounds.getSouthWest();
      var northEast = bounds.getNorthEast();
      me.load(me, {maxy: northEast.lat(), miny: southWest.lat(), maxx: northEast.lng(), minx: southWest.lng()});
    }
  });
}

PanoramioLayer.prototype.enable = function() {
  this.enabled = true;
  GEvent.trigger(map, "moveend");
}

PanoramioLayer.prototype.disable = function() {
  this.enabled = false;
  this.mgr.clearMarkers();
  this.ids = {};
}

PanoramioLayer.prototype.getEnabled = function() {
  return this.enabled;
}

PanoramioLayer.prototype.load = function(panoLayer, userOptions) {
  var options = {
    order: "upload_date",
    set: "full",
    from: "0",
    to: "#URL.number#",
    minx: "-32",
    miny: "23",
    maxx: "-34",
    maxy: "27",
    size: "small"
  };
 
  for (optionName in userOptions) {
    if (userOptions.hasOwnProperty(optionName)) {
      options[optionName] = userOptions[optionName];
    }
  }
 
  var url = "http://www.panoramio.com/map/get_panoramas.php?";
  var uniqueID = "";
 
  for (optionName in options) {
    if (options.hasOwnProperty(optionName)) {
      var optionVal = "" + options[optionName] + "";
      url += optionName + "=" + optionVal + "&";
      uniqueID += optionVal.replace(/[^\w]+/g,"");
    }
  }
  var callbackName = "PanoramioLayerCallback.loader" + uniqueID; //ask dion
  eval(callbackName + " = function(json) { var pa = new PanoramioLayerCallback(json, panoLayer);}");
 
  var script = document.createElement('script');
  script.setAttribute('src', url + 'callback=' + callbackName);
  script.setAttribute('id', 'jsonScript');
  script.setAttribute('type', 'text/javascript');
  document.documentElement.firstChild.appendChild(script);
}
	</script>
	<script type="text/javascript">
	/*
* PanoMapTypeControl Class 
*  Copyright (c) 2007, Google 
*  Author: Pamela Fox, others
* 
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* 
*       http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
* This class lets you add a control to the map which mimics GMapTypeControl
*  and allows for the addition of a traffic button/traffic key.
*/

/*
 * Constructor for PanoMapTypeControl
 */
function PanoMapTypeControl(opt_opts) {
  this.options = opt_opts || {};
}


PanoMapTypeControl.prototype = new GControl();

/**
 * Is called by GMap2's addOverlay method. Creates the button 
 *  and appends to the map div.
 * @param {GMap2} map The map that has had this PanoMapTypeControl added to it.
 * @return {DOM Object} Div that holds the control
 */ 
PanoMapTypeControl.prototype.initialize = function(map) {
  var container = document.createElement("div");
  var me = this;
  var panoDiv = me.createButton_("Photos");
  panoDiv.style.marginRight = "8px";
   if (me.panoLayer) {
        me.panoLayer.enable();
    } else {
      me.panoLayer = new PanoramioLayer(map);
      me.panoLayer.enable();
    }
  me.toggleButton_(panoDiv.firstChild, true);
   GEvent.addDomListener(panoDiv, "click", function() {
    if (me.panoLayer) {
      if (me.panoLayer.getEnabled()) {
        me.panoLayer.disable();
      } else {
        me.panoLayer.enable();
      }
    } else {
      me.panoLayer = new PanoramioLayer(map);
      me.panoLayer.enable();
    }
    me.toggleButton_(panoDiv.firstChild, me.panoLayer.getEnabled());
  });

  var mapDiv = me.createButton_("Map");
  var satDiv = me.createButton_("Satellite");
  var hybDiv = me.createButton_("Hybrid");
 
  me.assignButtonEvent_(mapDiv, map, G_NORMAL_MAP, [satDiv, hybDiv]);
  me.assignButtonEvent_(satDiv, map, G_SATELLITE_MAP, [mapDiv, hybDiv]);
  me.assignButtonEvent_(hybDiv, map, G_HYBRID_MAP, [satDiv, mapDiv]);
  GEvent.addListener(map, "maptypechanged", function() {
    if (map.getCurrentMapType() == G_NORMAL_MAP) {
      GEvent.trigger(mapDiv, "click"); 
    } else if (map.getCurrentMapType() == G_SATELLITE_MAP) {
      GEvent.trigger(satDiv, "click");
    } else if (map.getCurrentMapType() == G_HYBRID_MAP) {
      GEvent.trigger(hybDiv, "click");
    }
  });

  container.appendChild(panoDiv);
  container.appendChild(mapDiv);
  container.appendChild(satDiv);
  container.appendChild(hybDiv);

  map.getContainer().appendChild(container);

  GEvent.trigger(map, "maptypechanged");
  return container;
}

/*
 * Creates simple buttons with text nodes. 
 * @param {String} text Text to display in button
 * @return {DOM Object} The div for the button.
 */
PanoMapTypeControl.prototype.createButton_ = function(text) {
  var buttonDiv = document.createElement("div");
  this.setButtonStyle_(buttonDiv);
  buttonDiv.style.cssFloat = "left";
  buttonDiv.style.styleFloat = "left";
  var textDiv = document.createElement("div");
  textDiv.appendChild(document.createTextNode(text));
  textDiv.style.width = "6em";
  buttonDiv.appendChild(textDiv);
  return buttonDiv;
}

/*
 * Assigns events to MapType buttons to change maptype
 *  and toggle button styles correctly for all buttons
 *  when button is clicked.
 *  @param {DOM Object} div Button's div to assign click to
 *  @param {GMap2} Map object to change maptype of.
 *  @param {Object} mapType GMapType to change map to when clicked
 *  @param {Array} otherDivs Array of other button divs to toggle off
 */  
PanoMapTypeControl.prototype.assignButtonEvent_ = function(div, map, mapType, otherDivs) {
  var me = this;

  GEvent.addDomListener(div, "click", function() {
    for (var i = 0; i < otherDivs.length; i++) {
      me.toggleButton_(otherDivs[i].firstChild, false);
    }
    me.toggleButton_(div.firstChild, true);
    map.setMapType(mapType);
  });
}

/*
 * Changes style of button to appear on/off depending on boolean passed in.
 * @param {DOM Object} div  Button div to change style of
 * @param {Boolean} boolCheck Used to decide to use on style or off style
 */
PanoMapTypeControl.prototype.toggleButton_ = function(div, boolCheck) {
   div.style.fontWeight = boolCheck ? "bold" : "";
   div.style.border = "1px solid white";
   var shadows = boolCheck ? ["Top", "Left"] : ["Bottom", "Right"];
   for (var j = 0; j < shadows.length; j++) {
     div.style["border" + shadows[j]] = "1px solid ##b0b0b0";
  } 
}

/*
 * Required by GMaps API for controls. 
 * @return {GControlPosition} Default location for control
 */
PanoMapTypeControl.prototype.getDefaultPosition = function() {
  return new GControlPosition(G_ANCHOR_TOP_RIGHT, new GSize(7, 7));
}

/*
 * Sets the proper CSS for the given button element.
 * @param {DOM Object} button Button div to set style for
 */
PanoMapTypeControl.prototype.setButtonStyle_ = function(button) {
  button.style.color = "##000000";
  button.style.backgroundColor = "white";
  button.style.font = "small Arial";
  button.style.border = "1px solid black";
  button.style.padding = "0px";
  button.style.margin= "0px";
  button.style.textAlign = "center";
  button.style.fontSize = "12px"; 
  button.style.cursor = "pointer";
}
	</script>
    <script type="text/javascript">
    //<![CDATA[

var map = null;
var geocoder = null;
function setupMap() {
  if (GBrowserIsCompatible()) {
    map = new GMap2(document.getElementById("map"));
    map.setCenter(new GLatLng(-30,25), 6);
    map.addControl(new GSmallMapControl());
    map.enableDoubleClickZoom();
    map.enableScrollWheelZoom();
    map.addControl(new PanoMapTypeControl()); 
    geocoder = new GClientGeocoder();
  }
      if (geocoder) {
      	<cfif variables.point EQ "new GLatLng(-30,25)">
			var address = "Addo National Elephant Park";
			var point = "#variables.point#";
		<cfelse>
			var address = "#URL.address#";
		</cfif>
        geocoder.getLatLng(
          address,
          function(point) {
            if (!point) {
              alert(address + " not found");
            } else {
              map.setCenter(point, <cfif variables.point EQ "new GLatLng(-30,25)">6<cfelse>#URL.zoom#</cfif>);
              var marker = new GMarker(point);
              map.addOverlay(marker);
              <!--- // Open Information Window
              marker.openInfoWindowHtml("#URL.address#");
			--->
            }
          }
        );
      }
}
    //]]>
    </script>
</cfoutput>
  </head>

  <body onload="setupMap()" onunload="GUnload()" style="margin:0;padding:0;background-color:#000;color:#FFF">
    <div id="map" style="width:800px;height:600px;"></div>
    <br/>
    Photos provided by Panoramio are under the copyright of their owners.
  </body>
</html>