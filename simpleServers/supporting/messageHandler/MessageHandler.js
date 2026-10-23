const 
    MessageHasher = require("./MessageHasher"),
    MessageEncryptor = require("./MessageEncryptor");
;


/**
 * Provide single class for the handling of message
 */
class MessageHandler{

    /**
     * Construct abstract message handler
     */
    constructor() {
        this.messageHasher = new MessageHasher();
        this.messageCipher = new MessageEncryptor();
    }


    /**
     * Encrypt provided message
     * 
     * @param {Message to encrypt} msg 
     * @returns Encrypted message
     */
    encryptMsg(msg) {
        let output = {
            "Message": msg,
            "EncryptedMessage": ""
        };
        output.EncryptedMessage = this.messageCipher.encryptMessage(msg);
        return output;
    }


    /**
     * Decrypt provided message
     * 
     * @param {Message to decrypt} msg 
     * @returns Message
     */
    decryptMsg(msg) {
        let output = {
            "Message": msg,
            "DecryptedMesssage": ""
        };
        output.DecryptedMesssage = this.messageCipher.decryptMessage(msg);
        return output;
    }


    /**
     * Hash message using salt
     * 
     * @param {Message} msg 
     * @returns Hash
     */
    hashMsg(msg) {
        return this.messageHasher.hashMessage(msg);
    }


    /**
     * Hash input message
     * 
     * @param {Message} msg 
     * @returns '{Message, Salt}'
     */
    hashMsgWithSalt(msg) {
        let output = {
            "Message": msg,
            "Hash": "",
            "Salt": ""
        }
        output.Salt = this.fetchSalt();
        output.Hash = this.messageHasher.hashWithSalt(msg, output.Salt)
        return output;
    }


    /**
     * Fetch a random salt
     * 
     * @returns Salt
     */
    fetchSalt() {
        return this.messageHasher.fetchSalt();
    }


    /**
     * Fetch random buffer array of required size
     * 
     * @param {Byte size} nBytes 
     * @returns Buffer arr
     */
    fetchRandomBuffer(nBytes) {
        return this.messageCipher.fetchRandomBuffer(nBytes);
    }
}

module.exports = MessageHandler;