const crypto = require("crypto");


/**
 * Model class to represent HTTP
 *  parameters for fetching OIDC token
 */
class TokenModel {
    id;
    method;
    headers;
    body;


    /**
     * Use provided clientId and clientSecret
     *  to draft parameters for fetching OIDC token
     * 
     */
    constructor(clientId, clientSecret) {

        if ( !clientId || !clientSecret ) {
            throw new Error("Client Id and secret are both required");
        }

        this.id = crypto.randomUUID();
        this.method = "POST";
        this.headers = Object.freeze({
            "Content-Type": "application/x-www-form-urlencoded"
        })
        this.body = new URLSearchParams({
            grant_type: "client_credentials",
            client_id: clientId,
            client_secret: clientSecret
        });
    }


    /**
     * Get method
     * 
     * @returns string
     */
    getMethod() {
        return this.method;
    }


    /**
     * Get headers
     * 
     * @returns string
     */
    getHeaders() {
        return this.headers;
    }


    /**
     * Get body
     * 
     * @returns string
     */
    getBody() {
        return this.body;
    }


    /**
     * Get ID field
     * 
     * @returns Id
     */
    getID() {
        return this.id;
    }


    /**
     * Represent as options object
     * 
     * @returns Object
     */
    asOptions() {
        return {
            method: this.method,
            headers: this.headers,
            body: this.body
        }
    }


    /**
     * Verifies class parameters
     * 
     * @returns {boolean}
     */
    verify() {

        // Construct url search parameters
        const fields = new URLSearchParams(this.body);

        // Verify class parameters
        const valid = 
            this.method === "POST" &&
            this.headers["Content-Type"] ===
                "application/x-www-form-urlencoded" &&
            fields.get("grant_type") === "client_credentials" &&
            Boolean(fields.get("client_type")) &&
        Boolean(fields.get("client_secret"));

        // Handle state
        if ( valid ) {
            return true;
        }
        else {
            throw new Error("Invalid Token request configurations");
        }
    }
}


module.exports = {
    TokenModel
};