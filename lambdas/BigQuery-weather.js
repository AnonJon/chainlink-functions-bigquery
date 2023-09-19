const crypto = require("crypto");
const querystring = require("querystring");

// Needed to create Oauth token for BigQuery call
const JWT_HEADER = '{"alg":"RS256","typ":"JWT"}';
const TOKEN_URL = "https://oauth2.googleapis.com/token";
const AUDIENCE = "https://oauth2.googleapis.com/token";
const SCOPE = "https://www.googleapis.com/auth/cloud-platform.read-only";
const BIGQUERY_BASE_URL =
  "https://bigquery.googleapis.com/bigquery/v2/projects/";

const createJWT = (iss, key, scope = SCOPE, audience = AUDIENCE) => {
  const privateKey = key.replace(/\\n/g, "\n");
  const currentTimeInSeconds = Math.round(Date.now() / 1000);

  const jwtClaimSetObj = {
    iss,
    scope,
    aud: audience,
    exp: currentTimeInSeconds + 3500,
    iat: currentTimeInSeconds,
  };

  const jwtBase64Headers = Buffer.from(JWT_HEADER).toString("base64");
  const jwtBase64ClaimSet = Buffer.from(
    JSON.stringify(jwtClaimSetObj)
  ).toString("base64");
  const stringToSign = `${jwtBase64Headers}.${jwtBase64ClaimSet}`;
  const jwtBase64Signature = crypto
    .sign("RSA-SHA256", stringToSign, privateKey)
    .toString("base64");

  return `${jwtBase64Headers}.${jwtBase64ClaimSet}.${jwtBase64Signature}`;
};

const getOauthToken = async (iss, key) => {
  const jwt = createJWT(iss, key);

  const jwtRequest = {
    grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
    assertion: jwt,
  };

  const jwtRequestString = querystring.stringify(jwtRequest);

  try {
    const tokenResponse = await Functions.makeHttpRequest({
      url: TOKEN_URL,
      method: "post",
      data: jwtRequestString,
    });
    return tokenResponse.data.access_token;
  } catch (error) {
    console.error("Error fetching OAuth token:", error);
    throw new Error("Error fetching OAuth token");
  }
};

const executeQuery = async (query) => {
  const requestConfig = {
    method: "post",
    url: `${BIGQUERY_BASE_URL}${secrets.projectId}/queries`,
    headers: {
      Authorization: `Bearer ${await getOauthToken(secrets.iss, secrets.key)}`,
      Accept: "application/json",
      "Content-Type": "application/json",
    },
    data: {
      query,
      useLegacySql: false,
    },
  };

  const response = await Functions.makeHttpRequest(requestConfig);

  if (!response.data) {
    throw new Error("Invalid response from BigQuery");
  }

  const rows = response.data.rows;

  let answer;
  try {
    answer = parseFloat(rows[0].f[6].v); // grab the temp from the response
  } catch (error) {
    throw new Error(`Error processing query result: ${error.message}`);
  }

  return Buffer.concat([Functions.encodeUint256(BigInt(answer * 10 ** 18))]);
};

const query = args[0];
const result = await executeQuery(query);
return result;
