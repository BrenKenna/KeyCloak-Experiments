
// Fetch required libs
const
    MessageHandler = require('../supporting/messageHandler/MessageHandler'),
    appLogger = require('../supporting/logging/appLogger')
;


// Initialize message handler
msgHandler = new MessageHandler();


// Method for encryption endpoint
const msgEncryption = (req, resp, next) => {
    
    // Handle input message
    appLogger.info(`A new encryption request has come in`);
    appLogger.info(`A new test request of type '${req.method}' 'has come in on '${req.originalUrl}' from '${req.ips}' named '${req.hostname}'`);
    appLogger.info(req.body);
    let output = msgHandler.encryptMsg(req.body.message)
    appLogger.info(output);

    // Write and send resonse
    return resp.status(200).json(output);
}


// Method for decryption endpoint
const msgDecryption = (req, resp, next) => {
    
    // Handle input message
    appLogger.info(`A new decryption request has come in`);
    appLogger.info(`A new test request of type '${req.method}' 'has come in on '${req.originalUrl}' from '${req.ips}' named '${req.hostname}'`);
    appLogger.info(req.body);
    let output = msgHandler.decryptMsg(req.body.message);
    appLogger.info(output);

    // Write and send resonse
    return resp.status(200).json(output);
}


// Export methods
module.exports = {
    msgEncryption,
    msgDecryption
}