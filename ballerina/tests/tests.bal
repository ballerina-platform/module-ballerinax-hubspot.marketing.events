import ballerina/http;
import ballerina/log;
import ballerina/oauth2;
import ballerina/test;

configurable boolean isLiveServer = ?;
configurable string serviceUrl = ?;
configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable int localPort = 9090;

Client hubspotClient = test:mock(Client);

OAuth2RefreshTokenGrantConfig auth = {
    clientId: isLiveServer ? clientId : "test",
    clientSecret: isLiveServer ? clientSecret : "test",
    refreshToken: isLiveServer ? refreshToken : "test",
    credentialBearer: oauth2:POST_BODY_BEARER // this line should be added in to when you are going to create auth object.
};
ConnectionConfig config = {auth};

@test:BeforeSuite
function setup() returns error? {
    if isLiveServer {
        log:printInfo("Starting Live Tests");
    } else {
        log:printInfo("Starting Mock Tests");
    }
    hubspotClient = check new (config, isLiveServer ? serviceUrl : string `localhost:${localPort}`);
}

string testObjId = "";
string[] batchTestObjIds = [];

@test:Config {
    groups: ["BASIC"]
}
function CreateMarketingEventTest() returns error? {

    // Create a New event

    CrmPropertyWrapper customProperty = {
        "name": "test_name",
        "value": "Custom Value"
    };

    MarketingEventCreateRequestParams sampleCreatePayload = {
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
        "customProperties": [
            customProperty
        ]
    };

    MarketingEventDefaultResponse createResp = check hubspotClient->postEvents_create(sampleCreatePayload);

    log:printInfo(string `Create Marketing Event Response: \n ${createResp.toString()}`);

    test:assertTrue(createResp?.objectId !is "" && createResp?.objectId is string);
    test:assertTrue(createResp.eventName == sampleCreatePayload.eventName);

    testObjId = createResp?.objectId is null ? "" : createResp?.objectId.toString();

    log:printInfo("Create Marketing Event Successful");

};

@test:Config {
    groups: ["BASIC"]
}
function CreateOrUpdateMarketingEventTest() returns error? {

    // Create a New event

    string externalEventId = "11000";

    CrmPropertyWrapper customProperty = {
        "name": "test_name",
        "value": "Custom Value"
    };

    MarketingEventCreateRequestParams sampleCreatePayload = {
        "externalAccountId": "11111",
        "externalEventId": externalEventId,
        "eventName": "Test 2",
        "eventOrganizer": "Organizer 2",
        "eventCancelled": false,
        "eventUrl": "https://example.com/test-2",
        "eventDescription": "Test 2",
        "eventCompleted": false,
        "eventType": "CONFERENCE",
        "startDateTime": "2024-08-07T12:36:59.286Z",
        "endDateTime": "2024-08-07T12:36:59.286Z",
        "customProperties": [
            customProperty
        ]
    };

    MarketingEventPublicDefaultResponse createResp = check hubspotClient->putEventsExternaleventid_upsert(externalEventId, sampleCreatePayload);

    log:printInfo(string `Create Marketing Event using create or update Response: \n ${createResp.toString()}`);

    test:assertTrue(createResp?.objectId !is "" && createResp?.objectId is string);
    test:assertTrue(createResp.eventName == sampleCreatePayload.eventName);

    log:printInfo("Create or update Marketing Event - 1 Successful");

    // Update an existing event 

    string updatedEventName = "Test 2 Updated";
    string updatedEventOrganizer = "Organizer 2 Updated";

    MarketingEventCreateRequestParams sampleUpdatePayload = {
        "externalAccountId": "11111",
        "externalEventId": externalEventId,
        "eventName": updatedEventName,
        "eventOrganizer": updatedEventOrganizer
    };

    MarketingEventPublicDefaultResponse updateResp = check hubspotClient->putEventsExternaleventid_upsert(externalEventId, sampleUpdatePayload);

    log:printInfo(string `Update Marketing Event using create or update Response: \n ${sampleUpdatePayload.toString()}`);

    test:assertEquals(updateResp.eventName, updatedEventName);
    test:assertEquals(updateResp.eventOrganizer, updatedEventOrganizer);

    log:printInfo("Create or update Marketing Event - 2 Successful");

};

