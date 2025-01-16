// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/io;
import ballerina/oauth2;
import ballerinax/hubspot.marketing.events as hsmevents;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;

public function main() returns error? {

    hsmevents:OAuth2RefreshTokenGrantConfig auth = {
        clientId,
        clientSecret,
        refreshToken,
        credentialBearer: oauth2:POST_BODY_BEARER // this line should be added in to when you are going to create auth object.
    };
    hsmevents:ConnectionConfig config = {auth};

    hsmevents:Client hubspotMarketingClient = check new (config);

    // Step 1: Create a new event

    hsmevents:MarketingEventCreateRequestParams createPayload = {
        externalAccountId: "11111",
        externalEventId: "10000",
        eventName: "Winter webinar",
        eventOrganizer: "Snowman Fellowship",
        eventCancelled: false,
        eventUrl: "https://example.com/holiday-jam",
        eventType: "WEBINAR",
        eventDescription: "Let's get together to plan for the holidays",
        eventCompleted: false,
        startDateTime: "2024-08-06T12:36:59.286Z",
        endDateTime: "2024-08-08T12:36:59.286Z",
        customProperties: []
    };

    hsmevents:MarketingEventDefaultResponse createResp = check hubspotMarketingClient->postEvents_create(createPayload);

    string eventObjId = createResp?.objectId ?: "-1";

    io:println("Event Created: ", eventObjId);

    // Step 2: Update event details

    // NOTE: The custom property name should be created in the HubSpot account for that particular app before 
    // updating the event. Otherwise it won't be saved. 
    hsmevents:CrmPropertyWrapper customProperty = {
        name: "test_name",
        value: "Custom Updated Value"
    };

    hsmevents:MarketingEventPublicUpdateRequestV2 sampleUpdatePayload = {
        eventName: "Updated Event Name",
        eventOrganizer: "Updated Event Organizer",
        eventDescription: "Updated Event Description",
        eventUrl: "https://example.com/updated-holiday-jam",
        customProperties: [
            customProperty
        ]
    };

    hsmevents:MarketingEventPublicDefaultResponseV2 updateResp = check 
    hubspotMarketingClient->patchObjectid(eventObjId, sampleUpdatePayload);

    io:println("Event Updated: ", updateResp?.objectId ?: "-1");

    // Step 3: Get the event

    hsmevents:MarketingEventPublicDefaultResponseV2 getResp = check hubspotMarketingClient->getObjectid(eventObjId);

    io:println("Event Retrieved: \n", getResp.toJsonString());

    // Step 4: Change the event status to completed

    hsmevents:MarketingEventCompleteRequestParams completePayload = {
        startDateTime: "2024-08-06T12:36:59.286Z",
        endDateTime: "2024-08-08T12:36:59.286Z"
    };

    hsmevents:MarketingEventDefaultResponse completeResp = check 
    hubspotMarketingClient->postEventsExternaleventidComplete_complete("10000", completePayload, externalAccountId = "11111");

    io:println("Event Completed: ", completeResp?.objectId ?: "-1");

    // Step 5: Delete Event

    http:Response deleteResp = check hubspotMarketingClient->deleteObjectid(eventObjId);

    io:println("Event Deleted: ", deleteResp.statusCode == 204 ? "Success" : "Failed");
};
