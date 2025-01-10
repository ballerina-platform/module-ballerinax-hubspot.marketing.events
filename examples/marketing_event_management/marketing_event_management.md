# HubSpot Marketing Event Management

This use case demonstrates how the `HubSpot Marketing Events` connector can be utilized to create, update, cancel and delete events. By utilizing this companies can automate the event creation and management process.

## Prerequisites

### 1. Setup HubSpot account

Refer to the [Setup guide](../../README.md#setup-guide) to set up your HubSpot account, if you do not have one.

### 2. Configuration

Update your HubSpot account related configurations in the `Config.toml` file in the example root directory:

```toml
clientId = "<clientId>"
clientSecret = "<clientSecret>"
refreshToken = "<refreshToken>"
```

## Run the example

Execute the following command to run the example:

```ballerina
bal run
```
