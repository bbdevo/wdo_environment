@isTest
public with sharing class tst_slackMessages {
    private static FINAL Integer NUMBER_OF_ACCOUNTS = 2;

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

        /* get inserted data */
        List<Account> accounts = [SELECT Id FROM Account];

        /* assert that the data inserted properly */
        System.assertEquals(NUMBER_OF_ACCOUNTS, accounts.size(), 'Account insert failure');
    }

    @isTest
	public static void testCreateMessage() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Map<String, Object>> payload = new List<Map<String, Object>>{
            new Map<String, Object>{
                'channelId' => 'CJJLYAU1Z',
                'channelName' => 'general',
                'channelType' => 'type',
                'content' => 'Some content 1',
                'recordId' => account.Id,
                'teamId' => 'TJXUZKUA3',
                'timeStamp' => '1561491020638',
                'userImageUrl' => 'https://ca.slack-edge.com/T029XLGQD-UGF3UEV6Z-3a54d051995f-48',
                'userName' => 'Spencer Janis'
            },
            new Map<String, Object>{
                'channelId' => 'CJJLYAU1Z',
                'channelName' => 'general',
                'channelType' => 'type',
                'content' => 'Some content 2',
                'recordId' => account.Id,
                'teamId' => 'TJXUZKUA3',
                'timeStamp' => '1561491020638',
                'userImageUrl' => 'https://ca.slack-edge.com/T029XLGQD-UGF3UEV6Z-3a54d051995f-48',
                'userName' => 'Spencer Janis'
            }
        };

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(JSON.serialize(payload));
        RestContext.request = req;

        Test.startTest();
        slackMessages.createMessage();
        Test.stopTest();

        List<Slack_Message__c> slackMessages = [SELECT Id FROM Slack_Message__c];
        System.assertEquals(2, slackMessages.size(), 'Message insert failure');
	}

}