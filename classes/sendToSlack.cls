public with sharing class sendToSlack {

    @AuraEnabled
    public static responseData getObjectData(Boolean isGlobal) {
        responseData rd = new responseData();
        try {
            List<Map<String, String>> listOfMapsOfObjectInfos = new List<Map<String, String>>();
            for (Schema.DescribeSobjectResult describedObject : Schema.describeSObjects(constants.HERO_OBJECTS)) {
                if(isGlobal && describedObject.getName() == 'Task'){
                    continue;
                }
                if (describedObject.isAccessible() && describedObject.isQueryable()) {
                    listOfMapsOfObjectInfos.add(new Map<String, String>{
                        'value' => describedObject.getName(),
                        'label' => describedObject.getLabel()
                    });
                }
            }
            rd.put('objects', listOfMapsOfObjectInfos);
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getStrippedResults();
    }

    @AuraEnabled
    public static responseData getPrimaryObjectNameField(String objectName) {
        responseData rd = new responseData();
        try {
            String nameField = getNameField(objectName);
            rd.put('nameField', nameField);
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getStrippedResults();
    }

    @AuraEnabled
    public static responseData searchRecords(String searchTerm, String objectName) {
        responseData rd = new responseData();
        try {
            String nameField = getNameField(objectName);
            checkAccess('searchRecords', objectName, nameField);

            String formattedSearchTerm = '%' + String.escapeSingleQuotes(searchTerm) + '%';
            String dynamicSOQL = '';
            dynamicSOQL += ' SELECT Id ';
            dynamicSOQL += ' ,      ' + nameField + ' ';
            dynamicSOQL += ' FROM   ' + String.escapeSingleQuotes(objectName) + ' ';
            dynamicSOQL += ' WHERE  ' + nameField    + ' LIKE :formattedSearchTerm ';
            dynamicSOQL += ' ORDER  BY ' + nameField;
            dynamicSOQL += ' LIMIT  5 ';

            rd.put('results', Database.query(dynamicSOQL));
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getStrippedResults();
    }

    @AuraEnabled
    public static responseData getRecordData(ID recordId, String objectName) {
        responseData rd = new responseData();
        try {
            String nameField = getNameField(objectName);
            checkAccess('getRecordData', objectName, nameField);

            String formattedRecordId = String.escapeSingleQuotes(recordId);
            String dynamicSOQL = '';
            dynamicSOQL += ' SELECT Id ';
            dynamicSOQL += ' ,      ' + nameField + ' ';
            dynamicSOQL += ' FROM   ' + recordId.getSobjectType() + ' ';
            dynamicSOQL += ' WHERE  Id = :formattedRecordId ';
            dynamicSOQL += ' LIMIT  1 ';
            rd.put('recordData', Database.query(dynamicSOQL));
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getStrippedResults();
    }

    @AuraEnabled
    public static responseData getRecentlyViewed(String objectName) {
        responseData rd = new responseData();
        try {
            checkAccess('getRecentlyViewed');

            List<RecentlyViewed> recentlyViewed = [
                SELECT  Id, Name
                FROM    RecentlyViewed
                WHERE   Type = :objectName
                ORDER   BY LastViewedDate DESC
                LIMIT   5
            ];

            rd.put('recentlyViewed', recentlyViewed);
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getStrippedResults();
    }

    @AuraEnabled
    public static responseData getAuthData() {
        responseData rd = new responseData();
        try {
            checkAccess('getAuthData');

            List<Map<String, String>> valueLabelMapList = new List<Map<String, String>>();
            List<Slack_Auth__c> auths = [
                SELECT  Id, Workspace__c, Is_Most_Recent__c
                FROM    Slack_Auth__c
                WHERE   User__c = :UserInfo.getUserId()
                ORDER   BY Is_Most_Recent__c DESC
            ];
            if (auths.size() > 0) {
                rd.put('mostRecentWorkspaceId', auths[0].Id);
            }
            for (Slack_Auth__c auth : auths) {
                valueLabelMapList.add(new Map<String, String>{
                    'value' => auth.Id,
                    'label' => auth.Workspace__c
                });
            }
            valueLabelMapList.add(new Map<String, String>{
                'value' => 'Add Workspace',
                'label' => 'Add Workspace',
                'icon' => 'utility:add'
            });

            rd.put('isUserAuthed', valueLabelMapList.size() > 1);
            rd.put('workspaceList', valueLabelMapList);
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getStrippedResults();
    }

    @AuraEnabled
    public static responseData getRecentChannels(ID slackAuthId, String types) {
        responseData rd = new responseData();
        try {
            checkAccess('getRecentChannels');
            if (!Test.isRunningTest()) {
                utilities.checkValidAuth(slackAuthId);
            }

            Integer noResultsLimit = 20;
            List<Object> picklistValues = new List<Object>();
            List<Map<String, Object>> options = new List<Map<String, Object>>();
            String optGroupLabel = 'Recent Channels';
            List<String> typesList = types.split(',');
            for (Recent_Channel__c channel : [
                SELECT  Id, Name, Channel_Id__c, Type__c, Slack_Auth__r.Workspace__c
                FROM    Recent_Channel__c
                WHERE   OwnerId = :UserInfo.getUserId()
                AND     Slack_Auth__r.Id = :slackAuthId
                AND     Type__c IN :typesList
                ORDER   BY CreatedDate DESC
            ]) {
                String icon = '';

                if(channel.Type__c == 'channel'){
                    icon = 'utility:topic2';
                } else if (channel.Type__c == 'mpim') {
                    icon = 'utility:groups';
                } else {
                    icon = 'utility:user';
                }

                options.add(new Map<String, Object>{
                    'value' => channel.Channel_Id__c + '|' + channel.Type__c,
                    'label' => channel.Name,
                    'icon' => icon
                });
            }

            if (options.isEmpty()) {
                List<Object> resultList = (List<Object>)searchSlackChannels('', slackAuthId, noResultsLimit, types, false).results.get('response');
                for (Object result : resultList) {
                    Map<String, Object> resultMap = (Map<String, Object>)result;
                    options.add(resultMap);
                }
                // options.addAll(resultList);
                optGroupLabel = types.contains('user') || types.contains('mpim') ? 'Suggested Channels or People' : 'Suggested Channels';
            }

            Map<String, Object> optGroup = new Map<String, Object>{
                'isOptGroup' => true,
                'label' => optGroupLabel
            };
            optGroup.put('options', options);
            picklistValues.add(optGroup);
            rd.put('recentChannels', picklistValues);
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getStrippedResults();
    }

    @AuraEnabled
    public static responseData sendMessage(String message, String channelId, String channelType, String slackAuthId, Id recordId) {
        responseData rd = new responseData();
        try {
            checkAccess('sendMessage');
            if (!Test.isRunningTest()) {
                utilities.checkValidAuth(slackAuthId);
            }

            Slack_Auth__c auth = [
                SELECT  Id, Access_Token__c, Workspace_Id__c, Slack_User_Id__c
                FROM    Slack_Auth__c
                WHERE   Id = :slackAuthId
            ];

            String escapedRecordId = String.escapeSingleQuotes(recordId);
            String objType = recordId.getSobjectType() + '';
            Schema.DescribeSObjectResult describedObj = Schema.getGlobalDescribe().get(objType).getDescribe();

            if(!describedObj.isAccessible() && !describedObj.isQueryable()) {
                rd.addError('Invalid access to object ' + objType);
                return rd.getStrippedResults();
            }

            Map<String, Schema.SObjectField> fieldMap = describedObj.fields.getMap();
            String soqlQuery = 'SELECT ';

            for(Schema.SObjectField field : fieldMap.values()) {
                Schema.DescribeFieldResult describedField = field.getDescribe();
                if(describedField.isAccessible()) {
                    soqlQuery += describedField.getName() + ', ';
                }
            }

            soqlQuery = soqlQuery.removeEnd(', ');
            soqlQuery += ' FROM ' + objType;
            soqlQuery += ' WHERE Id = :escapedRecordId';

            sObject recordData = Database.query(soqlQuery);

            String token = !Test.isRunningTest() ? utilities.decryptValue(auth.Access_Token__c) : 'token';
            String endpoint = constants.SFDC_TO_SLACK_MESSGE;
            String method = 'POST';
            String reqBody = JSON.serialize(new Map<String, Object>{
                'orgId' => constants.ORG_ID,
                'userId' => UserInfo.getUserId(),
                'message' => message,
                'objectType' => objType,
                'recordData' => recordData,
                'workspaceId' => auth.Workspace_Id__c,
                'slackUserId' => auth.Slack_User_Id__c,
                'channelId' => channelId,
                'channelType' => channelType
            });
            Map<String, String> headers = new Map<String, String>{
                'Authorization' => token
            };
            HttpResponse res = utilities.makeCallout(endPoint, method, reqBody, headers);
            rd.put('result', res.getBody());
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getStrippedResults();
    }

    @AuraEnabled
    public static responseData searchSlackChannels(String query, String slackAuthId, Integer count, String types, Boolean dml) {
        responseData rd = new responseData();
        try{
            checkAccess('searchSlackChannels');
            if (!Test.isRunningTest()) {
                utilities.checkValidAuth(slackAuthId);
            }
            Boolean updateAuth = false;

            List<Map<String, String>> searchResults = new List<Map<String, String>>();
            Slack_Auth__c auth = [
                SELECT  Id, Access_Token__c, Workspace_Id__c, Object_Search_Url__c, Object_Search_Url_Expiration_Date_Time__c
                FROM    Slack_Auth__c
                WHERE   Id = :slackAuthId
            ];
            String endpoint;
            if (auth.Object_Search_Url__c == null || auth.Object_Search_Url_Expiration_Date_Time__c < Datetime.now()) {
                auth = !Test.isRunningTest() ? utilities.getObjectSearchUrl(auth) : auth;
                endpoint = auth.Object_Search_Url__c;
                updateAuth = true;
            } else {
                endpoint = auth.Object_Search_Url__c;
            }
            endpoint += '/objects/search';
            String token = !Test.isRunningTest() ? utilities.decryptValue(auth.Access_Token__c) : 'token';
            String method = 'POST';
            String reqBody = JSON.serialize(new Map<String, Object>{
                'token' => token,
                'query' => query,
                'types' => types,
                'count' => count
            });
            HttpResponse res = utilities.makeCallout(endpoint, method, reqBody);
            Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            Set<String> resultTypes = new Set<String>{'users', 'mpims', 'channels'};

            for(String key : resultTypes){
                if(resBody.containsKey(key)){
                    searchResults.addAll(processSearchResult(key, resBody));
                }
            }
            if (dml) {
                if (updateAuth) {
                    update auth;
                }
            }
            rd.put('response', searchResults);
        } catch(Exception e){
            rd.addError(e);
        }

        return rd.getStrippedResults();
    }

    @AuraEnabled
    public static responseData updateMostRecentWorkspace(ID slackAuthId) {
        responseData rd = new responseData();
        try {
            checkAccess('updateMostRecentWorkspace');

            Slack_Auth__c auth = [SELECT Id, Is_Most_Recent__c FROM Slack_Auth__c WHERE Id = :slackAuthId];
            auth.Is_Most_Recent__c = true;
            update auth;
        } catch(Exception e) {
            rd.addError(e);
        }
        return rd.getStrippedResults();
    }

    @AuraEnabled
    public static responseData createRecentChannel(String name, ID slackAuthId, String channelId, String type) {
        responseData rd = new responseData();
        try {
            checkAccess('createRecentChannel');

            Recent_Channel__c channel = new Recent_Channel__c();
            channel.Name = name;
            channel.Slack_Auth__c = slackAuthId;
            channel.Channel_Id__c = channelId;
            channel.Type__c = type;
            insert channel;
        } catch(Exception e) {
            rd.addError(e);
        }
        return rd.getStrippedResults();
    }

    @AuraEnabled
    public static void deleteAuth(String authId) {
        utilities.deleteAuth(authId);
    }


    private static List<Map<String, String>> processSearchResult(String key, Map<String, Object> resBody){
        String icon = '';

        if(key == 'channels'){
            icon = 'utility:topic2';
        } else if (key == 'mpims') {
            icon = 'utility:groups';
        } else {
            icon = 'utility:user';
        }

        List<Map<String, String>> options = new List<Map<String, String>>();

        List<Object> searchResults = (List<Object>)resBody.get(key);
        for(Object result : searchResults) {
            Map<String, Object> resultMap = (Map<String, Object>)result;

            if(resultMap.containsKey('is_bot') && resultMap.get('is_bot') != null){
                if(Boolean.valueOf(resultMap.get('is_bot'))){
                    continue;
                }
            }

            String label = 'Unnamed ' + key.removeEnd('s');

            if(resultMap.containsKey('real_name')){
                label = resultMap.get('real_name').toString();
            } else if(resultMap.containsKey('name')){
                label = resultMap.get('name').toString();
            }
            
            Map<String, String> option = new Map<String, String>{
                'label' => label,
                'value' => resultMap.get('id').toString() + '|' + key.removeEnd('s'),
                'icon' => icon
            };

            options.add(option);
        }

        return options;
    }

    public static String getNameField(String objectName) {
        checkAccess('getNameField');

        String nameField = [
            SELECT  QualifiedApiName
            FROM    FieldDefinition
            WHERE   EntityDefinition.QualifiedApiName = :objectName
            AND     IsNameField = true
        ].QualifiedApiName;
        return nameField;
    }

    private static Map<String, Map<String, Map<String, Set<String>>>> dynamicAccessMap(String objectName, String fieldName) {
        return new Map<String, Map<String, Map<String, Set<String>>>> {
            'searchRecords' => new Map<String, Map<String, Set<String>>>{
                objectName => new Map<String, Set<String>> {
                    'Read' => new Set<String> {
                        'Id', fieldName
                    }
                }
            },
            'getRecordData' => new Map<String, Map<String, Set<String>>>{
                objectName => new Map<String, Set<String>> {
                    'Read' => new Set<String> {
                        'Id', fieldName
                    }
                }
            }
        };
    }

    private static final Map<String, Map<String, Map<String, Set<String>>>> ACCESS_MAP = new Map<String, Map<String, Map<String, Set<String>>>>{
        'getRecentlyViewed' => new Map<String, Map<String, Set<String>>> {
            'RecentlyViewed' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Name'
                }
            }
        },
        'getAuthData' => new Map<String, Map<String, Set<String>>> {
            'Slack_Auth__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Workspace__c', 'Is_Most_Recent__c', 'User__c'
                }
            }
        },
        'getRecentChannels' => new Map<String, Map<String, Set<String>>> {
            'Recent_Channel__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Name', 'Channel_Id__c', 'Type__c', 'Slack_Auth__c', 'CreatedDate'
                }
            },
            'Slack_Auth__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Workspace__c'
                }
            }
        },
        'sendMessage' => new Map<String, Map<String, Set<String>>> {
            'Slack_Auth__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Access_Token__c', 'Workspace_Id__c', 'Slack_User_Id__c'
                }
            }
        },
        'searchSlackChannels' => new Map<String, Map<String, Set<String>>> {
            'Slack_Auth__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Access_Token__c', 'Workspace_Id__c', 'Object_Search_Url__c', 'Object_Search_Url_Expiration_Date_Time__c'
                },
                'Update' => new Set<String>{
                    'Object_Search_Url__c', 'Object_Search_Url_Expiration_Date_Time__c'
                }
            }
        },
        'getNameField' => new Map<String, Map<String, Set<String>>> {
            'FieldDefinition' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'QualifiedApiName', 'IsNameField'
                }
            },
            'EntityDefinition' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'QualifiedApiName'
                }
            }
        },
        'updateMostRecentWorkspace' => new Map<String, Map<String, Set<String>>> {
            'Slack_Auth__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Is_Most_Recent__c'
                },
                'Update' => new Set<String>{
                    'Is_Most_Recent__c'
                }
            }
        },
        'createRecentChannel' => new Map<String, Map<String, Set<String>>> {
            'Recent_Channel__c' => new Map<String, Set<String>> {
                'Create' => new Set<String> {
                    'Name', 'Slack_Auth__c', 'Channel_Id__c', 'Type__c'
                }
            }
        }
    };

    private static void checkAccess(String methodName) {
        dmlManager.checkAccess(ACCESS_MAP.get(methodName));
    }

    private static void checkAccess(String methodName, String objectName, String fieldName) {
        dmlManager.checkAccess(dynamicAccessMap(objectName, fieldName).get(methodName));
    }

}