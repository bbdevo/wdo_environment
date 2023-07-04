public with sharing class slackAlerts {

    @AuraEnabled
    public static responseData getSubscriptions(String objectApiName, ID recordId, String channelId) {
        responseData rd = new responseData();
        try {
            checkAccess('getSubscriptions');
            List<Subscription__c> existingSubscriptions = [
                SELECT  Id, Subscription_Type__c, Field__c, Value__c, Record_Id__c, User__c, Channel_Id__c
                FROM    Subscription__c
                WHERE   Record_Id__c = :recordId
                AND     Channel_Id__c = :channelId
                AND     (
                            Subscription_Type__c <> :constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME
                        OR  (
                                Subscription_Type__c = :constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME
                            AND User__c = :UserInfo.getUserId()
                            )
                        )
            ];
            List<Map<String, Object>> subscriptions = subscriptionList(objectApiName);
            for (Subscription__c existingSubscription : existingSubscriptions) {

                // assigned to me
                if (existingSubscription.Subscription_Type__c == constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME) {
                    for (Object subscriptionTypeObject : subscriptions) {
                        Map<String, Object> subscriptionType = (Map<String, Object>)subscriptionTypeObject;
                        if (subscriptionType.get('type') == constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME) {
                            subscriptionType.put('existingId', existingSubscription.Id);
                            subscriptionType.put('checked', true);
                        }
                    }
                }

                // date overdue
                if (existingSubscription.Subscription_Type__c == constants.NOTIFICATION_TYPE_DATE_OVERDUE) {
                    for (Object subscriptionTypeObject : subscriptions) {
                        Map<String, Object> subscriptionType = (Map<String, Object>)subscriptionTypeObject;
                        if (subscriptionType.get('type') == constants.NOTIFICATION_TYPE_DATE_OVERDUE) {
                            if (subscriptionType.get('field') == existingSubscription.Field__c) {
                                subscriptionType.put('existingId', existingSubscription.Id);
                                subscriptionType.put('checked', true);
                            }
                        }
                    }
                }

                // date reached
                if (existingSubscription.Subscription_Type__c == constants.NOTIFICATION_TYPE_DATE_REACHED) {
                    for (Object subscriptionTypeObject : subscriptions) {
                        Map<String, Object> subscriptionType = (Map<String, Object>)subscriptionTypeObject;
                        if (subscriptionType.get('type') == constants.NOTIFICATION_TYPE_DATE_REACHED) {
                            if (subscriptionType.get('field') == existingSubscription.Field__c) {
                                subscriptionType.put('existingId', existingSubscription.Id);
                                subscriptionType.put('checked', true);
                            }
                        }
                    }
                }

                // field changed
                if (existingSubscription.Subscription_Type__c == constants.NOTIFICATION_TYPE_FIELD_CHANGED) {
                    for (Object subscriptionTypeObject : subscriptions) {
                        Map<String, Object> subscriptionType = (Map<String, Object>)subscriptionTypeObject;
                        if (subscriptionType.get('type') == constants.NOTIFICATION_TYPE_FIELD_CHANGED) {
                            if (subscriptionType.get('field') == existingSubscription.Field__c) {
                                subscriptionType.put('existingId', existingSubscription.Id);
                                subscriptionType.put('checked', true);
                            }
                        }
                    }
                }

                // field is value
                if (existingSubscription.Subscription_Type__c == constants.NOTIFICATION_TYPE_FIELD_IS_VALUE) {
                    for (Object subscriptionTypeObject : subscriptions) {
                        Map<String, Object> subscriptionType = (Map<String, Object>)subscriptionTypeObject;
                        if (subscriptionType.get('type') == constants.NOTIFICATION_TYPE_FIELD_IS_VALUE) {
                            if (subscriptionType.get('field') == existingSubscription.Field__c && subscriptionType.get('value') == existingSubscription.Value__c) {
                                subscriptionType.put('existingId', existingSubscription.Id);
                                subscriptionType.put('checked', true);
                            }
                        }
                    }
                }

                // opportunity won
                if (existingSubscription.Subscription_Type__c == constants.NOTIFICATION_TYPE_OPPORTUNITY_WON) {
                    for (Object subscriptionTypeObject : subscriptions) {
                        Map<String, Object> subscriptionType = (Map<String, Object>)subscriptionTypeObject;
                        if (subscriptionType.get('type') == constants.NOTIFICATION_TYPE_OPPORTUNITY_WON) {
                            subscriptionType.put('existingId', existingSubscription.Id);
                            subscriptionType.put('checked', true);
                        }
                    }
                }

            }
            rd.put('subscriptions', subscriptions);
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getStrippedResults();
    }

    @AuraEnabled
    public static responseData getExistingChannelNames(ID recordId, ID authId) {
        responseData rd = new responseData();
        try {
            checkAccess('getExistingChannelNames');

            Slack_Auth__c auth = [SELECT Workspace_Id__c FROM Slack_Auth__c WHERE Id = :authId];

            Set<String> existingChannelNames = new Set<String>();
            List<Subscription__c> subscriptions = [
                SELECT  Channel_Name__c
                FROM    Subscription__c
                WHERE   Record_Id__c = :recordId
                AND Workspace_Id__c = :auth.Workspace_Id__c
                AND     (
                            Subscription_Type__c <> :constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME
                        OR  (
                                Subscription_Type__c = :constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME
                                AND User__c = :UserInfo.getUserId()
                            )
                        )
            ];
            for (Subscription__c subscription : subscriptions) {
                existingChannelNames.add(subscription.Channel_Name__c);
            }
            rd.put('existingChannelNames', existingChannelNames);
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getStrippedResults();
    }

    @AuraEnabled
    public static responseData sendSubscriptionPayload(String selectedOptionsJson, String unselectedOptionsJson, String channelId, String channelName, ID recordId, String authId) {
        responseData rd = new responseData();
        try {
            checkAccess('sendSubscriptionPayloads');

            List<Object> selectedOptions = (List<Object>)JSON.deserializeUntyped(selectedOptionsJson);
            List<Object> unselectedOptions = (List<Object>)JSON.deserializeUntyped(unselectedOptionsJson);
            Slack_Auth__c auth = [SELECT Workspace_Id__c, Slack_User_Id__c FROM Slack_Auth__c WHERE Id = :authId];
            Set<String> subscriptionIdsToDelete = new Set<String>();

            // subscriptions to insert
            String postEndpoint = constants.SFDC_TO_SLACK_SUBSCRIPTION;
            String postMethod = 'POST';
            List<Map<String, Object>> postReqBody = new List<Map<String, Object>>();
            for (Object selectedOption : selectedOptions) {
                Map<String, Object> selectedOptionMap = (Map<String, Object>)selectedOption;
                if (selectedOptionMap.get('existingId') == null) {
                    String userId = selectedOptionMap.get('type') == constants.NOTIFICATION_TYPE_ASSIGNED_TO_ME ? UserInfo.getUserId() : null;
                    postReqBody.add(new Map<String, Object>{
                        'channelId' => channelId,
                        'channelName'=> channelName,
                        'field' => (String)selectedOptionMap.get('field'),
                        'objectType' => (String)selectedOptionMap.get('objectType'),
                        'recordId' => recordId,
                        'sfOrgId' => constants.ORG_ID,
                        'sfUserId' => userId,
                        'slackUserId' => auth.Slack_User_Id__c,
                        'type' => (String)selectedOptionMap.get('type'),
                        'value'  => (String)selectedOptionMap.get('value'),
                        'workspaceId' => auth.Workspace_Id__c
                    });
                }
            }

            // subscriptions to delete
            String deleteEndpoint = constants.SFDC_TO_SLACK_SUBSCRIPTION;
            String deleteMethod = 'DELETE';
            List<String> deleteReqBody = new List<String>();
            for (Object unselectedOption : unselectedOptions) {
                Map<String, Object> unselectedOptionMap = (Map<String, Object>)unselectedOption;
                if (unselectedOptionMap.get('existingId') != null) {
                    subscriptionIdsToDelete.add((String)unselectedOptionMap.get('existingId'));
                }
            }
            List<Subscription__c> subscriptionSlackIdsToDelete = [SELECT Id, Subscription_Id__c FROM Subscription__c WHERE Id IN :subscriptionIdsToDelete];
            for (Subscription__c subscriptionSlackIdToDelete : subscriptionSlackIdsToDelete) {
                deleteReqBody.add(subscriptionSlackIdToDelete.Subscription_Id__c);
            }

            // callouts
            if (!postReqBody.isEmpty()) {
                HttpResponse postResponse = utilities.makeCallout(postEndpoint, postMethod, JSON.serialize(postReqBody));
                if (postResponse.getStatusCode() != 200) {
                    if (postResponse.getBody().length() != 0) {
                        Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(postResponse.getBody());
                        if(resBody.containsKey('error')) {
                            rd.addError((String)resBody.get('error'));
                        }
                    } else {
                        rd.addError('unknown error');
                    }
                }
                rd.put('postResponse', postResponse.getBody());
            }
            if (!subscriptionSlackIdsToDelete.isEmpty()) {
                HttpResponse deleteResponse = utilities.makeCallout(deleteEndpoint, deleteMethod, JSON.serialize(deleteReqBody));
                if (deleteResponse.getStatusCode() != 200) {
                    if (deleteResponse.getBody().length() != 0) {
                        Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(deleteResponse.getBody());
                        if(resBody.containsKey('error')) {
                            rd.addError((String)resBody.get('error'));
                        }
                    } else {
                        rd.addError('unknown error');
                    }
                } else {
                    delete subscriptionSlackIdsToDelete;
                }
                rd.put('deletedSubscriptions', deleteResponse.getBody());
            }
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getStrippedResults();
    }

    @AuraEnabled
    public static void deleteAuth(String authId) {
        utilities.deleteAuth(authId);
    }

    public static List<Map<String, Object>> subscriptionList(String objectApiName) {
        List<Map<String, Object>> subscriptionList;
        switch on objectApiName {
            when 'Account' {
                subscriptionList = new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'objectType' => 'Account',
                        'label' => 'Account owner has changed',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_CHANGED,
                        'field' => 'OwnerId',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Task',
                        'label' => 'An email was sent',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
                        'field' => 'TaskSubtype',
                        'value' => 'Email',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Task',
                        'label' => 'A call was logged',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
                        'field' => 'TaskSubtype',
                        'value' => 'Call',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Event',
                        'label' => 'An event happened',
                        'type' => constants.NOTIFICATION_TYPE_DATE_REACHED,
                        'field' => 'EndDateTime',
                        'checked' => false
                    }
                };
            }
            when 'Contact' {
                subscriptionList = new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'objectType' => 'Contact',
                        'label' => 'Contact has left the company',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_CHANGED,
                        'field' => 'AccountId',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Contact',
                        'label' => 'Contact owner has changed',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_CHANGED,
                        'field' => 'OwnerId',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Task',
                        'label' => 'An email was sent',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
                        'field' => 'TaskSubtype',
                        'value' => 'Email',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Task',
                        'label' => 'A call was logged',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
                        'field' => 'TaskSubtype',
                        'value' => 'Call',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Event',
                        'label' => 'An event happened',
                        'type' => constants.NOTIFICATION_TYPE_DATE_REACHED,
                        'field' => 'EndDateTime',
                        'checked' => false
                    }
                };
            }
            when 'Lead' {
                subscriptionList = new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'objectType' => 'Lead',
                        'label' => 'Lead was converted',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_CHANGED,
                        'field' => 'IsConverted',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Lead',
                        'label' => 'Lead status has changed',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_CHANGED,
                        'field' => 'Status',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Lead',
                        'label' => 'Lead owner has changed',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_CHANGED,
                        'field' => 'OwnerId',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Task',
                        'label' => 'An email was sent',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
                        'field' => 'TaskSubtype',
                        'value' => 'Email',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Task',
                        'label' => 'A call was logged',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
                        'field' => 'TaskSubtype',
                        'value' => 'Call',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Event',
                        'label' => 'An event happened',
                        'type' => constants.NOTIFICATION_TYPE_DATE_REACHED,
                        'field' => 'EndDateTime',
                        'checked' => false
                    }
                };
            }
            when 'Case' {
                subscriptionList = new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'objectType' => 'Case',
                        'label' => 'Case status has changed',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_CHANGED,
                        'field' => 'Status',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Case',
                        'label' => 'Case priority had changed',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_CHANGED,
                        'field' => 'Priority',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Case',
                        'label' => 'Case owner has changed',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_CHANGED,
                        'field' => 'OwnerId',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Task',
                        'label' => 'An email was sent',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
                        'field' => 'TaskSubtype',
                        'value' => 'Email',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Task',
                        'label' => 'A call was logged',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
                        'field' => 'TaskSubtype',
                        'value' => 'Call',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Event',
                        'label' => 'An event happened',
                        'type' => constants.NOTIFICATION_TYPE_DATE_REACHED,
                        'field' => 'EndDateTime',
                        'checked' => false
                    }
                };
            }
            when 'Opportunity' {
                subscriptionList = new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'objectType' => 'Opportunity',
                        'label' => 'Opportunity stage changed to "Won"',
                        'type' => constants.NOTIFICATION_TYPE_OPPORTUNITY_WON,
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Opportunity',
                        'label' => 'Opportunity stage has changed',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_CHANGED,
                        'field' => 'StageName',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Opportunity',
                        'label' => 'Opportunity amount has changed',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_CHANGED,
                        'field' => 'Amount',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Opportunity',
                        'label' => 'Opportunity closes today',
                        'type' => constants.NOTIFICATION_TYPE_DATE_REACHED,
                        'field' => 'CloseDate',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Opportunity',
                        'label' => 'Opportunity close date has passed',
                        'type' => constants.NOTIFICATION_TYPE_DATE_OVERDUE,
                        'field' => 'CloseDate',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Opportunity',
                        'label' => 'Opportunity close date changed',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_CHANGED,
                        'field' => 'CloseDate',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Task',
                        'label' => 'An email was sent',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
                        'field' => 'TaskSubtype',
                        'value' => 'Email',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Task',
                        'label' => 'A call was logged',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_IS_VALUE,
                        'field' => 'TaskSubtype',
                        'value' => 'Call',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Event',
                        'label' => 'An event happened',
                        'type' => constants.NOTIFICATION_TYPE_DATE_REACHED,
                        'field' => 'EndDateTime',
                        'checked' => false
                    }
                };
            }
            when 'Task' {
                subscriptionList = new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'objectType' => 'Task',
                        'label' => 'Task is due today',
                        'type' => constants.NOTIFICATION_TYPE_DATE_REACHED,
                        'field' => 'ActivityDate',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Task',
                        'label' => 'Task due date has passed',
                        'type' => constants.NOTIFICATION_TYPE_DATE_OVERDUE,
                        'field' => 'ActivityDate',
                        'checked' => false
                    },
                    new Map<String, Object>{
                        'objectType' => 'Task',
                        'label' => 'Task status changed',
                        'type' => constants.NOTIFICATION_TYPE_FIELD_CHANGED,
                        'field' => 'Status',
                        'checked' => false
                    }
                };
            }
        }
        return subscriptionList;
    }

    private static final Map<String, Map<String, Map<String, Set<String>>>> ACCESS_MAP = new Map<String, Map<String, Map<String, Set<String>>>>{
        'getSubscriptions' => new Map<String, Map<String, Set<String>>> {
            'Subscription__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Subscription_Type__c', 'Field__c', 'Value__c', 'Record_Id__c', 'User__c', 'Channel_Id__c'
                }
            }
        },
        'getExistingChannelNames' => new Map<String, Map<String, Set<String>>> {
            'Subscription__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Channel_Name__c'
                }
            }
        },
        'sendSubscriptionPayloads' => new Map<String, Map<String, Set<String>>> {
            'Slack_Auth__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Workspace_Id__c', 'Slack_User_Id__c'
                }
            },
            'Subscription__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Subscription_Id__c'
                }
            }
        }
    };

    private static void checkAccess(String methodName) {
        dmlManager.checkAccess(ACCESS_MAP.get(methodName));
    }

}