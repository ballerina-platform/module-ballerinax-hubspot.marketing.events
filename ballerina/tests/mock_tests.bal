import ballerina/http;
import ballerina/log;
import ballerina/test;

configurable int localPort = 9090;

// Using Separate Client for Mock Tests
Client mockClient = test:mock(Client);

// Create Mock Auth Config
OAuth2RefreshTokenGrantConfig mockAuth = {
    clientId: "mock",
    clientSecret: "mock",
    refreshToken: "mock",
    refreshUrl: string `http://localhost:${localPort}/oauth2/token`
};
ConnectionConfig mockConfig = {auth: mockAuth};

string mockTestObjId = "";

@test:BeforeGroups {
    value: ["mock_tests"]
}
function setupMock() returns error? {
    log:printInfo(string `Initiating mock server in port ${localPort}`);
    check httpListener.attach(mockService, "/");
    check httpListener.'start();

    log:printInfo("Starting Mock Tests");
    // Create Mock Client
    mockClient = check new (mockConfig, string `http://localhost:${localPort}`);
};

@test:Config {
    groups: ["mock_tests"]
}
function CreateMarketingEventMockTest() returns error? {

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

    MarketingEventDefaultResponse createResp = check mockClient->postEvents_create(sampleCreatePayload);

    test:assertTrue(createResp?.objectId !is "" && createResp?.objectId is string);
    test:assertTrue(createResp.eventName == sampleCreatePayload.eventName);
    mockTestObjId = createResp?.objectId is null ? "" : createResp?.objectId.toString();
};

@test:Config {
    groups: ["mock_tests"]
}
function CreateOrUpdateMarketingEventMockTest() returns error? {

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

    MarketingEventPublicDefaultResponse createResp = check mockClient->putEventsExternaleventid_upsert(
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

    MarketingEventPublicDefaultResponse updateResp = check mockClient->putEventsExternaleventid_upsert(
        externalEventId, sampleUpdatePayload);

    test:assertEquals(updateResp.eventName, updatedEventName);
    test:assertEquals(updateResp.eventOrganizer, updatedEventOrganizer);
};

@test:Config {
    groups: ["mock_tests"],
    dependsOn: [CreateMarketingEventMockTest, CreateOrUpdateMarketingEventMockTest]
}
function GetAllMarketingEventsMockTest() returns error? {

    CollectionResponseMarketingEventPublicReadResponseV2ForwardPaging getResp = check mockClient->get();

    test:assertTrue(getResp?.results !is ());
};

@test:Config {
    groups: ["mock_tests"],
    dependsOn: [CreateMarketingEventMockTest, CreateOrUpdateMarketingEventMockTest]
}
function AssociateListFromInternalIdsMockTest() returns error? {

    string listId = "9"; // ILS List ID of the list

    http:Response createResp = check
    mockClient->putAssociationsMarketingeventidListsListid_associatebymarketingeventid(testObjId, listId);

    test:assertTrue(createResp.statusCode >= 200 && createResp.statusCode < 300);
}

// Delete All the Event Objects (After Group)

@test:AfterGroups {
    value: ["mock_tests"],
    alwaysRun: true
}
function DeleteMarketingEventByObjectIdMockTest() returns error? {

    // Valid ObjID

    http:Response deleteResp = check mockClient->deleteObjectid(testObjId);

    test:assertTrue(deleteResp.statusCode == 204);

    // Invalid ObjID

    string invalidObjId = "8436";

    http:Response deleteResp2 = check mockClient->deleteObjectid(invalidObjId);

    test:assertTrue(deleteResp2.statusCode == 404);
    mockTestObjId = "";
};

@test:AfterGroups {
    value: ["mock_tests"],
    alwaysRun: true
}
function DeleteMarketingEventByExternalIdsMockTest() returns error? {

    string externalAccountId = "11111";
    string externalEventId = "11000";

    http:Response deleteResp = check
    mockClient->deleteEventsExternaleventid_archive(externalEventId, externalAccountId = externalAccountId);

    test:assertTrue(deleteResp.statusCode == 204);
};
