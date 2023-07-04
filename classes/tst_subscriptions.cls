@isTest
public class tst_subscriptions {
    @testSetup static void setupData() {
        utilities.generateEncryptionKey();
    }

    @isTest static void sendAssignedToMe() {
        Map<String, String> subObj = new Map<String, String>{
            'type' => constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME,
            'objectType' => 'Account',
            'subscriptionId' => 'subId',
            'workspaceId' => 'workId',
            'channelId' => 'channelId',
            'sfUserId' => UserInfo.getUserId()
        };

        List<Map<String, Object>> payload = new List<Map<String, Object>>{subObj};

        sendPost(payload);

        Subscription__c subscription = [SELECT Id, Channel_Id__c, Field__c, Object_Type__c, Record_Id__c,
                                        Subscription_Id__c, Subscription_Type__c, User__c, Value__c, Workspace_Id__c
                                        FROM Subscription__c];

        System.assertEquals(constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME, subscription.Subscription_Type__c);
        System.assertEquals(subObj.get('workspaceId'), subscription.Workspace_Id__c);
        System.assertEquals(subObj.get('channelId'), subscription.Channel_Id__c);
        System.assertEquals(subObj.get('objectType'), subscription.Object_Type__c);
        System.assertEquals(subObj.get('subscriptionId'), subscription.Subscription_Id__c);
        System.assertEquals(UserInfo.getUserId(), subscription.User__c);
    }

    @isTest static void sendDateReached() {
        Date closeDate = Date.today();
        Opportunity a = new Opportunity(
            Name = '123',
            CloseDate = closeDate,
            StageName = 'Prospecting'
            );

        insert a;

        Map<String, String> subObj = new Map<String, String>{
            'type' => constants.NOTIFICATION_TYPE_DATE_REACHED,
            'objectType' => 'Opportunity',
            'field' => 'CloseDate',
            'subscriptionId' => 'subId',
            'recordId' => a.Id,
            'workspaceId' => 'workId',
            'channelId' => 'channelId'
        };

        List<Map<String, Object>> payload = new List<Map<String, Object>>{subObj};

        sendPost(payload);

        Subscription__c subscription = [SELECT Id, Channel_Id__c, Field__c, Object_Type__c, Record_Id__c,
                                        Subscription_Id__c, Subscription_Type__c, User__c, Value__c, Workspace_Id__c
                                        FROM Subscription__c];

        System.assertEquals(constants.NOTIFICATION_TYPE_DATE_REACHED, subscription.Subscription_Type__c);
        System.assertEquals(subObj.get('workspaceId'), subscription.Workspace_Id__c);
        System.assertEquals(subObj.get('channelId'), subscription.Channel_Id__c);
        System.assertEquals(subObj.get('objectType'), subscription.Object_Type__c);
        System.assertEquals(subObj.get('subscriptionId'), subscription.Subscription_Id__c);
        System.assertEquals(subObj.get('recordId'), subscription.Record_Id__c);
    }

    @isTest static void sendDateOverdue() {
        Date closeDate = Date.today();
        Opportunity a = new Opportunity(
            Name = '123',
            CloseDate = closeDate,
            StageName = 'Prospecting'
            );

        insert a;

        Map<String, String> subObj = new Map<String, String>{
            'type' => constants.NOTIFICATION_TYPE_DATE_OVERDUE,
            'objectType' => 'Opportunity',
            'field' => 'CloseDate',
            'subscriptionId' => 'subId',
            'recordId' => a.Id,
            'workspaceId' => 'workId',
            'channelId' => 'channelId'
        };

        List<Map<String, Object>> payload = new List<Map<String, Object>>{subObj};

        sendPost(payload);

        Subscription__c subscription = [SELECT Id, Channel_Id__c, Field__c, Object_Type__c, Record_Id__c,
                                        Subscription_Id__c, Subscription_Type__c, User__c, Value__c, Workspace_Id__c
                                        FROM Subscription__c];

        System.assertEquals(constants.NOTIFICATION_TYPE_DATE_OVERDUE, subscription.Subscription_Type__c);
        System.assertEquals(subObj.get('workspaceId'), subscription.Workspace_Id__c);
        System.assertEquals(subObj.get('channelId'), subscription.Channel_Id__c);
        System.assertEquals(subObj.get('objectType'), subscription.Object_Type__c);
        System.assertEquals(subObj.get('subscriptionId'), subscription.Subscription_Id__c);
        System.assertEquals(subObj.get('recordId'), subscription.Record_Id__c);
        System.assertEquals(subObj.get('field'), subscription.Field__c);
    }

