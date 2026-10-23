
// Fetch required libs
const
    MessageHandler = require('../supporting/messageHandler/MessageHandler'),
    appLogger = require('../supporting/logging/appLogger')
;

// Initialize message handler
msgHandler = new MessageHandler();


// Provide digest of input message
const hashMsg = (req, resp, next) => {

    // Log request
    appLogger.info("A new hashing request has come in");
    appLogger.info(`A new test request of type '${req.method}' 'has come in on '${req.originalUrl}' from '${req.ip}' named '${req.hostname}'`);
    appLogger.info(req.body);

    // Process request
    let output = msgHandler.hashMsg(req.body.message);
    appLogger.info(output);

    // Provide response
    return resp.status(200).json(output);
};


// Provide digest of input message
const hashMsgWithSalt = (req, resp, next) => {

    // Log request
    appLogger.info("A new hashing request has come in");
    appLogger.info(`A new test request of type '${req.method}' 'has come in on '${req.originalUrl}' from '${req.ip}' named '${req.hostname}'`);
    appLogger.info(req.body);

    // Process request
    let output = msgHandler.hashMsgWithSalt(req.body.message);
    appLogger.info(output);

    // Provide response
    return resp.status(200).json(output);
};


// Export endpoint methods
module.exports = {
    hashMsg,
    hashMsgWithSalt
}