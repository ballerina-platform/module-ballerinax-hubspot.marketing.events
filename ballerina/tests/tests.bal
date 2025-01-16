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
import ballerina/oauth2;
import ballerina/test;

configurable boolean isLiveServer = false;
configurable string refreshToken = "mock";
configurable string clientId = "mock";
configurable string clientSecret = "mock";
configurable string devApiKey = "-1";
configurable int localPort = 9090;

Client hubspotClient = test:mock(Client);

// Using a separate client for app setting tests since it need developer API key
Client hubspotAppSettingClient = test:mock(Client);

string testObjId = "";
string[] batchTestObjIds = [];
string appId = "";

@test:BeforeSuite
function setupTests() returns error? {
    if isLiveServer {
        log:printInfo("Initiating live server");
        OAuth2RefreshTokenGrantConfig auth = {
            clientId,
            clientSecret,
            refreshToken,
            credentialBearer: oauth2:POST_BODY_BEARER // this line should be added in to when you are going to create auth object.
        };
        ConnectionConfig config = {auth};
        hubspotClient = check new (config);

        // Only create the app setting client if the Dev API key is set
        if devApiKey != "-1" {
            log:printInfo("Developer API Key Found. Running App Setting Tests");
            ApiKeysConfig apiKeysConfig = {
                hapikey: devApiKey,
                private\-app\-legacy: ""
            };
            hubspotAppSettingClient = check new ({auth: apiKeysConfig});
        } else {
            log:printInfo("Developer API Key Not Found. Skipping App Setting Tests");
        }

    } else {
        log:printInfo("Initiating mock server");
        check httpListener.attach(mockService, "/");
        check httpListener.'start();

        // Create Mock Auth Config
        OAuth2RefreshTokenGrantConfig mockAuth = {
            clientId,
            clientSecret,
            refreshToken,
            refreshUrl: string `http://localhost:${localPort}/oauth2/token`
        };
        ConnectionConfig mockConfig = {auth: mockAuth};

        hubspotClient = check new (mockConfig, string `http://localhost:${localPort}`);
    }

};

@test:Config {
    groups: ["BASIC", "live_tests", "mock_tests"]
}
function CreateMarketingEventTest() returns error? {

    // Create a New event
    CrmPropertyWrapper customProperty = {
        name: "test_name",
        value: "Custom Value"
    };

    MarketingEventCreateRequestParams sampleCreatePayload = {
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
        customProperties: [
            customProperty
        ]
    };

    MarketingEventDefaultResponse createResp = check hubspotClient->postEvents_create(sampleCreatePayload);

    test:assertTrue(createResp?.objectId !is "" && createResp?.objectId is string);
    test:assertTrue(createResp.eventName == sampleCreatePayload.eventName);
    testObjId = createResp?.objectId is null ? "" : createResp?.objectId.toString();
};

@test:Config {
    groups: ["BASIC", "live_tests", "mock_tests"]
}
function CreateOrUpdateMarketingEventTest() returns error? {

    // Create a New event

    string externalEventId = "11000";

    CrmPropertyWrapper customProperty = {
        name: "test_name",
        value: "Custom Value"
    };

    MarketingEventCreateRequestParams sampleCreatePayload = {
        externalAccountId: "11111",
        externalEventId: externalEventId,
        eventName: "Test 2",
        eventOrganizer: "Organizer 2",
        eventCancelled: false,
        eventUrl: "https://example.com/test-2",
        eventDescription: "Test 2",
        eventCompleted: false,
        eventType: "CONFERENCE",
        startDateTime: "2024-08-07T12:36:59.286Z",
        endDateTime: "2024-08-07T12:36:59.286Z",
        customProperties: [
            customProperty
        ]
    };

    MarketingEventPublicDefaultResponse createResp = check hubspotClient->putEventsExternaleventid_upsert(
        externalEventId, sampleCreatePayload);

    test:assertTrue(createResp?.objectId !is "" && createResp?.objectId is string);
    test:assertTrue(createResp.eventName == sampleCreatePayload.eventName);

    // Update an existing event 

    string updatedEventName = "Test 2 Updated";
    string updatedEventOrganizer = "Organizer 2 Updated";

    MarketingEventCreateRequestParams sampleUpdatePayload = {
        externalAccountId: "11111",
        externalEventId: externalEventId,
        eventName: updatedEventName,
        eventOrganizer: updatedEventOrganizer
    };

    MarketingEventPublicDefaultResponse updateResp = check hubspotClient->putEventsExternaleventid_upsert(
        externalEventId, sampleUpdatePayload);

    test:assertEquals(updateResp.eventName, updatedEventName);
    test:assertEquals(updateResp.eventOrganizer, updatedEventOrganizer);
};