@test:Config {
    groups: ["BASIC"],
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
        "eventName": updatedEventName,
        "eventOrganizer": updatedEventOrganizer,
        "eventDescription": updatedEventDescription,
        "eventUrl": updatedEventUrl
    };

    MarketingEventPublicDefaultResponse updateResp = check hubspotClient->patchEventsExternaleventid_update(externalEventId, sampleUpdatePayload, externalAccountId = externalAccountId);

    log:printInfo(string `Update Marketing Event by external Ids Response: \n ${updateResp.toString()}`);
    test:assertEquals(updateResp.eventName, updatedEventName);
    test:assertEquals(updateResp.eventOrganizer, updatedEventOrganizer);
    test:assertEquals(updateResp?.eventDescription, updatedEventDescription);
    test:assertEquals(updateResp?.eventUrl, updatedEventUrl);

};

@test:Config {
    groups: ["BASIC"],
    dependsOn: [CreateMarketingEventTest]
}
function updateMarketingEventByObjectIdTest() returns error? {

    string updatedEventName = "Test 4 Updated";
    string updatedEventOrganizer = "Organizer 4 Updated";
    string updatedEventDescription = "Test 4 Updated";
    string updatedEventUrl = "https://example.com/test-4";

    CrmPropertyWrapper customProperty = {
        "name": "test_name",
        "value": "Custom Updated Value"
    };

    MarketingEventPublicUpdateRequestV2 sampleUpdatePayload = {
        "eventName": updatedEventName,
        "eventOrganizer": updatedEventOrganizer,
        "eventDescription": updatedEventDescription,
        "eventUrl": updatedEventUrl,
        "customProperties": [
            customProperty
        ]
    };

    MarketingEventPublicDefaultResponseV2 updateResp = check hubspotClient->patchObjectid(testObjId, sampleUpdatePayload);

    log:printInfo(string `Update Marketing Event by object Id ${testObjId} Response: \n ${updateResp.toString()}`);
    test:assertEquals(updateResp.eventName, updatedEventName);
    test:assertEquals(updateResp?.eventOrganizer, updatedEventOrganizer);
    test:assertEquals(updateResp?.eventDescription, updatedEventDescription);
    test:assertEquals(updateResp?.eventUrl, updatedEventUrl);
};

@test:Config {
    groups: ["BASIC"],
    dependsOn: [UpdateMarketingEventByExternalIdsTest, updateMarketingEventByObjectIdTest]
}
function GetAllMarketingEventsTest() returns error? {

    CollectionResponseMarketingEventPublicReadResponseV2ForwardPaging getResp = check hubspotClient->get();

    log:printInfo(string `Get All Marketing Events Response: \n ${getResp.toString()}`);

    test:assertTrue(getResp?.results !is ());
};

@test:Config {
    groups: ["BASIC"],
    dependsOn: [UpdateMarketingEventByExternalIdsTest, updateMarketingEventByObjectIdTest]
}
function GetMarketingEventbyExternalIdsTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";

    MarketingEventPublicReadResponse getResp = check hubspotClient->getEventsExternaleventid_getdetails(externalEventId, externalAccountId = externalAccountId);

    log:printInfo(string `Get Marketing Event by ExternalIds Response: \n ${getResp.toString()}`);

    test:assertTrue(getResp?.objectId !is "" && getResp?.objectId is string);
    test:assertTrue(getResp.eventName != "");
};

