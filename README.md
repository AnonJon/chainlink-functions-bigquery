# BigQuery Chainlink Functions

## Setup

### Environment

Set environment variables. See `.env.example`

### Install Dependencies

```bash
make install
```

### GCloud

A service account is needed to use the googles BigQuery API even if it's a public dataset. The steps below will help you set one up.

#### Generate JSON keys

1. **Go to the Google Cloud Console**: [https://console.cloud.google.com/](https://console.cloud.google.com/)
2. **Select your project**: From the top dropdown, choose the project in which you want to create the service account.
3. **Navigate to IAM & Admin**: In the left-hand navigation pane, click on "IAM & Admin", then select "Service accounts".
4. **Create Service Account**: Click on the "CREATE SERVICE ACCOUNT" button.
5. **Fill out the form**:
   - **Name**: Give your service account a name.
   - **Description**: Optionally, add a description.
   - Click "Create".
6. **Assign roles**: In the next step, you can assign roles to your service account. This determines the permissions the service account will have.
7. **Generate a key**: After roles have been assigned, you'll have the option to generate a JSON key for the service account, which can be used for authentication in applications and scripts.
8. Click "Done".

#### JSON keys

You should now have a JSON file like the example below

```json
{
  "type": "service_account",
  "project_id": "PROJECT_ID",
  "private_key_id": "JF9883U948U3FJIJSOIFJSID",
  "private_key": "-----BEGIN PRIVATE KEY-----\nPRIVATE_KEY\n-----END PRIVATE KEY-----\n",
  "client_email": "PROJECT_ID@PROJECT_ID.iam.gserviceaccount.com",
  "client_id": "34534534535",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/PROJECT_ID%40PROJECT_ID.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
```

You will be using the following keys as secrets in the next section for your Chainlink Function `project_id`, `private_key`, `client_email`

### Off-chain Secrets

The contract is utilizing off-chain secrets to keep data more secure. The steps below will help you create and set the secrets in your contract.

#### Build Off-chain Secrets

Remember to set your env varibles from the generated gcloud json. See `.env.example` for examples.

```bash
make build-offchain-secrets
```

#### Create Gist

With your generated `offchain-secrets.json` file you can now create a Gist to host your encrypted secrets. Run the following Github CLI commands to create your Gist.

Before running the command, make sure you have the `Github CLI` tool installed.

```bash
make create-gist
```

#### Encrypt Gist

The last step is to now encrypt the Gist for storing on the blockchain.

```bash
make encrypt-gist
```

Enter your Gist URL and a hex string will generated. This string will be whats added to your contract as your secrets for your Function.

## Deploy

```bash
make deploy-BQ-weather
```

## Examples

The contract has one function `requestWeather()` which is your entry point to retrieving data from BigQuery. It takes in one argument `_query` which is the SQL query you will use to retrieve data from the tables of your choice. To examine the data and test out queries before running it live, visit [https://console.cloud.google.com/marketplace/product/noaa-public/gsod](https://console.cloud.google.com/marketplace/product/noaa-public/gsod)

Try passing in the following query to the `requestWeather()` function.

```sql
SELECT * FROM bigquery-public-data.noaa_gsod.gsod2023 where stn = '081810' order by date desc limit 1
```

This will get the latest temp data for the station `081810` which is the station for the city of `Barcelona`.

Call the `getCurrentTemperature()` function to get the current temperature from the returned data in wei.