@test:Config {
    groups: ["BASIC", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateOrUpdateMarketingEventTest]
}
function UpdateMarketingEventByExternalIdsTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";
    string updatedEventName = "Test 3 Updated";
    string updatedEventOrganizer = "Organizer 3 Updated";
    string updatedEventDescription = "Test 3 Updated";
    string updatedEventUrl = "https://example.com/test-3";

    MarketingEventUpdateRequestParams sampleUpdatePayload = {
        eventName: updatedEventName,
        eventOrganizer: updatedEventOrganizer,
        eventDescription: updatedEventDescription,
        eventUrl: updatedEventUrl
    };

    MarketingEventPublicDefaultResponse updateResp = check hubspotClient->patchEventsExternaleventid_update(
        externalEventId, sampleUpdatePayload, externalAccountId = externalAccountId);

    test:assertEquals(updateResp.eventName, updatedEventName);
    test:assertEquals(updateResp.eventOrganizer, updatedEventOrganizer);
    test:assertEquals(updateResp?.eventDescription, updatedEventDescription);
    test:assertEquals(updateResp?.eventUrl, updatedEventUrl);
};

@test:Config {
    groups: ["BASIC", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateMarketingEventTest]
}
function updateMarketingEventByObjectIdTest() returns error? {

    string updatedEventName = "Test 4 Updated";
    string updatedEventOrganizer = "Organizer 4 Updated";
    string updatedEventDescription = "Test 4 Updated";
    string updatedEventUrl = "https://example.com/test-4";

    CrmPropertyWrapper customProperty = {
        name: "test_name",
        value: "Custom Updated Value"
    };

    MarketingEventPublicUpdateRequestV2 sampleUpdatePayload = {
        eventName: updatedEventName,
        eventOrganizer: updatedEventOrganizer,
        eventDescription: updatedEventDescription,
        eventUrl: updatedEventUrl,
        customProperties: [
            customProperty
        ]
    };

    MarketingEventPublicDefaultResponseV2 updateResp = check hubspotClient->patchObjectid(testObjId, sampleUpdatePayload);

    test:assertEquals(updateResp.eventName, updatedEventName);
    test:assertEquals(updateResp?.eventOrganizer, updatedEventOrganizer);
    test:assertEquals(updateResp?.eventDescription, updatedEventDescription);
    test:assertEquals(updateResp?.eventUrl, updatedEventUrl);
};

@test:Config {
    groups: ["BASIC", "live_tests", "mock_tests"],
    dependsOn: [CreateMarketingEventTest, CreateOrUpdateMarketingEventTest]
}
function GetAllMarketingEventsTest() returns error? {

    CollectionResponseMarketingEventPublicReadResponseV2ForwardPaging getResp = check hubspotClient->get();

    test:assertTrue(getResp?.results !is ());
};

@test:Config {
    groups: ["BASIC", "live_tests"],
    enable: isLiveServer,
    dependsOn: [UpdateMarketingEventByExternalIdsTest, updateMarketingEventByObjectIdTest]
}
function GetMarketingEventbyExternalIdsTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";

    MarketingEventPublicReadResponse getResp = check hubspotClient->getEventsExternaleventid_getdetails(
        externalEventId, externalAccountId = externalAccountId);

    test:assertTrue(getResp?.objectId !is "" && getResp?.objectId is string);
    test:assertTrue(getResp.eventName != "");
};

