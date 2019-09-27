const express = require('express');
var request = require('request');
var fs = require("fs");

const app = express(); 

var options = {
	method: 'GET',
	url: 'http://stagmbxiot.mobilogix.com/api/tenant/devices?limit=4000&textSearch=',
	credentials:"omit",
	headers:{"accept":"application/json, text/plain, */*","accept-language":"en-US,en;q=0.9","x-authorization":"Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ0ZW5hbnQyQG1vYmlsb2dpeC5jb20iLCJzY29wZXMiOlsiVEVOQU5UX0FETUlOIl0sInVzZXJJZCI6IjdmZjRmMjkwLWUwZTYtMTFlOS05NThmLTQzMzkxOTk4YzY0OSIsImVuYWJsZWQiOnRydWUsImlzUHVibGljIjpmYWxzZSwidGVuYW50SWQiOiI2ZWE4OGFiMC1lMGU2LTExZTktOTU4Zi00MzM5MTk5OGM2NDkiLCJjdXN0b21lcklkIjoiMTM4MTQwMDAtMWRkMi0xMWIyLTgwODAtODA4MDgwODA4MDgwIiwiaXNzIjoidGhpbmdzYm9hcmQuaW8iLCJpYXQiOjE1Njk1NjIyNTMsImV4cCI6MTU2OTU3MTI1M30.T4afOG33lMYNqk7mB7D7Q-oc41wCt2wsMcEnuZ5nSQMnQcuJONZubyoq7tjgZaXxTKPPFC_Be03MaxHmhn74Jg"}
}

let options1 = {}

request(options, function (error, response, body) {
  if (error) {
  	console.log(error);
  	return;
  }
  const devices = JSON.parse(body).data;
  const deviceIds = devices.map((device) => {
  		return device.id.id;
  })
  const accessTokens = []
  for(i=0; i<deviceIds.length; i++) {
  	options1 = {
  		method: 'GET',
		url: 'http://stagmbxiot.mobilogix.com/api/device/'+deviceIds[i]+'/credentials',
		credentials:"omit",
		headers:{"accept":"application/json, text/plain, */*","accept-language":"en-US,en;q=0.9","x-authorization":"Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ0ZW5hbnQyQG1vYmlsb2dpeC5jb20iLCJzY29wZXMiOlsiVEVOQU5UX0FETUlOIl0sInVzZXJJZCI6IjdmZjRmMjkwLWUwZTYtMTFlOS05NThmLTQzMzkxOTk4YzY0OSIsImVuYWJsZWQiOnRydWUsImlzUHVibGljIjpmYWxzZSwidGVuYW50SWQiOiI2ZWE4OGFiMC1lMGU2LTExZTktOTU4Zi00MzM5MTk5OGM2NDkiLCJjdXN0b21lcklkIjoiMTM4MTQwMDAtMWRkMi0xMWIyLTgwODAtODA4MDgwODA4MDgwIiwiaXNzIjoidGhpbmdzYm9hcmQuaW8iLCJpYXQiOjE1Njk1NjIyNTMsImV4cCI6MTU2OTU3MTI1M30.T4afOG33lMYNqk7mB7D7Q-oc41wCt2wsMcEnuZ5nSQMnQcuJONZubyoq7tjgZaXxTKPPFC_Be03MaxHmhn74Jg"}
	}
	request(options1, function (err, res, resBody) {
		if(err) {
			console.log(err);
			return;
		}
		const credentials = JSON.parse(resBody)
		let data = `${credentials.credentialsId}`
		fs.appendFile("userlist.csv", data + '\n', (err) => {
		  if (err) console.log(err);
		  console.log("Successfully Written to File.");
		});
	})
  }
});

app.listen(9999, () => {
  console.log('%s App is running at http://localhost:9999 in %s mode');
  console.log('  Press CTRL-C to stop\n');
});

module.exports = app;
