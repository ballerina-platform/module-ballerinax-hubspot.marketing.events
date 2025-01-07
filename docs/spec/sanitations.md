_Author_: @Sadeesha-Sath \
_Created_: 2025/01/02 \
_Updated_: 2025/01/02 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from HubSpot Marketing Events.
The OpenAPI specification is obtained from the [HubSpot Marketing Events OpenAPI Documentation](https://developers.hubspot.com/docs/reference/api/marketing/marketing-events). These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

1. **Change the `url` property of the `servers` object**:
   - **Original**: `https://api.hubapi.com`
   - **Updated**: `https://api.hubapi.com/marketing/v3/marketing-events`
   - **Reason**: This change is made to ensure that all API paths are relative to the versioned base URL of the relevant API (`/marketing/v3.marketing-events`), which improves the consistency and usability of the APIs.

2. **Update API Paths**:
   - **Original**: Paths included the specific API endpoint URL and version prefix in each endpoint (e.g., `/marketing/v3/marketing-events/events/{externalEventId}`).
   - **Updated**: Paths are modified to remove the marketing-events API endpoint URL and version prefix from the endpoints, as it is now included in the base URL. For example:
     - **Original**: `/marketing/v3/marketing-events/events/{externalEventId}`
     - **Updated**: `/events/{externalEventId}`
   - **Reason**: This modification simplifies the API paths, making them shorter and more readable. It also centralizes the versioning to the base URL, which is a common best practice.

3. **Update datetime format**
   - **Original**: Object Property format of date-time values were written as 'date-time'
   - **Updated**: Object Property format was changed to 'datetime'
   - **Reason**: For the Ballerina OpenAPI tool to correctly recognize the abovementioned format.

4. **Substitute `PropertyValue[]` fields with `CRMPropertyWrapper[]`**
   - **Original**: Several calls used `PropertyValue[]` record for `customProperties` field and others used `CRMPropertyWrapper[]`
   - **Updated**: All `customProperties` fields use `CRMPropertyWrapper[]` record.
   - **Reason**: `PropertyValue[]` field does not conform to the standards of being a customProperty according to HubSpot definition of what a custom property should be. (_HubSpot Definition: "These can be whatever kind of property names and values you want"._) This breaks some calls and doesn't save any of the custom properties to the site. Using `CRMPropertyWrapper[]` this issue can be mitigated and the API works as intended.

5. **Add `vid` as a required parameter for MarketingEventSubscriber**:
   - **Original**: `vid` field was an optional field.  
   - **Updated**: `vid` field was made a required field.
   - **Reason**: Even though the specification mentioned that the `vid` field is not required, the API fails when vid is not set.

6. **Make `vid` an integer type instead of int32**
   - **Original**: All `vid` fields were formatted as `int32`
   - **Updated**: `vid` fields were converted to `integer`
   - **Reason** - From Contacts API v1 to v3, the `vid` values changed to have more digits, making them overflow the int32 limit.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/openapi.json --mode client --license docs/license.txt -o ballerina
```

Note: The license year is hardcoded to 2024, change if necessary.
