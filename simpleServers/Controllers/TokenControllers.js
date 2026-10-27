const { TokenAccessModel } = require("../Models/TokenAccessModel");
const { TokenEvaluationModel } = require("../Models/TokenEvalModel");
const { TokenHandler } = require("../supporting/tokenHandler/TokenHandler");


/**
 * Fetch promise for bearer from provided accessTokenModel
 * 
 * @param {TokenAccessModel} accessTokenModel 
 * @returns {Promise<string>}
 */
function createFetchTokenController(accessTokenModel) {

    // Checks token is present
    if ( !accessTokenModel ) {
        throw new Error("TokenAccessModel required");
    }

    // Try verify token
    try {
        accessTokenModel.verify();
    }
    catch ( error ) {
        throw new Error("Unable to verify token");
    }

    // Initialize token handler to fetch token
    const tokenHandler = new TokenHandler();
    return async function fetchToken() {
        return tokenHandler.fetchToken(accessTokenModel);
    }
}


/**
 * Fetch promise for evaluating authenticity and
 *  authorization of access token
 * 
 * 
 * @param {TokenEvaluationModel} tokenEvaluationModel 
 * @returns { Promise<TokenValidationResult> }
 */
function createEvaluateTokenController(tokenEvaluationModel) {

    // Checks token evaluation model
    if ( !tokenEvaluationModel ) {
        throw new Error("Token evaluation model is required");
    }

    // Try verify token
    try {
        tokenEvaluationModel.verify();
    }
    catch ( error ) {
        throw new Error("Unable to verify token");
    }

    // Initalizes handler for token evaluation
    return async function evaluateToken(req, resp, next) {

        // Parse auth headers
        const header = req.headers.authorization || "";
        const match = header.match(/^Bearer\s+(\S+)$/i);

        // Checks bearer token is present
        if ( !match ) {
            return resp.status(401).json({
                error: "Missing or malformed bearer token"
            });
        }

        // Try evaluate token
        try {

            // Update token handler
            const tokenHandler = new TokenHandler();
            tokenHandler.setTokenEvaluationModel(tokenEvaluationModel);
            const result = await tokenHandler.evaluateToken(
                match[1]
            );

            // Checks authenticated token is authorized for action
            if ( !result.authorized ) {
                return resp.status(403).json({
                    error: "Insufficient permissions"
                });
            }

            // Provide authorized result
            req.auth = result;
            return next();
        }

        // Otherwise catch bubbled jwt error
        catch (error) {
            console.log(error);
            return resp.status(401).json({
                error: `Invalid or expired token '${error}'`
            });
        }
    }
}


module.exports = {
    createFetchTokenController,
    createEvaluateTokenController
}