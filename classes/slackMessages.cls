@RestResource(urlMapping='/slackMessages')
global with sharing class slackMessages {
    private static final Map<String, Map<String, Map<String, Set<String>>>> ACCESS_MAP = new Map<String, Map<String, Map<String, Set<String>>>>{
        'createMessage' => new Map<String, Map<String, Set<String>>> {
            'Slack_Message__c' => new Map<String, Set<String>> {
                'Create' => new Set<String> {
                    'Channel_Id__c', 'Channel_Name__c', 'Channel_Type__c', 'Content__c', 'Record_Id__c',
                    'Team_Id__c', 'Time_Stamp__c', 'User_Image_Url__c', 'User_Name__c', 'Message_Url__c'
                }
            }
        }
    };

    @HttpPost
    global static void createMessage() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            checkAccess('createMessage');

            List<Object> messages = (List<Object>)JSON.deserializeUntyped(req.requestBody.toString());
            List<Slack_Message__c> messagesToInsert = new List<Slack_Message__c>();
            for(Object message : messages) {
                Map<String, Object> messageMap = (Map<String, Object>)message;
                Slack_Message__c messageToInsert = new Slack_Message__c(
                    Channel_Id__c = (String)messageMap.get('channelId'),
                    Channel_Name__c = (String)messageMap.get('channelName'),
                    Channel_Type__c = (String)messageMap.get('channelType'),
                    Content__c = (String)messageMap.get('content'),
                    Message_Url__c = (String)messageMap.get('messageUrl'),
                    Record_Id__c = (String)messageMap.get('recordId'),
                    Team_Id__c = (String)messageMap.get('teamId'),
                    Time_Stamp__c = (Datetime)DateTime.newInstance(Long.valueOf((String)messageMap.get('timeStamp'))),
                    User_Image_Url__c = (String)messageMap.get('userImageUrl'),
                    User_Name__c = (String)messageMap.get('userName')
                );
                messagesToInsert.add(messageToInsert);
            }
            insert messagesToInsert;
        } catch (Exception e) {
            res.statusCode = 500;
            Map<String, Object> errorMap = new Map<String, Object>{
                'errors' => new List<String>{e.getMessage()},
                'trace' => e.getStackTraceString()
            };
            System.debug('*********************** ' + e.getMessage());
            res.responseBody = Blob.valueOf(JSON.serialize(errorMap));
        }
    }

    private static void checkAccess(String methodName) {
        dmlManager.checkAccess(ACCESS_MAP.get(methodName));
    }

}