@test:Config {
    groups: ["BASIC", "live_tests"],
    enable: isLiveServer,
    dependsOn: [updateMarketingEventByObjectIdTest]
}
function GetMarketingEventbyObjectIdTest() returns error? {
    // Correct Usage

    MarketingEventPublicReadResponseV2 getResp = check hubspotClient->getObjectid(testObjId);

    test:assertTrue(getResp.objectId !is "");
    test:assertTrue(getResp.eventName !is "");
    test:assertTrue(getResp?.appInfo?.id !is ());
    appId = getResp?.appInfo?.id ?: "-1";

    // Invalid ObjID
    string invalidObjId = "8456";

    MarketingEventPublicReadResponseV2|error getResp2 = hubspotClient->getObjectid(invalidObjId);

    test:assertTrue(getResp2 is error);
};

@test:Config {
    groups: ["BATCH", "live_tests"],
    enable: isLiveServer
}
function BatchCreateOrUpdateMarketingEventsTest() returns error? {
    string externalAccountId = "112233";

    CrmPropertyWrapper customPropertySample = {
        name: "test_name",
        value: "Custom Value"
    };

    MarketingEventCreateRequestParams sampleCreatePayload = {
        externalAccountId: externalAccountId,
        externalEventId: "20000",
        eventName: "Test 5",
        eventOrganizer: "Organizer 5",
        eventCancelled: false,
        eventUrl: "https://example.com/test-5",
        eventDescription: "Test 5",
        eventCompleted: false,
        eventType: "CONFERENCE",
        startDateTime: "2024-08-07T12:36:59.286Z",
        endDateTime: "2024-08-07T12:36:59.286Z",
        customProperties: [
            customPropertySample
        ]
    };

    MarketingEventCreateRequestParams sampleCreatePayload2 = {
        externalAccountId: externalAccountId,
        externalEventId: "21000",
        eventName: "Test 6",
        eventOrganizer: "Organizer 6",
        eventCancelled: false,
        eventUrl: "https://example.com/test-6",
        eventDescription: "Test 6",
        eventCompleted: false,
        eventType: "CONFERENCE",
        startDateTime: "2024-08-07T12:36:59.286Z",
        endDateTime: "2024-08-07T12:36:59.286Z",
        customProperties: [
            customPropertySample
        ]
    };

    MarketingEventCreateRequestParams sampleCreatePayload3 = {
        externalAccountId: externalAccountId,
        externalEventId: "22000",
        eventName: "Test 7",
        eventOrganizer: "Organizer 7",
        eventCancelled: false,
        eventUrl: "https://example.com/test-7",
        eventDescription: "Test 7",
        eventCompleted: false,
        eventType: "CONFERENCE",
        startDateTime: "2024-08-07T12:36:59.286Z",
        endDateTime: "2024-08-07T12:36:59.286Z",
        customProperties: [customPropertySample]
    };

    BatchInputMarketingEventCreateRequestParams batchPayload = {
        inputs: [sampleCreatePayload, sampleCreatePayload2]
    };

    BatchResponseMarketingEventPublicDefaultResponse batchResp = check
    hubspotClient->postEventsUpsert_batchupsert(batchPayload);

    if batchResp.results is MarketingEventPublicDefaultResponse[] {
        foreach MarketingEventPublicDefaultResponse resp in <MarketingEventPublicDefaultResponse[]>batchResp.results {
            test:assertTrue(resp?.objectId !is "" && resp?.objectId is string);
            batchTestObjIds.push(resp?.objectId.toString());
        }
    } else {
        test:assertFail("Batch Create or Update Marketing Events Failed");
    }

    test:assertTrue(batchResp.results is MarketingEventPublicDefaultResponse[] &&
            [<MarketingEventPublicDefaultResponse[]>batchResp.results].length() > 0);

    BatchInputMarketingEventCreateRequestParams batchPayload2 = {
        inputs: [sampleCreatePayload3]
    };

    BatchResponseMarketingEventPublicDefaultResponse batchResp2 = check hubspotClient->postEventsUpsert_batchupsert(batchPayload2);

    MarketingEventPublicDefaultResponse[] results = <MarketingEventPublicDefaultResponse[]>batchResp2.results;
    test:assertTrue(results[0]?.objectId is string && results[0]?.objectId !is "");
};