    @isTest static void sendFieldChanged() {
        Map<String, String> subObj = new Map<String, String>{
            'type' => constants.NOTIFICATION_TYPE_FIELD_CHANGED,
            'objectType' => 'Opportunity',
            'field' => 'Name',
            'subscriptionId' => 'subId',
            'workspaceId' => 'workId',
            'channelId' => 'channelId'
        };

        List<Map<String, Object>> payload = new List<Map<String, Object>>{subObj};

        sendPost(payload);

        Subscription__c subscription = [SELECT Id, Channel_Id__c, Field__c, Object_Type__c, Record_Id__c,
                                        Subscription_Id__c, Subscription_Type__c, User__c, Value__c, Workspace_Id__c
                                        FROM Subscription__c];

        System.assertEquals(constants.NOTIFICATION_TYPE_FIELD_CHANGED, subscription.Subscription_Type__c);
        System.assertEquals(subObj.get('workspaceId'), subscription.Workspace_Id__c);
        System.assertEquals(subObj.get('channelId'), subscription.Channel_Id__c);
        System.assertEquals(subObj.get('objectType'), subscription.Object_Type__c);
        System.assertEquals(subObj.get('subscriptionId'), subscription.Subscription_Id__c);
        System.assertEquals(subObj.get('field'), subscription.Field__c);
    }

    @isTest static void sendFieldIsValue() {
        Map<String, String> subObj = new Map<String, String>{
            'type' => constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
            'objectType' => 'Opportunity',
            'field' => 'Name',
            'value' => '123',
            'subscriptionId' => 'subId',
            'workspaceId' => 'workId',
            'channelId' => 'channelId'
        };

        List<Map<String, Object>> payload = new List<Map<String, Object>>{subObj};

        sendPost(payload);

        Subscription__c subscription = [SELECT Id, Channel_Id__c, Field__c, Object_Type__c, Record_Id__c,
                                        Subscription_Id__c, Subscription_Type__c, User__c, Value__c, Workspace_Id__c
                                        FROM Subscription__c];

        System.assertEquals(constants.NOTIFICATION_TYPE_FIELD_IS_VALUE, subscription.Subscription_Type__c);
        System.assertEquals(subObj.get('workspaceId'), subscription.Workspace_Id__c);
        System.assertEquals(subObj.get('channelId'), subscription.Channel_Id__c);
        System.assertEquals(subObj.get('objectType'), subscription.Object_Type__c);
        System.assertEquals(subObj.get('subscriptionId'), subscription.Subscription_Id__c);
        System.assertEquals(subObj.get('field'), subscription.Field__c);
        System.assertEquals(subObj.get('value'), subscription.Value__c);
    }

    @isTest static void sendNew() {
        Map<String, String> subObj = new Map<String, String>{
            'type' => constants.NOTIFICATION_TYPE_NEW,
            'objectType' => 'Opportunity',
            'subscriptionId' => 'subId',
            'workspaceId' => 'workId',
            'channelId' => 'channelId'
        };

        List<Map<String, Object>> payload = new List<Map<String, Object>>{subObj};

        sendPost(payload);

        Subscription__c subscription = [SELECT Id, Channel_Id__c, Field__c, Object_Type__c, Record_Id__c,
                                        Subscription_Id__c, Subscription_Type__c, User__c, Value__c, Workspace_Id__c
                                        FROM Subscription__c];

        System.assertEquals(constants.NOTIFICATION_TYPE_NEW, subscription.Subscription_Type__c);
        System.assertEquals(subObj.get('workspaceId'), subscription.Workspace_Id__c);
        System.assertEquals(subObj.get('channelId'), subscription.Channel_Id__c);
        System.assertEquals(subObj.get('objectType'), subscription.Object_Type__c);
        System.assertEquals(subObj.get('subscriptionId'), subscription.Subscription_Id__c);
    }