@test:Config {
    groups: ["BASIC"],
    dependsOn: [UpdateMarketingEventByExternalIdsTest, updateMarketingEventByObjectIdTest]
}
function GetMarketingEventbyObjectIdTest() returns error? {

    // Correct Usage

    MarketingEventPublicReadResponseV2 getResp = check hubspotClient->getObjectid(testObjId);

    log:printInfo(string `Get Marketing Event by object Id ${testObjId} Response: \n ${getResp.toString()}`);

    test:assertTrue(getResp.objectId !is "");
    test:assertTrue(getResp.eventName !is "");

    log:printInfo("Get Marketing Event by object Id Successful - 1");

    // Invalid ObjID

    string invalidObjId = "8456";

    MarketingEventPublicReadResponseV2|error getResp2 = hubspotClient->getObjectid(invalidObjId);

    // log:printInfo(string `Get Marketing Event by object Id Response: \n ${getResp2.toString()}`);

    test:assertTrue(getResp2 is error);

    log:printInfo("Get Marketing Event by object Id Successful - 2");

};

@test:Config {
    groups: ["BATCH"]
}
function BatchCreateOrUpdateMarketingEventsTest() returns error? {

    string externalAccountId = "112233";

    CrmPropertyWrapper customPropertySample = {
        "name": "test_name",
        "value": "Custom Value"
    };

    MarketingEventCreateRequestParams sampleCreatePayload = {
        "externalAccountId": externalAccountId,
        "externalEventId": "20000",
        "eventName": "Test 5",
        "eventOrganizer": "Organizer 5",
        "eventCancelled": false,
        "eventUrl": "https://example.com/test-5",
        "eventDescription": "Test 5",
        "eventCompleted": false,
        "eventType": "CONFERENCE",
        "startDateTime": "2024-08-07T12:36:59.286Z",
        "endDateTime": "2024-08-07T12:36:59.286Z",
        "customProperties": [
            customPropertySample
        ]
    };

    MarketingEventCreateRequestParams sampleCreatePayload2 = {
        "externalAccountId": externalAccountId,
        "externalEventId": "21000",
        "eventName": "Test 6",
        "eventOrganizer": "Organizer 6",
        "eventCancelled": false,
        "eventUrl": "https://example.com/test-6",
        "eventDescription": "Test 6",
        "eventCompleted": false,
        "eventType": "CONFERENCE",
        "startDateTime": "2024-08-07T12:36:59.286Z",
        "endDateTime": "2024-08-07T12:36:59.286Z",
        "customProperties": [
            customPropertySample
        ]
    };

    MarketingEventCreateRequestParams sampleCreatePayload3 = {
        "externalAccountId": externalAccountId,
        "externalEventId": "22000",
        "eventName": "Test 7",
        "eventOrganizer": "Organizer 7",
        "eventCancelled": false,
        "eventUrl": "https://example.com/test-7",
        "eventDescription": "Test 7",
        "eventCompleted": false,
        "eventType": "CONFERENCE",
        "startDateTime": "2024-08-07T12:36:59.286Z",
        "endDateTime": "2024-08-07T12:36:59.286Z",
        "customProperties": [customPropertySample]
    };

    BatchInputMarketingEventCreateRequestParams batchPayload = {
        inputs: [sampleCreatePayload, sampleCreatePayload2]
    };

    BatchResponseMarketingEventPublicDefaultResponse batchResp = check hubspotClient->postEventsUpsert_batchupsert(batchPayload);

    log:printInfo(string `Batch Create or Update Marketing Events Response: \n ${batchResp.toString()}`);
    if batchResp.results is MarketingEventPublicDefaultResponse[] {
        foreach MarketingEventPublicDefaultResponse resp in <MarketingEventPublicDefaultResponse[]>batchResp.results {
            test:assertTrue(resp?.objectId !is "" && resp?.objectId is string);
            batchTestObjIds.push(resp?.objectId.toString());
        }
    } else {
        test:assertFail("Batch Create or Update Marketing Events Failed");
    }

    test:assertTrue(batchResp.results is MarketingEventPublicDefaultResponse[] && [<MarketingEventPublicDefaultResponse[]>batchResp.results].length() > 0);

    BatchInputMarketingEventCreateRequestParams batchPayload2 = {
        inputs: [sampleCreatePayload3]
    };

    BatchResponseMarketingEventPublicDefaultResponse batchResp2 = check hubspotClient->postEventsUpsert_batchupsert(batchPayload2);

    log:printInfo(string `Batch Create or Update Marketing Events Response: \n ${batchResp2.toString()}`);
};

