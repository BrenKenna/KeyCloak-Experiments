
/**
 * Class to represent a valid token
 */
class TokenValidationResult {
    
    valid;
    authorized;
    subject;
    clientId;
    roles;


    /**
     * 
     * @param {bool} valid 
     * @param {bool} authorized 
     * @param {string} subject 
     * @param {string} clientId 
     * @param {[]} roles 
     */
    constructor(valid, authorized, subject, clientId, roles) {
        this.valid = valid;
        this.authorized = authorized;
        this.subject = subject;
        this.clientId = clientId;
        this.role = roles;
    }


    isValid() {
        return this.valid;
    }

    isAuthorized() {
        return this.authorized;
    }

    getSubject() {
        return this.subject;
    }

    getClientId() {
        return this.clientId;
    }

    getRoles() {
        return this.roles;
    }
}


module.exports = {
    TokenValidationResult
};