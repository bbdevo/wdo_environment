public with sharing class recentChannelTrigger {
    public static void maintainRecentChannels(List<Recent_Channel__c> newChannels){
        Map<String, Map<String, Set<String>>> accessChecks = new Map<String, Map<String, Set<String>>> {
            'Recent_Channel__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Slack_Auth__c', 'Channel_Id__c', 'CreatedDate'
                },
                'Delete' => new Set<String>()
            }
        };
        dmlManager.checkAccess(accessChecks);

        Set<String> slackAuthIds = new Set<String>();
        Set<String> newChannelIds = new Set<String>();
        List<Recent_Channel__c> channelsToDelete = new List<Recent_Channel__c>();
        Map<String, List<Recent_Channel__c>> recentChannelsBySlackAuth = new Map<String, List<Recent_Channel__c>>();

        for(Recent_Channel__c newChannel : newChannels) {
            if(!recentChannelsBySlackAuth.containsKey(newChannel.Slack_Auth__c)) {
                recentChannelsBySlackAuth.put(newChannel.Slack_Auth__c, new List<Recent_Channel__c>());
            }

            recentChannelsBySlackAuth.get(newChannel.Slack_Auth__c).add(newChannel);
            slackAuthIds.add(newChannel.Slack_Auth__c);
            newChannelIds.add(newChannel.Channel_Id__c);
        }

        List<Recent_Channel__c> existingChannels = [SELECT  Id, Slack_Auth__c, Channel_Id__c
                                                    FROM    Recent_Channel__c
                                                    WHERE   Slack_Auth__c =: slackAuthIds
                                                    ORDER   BY CreatedDate DESC];

        for(Recent_Channel__c existingChannel : existingChannels){
            List<Recent_Channel__c> totalChannels = recentChannelsBySlackAuth.get(existingChannel.Slack_Auth__c);

            if(totalChannels.size() >= 20 || newChannelIds.contains(existingChannel.Channel_Id__c)){
                channelsToDelete.add(existingChannel);
            } else {
                totalChannels.add(existingChannel);
            }
        }

        delete channelsToDelete;
    }
}