@isTest
public with sharing class tst_slackAlerts {

    private static final String CHANNEL_ID = 'UJW4MS26L';
    private static final String CHANNEL_NAME = 'channel-name';

    private static FINAL Integer NUMBER_OF_AUTHS = 2;
    private static FINAL Integer NUMBER_OF_ACCOUNTS = 2;
    private static FINAL Integer NUMBER_OF_CONTACTS = 2;
    private static FINAL Integer NUMBER_OF_LEADS = 2;
    private static FINAL Integer NUMBER_OF_CASES = 2;
    private static FINAL Integer NUMBER_OF_OPPORTUNITIES = 2;
    private static FINAL Integer NUMBER_OF_TASKS = 2;


    @TestSetup
    static void makeData() {
        List<Subscription__c> subscriptionsToInsert = new List<Subscription__c>();

        /* make auths */
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

        /* make accounts */
        List<Account> accountsToInsert = new List<Account>();
        for (Integer i = 0; i < NUMBER_OF_ACCOUNTS; i++) {
            Account accountToInsert = new Account();
            accountToInsert.Name = 'accountName' + i;
            accountsToInsert.add(accountToInsert);
        }
        insert accountsToInsert;
        List<Map<String, Object>> accountSubscriptions = slackAlerts.subscriptionList('Account');
        for (Account insertedAccount : accountsToInsert) {
            for (Object subscriptionTypeObject : accountSubscriptions) {
                Map<String, Object> subscriptionType = (Map<String, Object>)subscriptionTypeObject;
                Subscription__c subscriptionToInsert = new Subscription__c();
                subscriptionToInsert.Field__c = (String)subscriptionType.get('field');
                subscriptionToInsert.Value__c = (String)subscriptionType.get('value');
                subscriptionToInsert.Subscription_Type__c = (String)subscriptionType.get('type');
                subscriptionToInsert.Object_Type__c = (String)subscriptionType.get('objectType');
                subscriptionToInsert.Record_Id__c = insertedAccount.Id;
                subscriptionToInsert.User__c = UserInfo.getUserId();
                subscriptionToInsert.Channel_Id__c = CHANNEL_ID;
                subscriptionToInsert.Channel_Name__c = CHANNEL_NAME;
                subscriptionsToInsert.add(subscriptionToInsert);
            }
        }

        /* make contacts */
        List<Contact> contactsToInsert = new List<Contact>();
        for (Integer i = 0; i < NUMBER_OF_CONTACTS; i++) {
            Contact contactToInsert = new Contact();
            contactToInsert.LastName = 'LastName' + i;
            contactsToInsert.add(contactToInsert);
        }
        insert contactsToInsert;
        List<Map<String, Object>> contactSubscriptions = slackAlerts.subscriptionList('Contact');
        for (Contact insertedContact : contactsToInsert) {
            for (Object subscriptionTypeObject : contactSubscriptions) {
                Map<String, Object> subscriptionType = (Map<String, Object>)subscriptionTypeObject;
                Subscription__c subscriptionToInsert = new Subscription__c();
                subscriptionToInsert.Field__c = (String)subscriptionType.get('field');
                subscriptionToInsert.Value__c = (String)subscriptionType.get('value');
                subscriptionToInsert.Subscription_Type__c = (String)subscriptionType.get('type');
                subscriptionToInsert.Object_Type__c = (String)subscriptionType.get('objectType');
                subscriptionToInsert.Record_Id__c = insertedContact.Id;
                subscriptionToInsert.User__c = UserInfo.getUserId();
                subscriptionToInsert.Channel_Id__c = CHANNEL_ID;
                subscriptionToInsert.Channel_Name__c = CHANNEL_NAME;
                subscriptionsToInsert.add(subscriptionToInsert);
            }
        }

        /* make leads */
        List<Lead> leadsToInsert = new List<Lead>();
        for (Integer i = 0; i < NUMBER_OF_LEADS; i++) {
            Lead leadToInsert = new Lead();
            leadToInsert.LastName = 'LastName' + i;
            leadToInsert.Company = 'Company' + i;
            leadsToInsert.add(leadToInsert);
        }
        insert leadsToInsert;
        List<Map<String, Object>> leadSubscriptions = slackAlerts.subscriptionList('Lead');
        for (Lead insertedLead : leadsToInsert) {
            for (Object subscriptionTypeObject : leadSubscriptions) {
                Map<String, Object> subscriptionType = (Map<String, Object>)subscriptionTypeObject;
                Subscription__c subscriptionToInsert = new Subscription__c();
                subscriptionToInsert.Field__c = (String)subscriptionType.get('field');
                subscriptionToInsert.Value__c = (String)subscriptionType.get('value');
                subscriptionToInsert.Subscription_Type__c = (String)subscriptionType.get('type');
                subscriptionToInsert.Object_Type__c = (String)subscriptionType.get('objectType');
                subscriptionToInsert.Record_Id__c = insertedLead.Id;
                subscriptionToInsert.User__c = UserInfo.getUserId();
                subscriptionToInsert.Channel_Id__c = CHANNEL_ID;
                subscriptionToInsert.Channel_Name__c = CHANNEL_NAME;
                subscriptionsToInsert.add(subscriptionToInsert);
            }
        }


        /* make cases */
        List<Case> casesToInsert = new List<Case>();
        for (Integer i = 0; i < NUMBER_OF_CASES; i++) {
            Case caseToInsert = new Case();
            caseToInsert.Subject = 'Subject' + i;
            casesToInsert.add(caseToInsert);
        }
        insert casesToInsert;
        List<Map<String, Object>> caseSubscriptions = slackAlerts.subscriptionList('Case');
        for (Case insertedCase : casesToInsert) {
            for (Object subscriptionTypeObject : caseSubscriptions) {
                Map<String, Object> subscriptionType = (Map<String, Object>)subscriptionTypeObject;
                Subscription__c subscriptionToInsert = new Subscription__c();
                subscriptionToInsert.Field__c = (String)subscriptionType.get('field');
                subscriptionToInsert.Value__c = (String)subscriptionType.get('value');
                subscriptionToInsert.Subscription_Type__c = (String)subscriptionType.get('type');
                subscriptionToInsert.Object_Type__c = (String)subscriptionType.get('objectType');
                subscriptionToInsert.Record_Id__c = insertedCase.Id;
                subscriptionToInsert.User__c = UserInfo.getUserId();
                subscriptionToInsert.Channel_Id__c = CHANNEL_ID;
                subscriptionToInsert.Channel_Name__c = CHANNEL_NAME;
                subscriptionsToInsert.add(subscriptionToInsert);
            }
        }

        /* make opportunities */
        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        for (Integer i = 0; i < NUMBER_OF_OPPORTUNITIES; i++) {
            Opportunity opportunityToInsert = new Opportunity();
            opportunityToInsert.Name = 'Name' + i;
            opportunityToInsert.StageName = 'StageName' + i;
            opportunityToInsert.CloseDate = Date.today().addDays(1);
            opportunitiesToInsert.add(opportunityToInsert);
        }
        insert opportunitiesToInsert;
        List<Map<String, Object>> opportunitySubscriptions = slackAlerts.subscriptionList('Opportunity');
        for (Opportunity insertedOpportunity : opportunitiesToInsert) {
            for (Object subscriptionTypeObject : opportunitySubscriptions) {
                Map<String, Object> subscriptionType = (Map<String, Object>)subscriptionTypeObject;
                Subscription__c subscriptionToInsert = new Subscription__c();
                subscriptionToInsert.Field__c = (String)subscriptionType.get('field');
                subscriptionToInsert.Value__c = (String)subscriptionType.get('value');
                subscriptionToInsert.Subscription_Type__c = (String)subscriptionType.get('type');
                subscriptionToInsert.Object_Type__c = (String)subscriptionType.get('objectType');
                subscriptionToInsert.Record_Id__c = insertedOpportunity.Id;
                subscriptionToInsert.User__c = UserInfo.getUserId();
                subscriptionToInsert.Channel_Id__c = CHANNEL_ID;
                subscriptionToInsert.Channel_Name__c = CHANNEL_NAME;
                subscriptionsToInsert.add(subscriptionToInsert);
            }
        }

        /* make tasks */
        List<Task> tasksToInsert = new List<Task>();
        for (Integer i = 0; i < NUMBER_OF_TASKS; i++) {
            Task taskToInsert = new Task();
            taskToInsert.Subject = 'Subject' + i;
            tasksToInsert.add(taskToInsert);
        }
        insert tasksToInsert;
        List<Map<String, Object>> taskSubscriptions = slackAlerts.subscriptionList('Task');
        for (Task insertedCase : tasksToInsert) {
            for (Object subscriptionTypeObject : taskSubscriptions) {
                Map<String, Object> subscriptionType = (Map<String, Object>)subscriptionTypeObject;
                Subscription__c subscriptionToInsert = new Subscription__c();
                subscriptionToInsert.Field__c = (String)subscriptionType.get('field');
                subscriptionToInsert.Value__c = (String)subscriptionType.get('value');
                subscriptionToInsert.Subscription_Type__c = (String)subscriptionType.get('type');
                subscriptionToInsert.Object_Type__c = (String)subscriptionType.get('objectType');
                subscriptionToInsert.Record_Id__c = insertedCase.Id;
                subscriptionToInsert.User__c = UserInfo.getUserId();
                subscriptionToInsert.Channel_Id__c = CHANNEL_ID;
                subscriptionToInsert.Channel_Name__c = CHANNEL_NAME;
                subscriptionsToInsert.add(subscriptionToInsert);
            }
        }

        /* insert all subscriptions */
        insert subscriptionsToInsert;

        /* get inserted data */
        List<Account> accounts = [SELECT Id FROM Account];
        List<Contact> contacts = [SELECT Id FROM Contact];
        List<Lead> leads = [SELECT Id FROM Lead];
        List<Case> cases = [SELECT Id FROM Case];
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity];
        List<Task> tasks = [SELECT Id FROM Task];
        List<Subscription__c> subscriptions = [SELECT Id FROM Subscription__c];

        /* assert that the data inserted properly */
        System.assertEquals(NUMBER_OF_ACCOUNTS, accounts.size(), 'Account insert failure');
        System.assertEquals(NUMBER_OF_CONTACTS, contacts.size(), 'Contact insert failure');
        System.assertEquals(NUMBER_OF_LEADS, leads.size(), 'Lead insert failure');
        System.assertEquals(NUMBER_OF_CASES, cases.size(), 'Case insert failure');
        System.assertEquals(NUMBER_OF_OPPORTUNITIES, opportunities.size(), 'Opportunity insert failure');
        System.assertEquals(NUMBER_OF_TASKS, tasks.size(), 'Task insert failure');
        System.assertEquals(NUMBER_OF_TASKS, tasks.size(), 'Task insert failure');
        System.assertEquals(
            (accountSubscriptions.size() * accounts.size()) +
            (contactSubscriptions.size() * contacts.size()) +
            (leadSubscriptions.size() * leads.size()) +
            (caseSubscriptions.size() * cases.size()) +
            (opportunitySubscriptions.size() * opportunities.size()) +
            (taskSubscriptions.size() * tasks.size()),
            subscriptions.size(),
            'Subscription insert failure'
        );
    }

    @isTest
    public static void testGetAccountSubscriptions() {
        Account account = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        responseData rd = slackAlerts.getSubscriptions('Account', account.Id, CHANNEL_ID);
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
        System.assertEquals(true, !rd.results.isEmpty(), 'results are empty');
    }

    @isTest
    public static void testGetContactSubscriptions() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        responseData rd = slackAlerts.getSubscriptions('Contact', contact.Id, CHANNEL_ID);
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
        System.assertEquals(true, !rd.results.isEmpty(), 'results are empty');
    }

    @isTest
    public static void testGetLeadSubscriptions() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];

        Test.startTest();
        responseData rd = slackAlerts.getSubscriptions('Lead', lead.Id, CHANNEL_ID);
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
        System.assertEquals(true, !rd.results.isEmpty(), 'results are empty');
    }

    @isTest
    public static void testGetCaseSubscriptions() {
        Case caseObj = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        responseData rd = slackAlerts.getSubscriptions('Case', caseObj.Id, CHANNEL_ID);
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
        System.assertEquals(true, !rd.results.isEmpty(), 'results are empty');
    }

    @isTest
    public static void testGetOpportunitySubscriptions() {
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        responseData rd = slackAlerts.getSubscriptions('Opportunity', opportunity.Id, CHANNEL_ID);
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
        System.assertEquals(true, !rd.results.isEmpty(), 'results are empty');
    }

    @isTest
    public static void testGetTaskSubscriptions() {
        Task task = [SELECT Id FROM Task LIMIT 1];

        Test.startTest();
        responseData rd = slackAlerts.getSubscriptions('Task', task.Id, CHANNEL_ID);
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
        System.assertEquals(true, !rd.results.isEmpty(), 'results are empty');
    }

    @isTest
    public static void testGetExistingChannelNames() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Slack_Auth__c auth = [SELECT Id FROM Slack_Auth__c LIMIT 1];
        Subscription__c subscription = new Subscription__c();
        subscription.Record_Id__c = account.Id;
        subscription.User__c = UserInfo.getUserId();
        subscription.Object_Type__c = 'Account';
        subscription.Subscription_Type__c = 'Assigned to Me';
        subscription.Channel_Name__c = CHANNEL_NAME;
        subscription.Channel_Id__c = CHANNEL_ID;
        insert subscription;

        Test.startTest();
        responseData rd = slackAlerts.getExistingChannelNames(account.Id, auth.Id);
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
        System.assertEquals(true, !rd.results.isEmpty(), 'results are empty');
    }

    @isTest
    public static void testDeleteAuth() {
        Slack_Auth__c auth = [SELECT Id FROM Slack_Auth__c LIMIT 1];

        Test.startTest();
        slackAlerts.deleteAuth(auth.Id);
        Test.stopTest();

        List<Slack_Auth__c> auths = [SELECT Id FROM Slack_Auth__c];
        System.assertEquals(NUMBER_OF_AUTHS - 1, auths.size(), 'Auth delete failure');
    }

    @isTest
    public static void testSendSubscriptionPayload() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Slack_Auth__c auth = [SELECT Id FROM Slack_Auth__c LIMIT 1];
        Subscription__c subscription = new Subscription__c();
        subscription.Record_Id__c = account.Id;
        subscription.User__c = UserInfo.getUserId();
        subscription.Object_Type__c = 'Account';
        subscription.Subscription_Type__c = 'Assigned to Me';
        subscription.Channel_Name__c = CHANNEL_NAME;
        subscription.Channel_Id__c = CHANNEL_ID;
        insert subscription;

        List<Map<String, Object>> selectedOptions = new List<Map<String, Object>>{
            new Map<String, Object>{
                'objectType' => 'Task',
                'label' => 'An Email is Sent for this Account',
                'type' => 'Field is Value',
                'field' => 'TaskSubtype',
                'value' => 'Email',
                'checked' => true
            }
        };

        List<Map<String, Object>> unselectedOptions = new List<Map<String, Object>>{
            new Map<String, Object>{
                'objectType' => 'Account',
                'label' => 'A New Account is Assigned to Me',
                'type' => 'Assigned to Me',
                'checked' => false,
                'existingId' => subscription.Id
            }
        };

        Test.setMock(HttpCalloutMock.class, new sendSubscriptionPayloadMock());
        Test.startTest();
        responseData rd = slackAlerts.sendSubscriptionPayload(JSON.serialize(selectedOptions), JSON.serialize(unselectedOptions), CHANNEL_ID, CHANNEL_NAME, account.Id, auth.Id);
        Test.stopTest();

        System.assertEquals(true, rd.isSuccess, 'response data is not success');
    }

    private class sendSubscriptionPayloadMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            return res;
        }
    }

}