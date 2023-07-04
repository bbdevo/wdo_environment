trigger AgentWorkTrigger on AgentWork(
    before insert,
    after insert,
    after update
) {
    if (Trigger.isAfter) {
        wkdw.AgentWorkTriggerHandlerGlobalProxy.handleTrigger(
            Trigger.newMap,
            Trigger.oldMap,
            Trigger.operationType
        );
    } else {
        for (AgentWork aw : Trigger.new) {
            if (aw.WorkItemId == null) {
                System.debug('WorkItemId should not be null');
            }
        }
    }
}