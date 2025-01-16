# HubSpot Marketing Event Participation Management

This use case demonstrates how the `HubSpot Marketing Events` connector can be utilized to create events, record participants, and update attendee information. By streamlining this process, companies can better manage events and their participants.

## Prerequisites

### 1. Setup HubSpot account

Refer to the [Setup guide](https://github.com/module-ballerinax-hubspot.marketing.events/tree/main/README.md#setup-guide) to set up your HubSpot account, if you do not have one.

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
