import ballerina/http;
import ballerina/log;

int localPort = 9090;

listener http:Listener httpListener = new (localPort);

http:Service mockService = service object {

};

function init() returns error? {
    if isLiveServer {
        log:printInfo("Skiping mock server initialization as the tests are running on live server");
        return;
    }
    log:printInfo("Initiating mock server");
    check httpListener.attach(mockService, "/");
    check httpListener.'start();
};
