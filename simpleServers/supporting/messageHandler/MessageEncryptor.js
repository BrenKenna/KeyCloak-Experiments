const crypto = require('crypto');


/**
 * Class to support the (de)encryption of messages
 */
class MessageEncryptor{

    /**
     * Constructor with random key & init vector
     */
    constructor() {
        this.msgKey = crypto.randomBytes(32),
        this.msgIV = crypto.randomBytes(16)
        this.cipher = crypto.createCipheriv('aes-256-cbc', Buffer.from(this.msgKey), this.msgIV);
        this.deCipher = crypto.createDecipheriv('aes-256-cbc', Buffer.from(this.msgKey), this.msgIV);
    }


    /**
     * Encrypt provided message, returning hexidecimal representation
     * 
     * @param {Message to encrypt} msg
     * @returns Encrypted Msg, Hex String
     */
    encryptMessage(msg) {

        // Encrypt message
        let msgEncrypter = this.cipher.update(msg);
        let encMsgBuff = Buffer.concat([msgEncrypter, this.cipher.final()]);
        let encMsg = encMsgBuff.toString('hex')

        // Return as hex string
        this.__refreshCipher__();
        return encMsg;
    }


    /**
     * Decrypt provided message, returning representation as string
     * 
     * @param {Message to decrypt} encMsg
     * @returns Decrypted Msg, String
     */
    decryptMessage(encMsg) {

        // Fetch buffer from input, and decrypt
        let encMsgBuff = Buffer.from(encMsg, 'hex');
        let msgDecrypter = this.deCipher.update(encMsgBuff);
        let decMsgBuffer = Buffer.concat([msgDecrypter, this.deCipher.final()]);
        let decMsg = decMsgBuffer.toString();

        // Return decrypted message
        this.__refreshDeCipher__();
        return decMsg;
    }


    /**
     * Generate a random buffer of the required size
     * 
     * @param {Byte size of buffer to create} nBytes 
     * @returns Buffer array
     */
    fetchRandomBuffer(nBytes) {
        return crypto.randomBytes(nBytes);
    }


    /**
     * Refresh cipher for encrypting messages
     */
    __refreshCipher__() {
        this.cipher = crypto.createCipheriv('aes-256-cbc', Buffer.from(this.msgKey), this.msgIV);
    }


    /**
     * Refresh cipher for decrypting messages
     */
    __refreshDeCipher__() {
        this.deCipher = crypto.createDecipheriv('aes-256-cbc', Buffer.from(this.msgKey), this.msgIV);
    }
}

module.exports = MessageEncryptor;