const crypto = require("crypto");
const querystring = require("querystring");

// Needed to create Oauth token for BigQuery call
const getOauthToken = async (iss, key) => {
  const privateKey = key.replace(/\\n/g, "\n");

  const jwtBase64Headers = Buffer.from('{"alg":"RS256","typ":"JWT"}').toString(
    "base64"
  );

  const currentTimeInSeconds = Math.round(Date.now() / 1000);

  const jwtClaimSetObj = {
    iss: iss,
    scope: "https://www.googleapis.com/auth/cloud-platform.read-only",
    aud: "https://oauth2.googleapis.com/token",
    exp: currentTimeInSeconds + 3500,
    iat: currentTimeInSeconds,
  };

  const jwtBase64ClaimSet = Buffer.from(
    JSON.stringify(jwtClaimSetObj)
  ).toString("base64");

  const stringToSign = `${jwtBase64Headers}.${jwtBase64ClaimSet}`;

  const jwtBase64Signature = crypto
    .sign("RSA-SHA256", stringToSign, privateKey)
    .toString("base64");

  const jwtRequest = {
    grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
    assertion: `${jwtBase64Headers}.${jwtBase64ClaimSet}.${jwtBase64Signature}`,
  };

  const jwtRequestString = querystring.stringify(jwtRequest);

  const tokenResponse = await Functions.makeHttpRequest({
    url: "https://oauth2.googleapis.com/token",
    method: "post",
    data: jwtRequestString,
  });
  return tokenResponse.data.access_token;
};

const query = args[0];
const requestConfig = {
  method: "post",
  url: `https://bigquery.googleapis.com/bigquery/v2/projects/${secrets.projectId}/queries`,
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

const rows = response.data.rows;
let answer;
try {
  answer = parseInt(rows[0].f[0].v);
} catch (error) {
  throw new Error("Query did not return a number");
}

return Buffer.concat([Functions.encodeUint256(answer)]);