    @isTest static void sendOpportunityWon() {
        Map<String, String> subObj = new Map<String, String>{
            'type' => constants.NOTIFICATION_TYPE_OPPORTUNITY_WON,
            'objectType' => 'Opportunity',
            'subscriptionId' => 'subId',
            'workspaceId' => 'workId',
            'channelId' => 'channelId'
        };

        List<Map<String, Object>> payload = new List<Map<String, Object>>{subObj};

        sendPost(payload);

        Subscription__c subscription = [SELECT Id, Channel_Id__c, Field__c, Object_Type__c, Record_Id__c,
                                        Subscription_Id__c, Subscription_Type__c, User__c, Value__c, Workspace_Id__c
                                        FROM Subscription__c];

        System.assertEquals(constants.NOTIFICATION_TYPE_OPPORTUNITY_WON, subscription.Subscription_Type__c);
        System.assertEquals(subObj.get('workspaceId'), subscription.Workspace_Id__c);
        System.assertEquals(subObj.get('channelId'), subscription.Channel_Id__c);
        System.assertEquals(subObj.get('objectType'), subscription.Object_Type__c);
        System.assertEquals(subObj.get('subscriptionId'), subscription.Subscription_Id__c);
    }

    @isTest static void sendBulk() {
        Map<String, String> subObj = new Map<String, String>{
            'type' => constants.NOTIFICATION_TYPE_OPPORTUNITY_WON,
            'objectType' => 'Opportunity',
            'subscriptionId' => 'subId',
            'workspaceId' => 'workId1',
            'channelId' => 'channelId'
        };

        Map<String, String> subObj2 = new Map<String, String>{
            'type' => constants.NOTIFICATION_TYPE_NEW,
            'objectType' => 'Opportunity',
            'subscriptionId' => 'subId2',
            'workspaceId' => 'workId2',
            'channelId' => 'channelId'
        };

        Map<String, String> subObj3 = new Map<String, String>{
            'type' => constants.NOTIFICATION_TYPE_NEW,
            'objectType' => 'Account',
            'subscriptionId' => 'subId3',
            'workspaceId' => 'workId3',
            'channelId' => 'channelId'
        };

        List<Map<String, Object>> payload = new List<Map<String, Object>>{subObj, subObj2, subObj3};

        sendPost(payload);

        List<Subscription__c> subscriptions = [SELECT Id, Channel_Id__c, Field__c, Object_Type__c, Record_Id__c,
                                               Subscription_Id__c, Subscription_Type__c, User__c, Value__c, Workspace_Id__c
                                               FROM Subscription__c
                                               ORDER BY Workspace_Id__c];

        System.assertEquals(3, subscriptions.size());
        System.assertEquals(constants.NOTIFICATION_TYPE_OPPORTUNITY_WON, subscriptions.get(0).Subscription_Type__c);
        System.assertEquals('Opportunity', subscriptions.get(0).Object_Type__c);
        System.assertEquals(constants.NOTIFICATION_TYPE_NEW, subscriptions.get(1).Subscription_Type__c);
        System.assertEquals('Opportunity', subscriptions.get(1).Object_Type__c);
        System.assertEquals(constants.NOTIFICATION_TYPE_NEW, subscriptions.get(2).Subscription_Type__c);
        System.assertEquals('Account', subscriptions.get(2).Object_Type__c);
    }

