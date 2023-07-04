@isTest
public class tst_auth {
    @isTest static void sendSlackTokens() {
        String clientId = constants.getClientId();

        Test.startTest();
        responseData rd = auth.getAuthData();
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess);
        System.assertEquals(clientId, (String)rd.results.get('slackClientId'));
    }
}