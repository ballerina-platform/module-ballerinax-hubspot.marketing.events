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
import ballerinax/hubspot.marketing.events as hubspot;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;

public function main() {

    final hubspot:Client hubspotClient = check new Client(
        {clientId, clientSecret, refreshToken, credentialBearer: oauth2:POST_BODY_BEARER}
    );

    // Create a new event

    hubspot:MarketingEventCreateRequestParams createPayload = {
        externalAccountId: "11111",
        externalEventId: "10000",
        eventName: "Winter webinar",
        eventOrganizer: "Snowman Fellowship",
        eventCancelled: false,
        eventUrl: "https://example.com/holiday-jam",
        eventType: "WEBINAR",
        eventDescription: "Let's get together to plan for the holidays",
        eventCompleted: false,
        startDateTime: "2024-08-07T12:36:59.286Z",
        endDateTime: "2024-08-07T12:36:59.286Z",
        customProperties: []
    };

    hubspot:MarketingEventDefaultResponse createResp = check hubspotClient->postEvents_create(createPayload);

    string eventObjId = createResp?.objectId ?: "-1";

    io:println("Event Created: ", eventObjId);

    // Update event details

    // NOTE: The custom property name should be created in the HubSpot account for that particular app before updating the event. Otherwise it won't be saved. 
    hubspot:CrmPropertyWrapper customProperty = {
        name: "test_name",
        value: "Custom Updated Value"
    };

    hubspot:MarketingEventPublicUpdateRequestV2 sampleUpdatePayload = {
        eventName: "Updated Event Name",
        eventOrganizer: "Updated Event Organizer",
        eventDescription: "Updated Event Description",
        eventUrl: "https://example.com/updated-holiday-jam",
        customProperties: [
            customProperty
        ]
    };

    hubspot:MarketingEventPublicDefaultResponseV2 updateResp = check hubspotClient->patchObjectid(eventObjId, sampleUpdatePayload);

    io:println("Event Updated: ", updateResp?.objectId ?: "-1");

    // Get the event

    hubspot:MarketingEventPublicDefaultResponseV2 getResp = check hubspotClient->getObjectid(eventObjId);

    io:println("Event Retrieved: ", getResp.toJsonString());

    // Change the event status to completed

    hubspot:MarketingEventCompleteRequestParams completePayload = {
        startDateTime: "2024-08-07T12:36:59.286Z",
        endDateTime: "2024-08-07T12:36:59.286Z"
    };

    hubspot:MarketingEventDefaultResponse completeResp = check hubspotClient->postEventsExternaleventidComplete_complete("11000", completePayload, externalAccountId = "11111");

    io:println("Event Completed: ", completeResp?.objectId ?: "-1");

};