@test:Config {
    groups: ["BATCH", "live_tests"],
    enable: isLiveServer,
    dependsOn: [BatchCreateOrUpdateMarketingEventsTest]
}
function BatchUpdateMarketingEventsByObjectId() returns error? {
    CrmPropertyWrapper customPropertySample = {
        name: "test_name",
        value: "Updated Custom Value"
    };

    MarketingEventPublicUpdateRequestFullV2 sampleUpdatePayload = {
        objectId: batchTestObjIds[0],
        eventName: "Updated Test 5",
        eventOrganizer: "Updated Organizer 5",
        eventCancelled: false,
        eventUrl: "https://example.com/test-5",
        eventDescription: "Updated Test 5",
        "eventCompleted": false,
        eventType: "WEBINAR",
        startDateTime: "2024-08-07T12:36:59.286Z",
        endDateTime: "2024-08-07T12:36:59.286Z",
        customProperties: [
            customPropertySample
        ]
    };

    MarketingEventPublicUpdateRequestFullV2 sampleUpdatePayload2 = {
        objectId: batchTestObjIds[1],
        eventName: "Updated Test 6",
        eventOrganizer: "Updated Organizer 6",
        eventCancelled: false,
        eventUrl: "https://example.com/test-6",
        eventDescription: "Test 6",
        "eventCompleted": false,
        eventType: "CONFERENCE",
        startDateTime: "2024-08-07T12:36:59.286Z",
        endDateTime: "2024-08-07T12:36:59.286Z",
        customProperties: []
    };

    BatchInputMarketingEventPublicUpdateRequestFullV2 batchPayload = {
        inputs: [sampleUpdatePayload, sampleUpdatePayload2]
    };

    BatchResponseMarketingEventPublicDefaultResponseV2|BatchResponseMarketingEventPublicDefaultResponseV2WithErrors batchResp = check hubspotClient->postBatchUpdate(batchPayload);

    test:assertTrue(batchResp.results is MarketingEventPublicDefaultResponseV2[] && [<MarketingEventPublicDefaultResponseV2[]>batchResp.results].length() > 0);
    MarketingEventPublicDefaultResponseV2[] results = <MarketingEventPublicDefaultResponseV2[]>batchResp.results;
    foreach MarketingEventPublicDefaultResponseV2 res in results {
        test:assertEquals(res.eventName, res.objectId == batchTestObjIds[0] ? "Updated Test 5" : "Updated Test 6");
        test:assertEquals(res?.eventOrganizer, res.objectId == batchTestObjIds[0] ? "Updated Organizer 5" : "Updated Organizer 6");
    }
};

@test:AfterGroups {
    value: ["BATCH"]
}
function BatchDeleteMarketingEventsByExternalIds() returns error? {
    string externalAccountId = "112233";

    BatchInputMarketingEventExternalUniqueIdentifier batchPayload = {
        inputs: [
            {
                appId: 5801892,
                externalAccountId: externalAccountId,
                externalEventId: "22000"
            }

        ]
    };

    http:Response batchResp = check hubspotClient->postEventsDelete_batcharchive(batchPayload);

    test:assertTrue(batchResp.statusCode == 202);

}

