public with sharing class subscriptionEngine implements Queueable {

    private Map<Id, sObject> newTriggerObjById;
    private Map<Id, sObject> oldTriggerObjById;
    private System.TriggerOperation triggerType;
    private Map<String, Schema.SObjectField> objFields;
    @TestVisible
    private static List<Subscription_Event__e> subscriptionEventsTest; //used to do testing
    private List<Subscription_Event__e> subscriptionEvents;
    private List<Subscription_Error__e> subscriptionErrors;
    private List<String> wonStages;
    private String objType;
    private Set<String> userRecordVisibilities; // UserId|RecordId
    private List<sObject> triggerObjs;
    private Set<Id> triggerObjIds;
    private List<String> objectSubscriptionTypes;
    private List<String> recordSubscriptionTypes;
    private Map<String, sObject> parentRecordById;
    private Map<String, List<sObject>> dateRecordsToDeletedBySubId;
    private Map<String, List<sObject>> recordsToSendBySubId;
    private Map<String, Subscription__c> subscriptionBySubscriptionId;
    Set<String> subUserIds;

    //constructor to check subscriptions
    public subscriptionEngine(Map<Id, sObject> newTriggerObjById, Map<Id, sObject> oldTriggerObjById, System.TriggerOperation triggerType, String objType){
        this.newTriggerObjById = newTriggerObjById;
        this.oldTriggerObjById = oldTriggerObjById;
        this.triggerType = triggerType;
        this.objType = objType;
    }

    //constructor for queueable
    public subscriptionEngine(Set<Id> triggerObjIds, Map<String, Subscription__c> subscriptionBySubscriptionId, Map<String, List<sObject>> dateRecordsToDeletedBySubId, Map<String, List<sObject>> recordsToSendBySubId, Set<String> subUserIds, String objType){
        this.triggerObjIds = triggerObjIds;
        this.subscriptionBySubscriptionId = subscriptionBySubscriptionId;
        this.dateRecordsToDeletedBySubId = dateRecordsToDeletedBySubId;
        this.recordsToSendBySubId = recordsToSendBySubId;
        this.subUserIds = subUserIds;
        this.objType = objType;
    }

    //check which records fufill condition and need to be sent out in a queueable
    public void processRecords(){
        try {
            if((Limits.getLimitQueries() - Limits.getQueries()) < 10) {
                return;
            }

            Slack_Settings__c slackSetting = Slack_Settings__c.getOrgDefaults();
            Decimal asyncLimit = slackSetting.Async_Limit__c == null ? 240000 : slackSetting.Async_Limit__c;
            Integer totalAsyncJobs = [SELECT COUNT() FROM AsyncApexJob WHERE CreatedDate = TODAY];

            if(totalAsyncJobs > asyncLimit){
                return;
            }

            checkAccess('sendSubscription');
            subscriptionErrors = new List<Subscription_Error__e>();
            objectSubscriptionTypes = new List<String>();
            recordSubscriptionTypes = new List<String>();
            subscriptionBySubscriptionId = new Map<String, Subscription__c>();
            recordsToSendBySubId = new Map<String, List<sObject>>();
            dateRecordsToDeletedBySubId = new Map<String, List<sObject>>();
            wonStages = new List<String>();
            subUserIds = new Set<String>();
            parentRecordById = new Map<String, sObject>();
            objFields = Schema.getGlobalDescribe().get(objType).getDescribe().fields.getMap();
            Decimal recordLimit = slackSetting.Trigger_Record_Limit__c == null ? 5 : slackSetting.Trigger_Record_Limit__c;
            Decimal maxSubscriptionObjectUsers = constants.TOTAL_ALLOWED_SUBSCRIPTIONS - recordLimit;
            Map<String, List<Subscription__c>> subscriptionsByRecordId = new Map<String, List<Subscription__c>>();
            List<String> ownerIds = new List<String>();
            Map<String, List<String>> parentRecordIdsByParentObj = new Map<String, List<String>>(); //parent objs of activities for Owned By Me checks

            setSubscriptionTypesAndTriggerIds();

            if(objFields.containsKey('OwnerId')) {
                for(sObject sObj : triggerObjs) {
                    ownerIds.add((String)sObj.get('OwnerId'));
                }
            }

            List<Subscription__c> objectLevelSubscriptions = getObjSubs(objType, objectSubscriptionTypes, ownerIds);
            List<Subscription__c> recordLevelSubscriptions = getRecordSubs(objType, recordSubscriptionTypes, ownerIds);
            List<Subscription__c> objectLevelSubscriptionsToCheck = new List<Subscription__c>();

            for(OpportunityStage stage : [SELECT ApiName
                                          FROM OpportunityStage
                                          WHERE IsWon = true
                                              AND IsClosed = true
                                              AND IsActive = true]) {
                wonStages.add(stage.ApiName);
            }


            for(Subscription__c subscription : recordLevelSubscriptions) {
                String userId = subscription.CreatedById;

                //sort out the object types and parent ids of the activities so we can
                //query for their parents later
                if((objType == 'Task' || objType == 'Event') &&
                   subscription.User__c != null &&
                   subscription.Record_Id__c != null) {
                    Id parentId = subscription.Record_Id__c;
                    String parentObjType = parentId.getSobjectType() + '';

                    if(!parentRecordIdsByParentObj.containsKey(parentObjType)){
                        parentRecordIdsByParentObj.put(parentObjType, new List<String>());
                    }

                    parentRecordIdsByParentObj.get(parentObjType).add(parentId);
                }

                if(!subUserIds.contains(userId) && subUserIds.size() < maxSubscriptionObjectUsers && subscription.Subscription_Type__c != constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME){
                    subUserIds.add(userId);
                }

                //Assigned to me is exempt. If you own the record you have access. So we won't need to do an access check on it later
                if(subUserIds.contains(userId) || subscription.Subscription_Type__c == constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME){
                    if(!subscriptionsByRecordId.containsKey(subscription.Record_Id__c)) {
                        subscriptionsByRecordId.put(subscription.Record_Id__c, new List<Subscription__c>());
                    }

                    subscriptionsByRecordId.get(subscription.Record_Id__c).add(subscription);
                    subscriptionBySubscriptionId.put(subscription.Subscription_Id__c, subscription);
                }
            }

            for(Subscription__c subscription : objectLevelSubscriptions) {
                String userId = subscription.CreatedById;

                if(!subUserIds.contains(userId) && subUserIds.size() < maxSubscriptionObjectUsers && subscription.Subscription_Type__c != constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME){
                    subUserIds.add(userId);
                }

                //Assigned to me is exempt. If you own the record you have access.
                if(subUserIds.contains(userId) || subscription.Subscription_Type__c == constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME) {
                    objectLevelSubscriptionsToCheck.add(subscription);
                    subscriptionBySubscriptionId.put(subscription.Subscription_Id__c, subscription);
                }
            }

            for(String parentObj : parentRecordIdsByParentObj.keySet()){
                if(Limits.getQueries() == Limits.getLimitQueries()) {
                    break;
                }

                List<String> parentRecordIds = parentRecordIdsByParentObj.get(parentObj);
                String soqlQuery = 'SELECT OwnerId FROM ' + parentObj + ' WHERE Id = :parentRecordIds';
                List<sObject> parentObjs = Database.query(soqlQuery);

                for(sObject sObj : parentObjs){
                    parentRecordById.put((String)sObj.get('Id'), sObj);
                }
            }

            for(sObject sObj : triggerObjs) {
                for(Subscription__c subscription : objectLevelSubscriptionsToCheck) {
                    checkSubscription(sObj, subscription);
                }

                List<String> recordIds = new List<String>();
                //if we're activites we need to also check for parent records.
                if(objType == 'Task' || objType == 'Event') {
                    if(sObj.get('WhoId') != null) {
                        recordIds.add((String)sObj.get('WhoId'));
                    }

                    if(sObj.get('WhatId') != null) {
                        recordIds.add((String)sObj.get('WhatId'));
                    }
                }

                //events can never be targetted so never use thier own id.
                if(objType != 'Event') {
                    recordIds.add((String)sObj.get('Id'));
                }

                for(String recordId : recordIds) {
                    if(subscriptionsByRecordId.containsKey(recordId)) {
                        for(Subscription__c subscription : subscriptionsByRecordId.get(recordId)) {
                            checkSubscription(sObj, subscription);
                        }
                    }
                }
            }

            if(!dateRecordsToDeletedBySubId.isEmpty() || !recordsToSendBySubId.isEmpty()){
                System.enqueueJob(new subscriptionEngine(triggerObjIds, subscriptionBySubscriptionId, dateRecordsToDeletedBySubId, recordsToSendBySubId, subUserIds, objType));
            }

            // List<Database.SaveResult> results = EventBus.publish(subscriptionEvents);
            //
            // for(Integer i; i < results.size(); i++) {
            //     Database.SaveResult sr = results.get(i);
            //
            //     if (!sr.isSuccess()) {
            //         Database.Error err = sr.getErrors().get(0);
            //         Subscription_Event__e notiEvent = subscriptionEvents.get(i);
            //         Subscription_Error__e notiError = new Subscription_Error__e(
            //             Error__c = 'Failed to publish subscription ' +  notiEvent.Subscription_Id__c + ': ' + err.getMessage()
            //             );
            //
            //         subscriptionErrors.add(notiError);
            //     }
            // }
            //
            // if(!subscriptionErrors.isEmpty()) {
            //     EventBus.publish(subscriptionErrors);
            // }

            System.debug('******************* subscriptionErrors ' + subscriptionErrors);
        } catch (Exception e){
            System.debug('************ engine err ' + e.getMessage());
            System.debug('************ engine err ' + e.getStackTraceString());
            List<Subscription_Error__e> subscriptionErrors = new List<Subscription_Error__e>{
                new Subscription_Error__e(
                    Error__c = 'Error in subscription engine: ' + e.getMessage() + '\n Line: ' + e.getLineNumber() + ' \nTrace:' + e.getStackTraceString()
                    )
            };

            EventBus.publish(subscriptionErrors);
        }
    }

    public void execute(QueueableContext context){
        try {
            subscriptionEventsTest = new List<Subscription_Event__e>();
            subscriptionEvents = new List<Subscription_Event__e>();
            subscriptionErrors = new List<Subscription_Error__e>();
            userRecordVisibilities = new Set<String>();

            for(String userId : subUserIds){
                checkRecordAccess(triggerObjIds, userId);
            }

            for(String subId : dateRecordsToDeletedBySubId.keySet()){
                for(sObject sObj : dateRecordsToDeletedBySubId.get(subId)){
                    //date delete events just remove
                    createSubscriptionEvent(sObj, subId, 'delete');
                }
            }

            for(String subId : recordsToSendBySubId.keySet()){
                Subscription__c subscription = subscriptionBySubscriptionId.get(subId);
                Boolean isAssignedToMe = subscription.Subscription_Type__c == constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME;
                for(sObject sObj : recordsToSendBySubId.get(subId)){
                    if(subscription.Record_Id__c == null){
                        String recordAccessKey = subscription.CreatedById + '|' + sObj.get('Id');

                        if(userRecordVisibilities.contains(recordAccessKey) || isAssignedToMe) {
                            createSubscriptionEvent(sObj, subId);
                        }
                    } else {
                        String recordAccessKey = subscription.CreatedById + '|' + subscription.Record_Id__c;
                        Boolean isConvertedLeadSub = false;

                        if(objType == 'Lead' && subscription.Field__c == 'IsConverted' && subscription.Subscription_Type__c == constants.NOTIFICATION_TYPE_FIELD_CHANGED){
                            isConvertedLeadSub = true;
                        }

                        //we can't check access on converted subs as no one owns them anymore. So we just let them through.
                        if(userRecordVisibilities.contains(recordAccessKey) || isConvertedLeadSub || isAssignedToMe) {
                            createSubscriptionEvent(sObj, subId);
                        }
                    }
                }
            }

            List<Database.SaveResult> results = EventBus.publish(subscriptionEvents);

            for(Integer i; i < results.size(); i++) {
                Database.SaveResult sr = results.get(i);

                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors().get(0);
                    Subscription_Event__e notiEvent = subscriptionEvents.get(i);
                    Subscription_Error__e notiError = new Subscription_Error__e(
                        Error__c = 'Failed to publish subscription ' +  notiEvent.Subscription_Id__c + ': ' + err.getMessage()
                        );

                    subscriptionErrors.add(notiError);
                }
            }

            if(!subscriptionErrors.isEmpty()) {
                EventBus.publish(subscriptionErrors);
            }

            System.debug('******************* subscriptionEvents ' + subscriptionEvents.size());
            System.debug('******************* subscriptionErrors ' + subscriptionErrors);
        } catch (Exception e){
            System.debug('************ queue engine err ' + e.getMessage());
            System.debug('************ queue engine err ' + e.getStackTraceString());
            List<Subscription_Error__e> subscriptionErrors = new List<Subscription_Error__e>{
                new Subscription_Error__e(
                    Error__c = 'Error in subscription engine: ' + e.getMessage() + '\n Line: ' + e.getLineNumber() + ' \nTrace:' + e.getStackTraceString()
                    )
            };

            EventBus.publish(subscriptionErrors);
        }
    }

    private void setSubscriptionTypesAndTriggerIds(){
        if(triggerType == System.TriggerOperation.AFTER_INSERT) {
            //we don't need to handle date reached on Insert as its scheduled in the subscriptions webservice.
            //we just need to monitor if the date changes
            objectSubscriptionTypes = new List<String>{constants.NOTIFICATION_TYPE_NEW, constants.NOTIFICATION_TYPE_FIELD_IS_VALUE, constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME, constants.NOTIFICATION_TYPE_OPPORTUNITY_WON};
            if(objType == 'Task') {
                recordSubscriptionTypes = new List<String>{constants.NOTIFICATION_TYPE_FIELD_IS_VALUE};
            }
            //events do need to handle date on Insert as they're created for a parent.
            if(objType == 'Event') {
                recordSubscriptionTypes = new List<String>{constants.NOTIFICATION_TYPE_FIELD_IS_VALUE, constants.NOTIFICATION_TYPE_DATE_REACHED};
            }

            triggerObjs = newTriggerObjById.values();
            triggerObjIds = newTriggerObjById.keySet();
        } else if(triggerType == System.TriggerOperation.AFTER_UPDATE) {
            objectSubscriptionTypes = new List<String>{constants.NOTIFICATION_TYPE_FIELD_CHANGED, constants.NOTIFICATION_TYPE_FIELD_IS_VALUE, constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME, constants.NOTIFICATION_TYPE_OPPORTUNITY_WON};
            recordSubscriptionTypes = new List<String>{constants.NOTIFICATION_TYPE_FIELD_CHANGED, constants.NOTIFICATION_TYPE_FIELD_IS_VALUE, constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME, constants.NOTIFICATION_TYPE_OPPORTUNITY_WON, constants.NOTIFICATION_TYPE_DATE_REACHED, constants.NOTIFICATION_TYPE_DATE_OVERDUE};
            triggerObjs = newTriggerObjById.values();
            triggerObjIds = newTriggerObjById.keySet();
        } else if(triggerType == System.TriggerOperation.BEFORE_DELETE) {
            recordSubscriptionTypes = new List<String>{constants.NOTIFICATION_TYPE_DATE_REACHED, constants.NOTIFICATION_TYPE_DATE_OVERDUE};
            triggerObjs = oldTriggerObjById.values();
            triggerObjIds = oldTriggerObjById.keySet();
        }

        //Activities need to check based of their parent record instead of their own Id.
        //Task is a combination of both as it can also have its own record level
        if(objType == 'Task') {
            triggerObjIds = new Set<Id>(triggerObjIds); // clone it so we can mod it

            for(sObject sObj : triggerObjs) {
                if(sObj.get('WhatId') != null) {
                    triggerObjIds.add((String)sObj.get('WhatId'));
                }

                if(sObj.get('WhoId') != null) {
                    triggerObjIds.add((String)sObj.get('WhoId'));
                }
            }
        }

        if(objType == 'Event') {
            triggerObjIds = new Set<Id>();

            for(sObject sObj : triggerObjs) {
                if(sObj.get('WhatId') != null) {
                    triggerObjIds.add((String)sObj.get('WhatId'));
                }

                if(sObj.get('WhoId') != null) {
                    triggerObjIds.add((String)sObj.get('WhoId'));
                }
            }
        }
    }

    private List<Subscription__c> getObjSubs(String objType, List<String> objectSubscriptionTypes, List<String> ownerIds){
        Integer assignedIndex = objectSubscriptionTypes.indexOf(constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME);

        if(assignedIndex != -1) {
            objectSubscriptionTypes.remove(assignedIndex);

            return [SELECT Id, CreatedById, Subscription_Id__c, Subscription_Type__c,
                    Field__c, Value__c, User__c, Record_Id__c
                    FROM Subscription__c
                    WHERE Record_Id__c = null
                        AND Object_Type__c =: objType
                        AND (
                        Subscription_Type__c =: objectSubscriptionTypes
                            OR (
                            Subscription_Type__c =: constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME
                                AND User__c =: ownerIds
                            )
                        )];
        } else {
            return [SELECT Id, CreatedById, Subscription_Id__c, Subscription_Type__c,
                    Field__c, Value__c, User__c, Record_Id__c
                    FROM Subscription__c
                    WHERE Record_Id__c = null
                        AND Object_Type__c =: objType
                        AND Subscription_Type__c =: objectSubscriptionTypes];
        }
    }

    private List<Subscription__c> getRecordSubs(String objType, List<String> recordSubscriptionTypes, List<String> ownerIds){
        Integer assignedIndex = recordSubscriptionTypes.indexOf(constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME);

        if(assignedIndex != -1) {
            objectSubscriptionTypes.remove(assignedIndex);

            return [SELECT Id, CreatedById, Record_Id__c, Subscription_Id__c,
                    Subscription_Type__c, Field__c, Value__c, User__c
                    FROM Subscription__c
                    WHERE Record_Id__c =: triggerObjIds
                        AND Object_Type__c =: objType
                        AND (
                        Subscription_Type__c =: recordSubscriptionTypes
                            OR (
                            Subscription_Type__c =: constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME
                                AND User__c =: ownerIds
                            )
                        )];
        } else {
            return [SELECT Id, CreatedById, Record_Id__c, Subscription_Id__c,
                    Subscription_Type__c, Field__c, Value__c, User__c
                    FROM Subscription__c
                    WHERE Record_Id__c =: triggerObjIds
                        AND Object_Type__c =: objType
                        AND Subscription_Type__c =: recordSubscriptionTypes];
        }
    }

    private void checkRecordAccess(Set<Id> recordIds, String userId) {
        if(Limits.getQueries() == Limits.getLimitQueries()) {
            Subscription_Error__e queryError = new Subscription_Error__e(
                Error__c = 'Failed to publish subscription for ' + userId + '. Too many soql queries during check record acesss.\nHere are the failed records: ' + recordIds
                );

            subscriptionErrors.add(queryError);

            return;
        }

        for(UserRecordAccess recordAccess : [SELECT RecordId
                                             FROM UserRecordAccess
                                             WHERE RecordId =: recordIds
                                                 AND UserId =: userId
                                                 AND HasReadAccess = true]) {
            userRecordVisibilities.add(userId + '|' + recordAccess.RecordId);
        }
    }

    private void checkSubscription(SObject sObj, Subscription__c subscription){
        //Logging Calls and Emails trigger Assigned to Me notifications due to the
        // automatic task creation. So don't trigger assigned to me if the Task is completed
        if(objType == 'Task' &&
           subscription.Subscription_Type__c == constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME &&
           sObj.get('Status') == 'Completed' ) {
            return;
        }


        //ownership check for activities
        if((objType == 'Task' || objType == 'Event') &&
           subscription.User__c != null &&
           subscription.Record_Id__c != null) {
               Id parentId = subscription.Record_Id__c;
               sObject parentObj = parentRecordById.get(parentId);

               if(parentObj != null){
                   Map<String, Object> fieldMap = parentObj.getPopulatedFieldsAsMap();

                   if(!fieldMap.containsKey('OwnerId') || (String)fieldMap.get('OwnerId') != subscription.User__c){
                       return;
                   }
               } else {
                   return;
               }
        }

        //can't use constants as it has to be a String or Enum for switches
        switch on subscription.Subscription_Type__c{
            when 'New' {
                addToSubscriptionMap(sObj, subscription);
            }
            when 'Date Reached', 'Date Overdue' {
                //Dates are usually record based to prevent flooding so we don't look at insert triggers
                //Event is an exception as its an activity for a specific record
                if(triggerType == System.TriggerOperation.BEFORE_DELETE){
                    addToSubscriptionMap(sObj, subscription, 'delete');
                } else if (triggerType == System.TriggerOperation.AFTER_UPDATE){
                    sObject oldSObj = oldTriggerObjById.get((String)sObj.get('Id'));
                    String oldVal = String.valueOf(oldSObj.get(subscription.Field__c));
                    String newVal = String.valueOf(sObj.get(subscription.Field__c));

                    if(oldVal != newVal){
                        addToSubscriptionMap(sObj, subscription, 'delete');
                        addToSubscriptionMap(sObj, subscription);
                    }
                } else if(triggerType == System.TriggerOperation.AFTER_INSERT && objType == 'Event'){
                    addToSubscriptionMap(sObj, subscription);
                }
            }
            when 'Assigned to Me' {
                String currentOwner = (String)sObj.get('OwnerId');
                if(triggerType == System.TriggerOperation.AFTER_INSERT){
                    if(currentOwner == subscription.User__c) {
                        addToSubscriptionMap(sObj, subscription);
                    }
                } else {
                    sObject oldSObj = oldTriggerObjById.get((String)sObj.get('Id'));
                    String oldOwner = String.valueOf(oldSObj.get('OwnerId'));

                    if(oldOwner != currentOwner && currentOwner == subscription.User__c){
                        addToSubscriptionMap(sObj, subscription);
                    }
                }
            }
            when 'Field is Value'{
                if(objFields.containsKey(subscription.Field__c)){
                    if (objFields.get(subscription.Field__c).getDescribe().isAccessible()) {
                        String newVal = String.valueOf(sObj.get(subscription.Field__c));
                        if(triggerType == System.TriggerOperation.AFTER_INSERT){
                            if(newVal == subscription.Value__c){
                                addToSubscriptionMap(sObj, subscription);
                            }
                        } else {
                            sObject oldSObj = oldTriggerObjById.get((String)sObj.get('Id'));
                            String oldVal = String.valueOf(oldSObj.get(subscription.Field__c));

                            if(oldVal != newVal && newVal == subscription.Value__c){
                                addToSubscriptionMap(sObj, subscription);
                            }
                        }
                    }
                }
            }
            when 'Field Changed'{
                if(objFields.containsKey(subscription.Field__c)){
                    if (objFields.get(subscription.Field__c).getDescribe().isAccessible()) {
                        sObject oldSObj = oldTriggerObjById.get((String)sObj.get('Id'));
                        String oldVal = String.valueOf(oldSObj.get(subscription.Field__c));
                        String newVal = String.valueOf(sObj.get(subscription.Field__c));

                        if(oldVal != newVal){
                            addToSubscriptionMap(sObj, subscription);
                        }
                    }
                }
            }
            when 'Opportunity Won'{
                if(objType == 'Opportunity'){
                    if(triggerType == System.TriggerOperation.AFTER_INSERT){
                        String stage = (String)sObj.get('StageName');

                        if(wonStages.contains(stage)){
                            addToSubscriptionMap(sObj, subscription);
                        }
                    } else {
                        sObject oldSObj = oldTriggerObjById.get((String)sObj.get('Id'));
                        String oldVal = String.valueOf(oldSObj.get('StageName'));
                        String newVal = String.valueOf(sObj.get('StageName'));
                        if(oldVal != newVal && wonStages.contains(newVal)){
                            addToSubscriptionMap(sObj, subscription);
                        }
                    }
                }
            }
        }
    }

    private void addToSubscriptionMap(sObject sObj, Subscription__c subscription){
        addToSubscriptionMap(sObj, subscription, '');
    }

    private void addToSubscriptionMap(sObject sObj, Subscription__c subscription, String actionType){
        if(actionType == 'delete'){
            if(!dateRecordsToDeletedBySubId.containsKey(subscription.Subscription_Id__c)){
                dateRecordsToDeletedBySubId.put(subscription.Subscription_Id__c, new List<sObject>());
            }

            dateRecordsToDeletedBySubId.get(subscription.Subscription_Id__c).add(sObj);
        } else {
            if(!recordsToSendBySubId.containsKey(subscription.Subscription_Id__c)){
                recordsToSendBySubId.put(subscription.Subscription_Id__c, new List<sObject>());
            }

            recordsToSendBySubId.get(subscription.Subscription_Id__c).add(sObj);
        }
    }

    private void createSubscriptionEvent(sObject sObj, String subId){
        createSubscriptionEvent(sObj, subId, '');
    }

    private void createSubscriptionEvent(sObject sObj, String subId, String actionType){
        Subscription_Event__e subscriptionEvent = new Subscription_Event__e(
            Subscription_Id__c = subId,
            Record_Data__c = JSON.serialize(sObj),
            Action__c = actionType
            );

        if(Test.isRunningTest()) {
            subscriptionEventsTest.add(subscriptionEvent);
        }

        subscriptionEvents.add(subscriptionEvent);
    }

    private final Map<String, Map<String, Map<String, Set<String>> >> ACCESS_MAP = new Map<String, Map<String, Map<String, Set<String>> >>{
        'sendSubscription' => new Map<String, Map<String, Set<String>>> {
            'Subscription__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Record_Id__c', 'Subscription_Id__c', 'Subscription_Type__c', 'Field__c', 'Value__c', 'User__c'
                }
            },
            'Slack_Settings__c' => new Map<String, Set<String>> {
                'Read' => new Set<String>{
                    'Trigger_Record_Limit__c'
                }
            }
        }
    };

    private void checkAccess(String methodName) {
        dmlManager.checkAccess(ACCESS_MAP.get(methodName));
    }
}