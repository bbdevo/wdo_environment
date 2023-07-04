public with sharing class postInstall implements InstallHandler {
    public void onInstall(InstallContext context) {
        if(context.previousVersion() == null) {
            utilities.generateEncryptionKey();
            Slack_Settings__c slackSettings = Slack_Settings__c.getOrgDefaults();
            slackSettings.Trigger_Record_Limit__c = 5;
            slackSettings.Async_Limit__c = 240000;
            insert slackSettings;
        } else {
            if(context.previousVersion().compareTo(new Version(1,41)) == 0 || context.previousVersion().compareTo(new Version(1,42)) == 0) {
                utilities.generateEncryptionKey();
            }

            Slack_Settings__c slackSettings = Slack_Settings__c.getOrgDefaults();

            if(slackSettings.Async_Limit__c == null){
                slackSettings.Async_Limit__c = 240000;
                upsert slackSettings;
            }
        }


        Setup_Settings__c settings = Setup_Settings__c.getOrgDefaults();

        if(settings.Namespace_Api__c == null){
            settings.Namespace_Api__c = constants.NAMESPACE_API;
            upsert settings;
        }
    }
}