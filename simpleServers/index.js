/**
 * Handle which endpoints to expose for server
 *  - ServerA = Hashing
 *  - ServerB = Encryption
 * 
 */

// Fetch required libs
const
    express = require('express'),
    bodyParser = require('body-parser'),
    Parser = require('./supporting/arg_parser/parser'),
    appLogger = require('./supporting/logging/appLogger'),
    hashingRouter = require('./Routes/hashingRouter'),
    cipherRouter = require('./Routes/cipherRouter')
;


/**
 * 
 * Parse command line arguments for 
 * 
 */

// Configure cmd-line arg parser
const parser = new Parser();
parser.setDescription("Simple web server, for kubernetes tinkering with a Server-A & Server-B.");
parser.addArg("Server", "Which server to run", "-S,--server");
parser.addArg("Port", "Which port to listen on", "-P,--port");
parser.addArg("Host", "Which IP to listen on", "-H,--host")
parser.updateGlobalVariables();


// Parse server and port
const parsedServer = parser.getGlobalArgumentValue("Server");
if ( parsedServer == null ) {
    appLogger.warn("Warning, no server mode detected exposing hashing and encrypting endpoints");
}
const server = parsedServer ?? "serverC";

const parsedPort = parser.getGlobalArgumentValue("Port");
if ( parsedPort == null ) {
    appLogger.warn(`Warning, server port not defined defaulting to 8080`);
}
const port = parsedPort ?? 8080;


// Parse host
const parsedHost = parser.getGlobalArgumentValue("Host");
if (parser.getGlobalArgumentValue("Host") == null) {
    appLogger.info("Warning, host parameter not provided defaulting to '0.0.0.0'");
}
else {
    appLogger.info(`Host has been defined to '${parsedHost}'`);
}
const host = parsedHost ?? "0.0.0.0";


// Log configuration
appLogger.info(`
Displaying Requested Server = '${server}'
Displaying Requested Port = '${port}'
Displaying Requested Host = ${host}\n`);
appLogger.info(parser);


/**
 * 
 * Use args for spinning up server
 * 
 */

// Configure http server & the message handler
const
    app = express();
    app.use(bodyParser.json());
    app.use(bodyParser.urlencoded({
        extended: true
    }))
;


/**
 * 
 * Configure endpoints
 * 
 */

// Testing
app.get("/", (req, resp) => {
    appLogger.info(`A new test request of type '${req.method}' 'has come in on '${req.baseURI}' from '${req.ip}' named '${req.hostname}'`);
    let output = {
        "Hello": "World!!!"
    };
    resp.send(output);
});


// Expose hasing with serverA
if ( server.toLowerCase() === "servera" || server.toLowerCase() === "server-a" ) {
    appLogger.info("ServerA detected, exposing Hashing Endpoints");
    app.use("/hashing", hashingRouter);
}

// Otherwise expose encryption if ServerB
if ( server.toLowerCase() === "serverb" || server.toLowerCase() === "server-b" ) {
    appLogger.info("ServerB detected, exposing Encrypting Endpoints");
    app.use("/encrypting", cipherRouter);
}

// Otherwise both
else {
    appLogger.warn("Unable to detect which server to run, exposing hashing & encrypted endpoints");
    app.use("/hashing", hashingRouter);
    app.use("/encrypting", cipherRouter);
}


// Start server
appLogger.info("Starting server");
app.listen(port, host, () => {
    appLogger.info(`Server configured on Port '${port}', host '${host}'`);
});