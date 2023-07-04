public with sharing class slackMessageTrigger {

    public static void updateLookupId(List<Slack_Message__c> newMessages) {
        Map<String, Map<String, Set<String>>> accessChecks = new Map<String, Map<String, Set<String>>> {
            'Slack_Message__c' => new Map<String, Set<String>> {
                'Update' => new Set<String> {
                    'Account__c', 'Contact__c', 'Lead__c', 'Case__c', 'Opportunity__c'
                }
            }
        };
        dmlManager.checkAccess(accessChecks);

        for (Slack_Message__c message : newMessages) {
            ID primitiveRecordId = message.Record_Id__c;
            String sobjectTypeName = primitiveRecordId.getSObjectType().getDescribe().getName();
            switch on sobjectTypeName {
                when 'Account' {
                    message.Account__c = primitiveRecordId;
                }
                when 'Contact' {
                    message.Contact__c = primitiveRecordId;
                }
                when 'Lead' {
                    message.Lead__c = primitiveRecordId;
                }
                when 'Case' {
                    message.Case__c = primitiveRecordId;
                }
                when 'Opportunity' {
                    message.Opportunity__c = primitiveRecordId;
                }
            }
        }
    }

}