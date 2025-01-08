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

import ballerina/oauth2;
import ballerinax/hubspot.marketing.events as hubspot;
import ballerina/io;
import ballerina/http;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;

public function main() {

    string url = "https://api.hubapi.com/marketing/v3/marketing-events";

    final hubspot:Client hubspotClient = check new Client(
        {clientId, clientSecret, refreshToken, credentialBearer: oauth2:POST_BODY_BEARER}, serviceUrl
    );

    // Create a new event

    hubspot:MarketingEventCreateRequestParams createPayload = {
        "externalAccountId": "11111",
        "externalEventId": "10000",
        "eventName": "Winter webinar",
        "eventOrganizer": "Snowman Fellowship",
        "eventCancelled": false,
        "eventUrl": "https://example.com/holiday-jam",
        "eventType": "WEBINAR",
        "eventDescription": "Let's get together to plan for the holidays",
        "eventCompleted": false,
        "startDateTime": "2024-08-07T12:36:59.286Z",
        "endDateTime": "2024-08-07T12:36:59.286Z",
        "customProperties": []
    };

    hubspot:MarketingEventDefaultResponse createResp = check hubspotClient->/events.post(createPayload);

    string eventObjId = createResp?.objectId ?: "-1";

    io:println("Event Created: ", eventObjId);


    // Register Participants to the event

    hubspot:BatchInputMarketingEventEmailSubscriber dummyParticipants = {
        inputs:[
            {
                email: "john.doe@abc.com",
                interactionDateTime: 1223124
            }
        ]
    };


    hubspot:BatchResponseSubscriberVidResponse registerResp = check hubspotClient->/[eventObjId]/attendance/register/email\-create.post(dummyParticipants);

    io:println("Participants Registered: ", registerResp?.results ?: "Failed");

    // Change Participant Status

    http:Response attendResp = check hubspotClient->/events/["10000"]/["attend"]/email\-upsert.post(dummyParticipants, externalAccountId = "11111");

    io:println("Participant Status Changed: ", attendResp.statusCode == 200 ? "Success" : "Failed");
    
}
