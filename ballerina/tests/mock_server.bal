// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com).
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
import ballerina/log;

listener http:Listener httpListener = new (localPort);

http:Service mockService = service object {

    resource isolated function post events(@http:Payload MarketingEventCreateRequestParams createPayload) 
    returns MarketingEventDefaultResponse {
        MarketingEventDefaultResponse response = {
            eventName: createPayload.eventName,
            eventType:  createPayload?.eventType ?: "WEBINAR",
            startDateTime: "2024-08-07T12:36:59.286Z",
            endDateTime: "2024-08-07T12:36:59.286Z",
            eventOrganizer: createPayload.eventOrganizer,
            eventDescription: createPayload?.eventDescription ?: "Let's get together to plan for the holidays",
            eventUrl: createPayload?.eventUrl ?: "https://example.com/holiday-jam",
            eventCancelled: false,
            eventCompleted: false,
            customProperties: [
            {
                name: "test_name",
                value: "Custom Value",
                "sourceVid": []
            }
            ],
            objectId: "395700216901"
        };
        return response;
    }

    resource isolated function put events/[string externalEventId](
        @http:Payload MarketingEventCreateRequestParams payload) returns MarketingEventPublicDefaultResponse {
        return {
            eventName: payload.eventName,
            eventType: payload?.eventType ?: "CONFERENCE",
            startDateTime: payload?.startDateTime ?: "2024-08-07T12:36:59.286Z",
            endDateTime: payload?.endDateTime ?: "2024-08-07T12:36:59.286Z",
            eventOrganizer: payload.eventOrganizer,
            eventDescription: payload?.eventDescription ?: "Let's get together to plan for the holidays",
            eventUrl: payload?.eventUrl ?: "https://example.com/holiday-jam",
            eventCancelled: payload?.eventCancelled ?: false,
            eventCompleted: payload?.eventCompleted ?: false,
            customProperties: payload?.customProperties ?: [],
            objectId: "395717835891",
            id: externalEventId,
            createdAt: "2025-01-09T08:39:19.907Z",
            updatedAt: "2025-01-09T08:39:19.907Z"
        };
    }

    resource isolated function get .() returns CollectionResponseMarketingEventPublicReadResponseV2ForwardPaging {
        CollectionResponseMarketingEventPublicReadResponseV2ForwardPaging response = {
            results: [
                {
                    eventName: "Winter webinar",
                    eventType: "WEBINAR",
                    startDateTime: "2024-08-07T12:36:59.286Z",
                    endDateTime: "2024-08-07T12:36:59.286Z",
                    eventOrganizer: "Snowman Fellowship",
                    eventDescription: "Let's get together to plan for the holidays",
                    eventUrl: "https://example.com/holiday-jam",
                    eventCancelled: false,
                    eventCompleted: false,
                    customProperties: [
                        {
                            name: "test_name",
                            value: "Custom Value"
                        }
                    ],
                    objectId: "395700216901",
                    externalEventId: "10000",
                    eventStatus: "PAST",
                    appInfo: {
                        id: "5801892",
                        name: "Ballerina Connector for HubSpot Marketing Events"
                    },
                    registrants: 0,
                    attendees: 0,
                    cancellations: 0,
                    noShows: 0,
                    createdAt: "2025-01-09T04:54:11.852Z",
                    updatedAt: "2025-01-09T04:54:12.542Z"
                }
            ]
        };
        return response;
    }

    // Associate List

    resource isolated function put associations/[string objectId]/lists/[string listId]() returns http:Response {
        http:Response response = new;
        response.statusCode = 204;
        return response;
    }

    resource isolated function delete events/[string externalEventId]() returns http:Response {
        http:Response response = new;
        response.statusCode = 204;
        return response;
    }

    resource isolated function delete [string objectId]() returns http:Response {
        http:Response response = new;
        if (objectId == "8436") {
            response.statusCode = 404;
            return response;
        }
        response.statusCode = 204;
        return response;
    }

};

function init() returns error? {
    if isLiveServer {
        log:printInfo("Skipping mock server initialization as the tests are running on live server");
        return;
    }
    log:printInfo("Initiating mock server");
    check httpListener.attach(mockService, "/");
    check httpListener.'start();
}
