const express = require('express');
var request = require('request');
var fs = require("fs");

const app = express(); 

var options = {
	method: 'GET',
	url: 'http://35.154.87.124/api/tenant/devices?limit=4000&textSearch=',
	credentials:"omit",
	headers:{"accept":"application/json, text/plain, */*","accept-language":"en-US,en;q=0.9","x-authorization":"Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ0ZW5hbnRAdGhpbmdzYm9hcmQub3JnIiwic2NvcGVzIjpbIlRFTkFOVF9BRE1JTiJdLCJ1c2VySWQiOiIyYWY2MmJmMC1kODQ1LTExZTktOWFiOC05OTBiNTIzMjAwYzkiLCJlbmFibGVkIjp0cnVlLCJpc1B1YmxpYyI6ZmFsc2UsInRlbmFudElkIjoiMmFjZTdmYjAtZDg0NS0xMWU5LTlhYjgtOTkwYjUyMzIwMGM5IiwiY3VzdG9tZXJJZCI6IjEzODE0MDAwLTFkZDItMTFiMi04MDgwLTgwODA4MDgwODA4MCIsImlzcyI6InRoaW5nc2JvYXJkLmlvIiwiaWF0IjoxNTY5MDc0MTA4LCJleHAiOjE1NjkwODMxMDh9.R7SgSckSPkfwZ7I6lsgE8vmj2AlMMbFLIX4pQwAdV8VkjAZ2Wk_BT1vY3jee0rRFCE0aiFk7pq2zFIZRd7zTJQ"}
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
		url: 'http://35.154.87.124/api/device/'+deviceIds[i]+'/credentials',
		credentials:"omit",
		headers:{"accept":"application/json, text/plain, */*","accept-language":"en-US,en;q=0.9","x-authorization":"Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ0ZW5hbnRAdGhpbmdzYm9hcmQub3JnIiwic2NvcGVzIjpbIlRFTkFOVF9BRE1JTiJdLCJ1c2VySWQiOiIyYWY2MmJmMC1kODQ1LTExZTktOWFiOC05OTBiNTIzMjAwYzkiLCJlbmFibGVkIjp0cnVlLCJpc1B1YmxpYyI6ZmFsc2UsInRlbmFudElkIjoiMmFjZTdmYjAtZDg0NS0xMWU5LTlhYjgtOTkwYjUyMzIwMGM5IiwiY3VzdG9tZXJJZCI6IjEzODE0MDAwLTFkZDItMTFiMi04MDgwLTgwODA4MDgwODA4MCIsImlzcyI6InRoaW5nc2JvYXJkLmlvIiwiaWF0IjoxNTY5MDc0MTA4LCJleHAiOjE1NjkwODMxMDh9.R7SgSckSPkfwZ7I6lsgE8vmj2AlMMbFLIX4pQwAdV8VkjAZ2Wk_BT1vY3jee0rRFCE0aiFk7pq2zFIZRd7zTJQ"}
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
