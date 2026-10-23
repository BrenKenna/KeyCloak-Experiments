// Provide logger
const log4js = require('log4js');

const logger = log4js.configure('./supporting/logging/log4j.properties.json');
const appLogging = logger.getLogger();
module.exports = appLogging;