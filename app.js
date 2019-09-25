const express = require('express');
var request = require('request');
var fs = require("fs");

const app = express(); 

var options = {
	method: 'GET',
	url: 'http://165.22.209.17/api/tenant/devices?limit=5000&textSearch=',
	credentials:"omit",
	headers:{"accept":"application/json, text/plain, */*","accept-language":"en-US,en;q=0.9","x-authorization":"Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ0ZW5hbnRAdGhpbmdzYm9hcmQub3JnIiwic2NvcGVzIjpbIlRFTkFOVF9BRE1JTiJdLCJ1c2VySWQiOiJjMTY1YzEwMC1kZjViLTExZTktODRjMC1jNTZlMzdkYTI1Y2QiLCJlbmFibGVkIjp0cnVlLCJpc1B1YmxpYyI6ZmFsc2UsInRlbmFudElkIjoiYzEzNTE0MTAtZGY1Yi0xMWU5LTg0YzAtYzU2ZTM3ZGEyNWNkIiwiY3VzdG9tZXJJZCI6IjEzODE0MDAwLTFkZDItMTFiMi04MDgwLTgwODA4MDgwODA4MCIsImlzcyI6InRoaW5nc2JvYXJkLmlvIiwiaWF0IjoxNTY5MzkyMTQ2LCJleHAiOjE1Njk0MDExNDZ9.7CRGUoKyW6lVw0t-3uU9Q_p6y5PnwfBO8pCAntkcShTRD8_hXP2HH6FtlAaay7vq5rwoZtjx8KtUoP76mNd_4g"}
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
		url: 'http://165.22.209.17/api/device/'+deviceIds[i]+'/credentials',
		credentials:"omit",
		headers:{"accept":"application/json, text/plain, */*","accept-language":"en-US,en;q=0.9","x-authorization":"Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ0ZW5hbnRAdGhpbmdzYm9hcmQub3JnIiwic2NvcGVzIjpbIlRFTkFOVF9BRE1JTiJdLCJ1c2VySWQiOiJjMTY1YzEwMC1kZjViLTExZTktODRjMC1jNTZlMzdkYTI1Y2QiLCJlbmFibGVkIjp0cnVlLCJpc1B1YmxpYyI6ZmFsc2UsInRlbmFudElkIjoiYzEzNTE0MTAtZGY1Yi0xMWU5LTg0YzAtYzU2ZTM3ZGEyNWNkIiwiY3VzdG9tZXJJZCI6IjEzODE0MDAwLTFkZDItMTFiMi04MDgwLTgwODA4MDgwODA4MCIsImlzcyI6InRoaW5nc2JvYXJkLmlvIiwiaWF0IjoxNTY5MzkyMTQ2LCJleHAiOjE1Njk0MDExNDZ9.7CRGUoKyW6lVw0t-3uU9Q_p6y5PnwfBO8pCAntkcShTRD8_hXP2HH6FtlAaay7vq5rwoZtjx8KtUoP76mNd_4g"}
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
