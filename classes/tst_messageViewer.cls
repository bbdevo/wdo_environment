@isTest
public with sharing class tst_messageViewer {
    private static FINAL Integer NUMBER_OF_ACCOUNTS = 2;
    private static FINAL Integer NUMBER_OF_RELATED_MESSAGES = 15;

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

        List<Slack_Message__c> slackMessagesToInsert = new List<Slack_Message__c>();
        for (Account insertedAccount : accountsToInsert) {
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
        insert slackMessagesToInsert;

        /* get inserted data */
        List<Account> accounts = [SELECT Id FROM Account];
        List<Slack_Message__c> messages = [SELECT Id FROM Slack_Message__c];

        /* assert that the data inserted properly */
        System.assertEquals(NUMBER_OF_ACCOUNTS, accounts.size(), 'Account insert failure');
        System.assertEquals(NUMBER_OF_RELATED_MESSAGES * NUMBER_OF_ACCOUNTS, messages.size(), 'Slack Message insert failure');
    }

    @isTest
    public static void testGetRelatedMessages() {
        ID accountId = [SELECT Id FROM Account LIMIT 1].Id;
    
        Test.startTest();
        responseData rd = messageViewer.getRelatedMessages(accountId, 5);
        Test.stopTest();
        
        System.assertEquals(true, rd.isSuccess, 'response data is not success');
        System.assertEquals(true, !rd.results.isEmpty(), 'results are empty');
    }
    
}