var http = require('http');

size=parseInt(process.env['SIZER'])
data=""; for (var i=0;i<size;i++) data+="*";

http.createServer( function (request, response) {
		response.writeHead(200, {'Content-Type': 'text/html'});
		response.end(data);
	} ).listen(9293);

console.log('http://localhost:9293 ready with '+size+' byte response request...');
