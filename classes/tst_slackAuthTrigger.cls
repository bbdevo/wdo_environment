@isTest
public with sharing class tst_slackAuthTrigger {

    private static FINAL Integer NUMBER_OF_AUTHS = 2;

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

        /* get inserted data */
        List<Slack_Auth__c> auths = [SELECT Id FROM Slack_Auth__c];

        /* assert that the data inserted properly */
        System.assertEquals(NUMBER_OF_AUTHS, auths.size(), 'Slack Auth insert failure');
    }

    @isTest
    public static void testUpdateMostRecentWorkspaceInsert() {
        Slack_Auth__c auth = new Slack_Auth__c();
        auth.User__c = UserInfo.getUserId();
        auth.Workspace__c = 'workspace';
        auth.Is_Most_Recent__c = true;
        auth.Workspace_Id__c = 'workspaceId';
        auth.Slack_User_Id__c = 'slackUserId';
        auth.Access_Token__c = 'accessToken';
        
        Test.startTest();
        insert auth;
        Test.stopTest();

        Slack_Auth__c insertedAuth = [SELECT Id, Is_Most_Recent__c FROM Slack_Auth__c WHERE Id = :auth.Id];
        List<Slack_Auth__c> existingAuths = [SELECT Id, Is_Most_Recent__c FROM Slack_Auth__c WHERE Id <> :auth.Id];

        System.assertEquals(true, insertedAuth.Is_Most_Recent__c, 'inserted auth is not most recent');
        for (Slack_Auth__c existingAuth : existingAuths) {
            System.assertEquals(false, existingAuth.Is_Most_Recent__c, 'existing auth is still most recent');
        }
    }

    @isTest
    public static void testUpdateMostRecentWorkspaceUpdate() {
        Slack_Auth__c auth = [SELECT Id, Is_Most_Recent__c FROM Slack_Auth__c WHERE Is_Most_Recent__c = false];
        auth.Is_Most_Recent__c = true;

        Test.startTest();
        update auth;
        Test.stopTest();

        Slack_Auth__c updatedAuth = [SELECT Id, Is_Most_Recent__c FROM Slack_Auth__c WHERE Id = :auth.Id];
        List<Slack_Auth__c> existingAuths = [SELECT Id, Is_Most_Recent__c FROM Slack_Auth__c WHERE Id <> :auth.Id];

        System.assertEquals(true, updatedAuth.Is_Most_Recent__c, 'updated auth is not most recent');
        for (Slack_Auth__c existingAuth : existingAuths) {
            System.assertEquals(false, existingAuth.Is_Most_Recent__c, 'existing auth is still most recent');
        }
    }
}