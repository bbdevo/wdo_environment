trigger slackMessage on Slack_Message__c (before insert) {

	if (Trigger.isInsert) {
		if (Trigger.isBefore) {
			slackMessageTrigger.updateLookupId(Trigger.new);
		}
	}
}