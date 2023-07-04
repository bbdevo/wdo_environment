public with sharing class messageViewer {

    @AuraEnabled
    public static responseData getRelatedMessages(ID recordId, Integer limitBy) {
        responseData rd = new responseData();
        try {
            checkAccess('getRelatedMessages');
            
            List<Map<String, Object>> messageMapList = new List<Map<String,Object>>();
            List<Slack_Message__c> messages = [
                SELECT  Id, Name, Channel_Name__c, User_Name__c, Content__c, Time_Stamp__c, User_Image_Url__c, Record_Id__c, Channel_Id__c, Team_Id__c, Message_Url__c
                FROM    Slack_Message__c
                WHERE   Record_Id__c = :recordId
                ORDER   BY Time_Stamp__c DESC
                LIMIT   :limitBy
            ];
            for (Slack_Message__c message : messages) {
                Map<String, Object> messageMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(message));
                String dateFormatString = message.Time_Stamp__c.date() == Date.today() ? 'h:mm a' : 'M/d/yyyy, h:mm a';
                messageMap.put('formattedTimeStamp', message.Time_Stamp__c.format(dateFormatString));
                messageMapList.add(messageMap);
            }
            rd.put('empty', messages.isEmpty());
            rd.put('allLoaded', messageMapList.size() < limitBy);
            rd.put('messages', messageMapList);
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getStrippedResults();
    }

    private static final Map<String, Map<String, Map<String, Set<String>>>> ACCESS_MAP = new Map<String, Map<String, Map<String, Set<String>>>>{
        'getRelatedMessages' => new Map<String, Map<String, Set<String>>> {
            'Slack_Message__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Name', 'Channel_Name__c', 'User_Name__c', 'Content__c', 'Time_Stamp__c', 'User_Image_Url__c', 'Record_Id__c', 'Channel_Id__c', 'Team_Id__c', 'Message_Url__c'
                }
            }
        }
    };

    private static void checkAccess(String methodName) {
        dmlManager.checkAccess(ACCESS_MAP.get(methodName));
    }

}