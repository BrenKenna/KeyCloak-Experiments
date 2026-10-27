const { jwtVerify } = require("jose");

const { TokenEvaluationModel } = require("../../Models/TokenEvalModel");
const { TokenAccessModel } = require("../../Models/TokenAccessModel");
const { TokenModel } = require("../../Models/TokenModel");
const { TokenValidationResult } = require("../../Models/TokenValidationResult");


/**
 * @typedef {Object} KeycloakTokenResponse
 * @property {string} access_token
 * @property {number} expires_in
 * @property {number} [refresh_expires_ind]
 * @property {string} [token_type]
 * @property {string} [scope]
 */


/**
 * Class to handle fetching OIDC token
 *  from keycloak server
 */
class TokenHandler{

    tokenEvalModel;


    /**
     * Empty constructor
     */
    constructor() {}


    /**
     * @param { TokenEvaluationModel } tokenEvalModel 
     */
    setTokenEvaluationModel(tokenEvalModel) {
        this.tokenEvalModel = tokenEvalModel;
    }

    
    /**
     * Evaluate provided bearer token. Remember that a token
     *  can be valid, but not authorized. Letting Jose.JwtVerify
     *  method erro bubble up, otherwise JWT is validated.
     * 
     * @param {string} token 
     * @returns { TokenValidationResult }
     */
    async evaluateToken(token) {

        // Evaluate token model
        if ( ! this.tokenEvalModel === undefined ) {
            return new TokenValidationResult(
                false,
                false,
                "NA",
                "NA",
                []
            );
        }

        // Verify JWT, or let jwtVerify error bubble up
        const { payload } = await jwtVerify(
            token,
            this.tokenEvalModel.getJwks(),
            {
                issuer: this.tokenEvalModel.getIssuer(),
                audience: this.tokenEvalModel.getAudience()
            }
        );

        // Fetch roles from token
        const roles = payload.resource_access?.[
            this.tokenEvalModel.getClientId()
        ].roles || [];

        // Provide result
        return new TokenValidationResult(
            true,
            roles.includes(this.tokenEvalModel.getRequiredRole()),
            payload.sub,
            payload.azp,
            roles
        );
    }


    /**
     * Public method to use to fetch & cache access token
     * 
     * @param {TokenAccessModel} model 
     * @returns {string}
     */
    async fetchToken(model) {
        const json = await this.getAccessToken(model);
        return this.cacheToken(json);
    }


    /**
     * Fetch access token
     * 
     * @param {TokenAccessModel} model 
     * @returns {Promise<KeycloakTokenResponse>}
     */
    async getAccessToken(model) {
        if ( !model.tokenStillValid() ) {
            throw new Error("Error invalid token");
        }

        const tokenModel = new TokenModel(
            model.getClientId(),
            model.getClientSecret()
        );

        const resp = await fetch(
            model.getKeycloakUrl(),
            tokenModel.asOptions()
        );


        if ( !resp.ok ) {
            throw new Error(
                `Token request failed with '${resp.status}' to '${model.getKeycloakUrl()}'`
            );
        }

        return await resp.json();
    }


    /**
     * Cache access token
     * 
     * @param {TokenAccessModel} model 
     * @param {KeycloakTokenResponse} dataJson
     * @returns {string}
     */
    cacheToken(model, dataJson) {

        if (
            typeof dataJson.access_token !== "string" ||
            typeof dataJson.expires_in !== "number"
        ) {
            throw new Error("Error invalid token response, access_token and expires_in must be declared");
        }

        model.cachedToken = dataJson.access_token;
        model.expiresAt = Date.now() + (dataJson * 1000);

        return model.getCachedToken();
    }
}


module.exports = {
    TokenHandler
};