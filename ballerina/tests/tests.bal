import ballerina/http;
import ballerina/log;
import ballerina/oauth2;
import ballerina/test;

configurable string serviceUrl = ?;
configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable boolean isLiveServer = ?;

OAuth2RefreshTokenGrantConfig auth = {
    clientId: isLiveServer ? clientId : "testClientId",
    clientSecret: isLiveServer ? clientSecret : "testClientSecret",
    refreshToken: isLiveServer ? refreshToken : "testRefreshToken",
    credentialBearer: oauth2:POST_BODY_BEARER // this line should be added in to when you are going to create auth object.
};

ConnectionConfig config = {auth};
final Client hubspotClient = check new Client(config, serviceUrl);

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

    MarketingEventDefaultResponse createResp = check hubspotClient->/events.post(sampleCreatePayload);

    log:printInfo(string `Create Marketing Event Response: \n ${createResp.toString()}`);

    test:assertTrue(createResp.objectId !is "" && createResp.objectId is string);
    test:assertTrue(createResp.eventName == sampleCreatePayload.eventName);

    testObjId = createResp.objectId is null ? "" : createResp.objectId.toString();

    log:printInfo("Create Marketing Event Successful");

};

@test:Config {
    groups: ["BASIC"]
}
isolated function CreateOrUpdateMarketingEventTest() returns error? {

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

    MarketingEventPublicDefaultResponse createResp = check hubspotClient->/events/[externalEventId].put(sampleCreatePayload);

    log:printInfo(string `Create Marketing Event using create or update Response: \n ${createResp.toString()}`);

    test:assertTrue(createResp.objectId !is "" && createResp.objectId is string);
    test:assertTrue(createResp.eventName == sampleCreatePayload.eventName);

    log:printInfo("Create or update Marketing Event - 1 Successful");

    // Update an existing event 

    // FIXME - Update is replacing values with null if not provided. Need to check with the team.

    // string updatedEventName = "Test 2 Updated";
    // string updatedEventOrganizer = "Organizer 2 Updated";

    // MarketingEventCreateRequestParams sampleUpdatePayload = {
    //     "externalAccountId": "11111",
    //     "externalEventId": externalEventId,
    //     "eventName": updatedEventName,
    //     "eventOrganizer": updatedEventOrganizer
    // };

    // MarketingEventPublicDefaultResponse updateResp = check hubspotClient->/events/[externalEventId].put(sampleUpdatePayload);

    // log:printInfo(string `Update Marketing Event using create or update Response: \n ${sampleUpdatePayload.toString()}`);

    // test:assertEquals(updateResp.eventName, updatedEventName);
    // test:assertEquals(updateResp.eventOrganizer, updatedEventOrganizer);

    // log:printInfo("Create or update Marketing Event - 2 Successful");

};

@test:Config {
    groups: ["BASIC"],
    dependsOn: [CreateMarketingEventTest, CreateOrUpdateMarketingEventTest]
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

    MarketingEventPublicDefaultResponse updateResp = check hubspotClient->/events/[externalEventId].patch(sampleUpdatePayload, externalAccountId = externalAccountId);

    log:printInfo(string `Update Marketing Event by external Ids Response: \n ${updateResp.toString()}`);
    test:assertEquals(updateResp.eventName, updatedEventName);
    test:assertEquals(updateResp.eventOrganizer, updatedEventOrganizer);
    test:assertEquals(updateResp.eventDescription, updatedEventDescription);
    test:assertEquals(updateResp.eventUrl, updatedEventUrl);

};

@test:Config {
    groups: ["BASIC"],
    dependsOn: [UpdateMarketingEventByExternalIdsTest]
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

    MarketingEventPublicDefaultResponseV2 updateResp = check hubspotClient->/[testObjId].patch(sampleUpdatePayload);

    log:printInfo(string `Update Marketing Event by object Id ${testObjId} Response: \n ${updateResp.toString()}`);
    test:assertEquals(updateResp.eventName, updatedEventName);
    test:assertEquals(updateResp.eventOrganizer, updatedEventOrganizer);
    test:assertEquals(updateResp.eventDescription, updatedEventDescription);
    test:assertEquals(updateResp.eventUrl, updatedEventUrl);
};

@test:Config {
    groups: ["BASIC"],
    dependsOn: [UpdateMarketingEventByExternalIdsTest, updateMarketingEventByObjectIdTest]
}
function GetAllMarketingEventsTest() returns error? {

    CollectionResponseMarketingEventPublicReadResponseV2ForwardPaging getResp = check hubspotClient->/();

    log:printInfo(string `Get All Marketing Events Response: \n ${getResp.toString()}`);

    test:assertTrue(getResp.results.length() > 0);
};

@test:Config {
    groups: ["BASIC"],
    dependsOn: [UpdateMarketingEventByExternalIdsTest, updateMarketingEventByObjectIdTest]
}
function GetMarketingEventbyExternalIdsTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";

    MarketingEventPublicReadResponse getResp = check hubspotClient->/events/[externalEventId](externalAccountId = externalAccountId);

    log:printInfo(string `Get Marketing Event by ExternalIds Response: \n ${getResp.toString()}`);

    test:assertTrue(getResp.objectId !is "" && getResp.objectId is string);
    test:assertTrue(getResp.eventName != "");
};