@test:AfterGroups {
    value: ["BATCH"]
}
function BatchDeleteMarketingEventsByObjectId() returns error? {

    MarketingEventPublicObjectIdDeleteRequest[] inputs = [];

    foreach string objId in batchTestObjIds {
        inputs.push({objectId: objId});
    }

    BatchInputMarketingEventPublicObjectIdDeleteRequest batchPayload = {
        inputs: inputs
    };

    http:Response batchResp = check hubspotClient->postBatchArchive(batchPayload);

    test:assertTrue(batchResp.statusCode == 204);

    batchTestObjIds = [];
}

@test:Config {
    groups: ["ATTENDEES", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateMarketingEventTest]
}
function RecordParticipantsByContactIdwithMarketingEventObjectIdsTest() returns error? {

    string subscriberState = "register";

    BatchInputMarketingEventSubscriber payload = {
        inputs: [
            {
                interactionDateTime: 10000222,
                vid: 86097279137
            },
            {
                interactionDateTime: 11111222,
                vid: 86097783654
            }
        ]
    };

    BatchResponseSubscriberVidResponse recordResp = check hubspotClient->postObjectidAttendanceSubscriberstateCreate(
        testObjId, subscriberState, payload);

    test:assertTrue(recordResp.results is SubscriberVidResponse[] && [<SubscriberVidResponse[]>recordResp.results].length() > 0);
};

@test:Config {
    groups: ["ATTENDEES", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateMarketingEventTest]
}
function RecordParticipantsByEmailwithMarketingEventObjectIdsTest() returns error? {

    string subscriberState = "register";

    BatchInputMarketingEventEmailSubscriber payload = {
        inputs: [
            {
                interactionDateTime: 1212121212,
                email: "john.doe@abc.com"
            }
        ]
    };

    BatchResponseSubscriberVidResponse recordResp = check hubspotClient->postObjectidAttendanceSubscriberstateEmailCreate(
        testObjId, subscriberState, payload);

    test:assertTrue(recordResp.results is SubscriberVidResponse[] && [<SubscriberVidResponse[]>recordResp.results].length() > 0);
};

@test:Config {
    groups: ["ATTENDEES", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateOrUpdateMarketingEventTest]
}
function RecordParticipantsByEmailwithMarketingEventExternalIdsTest() returns error? {

    string subscriberState = "attend";
    string externalAccountId = "11111";
    string externalEventId = "11000";

    BatchInputMarketingEventEmailSubscriber payload = {
        inputs: [
            {
                interactionDateTime: 1212121212,
                email: "john.doe@abc.com"
            }
        ]
    };

    BatchResponseSubscriberEmailResponse recordResp = check hubspotClient->postAttendanceExternaleventidSubscriberstateEmailCreate_recordbycontactemails(
        externalEventId, subscriberState, payload, externalAccountId = externalAccountId);

    test:assertTrue(recordResp.results is SubscriberVidResponse[] && [<SubscriberVidResponse[]>recordResp.results].length() > 0);
};

@test:Config {
    groups: ["ATTENDEES", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateOrUpdateMarketingEventTest]
}
function RecordParticipantsByContactIdswithMarketingEventExternalIdsTest() returns error? {

    string subscriberState = "attend";
    string externalAccountId = "11111";
    string externalEventId = "11000";

    BatchInputMarketingEventSubscriber payload = {
        inputs: [
            {
                interactionDateTime: 10000222,
                vid: 86097279137
            },
            {
                interactionDateTime: 11111222,
                vid: 86097783654
            }
        ]
    };

    BatchResponseSubscriberVidResponse recordResp = check
    hubspotClient->postAttendanceExternaleventidSubscriberstateCreate_recordbycontactids(
        externalEventId, subscriberState, payload, externalAccountId = externalAccountId);

    test:assertTrue(recordResp.results is SubscriberVidResponse[] && [<SubscriberVidResponse[]>recordResp.results].length() > 0);
};