@test:Config {
    groups: ["BATCH"],
    dependsOn: [BatchCreateOrUpdateMarketingEventsTest]
}
function BatchUpdateMarketingEventsByObjectId() returns error? {

    CrmPropertyWrapper customPropertySample = {
        "name": "test_name",
        "value": "Updated Custom Value"
    };

    MarketingEventPublicUpdateRequestFullV2 sampleUpdatePayload = {
        "objectId": batchTestObjIds[0],
        "eventName": "Updated Test 5",
        "eventOrganizer": "Updated Organizer 5",
        "eventCancelled": false,
        "eventUrl": "https://example.com/test-5",
        "eventDescription": "Updated Test 5",
        "eventCompleted": false,
        "eventType": "WEBINAR",
        "startDateTime": "2024-08-07T12:36:59.286Z",
        "endDateTime": "2024-08-07T12:36:59.286Z",
        customProperties: [
            customPropertySample
        ]
    };

    MarketingEventPublicUpdateRequestFullV2 sampleUpdatePayload2 = {
        "objectId": batchTestObjIds[1],
        "eventName": "Updated Test 6",
        "eventOrganizer": "Updated Organizer 6",
        "eventCancelled": false,
        "eventUrl": "https://example.com/test-6",
        "eventDescription": "Test 6",
        "eventCompleted": false,
        "eventType": "CONFERENCE",
        "startDateTime": "2024-08-07T12:36:59.286Z",
        "endDateTime": "2024-08-07T12:36:59.286Z",
        "customProperties": []
    };

    BatchInputMarketingEventPublicUpdateRequestFullV2 batchPayload = {
        inputs: [sampleUpdatePayload, sampleUpdatePayload2]
    };

    BatchResponseMarketingEventPublicDefaultResponseV2|BatchResponseMarketingEventPublicDefaultResponseV2WithErrors batchResp = check hubspotClient->postBatchUpdate(batchPayload);

    log:printInfo(string `Batch Create or Update Marketing Events Response: \n ${batchResp.toString()}`);

    test:assertTrue(batchResp.results is MarketingEventPublicDefaultResponseV2[] && [<MarketingEventPublicDefaultResponseV2[]>batchResp.results].length() > 0);
    MarketingEventPublicDefaultResponseV2[] results = <MarketingEventPublicDefaultResponseV2[]>batchResp.results;
    foreach MarketingEventPublicDefaultResponseV2 res in results {
        test:assertEquals(res.eventName, res.objectId == batchTestObjIds[0] ? "Updated Test 5" : "Updated Test 6");
        test:assertEquals(res?.eventOrganizer, res.objectId == batchTestObjIds[0] ? "Updated Organizer 5" : "Updated Organizer 6");
    }
};

@test:AfterGroups {
    value: ["BATCH"],
    alwaysRun: true
}
function BatchDeleteMarketingEventsByExternalIds() returns error? {
    string externalAccountId = "112233";

    BatchInputMarketingEventExternalUniqueIdentifier batchPayload = {
        inputs: [
            {
                "appId": 5801892,
                "externalAccountId": externalAccountId,
                "externalEventId": "22000"
            }

        ]
    };

    http:Response batchResp = check hubspotClient->postEventsDelete_batcharchive(batchPayload);

    log:printInfo(string `Batch Delete Marketing Events by External Ids 22000`);

    log:printInfo(batchResp.statusCode.toString());

    test:assertTrue(batchResp.statusCode == 202);

}