@test:Config {
    groups: ["BASIC"],
    dependsOn: [UpdateMarketingEventByExternalIdsTest, updateMarketingEventByObjectIdTest]
}
function GetMarketingEventbyObjectIdTest() returns error? {

    // Correct Usage

    MarketingEventPublicReadResponseV2 getResp = check hubspotClient->/[testObjId].get();

    log:printInfo(string `Get Marketing Event by object Id ${testObjId} Response: \n ${getResp.toString()}`);

    test:assertTrue(getResp.objectId !is "");
    test:assertTrue(getResp.eventName !is "");

    log:printInfo("Get Marketing Event by object Id Successful - 1");

    // Invalid ObjID

    string invalidObjId = "84536";
    if invalidObjId == testObjId {
        invalidObjId = "1227845";
    }

    MarketingEventPublicReadResponseV2|error getResp2 = hubspotClient->/[invalidObjId].get();

    // log:printInfo(string `Get Marketing Event by object Id Response: \n ${getResp2.toString()}`);

    test:assertTrue(getResp2 is error);

    log:printInfo("Get Marketing Event by object Id Successful - 2");

};



@test:AfterGroups {
    value: ["BASIC"],
    alwaysRun: true
}
function DeleteMarketingEventByObjectIdTest() returns error? {

    // Valid ObjID

    http:Response deleteResp = check hubspotClient->/[testObjId].delete();

    log:printInfo(string `Delete Marketing Event by object Id ${testObjId}`);

    test:assertTrue(deleteResp.statusCode == 204);

    // Invalid ObjID

    string invalidObjId = "84536";
    if invalidObjId == testObjId {
        invalidObjId = "1227845";
    }

    http:Response deleteResp2 = check hubspotClient->/[invalidObjId].delete();

    log:printInfo(string `Delete Marketing Event by object Id ${invalidObjId}`);

    test:assertTrue(deleteResp2.statusCode == 404);

    testObjId = "";

};

@test:AfterGroups {
    value: ["BASIC"],
    alwaysRun: true
}
function DeleteMarketingEventByExternalIdsTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";

    // Valid External Ids

    http:Response deleteResp = check hubspotClient->/events/[externalEventId].delete(externalAccountId = externalAccountId);

    log:printInfo(string `Delete Marketing Event by External Ids ${externalEventId} with ${externalAccountId}`);

    test:assertTrue(deleteResp.statusCode == 204);

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
        "customProperties":[customPropertySample]
    };

    BatchInputMarketingEventCreateRequestParams batchPayload = {
        inputs: [sampleCreatePayload, sampleCreatePayload2]
    };

    BatchResponseMarketingEventPublicDefaultResponse batchResp = check hubspotClient->/events/upsert.post(batchPayload);

    log:printInfo(string `Batch Create or Update Marketing Events Response: \n ${batchResp.toString()}`);

    foreach MarketingEventPublicDefaultResponse resp in batchResp.results {
        test:assertTrue(resp.objectId !is "" && resp.objectId is string);
        batchTestObjIds.push(resp.objectId.toString());
    }

    test:assertTrue(batchResp.results.length() > 0);

    BatchInputMarketingEventCreateRequestParams batchPayload2 = {
        inputs: [sampleCreatePayload3]
    };

    BatchResponseMarketingEventPublicDefaultResponse batchResp2 = check hubspotClient->/events/upsert.post(batchPayload2);

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

    BatchResponseMarketingEventPublicDefaultResponseV2|BatchResponseMarketingEventPublicDefaultResponseV2WithErrors batchResp = check hubspotClient->/batch/update.post(batchPayload);

    log:printInfo(string `Batch Create or Update Marketing Events Response: \n ${batchResp.toString()}`);

    test:assertTrue(batchResp.results.length() > 0);
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

    http:Response batchResp = check hubspotClient->/events/delete.post(batchPayload);

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

    http:Response batchResp = check hubspotClient->/batch/archive.post(batchPayload);

    log:printInfo(string `Batch Delete Marketing Events by Object Ids ${batchTestObjIds.toString()}`);

    log:printInfo(batchResp.statusCode.toString());

    test:assertTrue(batchResp.statusCode == 204);

    batchTestObjIds = [];
}



@test:Config{
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

    BatchResponseSubscriberVidResponse recordResp = check hubspotClient->/[testObjId]/attendance/[subscriberState]/create.post(payload);

    log:printInfo(string `Record Participants by Contact Id with Marketing Event Object Ids Response: \n ${recordResp.toString()}`);

    test:assertTrue(recordResp.results.length() > 0);

};




// @test:Config {
//     groups: ["live_server", "mock_server"],
//     dependsOn: [GetAllMarketingEventsTest, GetMarketingEventbyObjectIdTest]
// }
// function RecordParticipantsByContactIdwithMarketingEventExternalIdsTest() returns error? {

//     string externalAccountId = "12345";
//     string externalEventId = "67890";
//     int:Signed32 contactId = 204727;
//     string subscriberState = "register";

//     MarketingEventSubscriber subscriber = {
//         "interactionDateTime": 10000222,
//         "vid": contactId
//     };

//     BatchInputMarketingEventSubscriber payload = {
//         inputs: [subscriber]
//     };

//     BatchResponseSubscriberVidResponse recordResp = check hubspotClient->/attendance/[externalEventId]/[subscriberState]/create.post(payload, externalAccountId=externalAccountId);

//     log:printInfo(string `Record Participants by Contact Id with Marketing Event External Ids Response: \n ${recordResp.toString()}`);

//     test:assertTrue(recordResp.results.length() > 0);

// };