@test:Config {
    groups: ["IDENTIFIERS", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateMarketingEventTest]
}
function FindAppSpecificMarketingEventByExternalEventIdsTest() returns error? {

    string externalEventId = "11000";

    CollectionResponseSearchPublicResponseWrapperNoPaging resp = check hubspotClient->getEventsSearch_dosearch(
        q = externalEventId);

    test:assertTrue(resp.results !is ());
};

@test:Config {
    groups: ["IDENTIFIERS", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateMarketingEventTest]
}
function FindMarketingEventByExternalEventIdsTest() returns error? {

    string externalEventId = "11000";

    CollectionResponseWithTotalMarketingEventIdentifiersResponseNoPaging resp = check
    hubspotClient->getExternaleventidIdentifiers(externalEventId);

    test:assertTrue(resp.total !is ());
};

@test:Config {
    groups: ["EVENT_STATUS", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateMarketingEventTest]
}
function MarkEventCompletedTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "10000";

    MarketingEventCompleteRequestParams completePayload = {
        startDateTime: "2024-08-06T12:36:59.286Z",
        endDateTime: "2024-08-07T12:36:59.286Z"
    };

    MarketingEventDefaultResponse completeResp = check hubspotClient->postEventsExternaleventidComplete_complete(
        externalEventId, completePayload, externalAccountId = externalAccountId);

    test:assertTrue(completeResp?.objectId !is "");
    test:assertTrue(completeResp?.eventCompleted is boolean && <boolean>completeResp?.eventCompleted);
}

@test:Config {
    groups: ["EVENT_STATUS", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateMarketingEventTest]
}
function MarkEventCancelledTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "10000";

    MarketingEventDefaultResponse cancelResp = check hubspotClient->postEventsExternaleventidCancel_cancel(
        externalEventId, externalAccountId = externalAccountId);

    test:assertTrue(cancelResp?.objectId !is "");
    test:assertTrue(cancelResp?.eventCancelled is boolean && <boolean>cancelResp?.eventCancelled);
};

@test:Config {
    groups: ["SUBSCRIBER_STATE", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateMarketingEventTest, CreateOrUpdateMarketingEventTest]
}
function RecordSubStateByEmailTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";
    string subscriberState = "cancel";

    BatchInputMarketingEventEmailSubscriber dummyParticipants = {
        inputs: [
            {
                email: "john.doe@abc.com",
                interactionDateTime: 1223124
            }
        ]
    };

    http:Response cancelResp = check hubspotClient->postEventsExternaleventidSubscriberstateEmailUpsert_upsertbycontactemail(
        externalEventId, subscriberState, dummyParticipants, externalAccountId = externalAccountId);

    test:assertTrue(cancelResp.statusCode >= 200 && cancelResp.statusCode < 300);
};

@test:Config {
    groups: ["SUBSCRIBER_STATE", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateMarketingEventTest, CreateOrUpdateMarketingEventTest]
}
function RecordSubStateByContactIdTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";
    string subscriberState = "cancel";

    BatchInputMarketingEventSubscriber dummyParticipants = {
        inputs: [
            {
                "interactionDateTime": 10000222,
                "vid": 86097279137
            },
            {
                "interactionDateTime": 11111222,
                "vid": 86097783654
            }
        ]
    };

    http:Response cancelResp = check hubspotClient->postEventsExternaleventidSubscriberstateUpsert_upsertbycontactid(
        externalEventId, subscriberState, dummyParticipants, externalAccountId = externalAccountId);

    test:assertTrue(cancelResp.statusCode >= 200 && cancelResp.statusCode < 300);
};

@test:Config {
    groups: ["PARTICIPATION", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateMarketingEventTest]
}
function ReadParticipationBreakdownByContactIdentifierTest() returns error? {

    string email = "john.doe@abc.com";

    CollectionResponseWithTotalParticipationBreakdownForwardPaging getResp = check hubspotClient->getParticipationsContactsContactidentifierBreakdown_getparticipationsbreakdownbycontactid(email);

    test:assertFalse(getResp.results is ());
    test:assertTrue(getResp.total is int);
};