@test:AfterGroups {
    value: ["BATCH"],
    alwaysRun: true
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

    log:printInfo(string `Batch Delete Marketing Events by Object Ids ${batchTestObjIds.toString()}`);

    log:printInfo(batchResp.statusCode.toString());

    test:assertTrue(batchResp.statusCode == 204);

    batchTestObjIds = [];
}

@test:Config {
    groups: ["ATTENDEES"],
    dependsOn: [CreateMarketingEventTest]
}
function RecordParticipantsByContactIdwithMarketingEventObjectIdsTest() returns error? {

    string subscriberState = "register";

    BatchInputMarketingEventSubscriber payload = {
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

    BatchResponseSubscriberVidResponse recordResp = check hubspotClient->postObjectidAttendanceSubscriberstateCreate(testObjId, subscriberState, payload);

    log:printInfo(string `Record Participants by Contact Id with Marketing Event Object Ids Response: \n ${recordResp.toString()}`);

    test:assertTrue(recordResp.results is SubscriberVidResponse[] && [<SubscriberVidResponse[]>recordResp.results].length() > 0);

};

@test:Config {
    groups: ["ATTENDEES"],
    dependsOn: [CreateMarketingEventTest]
}
function RecordParticipantsByEmailwithMarketingEventObjectIdsTest() returns error? {

    string subscriberState = "register";

    BatchInputMarketingEventEmailSubscriber payload = {
        inputs: [
            {
                "interactionDateTime": 1212121212,
                "email": "john.doe@abc.com"
            }
        ]
    };

    BatchResponseSubscriberVidResponse recordResp = check hubspotClient->postObjectidAttendanceSubscriberstateEmailCreate(testObjId, subscriberState, payload);

    log:printInfo(string `Record Participants by Email with Marketing Event Object Ids Response: \n ${recordResp.toString()}`);

    test:assertTrue(recordResp.results is SubscriberVidResponse[] && [<SubscriberVidResponse[]>recordResp.results].length() > 0);

};

@test:Config {
    groups: ["ATTENDEES"],
    dependsOn: [CreateOrUpdateMarketingEventTest]
}
function RecordParticipantsByEmailwithMarketingEventExternalIdsTest() returns error? {

    string subscriberState = "attend";
    string externalAccountId = "11111";
    string externalEventId = "11000";

    BatchInputMarketingEventEmailSubscriber payload = {
        inputs: [
            {
                "interactionDateTime": 1212121212,
                "email": "john.doe@abc.com"
            }
        ]
    };

    BatchResponseSubscriberEmailResponse recordResp = check hubspotClient->postAttendanceExternaleventidSubscriberstateEmailCreate_recordbycontactemails(externalEventId, subscriberState, payload, externalAccountId = externalAccountId);

    log:printInfo(string `Record Participants by Email with Marketing Event External Ids Response: \n ${recordResp.toString()}`);

    test:assertTrue(recordResp.results is SubscriberVidResponse[] && [<SubscriberVidResponse[]>recordResp.results].length() > 0);
};

@test:Config {
    groups: ["ATTENDEES"],
    dependsOn: [CreateOrUpdateMarketingEventTest]
}
function RecordParticipantsByContactIdswithMarketingEventExternalIdsTest() returns error? {

    string subscriberState = "attend";
    string externalAccountId = "11111";
    string externalEventId = "11000";

    BatchInputMarketingEventSubscriber payload = {
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

    BatchResponseSubscriberVidResponse recordResp = check hubspotClient->postAttendanceExternaleventidSubscriberstateCreate_recordbycontactids(externalEventId, subscriberState, payload, externalAccountId = externalAccountId);

    log:printInfo(string `Record Participants by Email with Marketing Event External Ids Response: \n ${recordResp.toString()}`);

    test:assertTrue(recordResp.results is SubscriberVidResponse[] && [<SubscriberVidResponse[]>recordResp.results].length() > 0);
};

@test:Config {
    groups: ["IDENTIFIERS"],
    dependsOn: [CreateMarketingEventTest]
}
function FindAppSpecificMarketingEventByExternalEventIdsTest() returns error? {

    string externalEventId = "11000";

    CollectionResponseSearchPublicResponseWrapperNoPaging resp = check hubspotClient->getEventsSearch_dosearch(q = externalEventId);

    log:printInfo(string `Find App Specific Marketing Event by External Event Ids Response: \n ${resp.toString()}`);

    test:assertTrue(resp.results !is ());

};

@test:Config {
    groups: ["IDENTIFIERS"],
    dependsOn: [CreateMarketingEventTest]
}
function FindMarketingEventByExternalEventIdsTest() returns error? {

    string externalEventId = "11000";

    CollectionResponseWithTotalMarketingEventIdentifiersResponseNoPaging resp = check hubspotClient->getExternaleventidIdentifiers(externalEventId);

    log:printInfo(string `Find App Specific Marketing Event by External Event Ids Response: \n ${resp.toString()}`);

    test:assertTrue(resp.total !is ());

};

@test:Config {
    groups: ["EVENT_STATUS"],
    dependsOn: [CreateMarketingEventTest]
}
function MarkEventCompletedTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "10000";

    MarketingEventCompleteRequestParams completePayload = {
        startDateTime: "2024-08-06T12:36:59.286Z",
        endDateTime: "2024-08-07T12:36:59.286Z"
    };

    MarketingEventDefaultResponse completeResp = check hubspotClient->postEventsExternaleventidComplete_complete(externalEventId, completePayload, externalAccountId = externalAccountId);

    log:printInfo(string `Mark Event Completed Response: \n ${completeResp.toString()}`);
    test:assertTrue(completeResp?.objectId !is "");
    test:assertTrue(completeResp?.eventCompleted is boolean && <boolean>completeResp?.eventCompleted);
}

@test:Config {
    groups: ["EVENT_STATUS"],
    dependsOn: [CreateMarketingEventTest]
}
function MarkEventCancelledTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "10000";

    MarketingEventDefaultResponse cancelResp = check hubspotClient->postEventsExternaleventidCancel_cancel(externalEventId, externalAccountId = externalAccountId);

    log:printInfo(string `Mark Event Cancelled Response: \n ${cancelResp.toString()}`);
    test:assertTrue(cancelResp?.objectId !is "");
    test:assertTrue(cancelResp?.eventCancelled is boolean && <boolean>cancelResp?.eventCancelled);
};

