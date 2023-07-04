trigger slackAuth on Slack_Auth__c (before insert, before update) {

	/* insert context */
	if (Trigger.isInsert) {
		if (Trigger.isBefore) {
			slackAuthTrigger.updateMostRecentWorkspace(Trigger.oldMap, Trigger.new);
		}
	}

    /* update context */
    if (Trigger.isUpdate) {
        if (Trigger.isBefore) {
            slackAuthTrigger.updateMostRecentWorkspace(Trigger.oldMap, Trigger.new);
        }
    }
}