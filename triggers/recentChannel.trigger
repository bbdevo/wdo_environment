trigger recentChannel on Recent_Channel__c (before insert) {
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            recentChannelTrigger.maintainRecentChannels(Trigger.new);
        }
    }
}