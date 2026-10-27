const {
    createRemoteJWKSet
} = require("jose");


/**
 * TokenEvaluationModel
 * 
 */
class TokenEvaluationModel {
    issuer;
    audience;
    clientId;
    requiredRole;
    jwks;


    /**
     * Construct with parameters
     * 
     * @param {*} issuer 
     * @param {*} audience 
     * @param {*} clientId 
     * @param {*} requiredRole 
     */
    constructor (issuer, audience, clientId, requiredRole) {
        this.issuer = issuer;
        this.audience = audience;
        this.clientId = clientId;
        this.requiredRole = requiredRole;

        this.jwks = createRemoteJWKSet(
            new URL(
                `${this.issuer}/protocol/openid-connect/certs`
            )
        );
    }


    /**
     * Get issuer
     * 
     * @returns string
     */
    getIssuer() {
        return this.issuer;
    }


    /**
     * Get audience
     * 
     * @returns string
     */
    getAudience() {
        return this.audience;
    }


    /**
     * Get client Id
     * 
     * @returns clientId
     */
    getClientId() {
        return this.clientId;
    }


    /**
     * Get required role
     * 
     * @returns Role
     */
    getRequiredRole() {
        return this.requiredRole;
    }


    /**
     * Get JWKS
     * 
     * @returns JWKS 
     */
    getJwks() {
        return this.jwks;
    }


    /**
     * Verifies class parameters
     * 
     * @returns {boolean}
     */
    verify() {

        // Check class fields are present
        if ( 
            !this.issuer ||
            !this.audience ||
            !this.clientId ||
            !this.requiredRole
        ) {
            throw new Error("Token not configured");
        }

        // Verify issuer url
        let issuerUrl;
        try {
            issuerUrl = new URL(this.issuer);
        }
        catch {
            throw new Error("Invalid token issuer URL");
        }

        // Verify issuer endpoint is HTTP
        if ( ![ "http", "https"].includes(issuerUrl.protocol)) {
            throw new Error("Token issuer URL must be HTTP or HTTPS");
        }

        // Is verified
        return true;
    }
}


module.exports =  {
    TokenEvaluationModel
};