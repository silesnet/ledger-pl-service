var restify = require('restify');
var CSON = require('cson');
var invoices;

// var numberBase = 1396000000000;

// function cmpInvoiceNumber(a, b) {
//   if (a.number < b.number)
//     return -1;
//   if (a.number > b.number)
//     return 1;
//   return 0;
// }

function formatJson(req, res, body) {
  if (!body) {
    if (res.getHeader('Content-Length') === undefined &&
        res.contentLength === undefined) {
      res.setHeader('Content-Length', 0);
    }
    return null;
  }

  if (body instanceof Error) {
    if ((body.restCode || body.httpCode) && body.body) {
      body = body.body;
    } else {
      body = {
        message: body.message
      };
    }
  }

  if (Buffer.isBuffer(body))
    body = body.toString('base64');

  var data = JSON.stringify(body, null, 2);

  if (res.getHeader('Content-Length') === undefined &&
      res.contentLength === undefined) {
    res.setHeader('Content-Length', Buffer.byteLength(data));
  }
  return data;
}

var server = restify.createServer({
  formatters: {
    'application/json': formatJson
  }
});

server.use(restify.acceptParser(server.acceptable));
server.use(restify.queryParser());
server.use(restify.bodyParser());
server.use(restify.CORS());
// server.use(restify.fullResponse());

server.get('/invoices', function (req, res, next) {
  var invoice, base;
  invoices = CSON.parseFileSync(__dirname + '/invoices.cson');

  // base = (new Date()).getTime() - numberBase;
  // for (var i = 0; i < invoices.length; i++) {
  //   invoices[i].number = '' + (base + i);
  // }
  res.send({'invoices': invoices});
  return next();
});

server.put('/invoices', function(req, res, next) {
  console.log(req.body);
  res.send(200, {});
  return next();
});

server.listen(8089, function () {
  console.log('%s listening at %s', server.name, server.url);
});
