<cfparam name="URL.long" default="0">
<cfparam name="URL.lat" default="0">
<cfparam name="URL.zoom" default="8">
<cfparam name="URL.width" default="800">
<cfparam name="URL.height" default="500">
<!doctype html>
<html>
	<head>
		<title>Google Maps API V2 Demo with jQuery</title>
	</head>
	<body>
		<div id="mapSettings">
			<cfoutput>
			<form action="" method="get">
				<label for="long">Longitude: </label>
				<input type="text" name="long" id="long" value="#URL.long#" />
				<label for="lat">Latitude: </label>
				<input type="text" name="lat" id="lat" value="#URL.lat#" />
				<label for="zoom">Zoom Level: </label>
				<input type="text" name="zoom" id="zoom" value="#URL.zoom#" />
				<br />
				Map size:<br />
				<label for="width">Width</label>
				<input type="text" name="width" id="width" value="#URL.width#" />
				<label for="height">Height</label>
				<input type="text" name="height" id="height" value="#URL.height#" /><br />
				<input type="submit" value="Change" />
			</form>
			</cfoutput>
		</div>
		<div><hr /></div>
		<div id="map" style="<cfoutput>width:#URL.width#px;height:#URL.height#px;</cfoutput>"></div>
		<script src="http://www.google.com/jsapi?key=ABQIAAAAPT9xbOtNHgt7EN6HIEQDmxROqpW9pAvYKK_O7cOFTBUSPpOaERSIthqD0YI6oMBVKWV9bkOhvsERwg"></script>
		<script>
			google.load("jquery", "1");
			google.load("maps", "2");
		</script>
		<!--- Download this plugin at http://gmap.nurtext.de/download.html --->
		<script src="scripts/jquery.gmap.js"></script>
		<script>
			$(document).ready(function() {
				<cfoutput>
					var longt = #URL.long#;
					var lat = #URL.lat#;
					<cfif URL.lat EQ 0 AND URL.long EQ 0>
					if (navigator.geolocation) {
						navigator.geolocation.getCurrentPosition(
						function(position) {
							longt = position.coords.longitude;
							lat = position.coords.latitude;
							var redirect = confirm("You are here:\nLatitude: " + lat + "\nLongitude: " + longt + "\nClick OK to place the above mark onto the map");
							if (redirect) {
								location.href = "browserGeojQuery.cfm?long=" + longt + "&lat=" + lat;
							}
							else {
								alert("You have chosen to not show your current position on the map, please use the top form to specify the location and click the Change button.");
							}
						}, function() {
							alert("The geolocation feature for your browser is not available right now, please try again.");
							longt = #URL.long#;
							lat = #URL.lat#;
						});
					}
					else {
						alert("Your browser does not support geolocation feature. Please upgrade your browser.");
						longt = #URL.long#;
						lat = #URL.lat#;
					}
					</cfif>
					var options = {
						latitude: lat,
						longitude: longt,
						zoom: #URL.zoom#,
						<cfif URL.long NEQ 0 AND URL.lat NEQ 0>
						markers: [{
							latitude: lat,
							longitude: longt,
							html: "You are here:<br />Latitude: " + lat + "<br />Longitude: " + longt,
							popup: true
						}],
						</cfif>
						maptype: G_HYBRID_MAP
					};
				</cfoutput>
				$("#map").gMap(options);
				$("#long, #lat, #zoom, #width, #height").focus(function() {
					this.select();
				});
			});
		</script>
	</body>
</html>