const crypto = require('crypto');


/**
 * Class to support hasing messages
 */
class MessageHasher {

    /**
     * Default SHA-256 hasher
     */
    constructor() {
        this.hasher = crypto.createHash('sha256');
    }


    /**
     * Fetch a random uuid string
     * 
     * @returns Random UUID, String
     */
    fetchSalt() {
        return crypto.randomUUID();
    }


    /**
     * Hash input message
     * 
     * @param {Message to Hash} msg 
     * @returns Hash Message, String
     */
    hashMessage(msg) {

        // Hash msg
        this.hasher.update(msg);
        let output = this.hasher.digest('hex');

        // Refresh and return output
        this.__refresh__();
        return output;
    }


    /**
     * Generate a hash of salted message
     * 
     * @param {Message to hash} msg 
     * @param {Salt for hashing message} salt 
     * @returns String
     */
    hashWithSalt(msg, salt) {

        // Hash msg & salt
        let toHash = msg + "-" + salt;
        this.hasher.update(toHash);
        let output = this.hasher.digest('hex');

        // Refresh and return output
        this.__refresh__();
        return output;
    }


    /**
     * Refresh hasher
     */
    __refresh__() {
        this.hasher = crypto.createHash('sha256');
    }
}

module.exports = MessageHasher;