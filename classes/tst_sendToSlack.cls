@isTest
public with sharing class tst_sendToSlack {

    private static FINAL Integer NUMBER_OF_ACCOUNTS = 2;
    private static FINAL Integer NUMBER_OF_AUTHS = 2;
    private static FINAL Integer NUMBER_OF_CHANNELS = 2;

    @TestSetup
    static void makeData() {

        /* make data */
        List<Account> accountsToInsert = new List<Account>();
        for (Integer i = 0; i < NUMBER_OF_ACCOUNTS; i++) {
            Account account = new Account();
            account.Name = 'accountName' + i;
            accountsToInsert.add(account);
        }
        insert accountsToInsert;

        List<Slack_Auth__c> authsToInsert = new List<Slack_Auth__c>();
        for (Integer i = 0; i < NUMBER_OF_AUTHS; i++) {
            Slack_Auth__c auth = new Slack_Auth__c();
            auth.User__c = UserInfo.getUserId();
            auth.Workspace__c = 'workspace' + i;
            auth.Is_Most_Recent__c = i == 0 ? true : false;
            auth.Workspace_Id__c = 'workspaceId' + i;
            auth.Slack_User_Id__c = 'slackUserId' + i;
            auth.Access_Token__c = 'accessToken' + i;
            auth.Object_Search_Url__c = 'objectSearchUrl' + i;
            auth.Object_Search_Url_Expiration_Date_Time__c = Datetime.now().addDays(1);
            authsToInsert.add(auth);
        }
        insert authsToInsert;

        List<Recent_Channel__c> channelsToInsert = new List<Recent_Channel__c>();
        for (Integer i = 0; i < authsToInsert.size(); i++) {
            for (Integer j = 0; j < NUMBER_OF_CHANNELS; j++) {
                Recent_Channel__c channel = new Recent_Channel__c();
                channel.Slack_Auth__c = authsToInsert[i].Id;
                channel.Name = 'channelName' + j;
                channel.Channel_Id__c = 'channelId' + j;
                channelsToInsert.add(channel);
            }
        }
        insert channelsToInsert;

        /* get inserted data */
        List<Account> accounts = [SELECT Id FROM Account];
        List<Slack_Auth__c> auths = [SELECT Id FROM Slack_Auth__c];
        List<Recent_Channel__c> channels = [SELECT Id FROM Recent_Channel__c];

        /* assert that the data inserted properly */
        System.assertEquals(NUMBER_OF_ACCOUNTS, accounts.size(), 'Account insert failure');
        System.assertEquals(NUMBER_OF_AUTHS, auths.size(), 'Slack Auth insert failure');
        System.assertEquals((NUMBER_OF_AUTHS * NUMBER_OF_CHANNELS), channels.size(), 'Recent Channel insert failure');
    }

    @isTest
    public static void testGetObjectData() {
        Test.startTest();
        responseData rd = sendToSlack.getObjectData(false);
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
        System.assertEquals(true, !rd.results.isEmpty(), 'results are empty');
    }

    @isTest
    public static void testGetPrimaryObjectNameField() {
        Test.startTest();
        responseData rd = sendToSlack.getPrimaryObjectNameField('Account');
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
        System.assertEquals(true, !rd.results.isEmpty(), 'results are empty');
    }

    @isTest
    public static void testSearchRecords() {
        Test.startTest();
        responseData rd = sendToSlack.searchRecords('accountName', 'Account');
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
        System.assertEquals(true, !rd.results.isEmpty(), 'results are empty');
    }

    @isTest
    public static void testGetRecordData() {
        List<Account> accounts = [SELECT Id FROM Account];

        Test.startTest();
        responseData rd = sendToSlack.getRecordData(accounts[0].Id, 'Account');
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
        System.assertEquals(true, !rd.results.isEmpty(), 'results are empty');
    }

    @isTest
    public static void testGetRecentlyViewed() {
        Test.startTest();
        responseData rd = sendToSlack.getRecentlyViewed('Account');
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
        System.assertEquals(true, !rd.results.isEmpty(), 'results are empty');
    }

    @isTest
    public static void testGetAuthData() {
        Test.startTest();
        responseData rd = sendToSlack.getAuthData();
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
        System.assertEquals(true, !rd.results.isEmpty(), 'results are empty');
    }

    @isTest
    public static void testGetRecentChannels() {
        List<Slack_Auth__c> auths = [SELECT Id FROM Slack_Auth__c];
        Test.setMock(HttpCalloutMock.class, new searchSlackChannelsMock());

        Test.startTest();
        responseData rd = sendToSlack.getRecentChannels(auths[0].Id, 'channel,user,mpim');
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
        System.assertEquals(true, !rd.results.isEmpty(), 'results are empty');
    }
    
    @isTest
    public static void testGetRecentChannelsWithExisting() {
        Slack_Auth__c auth = [SELECT Id FROM Slack_Auth__c LIMIT 1];
        List<Recent_Channel__c> recentChannels = new List<Recent_Channel__c>{
            new Recent_Channel__c(
                Channel_Id__c = 'userChannelId',
                Name = 'userChannelName',
                Slack_Auth__c = auth.Id,
                Type__c = 'user'
            ),
            new Recent_Channel__c(
                Channel_Id__c = 'channelChannelId',
                Name = 'channelChannelName',
                Slack_Auth__c = auth.Id,
                Type__c = 'channel'
            ),
            new Recent_Channel__c(
                Channel_Id__c = 'mpimChannelId',
                Name = 'mpimChannelName',
                Slack_Auth__c = auth.Id,
                Type__c = 'mpim'
            )
        };
        insert recentChannels;
        Test.setMock(HttpCalloutMock.class, new searchSlackChannelsMock());

        Test.startTest();
        responseData rd = sendToSlack.getRecentChannels(auth.Id, 'channel,user,mpim');
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
        System.assertEquals(true, !rd.results.isEmpty(), 'results are empty');
    }

    @isTest
    public static void testSendMessage() {
        List<Recent_Channel__c> channels = [SELECT Id FROM Recent_Channel__c];
        List<Slack_Auth__c> auths = [SELECT Id FROM Slack_Auth__c];
        List<Account> accounts = [SELECT Id FROM Account];

        Test.setMock(HttpCalloutMock.class, new sendMessageMock());

        Test.startTest();
        responseData rd = sendToSlack.sendMessage('message', channels[0].Id, 'channel', auths[0].Id, accounts[0].Id);
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
    }

    @isTest
    public static void testSearchSlackChannels() {
        Slack_Auth__c auth = [SELECT Id FROM Slack_Auth__c LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new searchSlackChannelsMock());

        Test.startTest();
        responseData rd = sendToSlack.searchSlackChannels('test', auth.Id, 20, 'channel,user,mpim', false);
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
        System.assertEquals(true, !rd.results.isEmpty(), 'results are empty');
    }

    @isTest
    public static void testCheckValidAuth() {
        Slack_Auth__c auth = [SELECT Id FROM Slack_Auth__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new checkValidAuthMock());

        Test.startTest();
        responseData rd = new responseData();
        try {
            utilities.checkValidAuth(auth.Id);
        } catch (Exception e) {
            rd.addError(e);
        }
        Test.stopTest();
        System.assertEquals(rd.error, 'Invalid Auth', 'Error is not "Invalid Auth"');
    }

    @isTest
    public static void testDeleteAuth() {
        Slack_Auth__c auth = [SELECT Id FROM Slack_Auth__c LIMIT 1];

        Test.startTest();
        sendToSlack.deleteAuth(auth.Id);
        Test.stopTest();

        List<Slack_Auth__c> auths = [SELECT Id FROM Slack_Auth__c];
        System.assertEquals(NUMBER_OF_AUTHS - 1, auths.size(), 'Auth delete failure');
    }

    private class sendMessageMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();

            res.setStatusCode(200);

            return res;
        }
    }

    private class searchSlackChannelsMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();

            List<Map<String, Object>> channels = new List<Map<String, Object>>();
            channels.add(new Map<String, Object>{
                'name' => 'channelName',
                'id' => 'channelId'
            });
            List<Map<String, Object>> users = new List<Map<String, Object>>();
            users.add(new Map<String, Object>{
                'real_name' => 'userName',
                'id' => 'userId'
            });
            List<Map<String, Object>> mpims = new List<Map<String, Object>>();
            mpims.add(new Map<String, Object>{
                'name' => 'mpimName',
                'id' => 'mpimId'
            });

            res.setBody(JSON.serialize(new Map<String, Object> {
                'channels' => channels,
                'users' => users,
                'mpims' => mpims,
                'ok' => true
            }));
            res.setStatusCode(200);

            return res;
        }
    }

    private class checkValidAuthMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody(JSON.serialize(new Map<String, Object> {
                'ok' => false,
                'error' => 'invalid_auth'
            }));
            res.setStatusCode(200);

            return res;
        }
    }
}