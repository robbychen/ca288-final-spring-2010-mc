<!--- Delete the cookie if the sign out link is clicked --->
<cfif isDefined("URL.sign") AND URL.sign EQ "out">
	<cfcookie name="identifier" expires="now" />
	<cflocation url="http://#cgi.server_name##cgi.SCRIPT_NAME#" />
</cfif>
<!doctype html>
	<head>
		<title>Open ID Demo</title>
	</head>
	<body>
		<!--- RPX API REST Call --->
		<cfif isDefined("form.token")>
			<cfhttp url="http://rpxnow.com/api/v2/auth_info" method="post" charset="utf-8">
				<cfhttpparam type="formfield" name="apiKey" value="69b0e7e665647f6b20e23d6bf9b90ad7f776549b" />
				<cfhttpparam type="formfield" name="token" value="#form.token#">
			</cfhttp>
			<!--- Convert generated JSON to structure --->
			<cfset accountInfos = deserializeJSON(cfhttp.FileContent) />
			<cfif accountInfos.stat EQ "ok">
				<!--- Set cookie if signed in successfully --->
				<cfcookie name="identifier" value="#accountInfos.profile.identifier#" expires="7" />
			<!--- Look for an existing record in the database based on the value inside the converted structure --->
			<cfquery name="qGetInfo" datasource="DSN0111">
				SELECT * FROM userInfo
				WHERE Identifier = '#accountInfos.profile.identifier#'
			</cfquery>
			<!--- Insert data into database if RecordCount is equal to 0 --->
			<cfif qGetInfo.RecordCount EQ 0>
				<cfquery datasource="DSN0111">
					<cfif structCount("#accountInfos.profile.name#") EQ 1>
						<cfset splitName = listToArray("#accountInfos.profile.name.formatted#"," ")>
						<cfset givenName = splitName[1]>
						<cfset familyName = splitName[2]>
					<cfelse>
						<cfset givenName = accountInfos.profile.name.givenName>
						<cfset familyName = accountInfos.profile.name.familyName>
					</cfif>
					INSERT INTO userInfo ("FName","LName","Email","Identifier","Provider") VALUES (
						'#givenName#','#familyName#','#accountInfos.profile.email#','#accountInfos.profile.identifier#','#accountInfos.profile.providerName#'
					)
				</cfquery>
			</cfif>
			</cfif>
		<cfelseif isDefined("cookie.identifier")>
			<!--- Look for an existing record in the database based on the value inside the cookie --->
			<cfquery name="qGetInfo" datasource="DSN0111">
				SELECT * FROM userInfo
				WHERE Identifier = '#cookie.identifier#'
			</cfquery>
		</cfif>
		<p>
		<!--- AJAX Sign in link for the RPX API --->
		<cfif NOT isDefined("cookie.identifier")>
			<a class="rpxnow" onclick="return false;"href="https://ca288-final-demo.rpxnow.com/openid/v2/signin?token_url=http%3A%2F%2F160.253.0.40%2FStudents%2FStudents%2F0111%2FOpenIDapi.cfm"> Sign In </a>
		<cfelse>
			<cfoutput>
				<cfif qGetInfo.RecordCount EQ 0>
					Welcome,
				<cfelse>
					Welcome back,
				</cfif>
				 #qGetInfo.FName# #qGetInfo.LName# <a href="?sign=out">Sign Out</a>
			</cfoutput>
 		</cfif>
		</p>
		<cfif isDefined("form.token")>
			<cfoutput>
				<!--- Output user info --->
				<table border="1" cellspacing="0" cellpadding="5" id="profileRecords">
				<cfloop collection="#accountInfos.profile#" item="profileItem">
				<tr>
					<cfif isStruct(accountInfos.profile[profileItem])>
						<th>#profileItem#</th>
						<td><ul>
							<cfloop collection="#accountInfos.profile[profileItem]#" item="subItem">
							<li>#subItem#: #accountInfos.profile[profileItem][subItem]#</li>
							</cfloop>
						</ul></td>
					<cfelse>
						<th>#profileItem#</th>
						<td>#accountInfos.profile[profileItem]#</td>
					</cfif>
				</tr>
				</cfloop>
				</table>
			</cfoutput>
			<cfelseif isDefined("cookie.identifier")>
				<table border="1" cellpadding="5" cellspacing="0">
					<tr>
						<th>First Name</th>
						<th>Last Name</th>
						<th>Email Name</th>
						<th>Identifier</th>
						<th>Provider</th>
					</tr>
					<tr>
						<cfoutput query="qGetInfo">
							<td>#qGetInfo.FName#</td>
							<td>#qGetInfo.LName#</td>
							<td>#qGetInfo.Email#</td>
							<td>#qGetInfo.Identifier#</td>
							<td>#qGetInfo.Provider#</td>
						</cfoutput>
					</tr>
				</table>
		</cfif>
		<!--- RPX API which uses OpenID API and other social network APIs --->
 		<script type="text/javascript">
  			var rpxJsHost = (("https:" == document.location.protocol) ? "https://" : "http://static.");
  			document.write(unescape("%3Cscript src='" + rpxJsHost + "rpxnow.com/js/lib/rpx.js' type='text/javascript'%3E%3C/script%3E"));
		</script>
		<script type="text/javascript">
  			RPXNOW.overlay = true;
  			RPXNOW.language_preference = 'en';
		</script>
		<style>
			#profileRecords th {
				text-transform:capitalize;
			}
		</style>
	</body>
</html>