@test:Config {
    groups: ["PARTICIPATION", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateMarketingEventTest, CreateOrUpdateMarketingEventTest]
}
function ReadParticipationBreakdownByExternalIdTest() returns error? {

    string externalEventId = "11000";
    string externalAccountId = "11111";

    CollectionResponseWithTotalParticipationBreakdownForwardPaging getResp = check hubspotClient->getParticipationsExternalaccountidExternaleventidBreakdown_getparticipationsbreakdownbyexternaleventid(
        externalAccountId, externalEventId);

    test:assertFalse(getResp.results is ());
    test:assertTrue(getResp.total is int);
};

@test:Config {
    groups: ["PARTICIPATION", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateMarketingEventTest, CreateOrUpdateMarketingEventTest]
}
function ReadParticipationBreakdownByInternalIdTest() returns error? {

    int internalId = check int:fromString(testObjId);

    CollectionResponseWithTotalParticipationBreakdownForwardPaging getResp = check hubspotClient->getParticipationsMarketingeventidBreakdown_getparticipationsbreakdownbymarketingeventid(internalId);

    test:assertFalse(getResp.results is ());
    test:assertTrue(getResp.total is int);
};

@test:Config {
    groups: ["PARTICIPATION", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateMarketingEventTest, CreateOrUpdateMarketingEventTest]
}
function ReadParticipationCountByInternalIdTest() returns error? {

    int id = check int:fromString(testObjId);

    AttendanceCounters getResp = check
    hubspotClient->getParticipationsMarketingeventid_getparticipationscountersbymarketingeventid(id);

    test:assertTrue(getResp.attended is int);
    test:assertTrue(getResp.registered is int);
};

@test:Config {
    groups: ["PARTICIPATION", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateMarketingEventTest, CreateOrUpdateMarketingEventTest]
}
function ReadParticipationCountByExternalIdTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";

    AttendanceCounters getResp = check
    hubspotClient->getParticipationsExternalaccountidExternaleventid_getparticipationscountersbyeventexternalid(
        externalAccountId, externalEventId);

    test:assertTrue(getResp.attended is int);
    test:assertTrue(getResp.registered is int);
};

@test:Config {
    groups: ["LISTS", "live_tests"],
    enable: isLiveServer,
    dependsOn: [CreateMarketingEventTest, CreateOrUpdateMarketingEventTest]
}
function AssociateListFromExternalIdsTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";

    string listId = "9"; // ILS List ID of the list

    http:Response createResp = check
    hubspotClient->putAssociationsExternalaccountidExternaleventidListsListid_associatebyexternalaccountandeventids(
        externalAccountId, externalEventId, listId);

    test:assertTrue(createResp.statusCode >= 200 && createResp.statusCode < 300);
}

@test:Config {
    groups: ["LISTS", "live_tests", "mock_tests"],
    dependsOn: [CreateMarketingEventTest, CreateOrUpdateMarketingEventTest]
}
function AssociateListFromInternalIdsTest() returns error? {

    string listId = "9"; // ILS List ID of the list

    http:Response createResp = check
    hubspotClient->putAssociationsMarketingeventidListsListid_associatebymarketingeventid(testObjId, listId);

    test:assertTrue(createResp.statusCode >= 200 && createResp.statusCode < 300);
}

@test:Config {
    groups: ["LISTS", "live_tests"],
    enable: isLiveServer,
    dependsOn: [AssociateListFromInternalIdsTest]
}
function GetAssociatedListsFromInternalIdsTest() returns error? {

    CollectionResponseWithTotalPublicListNoPaging getResp = check
    hubspotClient->getAssociationsMarketingeventidLists_getallbymarketingeventid(testObjId);

    test:assertTrue(getResp.total is int);
};

