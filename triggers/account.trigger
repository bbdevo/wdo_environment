trigger account on Account (after insert, after update, before delete) {
    if(trigger.isAfter && trigger.isInsert ||
       trigger.isAfter && trigger.isUpdate ||
       trigger.isBefore && trigger.isDelete) {
           try {

               Slack_Settings__c slackSetting = Slack_Settings__c.getOrgDefaults();
               Decimal recordLimit = slackSetting.Trigger_Record_Limit__c == null ? 5 : slackSetting.Trigger_Record_Limit__c;
               if((trigger.newMap != null && trigger.newMap.size() > recordLimit) ||
                  (trigger.oldMap != null && trigger.oldMap.size() > recordLimit)) {
                   return;
               }

               if(Limits.getQueueableJobs() == Limits.getLimitQueueableJobs()) {
                   String errMsg = 'Queuable limit reached. Account trigger failed to start queable job.';
                   utilities.publishTriggerSubError(trigger.newMap, trigger.oldMap, errMsg);
               } else {
                   subscriptionEngine engine = new subscriptionEngine(trigger.newMap, trigger.oldMap, trigger.operationType, 'Account');
                   engine.processRecords();
                   // System.enqueueJob(new subscriptionEngine(trigger.newMap, trigger.oldMap, trigger.operationType, 'Account'));
               }
           } catch(Exception e){
               try {
                   String errMsg = 'Account trigger failed due to ' + e.getMessage();
                   utilities.publishTriggerSubError(trigger.newMap, trigger.oldMap, errMsg);
               } catch(Exception e2){
                   //fail silently if the error handling fails
               }
           }
    }
}