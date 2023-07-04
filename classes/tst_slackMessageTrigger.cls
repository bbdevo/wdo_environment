@isTest
public with sharing class tst_slackMessageTrigger {

    private static FINAL Integer NUMBER_OF_ACCOUNTS = 2;
    private static FINAL Integer NUMBER_OF_CONTACTS = 2;
    private static FINAL Integer NUMBER_OF_LEADS = 2;
    private static FINAL Integer NUMBER_OF_CASES = 2;
    private static FINAL Integer NUMBER_OF_OPPORTUNITIES = 2;
    private static FINAL Integer NUMBER_OF_RELATED_MESSAGES = 2;

    @TestSetup
    static void makeData() {

        /* make accounts */
        List<Account> accountsToInsert = new List<Account>();
        for (Integer i = 0; i < NUMBER_OF_ACCOUNTS; i++) {
            Account accountToInsert = new Account();
            accountToInsert.Name = 'accountName' + i;
            accountsToInsert.add(accountToInsert);
        }
        insert accountsToInsert;

        /* make contacts */
        List<Contact> contactsToInsert = new List<Contact>();
        for (Integer i = 0; i < NUMBER_OF_CONTACTS; i++) {
            Contact contactToInsert = new Contact();
            contactToInsert.LastName = 'LastName' + i;
            contactsToInsert.add(contactToInsert);
        }
        insert contactsToInsert;

        /* make leads */
        List<Lead> leadsToInsert = new List<Lead>();
        for (Integer i = 0; i < NUMBER_OF_LEADS; i++) {
            Lead leadToInsert = new Lead();
            leadToInsert.LastName = 'LastName' + i;
            leadToInsert.Company = 'Company' + i;
            leadsToInsert.add(leadToInsert);
        }
        insert leadsToInsert;
        

        /* make cases */
        List<Case> casesToInsert = new List<Case>();
        for (Integer i = 0; i < NUMBER_OF_CASES; i++) {
            Case caseToInsert = new Case();
            caseToInsert.Subject = 'Subject' + i;
            casesToInsert.add(caseToInsert);
        }
        insert casesToInsert;

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

        /* get inserted data */
        List<Account> accounts = [SELECT Id FROM Account];
        List<Contact> contacts = [SELECT Id FROM Contact];
        List<Lead> leads = [SELECT Id FROM Lead];
        List<Case> cases = [SELECT Id FROM Case];
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity];

        /* assert that the data inserted properly */
        System.assertEquals(NUMBER_OF_ACCOUNTS, accounts.size(), 'Account insert failure');
        System.assertEquals(NUMBER_OF_CONTACTS, contacts.size(), 'Contact insert failure');
        System.assertEquals(NUMBER_OF_LEADS, leads.size(), 'Lead insert failure');
        System.assertEquals(NUMBER_OF_CASES, cases.size(), 'Case insert failure');
        System.assertEquals(NUMBER_OF_OPPORTUNITIES, opportunities.size(), 'Opportunity insert failure');
    }

    @isTest
    public static void testUpdateLookupId() {

        /* get inserted her objects */
        List<Account> insertedAccounts = [SELECT Id FROM Account];
        List<Contact> insertedContacts = [SELECT Id FROM Contact];
        List<Lead> insertedLeads = [SELECT Id FROM Lead];
        List<Case> insertedCases = [SELECT Id FROM Case];
        List<Opportunity> insertedOpportunities = [SELECT Id FROM Opportunity];

        /* insert messages for each hero object */
        List<Slack_Message__c> slackMessagesToInsert = new List<Slack_Message__c>();
        for (Account insertedAccount : insertedAccounts) {
            for (Integer j = 0; j < NUMBER_OF_RELATED_MESSAGES; j++) {
                Slack_Message__c messageToInsert = new Slack_Message__c();
                messageToInsert.Time_Stamp__c = j == 0 ? Datetime.now() : Datetime.now().addDays(-1);
                messageToInsert.Channel_Name__c = 'ChannelName' + j;
                messageToInsert.User_Name__c = 'UserName' + j;
                messageToInsert.Content__c = 'Content' + j;
                messageToInsert.User_Image_Url__c = 'UserImageUrl' + j;
                messageToInsert.Channel_Id__c = 'Id' + j;
                messageToInsert.Record_Id__c = insertedAccount.Id;
                slackMessagesToInsert.add(messageToInsert);
            }
        }

        for (Contact insertedContact : insertedContacts) {
            for (Integer j = 0; j < NUMBER_OF_RELATED_MESSAGES; j++) {
                Slack_Message__c messageToInsert = new Slack_Message__c();
                messageToInsert.Time_Stamp__c = j == 0 ? Datetime.now() : Datetime.now().addDays(-1);
                messageToInsert.Channel_Name__c = 'ChannelName' + j;
                messageToInsert.User_Name__c = 'UserName' + j;
                messageToInsert.Content__c = 'Content' + j;
                messageToInsert.User_Image_Url__c = 'UserImageUrl' + j;
                messageToInsert.Channel_Id__c = 'Id' + j;
                messageToInsert.Record_Id__c = insertedContact.Id;
                slackMessagesToInsert.add(messageToInsert);
            }
        }

        for (Lead insertedLead : insertedLeads) {
            for (Integer j = 0; j < NUMBER_OF_RELATED_MESSAGES; j++) {
                Slack_Message__c messageToInsert = new Slack_Message__c();
                messageToInsert.Time_Stamp__c = j == 0 ? Datetime.now() : Datetime.now().addDays(-1);
                messageToInsert.Channel_Name__c = 'ChannelName' + j;
                messageToInsert.User_Name__c = 'UserName' + j;
                messageToInsert.Content__c = 'Content' + j;
                messageToInsert.User_Image_Url__c = 'UserImageUrl' + j;
                messageToInsert.Channel_Id__c = 'Id' + j;
                messageToInsert.Record_Id__c = insertedLead.Id;
                slackMessagesToInsert.add(messageToInsert);
            }
        }

        for (Case insertedCase : insertedCases) {
            for (Integer j = 0; j < NUMBER_OF_RELATED_MESSAGES; j++) {
                Slack_Message__c messageToInsert = new Slack_Message__c();
                messageToInsert.Time_Stamp__c = j == 0 ? Datetime.now() : Datetime.now().addDays(-1);
                messageToInsert.Channel_Name__c = 'ChannelName' + j;
                messageToInsert.User_Name__c = 'UserName' + j;
                messageToInsert.Content__c = 'Content' + j;
                messageToInsert.User_Image_Url__c = 'UserImageUrl' + j;
                messageToInsert.Channel_Id__c = 'Id' + j;
                messageToInsert.Record_Id__c = insertedCase.Id;
                slackMessagesToInsert.add(messageToInsert);
            }
        }

        for (Opportunity insertedOpportunity : insertedOpportunities) {
            for (Integer j = 0; j < NUMBER_OF_RELATED_MESSAGES; j++) {
                Slack_Message__c messageToInsert = new Slack_Message__c();
                messageToInsert.Time_Stamp__c = j == 0 ? Datetime.now() : Datetime.now().addDays(-1);
                messageToInsert.Channel_Name__c = 'ChannelName' + j;
                messageToInsert.User_Name__c = 'UserName' + j;
                messageToInsert.Content__c = 'Content' + j;
                messageToInsert.User_Image_Url__c = 'UserImageUrl' + j;
                messageToInsert.Channel_Id__c = 'Id' + j;
                messageToInsert.Record_Id__c = insertedOpportunity.Id;
                slackMessagesToInsert.add(messageToInsert);
            }
        }
        
        /* test */
        Test.startTest();
        insert slackMessagesToInsert;
        Test.stopTest();

        /* get the inserted messages data */
        List<Slack_Message__c> messages = [SELECT Id, Record_Id__c, Account__c, Contact__c, Lead__c, Case__c, Opportunity__c FROM Slack_Message__c];

        /* assert that the trigger worked properly */
        System.assertEquals(
            NUMBER_OF_RELATED_MESSAGES * (NUMBER_OF_ACCOUNTS + NUMBER_OF_CONTACTS + NUMBER_OF_LEADS + NUMBER_OF_CASES + NUMBER_OF_OPPORTUNITIES),
            messages.size(),
            'Slack Message insert failure'
        );

        Integer numberOfAccountMessages = 0;
        Integer numberOfContactMessages = 0;
        Integer numberOfLeadMessages = 0;
        Integer numberOfCaseMessages = 0;
        Integer numberOfOpportunityMessages = 0;

        for (Slack_Message__c message : messages) {
            ID primitiveRecordId = message.Record_Id__c;
            String objectTypeName = primitiveRecordId.getSobjectType().getDescribe().getName();
            switch on objectTypeName {
                when 'Account' {
                    numberOfAccountMessages += 1;
                }
                when 'Contact' {
                    numberOfContactMessages += 1;
                }
                when 'Lead' {
                    numberOfLeadMessages += 1;
                }
                when 'Case' {
                    numberOfCaseMessages += 1;
                }
                when 'Opportunity' {
                    numberOfOpportunityMessages += 1;
                }
            }
        }
        
        System.assertEquals(NUMBER_OF_RELATED_MESSAGES * NUMBER_OF_ACCOUNTS, numberOfAccountMessages, 'Account Messages failure');
        System.assertEquals(NUMBER_OF_RELATED_MESSAGES * NUMBER_OF_CONTACTS, numberOfContactMessages, 'Contact Messages failure');
        System.assertEquals(NUMBER_OF_RELATED_MESSAGES * NUMBER_OF_LEADS, numberOfLeadMessages, 'Lead Messages failure');
        System.assertEquals(NUMBER_OF_RELATED_MESSAGES * NUMBER_OF_CASES, numberOfCaseMessages, 'Case Messages failure');
        System.assertEquals(NUMBER_OF_RELATED_MESSAGES * NUMBER_OF_OPPORTUNITIES, numberOfOpportunityMessages, 'Opportunity Messages failure');
    }
}