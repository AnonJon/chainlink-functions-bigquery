# BigQuery Chainlink Functions

## Setup

### Environment

Set environment variables. See `.env.example`

### GCloud

A service account is needed to use the googles BigQuery API even if it's a public dataset. The steps below will help you set one up.

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

### Off-chain Secrets

The contract is utilizing off-chain secrets to keep data more secure. The steps below will help you create and set the secrets in your contract.

## Deploy

```bash
make deploy-BQ-weather
```

## Examples

The contract has one function `requestWeather()` which is your entry point to retrieving data from BigQuery. It takes in one argument `_query` which is the SQL query you will use to retrieve data from the tables of your choice. To examine the data and test out queries before running it live, visit [https://console.cloud.google.com/marketplace/product/noaa-public/gsod](https://console.cloud.google.com/marketplace/product/noaa-public/gsod)
