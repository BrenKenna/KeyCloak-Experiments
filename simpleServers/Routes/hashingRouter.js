
const 
    express = require('express'),
    hashingControllers = require('../Controllers/hashingControllers')
;


// Initialize routes
const router = express.Router();
router.post('/hashMessage', hashingControllers.hashMsg);
router.post('/hashMessageWithSalt', hashingControllers.hashMsgWithSalt);


// Provide router
module.exports = router;