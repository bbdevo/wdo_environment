public with sharing class slackAuthTrigger {

    public static void updateMostRecentWorkspace(Map<Id, Slack_Auth__c> oldSlackAuths, List<Slack_Auth__c> newSlackAuths) {
        Map<String, Map<String, Set<String>>> accessChecks = new Map<String, Map<String, Set<String>>> {
            'Slack_Auth__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Is_Most_Recent__c', 'User__c'
                },
                'Update' => new Set<String> {
                    'Is_Most_Recent__c'
                }
            }
        };
        dmlManager.checkAccess(accessChecks);
        List<String> userIds = new List<String>();

        for(Slack_Auth__c slackAuth : newSlackAuths) {
            if(slackAuth.Is_Most_Recent__c) {
                if(oldSlackAuths != null) {
                    if(!oldSlackAuths.get(slackAuth.Id).Is_Most_Recent__c) {
                        userIds.add(slackAuth.User__c);
                    }
                } else {
                    userIds.add(slackAuth.User__c);
                }
            }
        }

        List<Slack_Auth__c> authsToUpdate = [SELECT Id, Is_Most_Recent__c
                                             FROM   Slack_Auth__c
                                             WHERE  Is_Most_Recent__c = true
                                             AND    User__c =: userIds];

        for(Slack_Auth__c slackAuth : authsToUpdate){
            slackAuth.Is_Most_Recent__c = false;
        }

        update authsToUpdate;
    }
}