@test:Config {
    groups: ["SUBSCRIBER_STATE"],
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

    http:Response cancelResp = check hubspotClient->postEventsExternaleventidSubscriberstateEmailUpsert_upsertbycontactemail(externalEventId, subscriberState, dummyParticipants, externalAccountId = externalAccountId);

    log:printInfo(string `Participants Cancelled: ${cancelResp.statusCode}`);

    test:assertTrue(cancelResp.statusCode >= 200 && cancelResp.statusCode < 300);

};

@test:Config {
    groups: ["SUBSCRIBER_STATE"],
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

    http:Response cancelResp = check hubspotClient->postEventsExternaleventidSubscriberstateUpsert_upsertbycontactid(externalEventId, subscriberState, dummyParticipants, externalAccountId = externalAccountId);

    log:printInfo(string `Participants Cancelled: ${cancelResp.statusCode}`);

    test:assertTrue(cancelResp.statusCode >= 200 && cancelResp.statusCode < 300);

};

@test:Config {
    groups: ["PARTICIPTION"],
    dependsOn: [CreateMarketingEventTest]
}
function ReadParticipationBreakdownByContactIdentifierTest() returns error? {

    string email = "john.doe@abc.com";

    CollectionResponseWithTotalParticipationBreakdownForwardPaging getResp = check hubspotClient->getParticipationsContactsContactidentifierBreakdown_getparticipationsbreakdownbycontactid(email);

    log:printInfo(string `Read Participations Breakdown by Contact Id Response: \n ${getResp.toString()}`);

    test:assertFalse(getResp.results is ());
    test:assertTrue(getResp.total is int);
};

