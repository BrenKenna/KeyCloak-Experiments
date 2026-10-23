
const 
    express = require('express'),
    cipherControllers = require('../Controllers/cipherControllers')
;

// Initialize routes
const router = express.Router();
router.post('/encrypt', cipherControllers.msgEncryption);
router.post('/decrypt', cipherControllers.msgDecryption);

// Provide router
module.exports = router;