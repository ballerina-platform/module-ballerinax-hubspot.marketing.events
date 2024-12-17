## Overview



[//]: # (TODO: Add overview mentioning the purpose of the module, supported REST API versions, and other high-level details.)

## Setup guide

[//]: # (TODO: Add detailed steps to obtain credentials and configure the module.)

To use the HubSpot Marketing Events connector, you must have access to the HubSpot API through a HubSpot developer account and a HubSpot App under it. Therefore you need to register for a developer account at HubSpot if you don't have one already.

### Step 1: Create/Login to a HubSpot Developer Account

If you don't have a HubSpot Developer Account you can sign up to a free account [here](https://developers.hubspot.com/get-started)

### Step 2 (Optional): Create a [Developer Test Account](https://developers.hubspot.com/beta-docs/getting-started/account-types#developer-test-accounts) under your accoun

Within app developer accounts, you can create developer test accounts to test apps and integrations without affecting any real HubSpot data.  

***These accounts are only for development and testing purposes. In production you should not use Developer Test Accounts.***

### Step 3: Create a HubSpot App under your account.

- In your developer account, navigate to the "Apps" section.

- Click on "Create App" and provide the necessary details, including the app name and description.

### Step 4: Configure the Authentication Flow.

- Move to the Auth Tab.
- In the Scopes section, add the following scopes for your app using the "Add new scope" button.

    > crm.objects.marketing_events.read  

    > crm.objects.marketing_events.write

- Add your Redirect URL in the relevant section. You can also use localhost addresses for local development purposes.

- Click Create App.

### Step 5: Get your Client ID and Client Secret

- Navigate to the Auth section of your app. Make sure to save the provided Client ID and Client Secret.

### Step 6: Setup Authentication Flow

Before proceeding with the Quickstart, ensure you have obtained the Access Token using the following steps:

1. Create an authorization URL using the following format:  

    > `https://app.hubspot.com/oauth/authorize?client_id=<YOUR_CLIENT_ID>&scope=<YOUR_SCOPES>&redirect_uri=<YOUR_REDIRECT_URI>`


## Quickstart

[//]: # (TODO: Add a quickstart guide to demonstrate a basic functionality of the module, including sample code snippets.)

## Examples

The `HubSpot Marketing Events` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/module-ballerinax-hubspot.marketing.events/tree/main/examples/), covering the following use cases:

[//]: # (TODO: Add examples)
