public with sharing class utilities {
    public static sObject getSobjectByMap(Map<String, Object> sourceMap, String sObjectName) {
        return getSobjectByMap(sourceMap, sObjectName, constants.NAMESPACE_API);
    }

    /*
        Takes in a map and converts it into the specified sObject type.
        This function will strip away any keys that don't match a field on the sObject
        so you don't have to worry about it being dirty.
    */
    public static sObject getSobjectByMap(Map<String, Object> sourceMap, String sObjectName, String namespace) {
        if (!Schema.getGlobalDescribe().containsKey(sObjectName)) {
            if (Schema.getGlobalDescribe().containsKey(namespace + sObjectName)) {
                sObjectName = namespace + sObjectName;
            } else {
                return null;
            }
        }

        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        Map<String, Object> objMap = new Map<String, Object>();

        for (String field : sourceMap.keySet()) {
            String value = String.valueOf(sourceMap.get(field));

            //only retain the value if it exists on our object
            if (!fieldMap.containsKey(field)) {
                if (fieldMap.containsKey(namespace + field)) {
                    field = namespace + field;
                } else {
                    continue;
                }
            }

            objMap.put(field, String.isEmpty(value) ? null : value);
        }

        return (sObject)JSON.deserialize(JSON.serialize(objMap), Type.forName(sObjectName));
    }

    public static HttpResponse makeCallout(String endPoint, String method){
        return makeCallout(endPoint, method, null, null);
    }

    public static HttpResponse makeCallout(String endPoint, String method, String body){
        return makeCallout(endPoint, method, body, null);
    }

    public static HttpResponse makeCallout(String endPoint, String method, Map<String, String> headers){
        return makeCallout(endPoint, method, null, headers);
    }

    public static HttpResponse makeCallout(String endPoint, String method, String body, Map<String, String> headers){
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint(endPoint);
        req.setMethod(method);
        req.setTimeout(60000);

        if(body != null) {
            req.setHeader('Content-Type', 'application/json');
            req.setBody(body);
        }

        // System.debug('************* endPonit ' + endPoint);
        // System.debug('************* headers ' + headers);
        // System.debug('************* body ' + body);
        if(headers != null) {
            for(String header : headers.keySet()) {
                req.setHeader(header, headers.get(header));
            }
        }

        HttpResponse res = h.send(req);

        // System.debug('************* res ' + res.getStatusCode());
        // System.debug('************* res ' + res.getBody());

        return res;
    }

    public static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();

        return service;
    }

    public static void generateEncryptionKey(){
        Map<String, Map<String, Set<String>>> accessChecks = new Map<String, Map<String, Set<String>>> {
            'Setup_Settings__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Encryption_Key__c'
                },
                'Create' => new Set<String> {
                    'Encryption_Key__c'
                },
                'Update' => new Set<String> {
                    'Encryption_Key__c'
                }
            }
        };

        dmlManager.checkAccess(accessChecks);

        Setup_Settings__c setupSettings = Setup_Settings__c.getOrgDefaults();

        if(setupSettings.Encryption_Key__c == null){
            Blob keyBlob = Crypto.generateAesKey(256);
            setupSettings.Encryption_Key__c = EncodingUtil.base64Encode(keyBlob);
            upsert setupSettings;
        }
    }

    public static Blob getEncryptionKey(){
        Map<String, Map<String, Set<String>>> accessChecks = new Map<String, Map<String, Set<String>>> {
            'Setup_Settings__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Encryption_Key__c'
                }
            }
        };

        dmlManager.checkAccess(accessChecks);

        Setup_Settings__c setupSettings = Setup_Settings__c.getOrgDefaults();
        return EncodingUtil.base64Decode(setupSettings.Encryption_Key__c);
    }

    public static String encryptValue(String value){
        Blob cryptoKey = getEncryptionKey();
        Blob data = Blob.valueOf(value);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, data);

        return EncodingUtil.base64Encode(encryptedData);
    }

    public static String decryptValue(String value){
        Blob cryptoKey = getEncryptionKey();
        Blob encryptedData = EncodingUtil.base64Decode(value);
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encryptedData);

        return decryptedData.toString();
    }

    public static void checkValidAuth(String authId) {
        Map<String, Map<String, Set<String>>> accessChecks = new Map<String, Map<String, Set<String>>> {
            'Slack_Auth__c' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Access_Token__c'
                }
            }
        };
        dmlManager.checkAccess(accessChecks);

        Slack_Auth__c auth = [
            SELECT  Id
            ,       Access_Token__c
            FROM    Slack_Auth__c
            WHERE   Id = :authId
        ];

        String token = !Test.isRunningTest() ? decryptValue(auth.Access_Token__c) : 'token';
        String endpoint = constants.SLACK_AUTH_TEST_BASE_URI + '?token=' + token;
        String method = 'POST';
        HttpResponse res = makeCallout(endPoint, method);
        if (res.getBody() != '') {
            Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            if(resBody.containsKey('error')) {
                String errorType = (String)resBody.get('error');
                if (constants.INVALID_AUTH_TYPES.contains(errorType)) {
                    CalloutException e = new CalloutException();
                    e.setMessage('Invalid Auth');
                    throw e;
                }
            }
        }
    }

    public static Slack_Auth__c getObjectSearchUrl(Slack_Auth__c auth) {
        Map<String, Map<String, Set<String>>> accessChecks = new Map<String, Map<String, Set<String>>> {
            'Slack_Auth__c' => new Map<String, Set<String>> {
                'Update' => new Set<String>{
                    'Object_Search_Url__c', 'Object_Search_Url_Expiration_Date_Time__c'
                }
            }
        };
        dmlManager.checkAccess(accessChecks);

        String token = !Test.isRunningTest() ? utilities.decryptValue(auth.Access_Token__c) : 'token';
        String endpoint = 'https://slack.com/api/api.getFlannelHttpUrl?token=' + token;
        String method = 'POST';
        HttpResponse res = makeCallout(endpoint, method);
        Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        String url = (String)resBody.get('url');
        Integer expirationSeconds = (Integer)resBody.get('ttl_seconds');
        Datetime expirationDatetime = Datetime.now().addSeconds(expirationSeconds);
        auth.Object_Search_Url__c = url;
        auth.Object_Search_Url_Expiration_Date_Time__c = expirationDatetime;
        return auth;
    }

    public static void deleteAuth(String authId) {
        Map<String, Map<String, Set<String>>> accessChecks = new Map<String, Map<String, Set<String>>> {
            'Slack_Auth__c' => new Map<String, Set<String>> {
                'Delete' => new Set<String>()
            }
        };
        dmlManager.checkAccess(accessChecks);
        Slack_Auth__c auth = [SELECT Id FROM Slack_Auth__c WHERE Id = :authId];
        delete auth;
    }

    public static void publishTriggerSubError(Map<Id, sObject> newMap, Map<Id, sObject> oldMap, String message){
        String recordIds = '';

        if(newMap != null){
            recordIds = String.join(new List<Id>(trigger.newMap.keySet()), ',');
        } else if(oldMap != null){
            recordIds = String.join(new List<Id>(trigger.oldMap.keySet()), ',');
        }

        List<Subscription_Error__e> subscriptionErrors = new List<Subscription_Error__e>{
            new Subscription_Error__e(
                Error__c = message + '\nRecords: ' + recordIds
            )
        };

        EventBus.publish(subscriptionErrors);
    }
}