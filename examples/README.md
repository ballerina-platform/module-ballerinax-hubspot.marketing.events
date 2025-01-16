# Examples

The `ballerinax/hubspot.marketing.events` connector provides practical examples illustrating usage in various scenarios.

1. [Event Participation Management](https://github.com/module-ballerinax-hubspot.marketing.events/tree/main/examples/event_participation_management/) - Use Marketing Event API to Manage and Update Participants seamlessly.
2. [Marketing Event Management](/examples/marketing_event_management/) - Create, update and manage multiple Marketing Events and automate event management.

## Prerequisites

### 1. Setup HubSpot account

Refer to the [Setup guide](https://github.com/module-ballerinax-hubspot.marketing.events/tree/main/README.md#setup-guide) to set up your HubSpot account, if you do not have one.

### 2. Configuration

Update your HubSpot account related configurations in the `Config.toml` file in the example root directory:

```toml
clientId = "<clientId>"
clientSecret = "<clientSecret>"
refreshToken = "<refreshToken>"

## Running an example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the examples with the local module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```
