// import ballerina/http;
// import ballerina/log;

// int localPort = 9090;

// listener http:Listener httpListener = new (localPort);

// http:Service mockService = service object {

//     resource function get marketing/v3/marketing\-events() returns json | http:Response {
//             json response = {
//                 "results": [
//                     {
//                         "appId": 1,
//                         "eventDetailsUrl": "https://www.example.com"
//                     }
//                 ],
//                 "paging": {
//                     "next": "https://www.example.com"
//                 }
//             };
//             return response;
//         }
// };

// function init() returns error? {
//     if isLiveServer {
//         log:printInfo("Skiping mock server initialization as the tests are running on live server");
//         return;
//     }
//     log:printInfo("Initiating mock server");
//     check httpListener.attach(mockService, "/");
//     check httpListener.'start();
// };
