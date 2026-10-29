const { TokenAccessModel } = require("./TokenAccessModel");
const { TokenEvaluationModel } = require("./TokenEvalModel");

/**
 * Create TokenAccessModel from options
 * 
 * @param {Object} - access token options
 * @returns {TokenAccessModel}
 */
function createTokenAccessModel({
    keycloakUrl,
    realm,
    clientId,
    clientSecret
}) {
    return new TokenAccessModel(
        keycloakUrl,
        realm,
        clientId,
        clientSecret
    );
}


/**
 * Create TokenEvalautionModel
 * 
 * @param {Object} - token evaluation options
 * @returns {TokenEvaluationModel}
 */
function createTokenEvaluationModel({
    issuer,
    audience,
    clientId,
    requiredRole
}) {
    return new TokenEvaluationModel(
        issuer,
        audience,
        clientId,
        requiredRole
    );
}


module.exports = {
    createTokenAccessModel,
    createTokenEvaluationModel
}