@test:Config {
    groups: ["LISTS", "live_tests"],
    enable: isLiveServer,
    dependsOn: [AssociateListFromExternalIdsTest]
}
function GetAssociatedListsFromExternalIdsTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";

    CollectionResponseWithTotalPublicListNoPaging getResp = check hubspotClient->getAssociationsExternalaccountidExternaleventidLists_getallbyexternalaccountandeventids(
        externalAccountId, externalEventId);
    test:assertTrue(getResp.total is int);
};

@test:Config {
    groups: ["LISTS", "live_tests"],
    enable: isLiveServer,
    dependsOn: [GetAssociatedListsFromExternalIdsTest]
}
function DeleteAssociatedListsfromExternalIdsTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";

    string listId = "9"; // ILS List ID of the list

    http:Response deleteResp = check hubspotClient->deleteAssociationsExternalaccountidExternaleventidListsListid_disassociatebyexternalaccountandeventids(
        externalAccountId, externalEventId, listId);

    test:assertTrue(deleteResp.statusCode >= 200 && deleteResp.statusCode < 300);
}

@test:Config {
    groups: ["LISTS", "live_tests"],
    enable: isLiveServer,
    dependsOn: [GetAssociatedListsFromInternalIdsTest]
}
function DeleteAssociatedListsfromInternalIdsTest() returns error? {

    string listId = "9"; // ILS List ID of the list

    http:Response deleteResp = check
    hubspotClient->deleteAssociationsMarketingeventidListsListid_disassociatebymarketingeventid(testObjId, listId);

    test:assertTrue(deleteResp.statusCode >= 200 && deleteResp.statusCode < 300);
}

// Set App Settings

@test:Config {
    groups: ["APP_SETTINGS", "live_tests"],
    enable: isLiveServer,
    dependsOn: [GetMarketingEventbyObjectIdTest]
}
function SetAppSettingsTest() returns error? {

    if devApiKey == "-1" {
        log:printInfo("Developer API Key Not Found. Skipping App Setting Tests");
        return;
    }

    EventDetailSettingsUrl payload = {
        eventDetailsUrl: "https://my.event.app/events/%s"
    };

    EventDetailSettings setResp = check
    hubspotAppSettingClient->postAppidSettings_update(check int:fromString(appId).ensureType(int:Signed32), payload);

    test:assertTrue(setResp?.appId.toString() == appId);
};

// Retrieve App Settings

@test:Config {
    groups: ["APP_SETTINGS", "live_tests"],
    enable: isLiveServer,
    dependsOn: [SetAppSettingsTest]
}
function GetAppSettingsTest() returns error? {

    if devApiKey == "-1" {
        log:printInfo("Developer API Key Not Found. Skipping App Retrieving Tests");
        return;
    }

    EventDetailSettings getResp = check
    hubspotAppSettingClient->getAppidSettings_getall(check int:fromString(appId).ensureType(int:Signed32));

    test:assertTrue(getResp?.appId.toString() == appId);
    test:assertEquals(getResp?.eventDetailsUrl, "https://my.event.app/events/%s");
};

// Delete All the Event Objects (After Suite)

@test:AfterSuite
function DeleteMarketingEventByObjectIdTest() returns error? {

    // Valid ObjID

    http:Response deleteResp = check hubspotClient->deleteObjectid(testObjId);

    test:assertTrue(deleteResp.statusCode == 204);

    // Invalid ObjID

    string invalidObjId = "8436";

    http:Response deleteResp2 = check hubspotClient->deleteObjectid(invalidObjId);

    test:assertTrue(deleteResp2.statusCode == 404);
    testObjId = "";
};

@test:AfterSuite
function DeleteMarketingEventByExternalIdsTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";

    // Valid External Ids

    http:Response deleteResp = check
    hubspotClient->deleteEventsExternaleventid_archive(externalEventId, externalAccountId = externalAccountId);

    test:assertTrue(deleteResp.statusCode == 204);
};
