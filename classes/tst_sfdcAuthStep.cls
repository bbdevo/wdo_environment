@isTest
public with sharing class tst_sfdcAuthStep {
    @isTest
    public static void testGetOrigin() {
        Test.startTest();
        sfdcAuthStep con = new sfdcAuthStep();
        String origin = con.getOrigin();
        Test.stopTest();

        System.assertEquals(constants.SALESFORCE_INSTANCE_URI, origin);
    }

    @isTest
    public static void testGetData() {
        Test.startTest();
        String response = sfdcAuthStep.getData();
        Test.stopTest();

        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.assert((Boolean)responseMap.get('isSuccess'), responseMap.get('error'));

        Map<String, Object> resultsMap = (Map<String, Object>)responseMap.get('results');

        System.assert(resultsMap.containsKey('oauthUri'), 'oauthUri not found');
        System.assert(resultsMap.containsKey('postMessageKey'), 'postMessageKey not found');
    }

    //old unit test since we don't send hte payload anymore
    // @isTest
    // public static void testSendAuthPayload() {
    //     String jsonString = JSON.serialize(new Map<String, Object> {
    //         'code' => 'testCode'
    //     });
    //
    //     Test.setMock(HttpCalloutMock.class, new sfdcAuthStepMock());
    //
    //     sfdcAuthStep.endpoint = 'https://test.salesforce.com';
    //     sfdcAuthStep.method = 'POST';
    //     Test.startTest();
    //     String response = sfdcAuthStep.sendAuthPayload(jsonString);
    //     Test.stopTest();
    //
    //     Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
    //     System.assert((Boolean)responseMap.get('isSuccess'), responseMap.get('error'));
    // }

    private class sfdcAuthStepMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();

            res.setBody(JSON.serialize(new Map<String, Object> {
                'refresh_token' => 'testRefreshToken'
            }));
            res.setStatusCode(200);

            return res;
        }
    }
}