@test:Config {
    groups: ["PARTICIPTION"],
    dependsOn: [CreateMarketingEventTest, CreateOrUpdateMarketingEventTest]
}
function ReadParticipationBreakdownByExternalIdTest() returns error? {

    string externalEventId = "11000";
    string externalAccountId = "11111";

    CollectionResponseWithTotalParticipationBreakdownForwardPaging getResp = check hubspotClient->getParticipationsExternalaccountidExternaleventidBreakdown_getparticipationsbreakdownbyexternaleventid(externalAccountId, externalEventId);

    log:printInfo(string `Read Participations Breakdown by External Event Id Response: \n ${getResp.toString()}`);
    test:assertFalse(getResp.results is ());
    test:assertTrue(getResp.total is int);
};

@test:Config {
    groups: ["PARTICIPTION"],
    dependsOn: [CreateMarketingEventTest, CreateOrUpdateMarketingEventTest]
}
function ReadParticipationBreakdownByInternalIdTest() returns error? {

    int internalId = check int:fromString(testObjId);

    CollectionResponseWithTotalParticipationBreakdownForwardPaging getResp = check hubspotClient->getParticipationsMarketingeventidBreakdown_getparticipationsbreakdownbymarketingeventid(internalId);

    log:printInfo(string `Read Participations Breakdown by Internal Event Id Response: \n ${getResp.toString()}`);
    test:assertFalse(getResp.results is ());
    test:assertTrue(getResp.total is int);
};

@test:Config {
    groups: ["PARTICIPTION"],
    dependsOn: [CreateMarketingEventTest, CreateOrUpdateMarketingEventTest]
}
function ReadParticipationCountByInternalIdTest() returns error? {

    int id = check int:fromString(testObjId);

    AttendanceCounters getResp = check hubspotClient->getParticipationsMarketingeventid_getparticipationscountersbymarketingeventid(id);

    log:printInfo(string `Read Participation Counts by Internal Event Id Response: \n ${getResp.toString()}`);
    test:assertTrue(getResp.attended is int);
    test:assertTrue(getResp.registered is int);
};

@test:Config {
    groups: ["PARTICIPTION"],
    dependsOn: [CreateMarketingEventTest, CreateOrUpdateMarketingEventTest]
}
function ReadParticipationCountByExternalIdTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";

    AttendanceCounters getResp = check hubspotClient->getParticipationsExternalaccountidExternaleventid_getparticipationscountersbyeventexternalid(externalAccountId, externalEventId);

    log:printInfo(string `Read Participation Counts by Internal Event Id Response: \n ${getResp.toString()}`);
    test:assertTrue(getResp.attended is int);
    test:assertTrue(getResp.registered is int);
};

@test:Config {
    groups: ["LISTS"],
    dependsOn: [CreateMarketingEventTest, CreateOrUpdateMarketingEventTest]
}
function AssociateListFromExternalIdsTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";

    string listId = "9"; // ILS List ID of the list

    http:Response createResp = check hubspotClient->putAssociationsExternalaccountidExternaleventidListsListid_associatebyexternalaccountandeventids(externalAccountId, externalEventId, listId);

    log:printInfo(string `Associate List by External Ids Response StatusCode: \n ${createResp.statusCode}`);
    test:assertTrue(createResp.statusCode >= 200 && createResp.statusCode < 300);
}

@test:Config {
    groups: ["LISTS"],
    dependsOn: [CreateMarketingEventTest, CreateOrUpdateMarketingEventTest]
}
function AssociateListFromInternalIdsTest() returns error? {

    string listId = "9"; // ILS List ID of the list

    http:Response createResp = check hubspotClient->putAssociationsMarketingeventidListsListid_associatebymarketingeventid(testObjId, listId);

    log:printInfo(string `Associate List by Internal Id Response StatusCode: \n ${createResp.statusCode}`);
    test:assertTrue(createResp.statusCode >= 200 && createResp.statusCode < 300);
}