    @isTest static void sendDupe() {
        Subscription__c existingSub = new Subscription__c(
            Subscription_Type__c = constants.NOTIFICATION_TYPE_NEW,
            Object_Type__c = 'Account',
            Subscription_Id__c = 'subId',
            Workspace_Id__c = 'workId1',
            Channel_Id__c = 'channelId1'
            );

        insert existingSub;

        Map<String, String> subObj = new Map<String, String>{
            'type' => constants.NOTIFICATION_TYPE_OPPORTUNITY_WON,
            'objectType' => 'Opportunity',
            'subscriptionId' => 'subId',
            'workspaceId' => 'workId2',
            'channelId' => 'channelId2'
        };

        List<Map<String, Object>> payload = new List<Map<String, Object>>{subObj};

        sendPost(payload);

        Subscription__c dbSub = [SELECT Id, Channel_Id__c, Field__c, Object_Type__c, Record_Id__c,
                                 Subscription_Id__c, Subscription_Type__c, User__c, Value__c, Workspace_Id__c
                                 FROM Subscription__c
                                 WHERE Id =: existingSub.Id
                                     ORDER BY Workspace_Id__c];

        System.assertEquals(constants.NOTIFICATION_TYPE_OPPORTUNITY_WON, dbSub.Subscription_Type__c);
        System.assertEquals('Opportunity', dbSub.Object_Type__c);
        System.assertEquals('channelId2', dbSub.Channel_Id__c);
        System.assertEquals('workId2', dbSub.Workspace_Id__c);
    }

    @isTest static void sendBulkWithDupes() {
        Map<String, String> subObj = new Map<String, String>{
            'type' => constants.NOTIFICATION_TYPE_OPPORTUNITY_WON,
            'objectType' => 'Opportunity',
            'subscriptionId' => 'subId',
            'workspaceId' => 'workId1',
            'channelId' => 'channelId1'
        };

        Map<String, String> subObj2 = new Map<String, String>{
            'type' => constants.NOTIFICATION_TYPE_NEW,
            'objectType' => 'Opportunity',
            'subscriptionId' => 'subId',
            'workspaceId' => 'workId2',
            'channelId' => 'channelId2'
        };

        List<Map<String, Object>> payload = new List<Map<String, Object>>{subObj, subObj2};

        sendPost(payload);

        List<Subscription__c> subscriptions = [SELECT Id, Channel_Id__c, Field__c, Object_Type__c, Record_Id__c,
                                               Subscription_Id__c, Subscription_Type__c, User__c, Value__c, Workspace_Id__c
                                               FROM Subscription__c
                                               ORDER BY Workspace_Id__c];

        System.assertEquals(1, subscriptions.size());
        System.assertEquals(constants.NOTIFICATION_TYPE_OPPORTUNITY_WON, subscriptions.get(0).Subscription_Type__c);
        System.assertEquals('workId1', subscriptions.get(0).Workspace_Id__c);
        System.assertEquals('channelId1', subscriptions.get(0).Channel_Id__c);
    }

    @isTest static void deleteSubscription() {
        Subscription__c sub = new Subscription__c(
            Subscription_Id__c = '123'
            );

        insert sub;

        List<String> payload = new List<String>{
            '123'
        };

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(JSON.serialize(payload));
        RestContext.request = req;

        Test.startTest();
        subscriptions.deleteSubscription();
        Test.stopTest();

        List<Subscription__c> dbSubs = [SELECT Id FROM Subscription__c];

        System.assert(dbSubs.isEmpty());
    }

    @isTest static void updateChannelName() {
        Subscription__c sub = new Subscription__c(
            Channel_Id__c = '123',
            Channel_Name__c = 'Some Name'
            );

        insert sub;

        Test.startTest();
        subscriptions.renameSubChannel('123', 'Other Name');
        Test.stopTest();

        Subscription__c renamedSub = [SELECT Id, Channel_Name__c FROM Subscription__c];

        System.assertEquals('Other Name', renamedSub.Channel_Name__c);
    }

    private static void sendPost(List<Map<String, Object>> payload){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestBody = Blob.valueOf(JSON.serialize(payload));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        subscriptions.createSubscription();
        Test.stopTest();
    }
}