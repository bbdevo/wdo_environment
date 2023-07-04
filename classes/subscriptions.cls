@RestResource(urlMapping='/subscriptions')
global with sharing class subscriptions {
    private static Map<String, String> subscriptionIdByRecordId = new Map<String, String>();
    private static Map<String, List<String>> recordIdsByObjType = new Map<String, List<String>>();
    private static Map<String, Integer> totalSubsByObjectOrRecord = new Map<String, Integer>();
    private static List<Object> errors = new List<Object>();

    @HttpPost
    global static void createSubscription() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            checkAccess('createSubscription');

            String jsonString = req.requestBody.toString();
            List<Object> subscriptionPayloads = (List<Object>)JSON.deserializeUntyped(jsonString);
            List<Subscription__c> newSubscriptions = new List<Subscription__c>();
            Set<String> objectTypes = new Set<String>();
            Set<String> subRecordIds = new Set<String>();
            Set<String> newSubIds = new Set<String>();

            for(Object obj : subscriptionPayloads) {
                Map<String, Object> subscriptionMap = (Map<String,Object>)obj;
                String recordId = (String)subscriptionMap.get('recordId');
                String objType = (String)subscriptionMap.get('objectType');
                String subscriptionId = (String)subscriptionMap.get('subscriptionId');

                objectTypes.add(objType);
                totalSubsByObjectOrRecord.put(objType, 0);

                if(recordId != null) {
                    subRecordIds.add(recordId);
                    totalSubsByObjectOrRecord.put(recordId, 0);
                }
            }
            //get a count of unique users for Object level and Record level.
            List<AggregateResult> aggResults = [SELECT Object_Type__c objType, Record_Id__c recordId
                                                FROM Subscription__c
                                                WHERE Subscription_Type__c !=: constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME
                                                AND  (
                                                    (Object_Type__c =: objectTypes AND Record_Id__c = null)
                                                    OR (Object_Type__c =: objectTypes AND Record_Id__c =: subRecordIds)
                                                    )
                                                GROUP BY CreatedById, Object_Type__c, Record_Id__c];

            for(AggregateResult aggRes : aggResults) {
                String recordId = (String)aggRes.get('objType');
                String objType = (String)aggRes.get('recordId');

                if(recordId != null) {
                    Integer currentTotal = totalSubsByObjectOrRecord.get(recordId);
                    totalSubsByObjectOrRecord.put(recordId, currentTotal + 1);
                } else {
                    Integer currentTotal = totalSubsByObjectOrRecord.get(objType);
                    totalSubsByObjectOrRecord.put(objType, currentTotal + 1);
                }
            }

            Slack_Settings__c slackSetting = Slack_Settings__c.getOrgDefaults();
            Decimal recordLimit = slackSetting.Trigger_Record_Limit__c == null ? 5 : slackSetting.Trigger_Record_Limit__c;
            Decimal maxSubscriptionObjectUsers = constants.TOTAL_ALLOWED_SUBSCRIPTIONS - recordLimit;

            for(Object obj : subscriptionPayloads) {
                Map<String, Object> subscriptionMap = (Map<String,Object>)obj;
                String subscriptionType = (String)subscriptionMap.get('type');
                String recordId = (String)subscriptionMap.get('recordId');
                String objType = (String)subscriptionMap.get('objectType');
                String subscriptionId = (String)subscriptionMap.get('subscriptionId');
                Integer totalSubs = totalSubsByObjectOrRecord.get(objType);

                //get rid of dupes
                if(newSubIds.contains(subscriptionId)) {
                    continue;
                } else {
                    newSubIds.add(subscriptionId);
                }

                if(recordId != null) {
                    totalSubs += totalSubsByObjectOrRecord.get(recordId);
                }
                //we can't support more than 80 due to soql limits.
                if(totalSubs >= maxSubscriptionObjectUsers) {
                    res.statusCode = 500;

                    Map<String, Object> err = new Map<String, Object>{
                        'errMsg' => 'Too many subscriptions for ' + objType + ' or for record ' + recordId,
                        'subscriptionId' => subscriptionId
                    };

                    errors.add(err);
                    continue;
                }


                Subscription__c subscription = new Subscription__c(
                    Field__c = (String)subscriptionMap.get('field'),
                    Value__c = (String)subscriptionMap.get('value'),
                    Subscription_Id__c = subscriptionId,
                    Subscription_Type__c = subscriptionType,
                    Object_Type__c = objType,
                    Record_Id__c = recordId,
                    Workspace_Id__c = (String)subscriptionMap.get('workspaceId'),
                    Channel_Id__c = (String)subscriptionMap.get('channelId'),
                    Channel_Name__c = (String)subscriptionMap.get('channelName'),
                    User__c = (String)subscriptionMap.get('sfUserId')
                    );

                if(subscriptionType == constants.NOTIFICATION_TYPE_DATE_REACHED || subscriptionType == constants.NOTIFICATION_TYPE_DATE_OVERDUE) {
                    if(!recordIdsByObjType.containsKey(objType)) {
                        recordIdsByObjType.put(objType, new List<String>());
                    }

                    recordIdsByObjType.get(objType).add(String.escapeSingleQuotes(recordId));
                    subscriptionIdByRecordId.put(recordId, subscriptionId);
                }

                newSubscriptions.add(subscription);
            }

            Database.upsert(newSubscriptions, Subscription__c.Fields.Subscription_Id__c);

            publishDateForNewSubs(res);

            if(!errors.isEmpty()) {
                Map<String, Object> errorMap = new Map<String, Object>{
                    'errors' => errors
                };

                res.responseBody = Blob.valueOf(JSON.serialize(errorMap));
            }
        } catch (Exception e){
            handleException(e);
        }
    }

    private static void publishDateForNewSubs(RestResponse res){
        Map<String, Schema.SObjectType> globalDesc = Schema.getGlobalDescribe();
        List<Subscription_Event__e> dateEventsToPublish = new List<Subscription_Event__e>();
        //find all date records and publish a reminder for them immediately
        for(String objType : recordIdsByObjType.keySet()) {
            if(Limits.getQueries() == Limits.getLimitQueries()) {
                List<String> subIds = new List<String>();
                for(String recordId : recordIdsByObjType.get(objType)) {
                    subIds.add(subscriptionIdByRecordId.get(recordId));
                }

                res.statusCode = 500;

                Map<String, Object> err = new Map<String, Object>{
                    'errMsg' => 'Too many different object types at once. Failed to publish reminders',
                    'subscriptionIds' => subIds
                };

                errors.add(err);
            } else {
                List<String> recordIds = recordIdsByObjType.get(objType);
                List<String> allowedFields = new List<String>();
                Schema.DescribeSObjectResult describedObj = globalDesc.get(objType).getDescribe();

                if(!describedObj.isAccessible()) {
                    List<String> subIds = new List<String>();
                    for(String recordId : recordIdsByObjType.get(objType)) {
                        subIds.add(subscriptionIdByRecordId.get(recordId));
                    }

                    res.statusCode = 500;

                    Map<String, Object> err = new Map<String, Object>{
                        'errMsg' => 'No access to object ' + objType + '. Failed to publish date reminder',
                        'subscriptionIds' => subIds
                    };

                    errors.add(err);
                    continue;
                }

                Map<String, Schema.SObjectField> objFields = describedObj.fields.getMap();

                for(Schema.SObjectField field : objFields.values()) {
                    Schema.DescribeFieldResult describedField = field.getDescribe();
                    if(describedField.isAccessible()) {
                        allowedFields.add(describedField.getName());
                    }
                }

                String soqlQuery = 'SELECT ' + String.join(allowedFields, ', ') +
                    ' FROM ' + String.escapeSingleQuotes(objType) +
                    ' WHERE Id = :recordIds';

                for(sObject sObj : Database.query(soqlQuery)) {
                    Subscription_Event__e subscriptionEvent = new Subscription_Event__e(
                        Record_Data__c = JSON.serialize(sObj),
                        Subscription_Id__c = subscriptionIdByRecordId.get((String)sObj.get('Id')),
                        Action__c = ''
                        );

                    dateEventsToPublish.add(subscriptionEvent);
                }
            }
        }

        List<Database.SaveResult> results = EventBus.publish(dateEventsToPublish);

        for (Integer i = 0; i < results.size(); i++) {
            Database.SaveResult sr = results.get(i);

            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    res.statusCode = 500;

                    Map<String, Object> errMap = new Map<String, Object>{
                        'errMsg' => 'Failed to publish date reminder. Error returned: ' + err.getMessage(),
                        'subscriptionId' => dateEventsToPublish.get(i).Subscription_Id__c
                    };

                    errors.add(errMap);
                }
            }
        }
    }

    @HttpPatch
    global static void renameSubChannel(String channelId, String channelName) {
        try {
            checkAccess('updateSubscription');

            List<Subscription__c> subscriptions = [SELECT Id, Channel_Name__c
                                                   FROM Subscription__c
                                                   WHERE Channel_Id__c =: channelId];

            for(Subscription__C subscription : subscriptions) {
                subscription.Channel_Name__c = channelName;
            }

            update subscriptions;
        } catch(Exception e){
            handleException(e);
        }
    }

    @HttpDelete
    global static void deleteSubscription(){
        try {
            checkAccess('deleteSubscription');
            RestRequest req = RestContext.request;
            List<String> subIds = (List<String>)JSON.deserialize(req.requestBody.toString(), List<String>.class);

            delete [SELECT Id FROM Subscription__c WHERE Subscription_Id__c =: subIds];
        } catch (Exception e){
            handleException(e);
        }
    }

    private static final Map<String, Map<String, Map<String, Set<String>> >> ACCESS_MAP = new Map<String, Map<String, Map<String, Set<String>> >>{
        'createSubscription' => new Map<String, Map<String, Set<String>>> {
            'Subscription__c' => new Map<String, Set<String>> {
                'Create' => new Set<String> {
                    'Field__c', 'Value__c', 'Subscription_Id__c', 'Subscription_Type__c', 'Object_Type__c', 'Record_Id__c'
                }
            }
        },
        'deleteSubscription' => new Map<String, Map<String, Set<String>>> {
            'Subscription__c' => new Map<String, Set<String>> {
                'Delete' => new Set<String>()
            }
        },
        'updateSubscription' => new Map<String, Map<String, Set<String>>> {
            'Subscription__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Channel_Name__c'
                },
                'Update' => new Set<String> {
                    'Channel_Name__c'
                }
            }
        }
    };

    private static void checkAccess(String methodName) {
        dmlManager.checkAccess(ACCESS_MAP.get(methodName));
    }

    private static void handleException(Exception e){
        RestResponse res = RestContext.response;
        res.statusCode = 500;
        Map<String, Object> err = new Map<String, Object>{
            'errMsg' => e.getMessage(),
            'trace' => e.getStackTraceString()
        };

        Map<String, Object> errorMap = new Map<String, Object>{
            'errors' => new List<Object>{err}
        };

        res.responseBody = Blob.valueOf(JSON.serialize(errorMap));
    }
}