@isTest
public with sharing class tst_recentChannelTrigger {

    private static FINAL Integer NUMBER_OF_AUTHS = 2;
    private static FINAL Integer NUMBER_OF_CHANNELS = 20;

    @TestSetup
    public static void makeData() {
        
        /* make data */
        List<Slack_Auth__c> authsToInsert = new List<Slack_Auth__c>();
        for (Integer i = 0; i < NUMBER_OF_AUTHS; i++) {
            Slack_Auth__c auth = new Slack_Auth__c();
            auth.User__c = UserInfo.getUserId();
            auth.Workspace__c = 'workspace' + i;
            auth.Is_Most_Recent__c = i == 0 ? true : false;
            auth.Workspace_Id__c = 'workspaceId' + i;
            auth.Slack_User_Id__c = 'slackUserId' + i;
            auth.Access_Token__c = 'accessToken' + i;
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
        List<Slack_Auth__c> auths = [SELECT Id FROM Slack_Auth__c];
        List<Recent_Channel__c> channels = [SELECT Id FROM Recent_Channel__c];

        /* assert that the data inserted properly */
        System.assertEquals(NUMBER_OF_AUTHS, auths.size(), 'Slack Auth insert failure');
        System.assertEquals((NUMBER_OF_AUTHS * NUMBER_OF_CHANNELS), channels.size(), 'Recent Channel insert failure');
    }

    @isTest
    public static void testMaintainRecentChannelsNoDupe() {
        List<Slack_Auth__c> auths = [SELECT Id FROM Slack_Auth__c];
        Recent_Channel__c channel = new Recent_Channel__c();
        channel.Slack_Auth__c = auths[0].Id;
        channel.Name = 'channelName';
        channel.Channel_Id__c = 'channelId';

        Test.startTest();
        insert channel;
        Test.stopTest();

        List<Recent_Channel__c> newChannelList = [SELECT Id FROM Recent_Channel__c WHERE Slack_Auth__r.Id = :auths[0].Id];

        System.assertEquals(20, newChannelList.size(), 'Channel list is too large');
    }

    @isTest
    public static void testMaintainRecentChannelsWithDupe() {
        List<Slack_Auth__c> auths = [SELECT Id FROM Slack_Auth__c];
        Recent_Channel__c channel = new Recent_Channel__c();
        channel.Slack_Auth__c = auths[0].Id;
        channel.Name = 'channelName0';
        channel.Channel_Id__c = 'channelId0';

        Test.startTest();
        insert channel;
        Test.stopTest();

        List<Recent_Channel__c> newChannelList = [SELECT Id FROM Recent_Channel__c WHERE Slack_Auth__r.Id = :auths[0].Id];

        System.assertEquals(20, newChannelList.size(), 'Channel list is too large');
    }
}