@test:Config {
    groups: ["LISTS"],
    dependsOn: [AssociateListFromInternalIdsTest]
}
function GetAssociatedListsFromInternalIdsTest() returns error? {

    CollectionResponseWithTotalPublicListNoPaging getResp = check hubspotClient->getAssociationsMarketingeventidLists_getallbymarketingeventid(testObjId);

    log:printInfo(string `Get Associated Lists by Internal Event Id Response: \n ${getResp.toString()}`);
    test:assertTrue(getResp.total is int);
};

@test:Config {
    groups: ["LISTS"],
    dependsOn: [AssociateListFromExternalIdsTest]
}
function GetAssociatedListsFromExternalIdsTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";

    CollectionResponseWithTotalPublicListNoPaging getResp = check hubspotClient->getAssociationsExternalaccountidExternaleventidLists_getallbyexternalaccountandeventids(externalAccountId, externalEventId);
    log:printInfo(string `Get Associated Lists from External Ids Response: \n ${getResp.toString()}`);
    test:assertTrue(getResp.total is int);
};

@test:Config {
    groups: ["LISTS"],
    dependsOn: [GetAssociatedListsFromExternalIdsTest]
}
function DeleteAssociatedListsfromExternalIdsTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";

    string listId = "9"; // ILS List ID of the list

    http:Response deleteResp = check hubspotClient->deleteAssociationsExternalaccountidExternaleventidListsListid_disassociatebyexternalaccountandeventids(externalAccountId, externalEventId, listId);

    log:printInfo(string `Disassociate List by External Ids Response StatusCode: \n ${deleteResp.statusCode}`);
    test:assertTrue(deleteResp.statusCode >= 200 && deleteResp.statusCode < 300);
}

@test:Config {
    groups: ["LISTS"],
    dependsOn: [GetAssociatedListsFromInternalIdsTest]
}
function DeleteAssociatedListsfromInternalIdsTest() returns error? {

    string listId = "9"; // ILS List ID of the list

    http:Response deleteResp = check hubspotClient->deleteAssociationsMarketingeventidListsListid_disassociatebymarketingeventid(testObjId, listId);

    log:printInfo(string `Disassociate List by Internal Id Response StatusCode: \n ${deleteResp.statusCode}`);
    test:assertTrue(deleteResp.statusCode >= 200 && deleteResp.statusCode < 300);
}

// Delete All the Event Objects (After Suite)

@test:AfterSuite {
    // value: ["BASIC"],
    alwaysRun: true
}
function DeleteMarketingEventByObjectIdTest() returns error? {

    // Valid ObjID

    http:Response deleteResp = check hubspotClient->deleteObjectid(testObjId);

    log:printInfo(string `Delete Marketing Event by object Id ${testObjId}`);

    test:assertTrue(deleteResp.statusCode == 204);

    // Invalid ObjID

    string invalidObjId = "8436";

    http:Response deleteResp2 = check hubspotClient->deleteObjectid(invalidObjId);

    log:printInfo(string `Delete Marketing Event by object Id ${invalidObjId}`);

    test:assertTrue(deleteResp2.statusCode == 404);

    testObjId = "";

};

@test:AfterSuite {
    // value: ["BASIC"],
    alwaysRun: true
}
function DeleteMarketingEventByExternalIdsTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";

    // Valid External Ids

    http:Response deleteResp = check hubspotClient->deleteEventsExternaleventid_archive(externalEventId, externalAccountId = externalAccountId);

    log:printInfo(string `Delete Marketing Event by External Ids ${externalEventId} with ${externalAccountId}`);

    test:assertTrue(deleteResp.statusCode == 204);

};
