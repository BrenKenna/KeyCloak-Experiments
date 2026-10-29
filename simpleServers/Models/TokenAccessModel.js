
/**
 * Model class to facilitate 
 *  authentication & authorization
 */
class TokenAccessModel {
    keycloakUrl;
    realm;
    clientId;
    clientSecret;
    refreshSkewSeconds;

    expriesAt = 0;
    cachedToken = null;
    expiresAt = 0;
    duration = 0;


    /**
     * Construct with required attributes
     * 
     * @param {*} keycloakUrl 
     * @param {*} realm 
     * @param {*} clientId 
     * @param {*} clientSecret 
     * @param {*} refreshSkewSeconds 
     */
    constructor (
        keycloakUrl,
        realm,
        clientId,
        clientSecret,
        expiresAt = 0,
        refreshSkewSeconds = 30
    ) {
        if ( !keycloakUrl || !realm || !clientId) {
            throw new Error(`
                Keycloak URL, Realm, and ClientId are all required`
            );
        }
        this.realm = realm;
        this.keycloakUrl = `${keycloakUrl}/${this.realm}/protocol/openid-connect/token`;
        this.clientId = clientId;
        this.clientSecret = clientSecret;
        this.expiresAt = expiresAt;
        this.refreshSkewSeconds = refreshSkewSeconds;
    }


    /**
     * Keycloak url 
     * 
     * @returns url
     */
    getKeycloakUrl() {
        return this.keycloakUrl;
    }


    /**
     * keycloak realm
     * 
     * @returns string
     */
    getRealm() {
        return this.realm;
    }

    
    /**
     * Client Id
     * 
     * @returns string
     */
    getClientId() {
        return this.clientId;
    }

    
    /**
     * Client secret
     * 
     * @returns string
     */
    getClientSecret() {
        return this.clientSecret;
    }


    /**
     * Cached token
     * 
     * @returns token
     */
    getCachedToken() {
        return this.cachedToken;
    }


    /**
     * Get duration
     * 
     * @returns number
     */
    getDuration() {
        return this.duration;
    }

    
    /**
     * Validates model parameters
     * 
     * @returns boolean
     */
    verify() {
        
        // Verify class field
        if ( !this.keycloakUrl ) {
            throw new Error("Keycloak URL must be specified");
        }

        // Verify url
        let url
        try {
            url = new URL(this.keycloakUrl);
        }
        catch {
            throw new Error("Invalid keycloak URL");
        }

        // Verify protocol
        if ( ![ "http", "https"].includes(url.protocol) ) {
            throw new Error("Keycloak endpoint must be either HTTP or HTTPS");
        }

        // Model verified
        return true;
    }


    /**
     * Checks if cached token is still valid
     * 
     * @returns boolean
     */
    tokenStillValid() {
        return this.cachedToken && 
            Date.now() <
                this.expiresAt - (this.refreshSkewSeconds * 1000);
    }
}


module.exports =  {
    TokenAccessModel
};