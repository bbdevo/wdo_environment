public with sharing class sfdcAuthStep {
    public static String endpoint = constants.SFDC_TO_SLACK_OAUTH;
    public static String method = 'POST';

    // callback uri is same as class name
    public static String redirectUri = constants.SLACK_SF_OAUTH_URL;

    public String getOrigin() {
        return constants.SALESFORCE_INSTANCE_URI;
    }

    @AuraEnabled
    public static String getData() {
        responseData rd = new responseData();

        try {
            checkAccess();

            String postMessageKey = String.valueOf(Crypto.getRandomInteger());

            Setup_Configuration__mdt setupConfiguration = [SELECT Id, Client_Id__c
                                                           FROM Setup_Configuration__mdt
                                                           WHERE DeveloperName = 'SFDC'];

            rd.put('isSandbox', constants.IS_SANDBOX);
            rd.put('namespace', constants.NAMESPACE == 'c' ? '' : constants.NAMESPACE);
            rd.put('oauthUri', getOauthUri(postMessageKey, setupConfiguration.Client_Id__c));
            rd.put('postMessageKey', postMessageKey);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }
    /*no longer used as Slack is handling the auth*/
    // @AuraEnabled
    // public static String sendAuthPayload(String jsonString) {
    //     responseData rd = new responseData();
    //
    //     try {
    //         checkAccess();
    //
    //         Setup_Configuration__mdt setupConfiguration = [SELECT Id, Client_Id__c, Client_Secret__c
    //                                                        FROM Setup_Configuration__mdt
    //                                                        WHERE DeveloperName = 'SFDC'];
    //
    //         Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
    //         String code = (String)params.get('code');
    //
    //         String refreshToken = getRefreshToken(code, setupConfiguration);
    //
    //         sendRefreshToken(refreshToken);
    //
    //         setupAssistant.saveSetupData(new Setup_Data__c(
    //                                          SFDC_Auth_Step_Completed__c = true
    //                                          ));
    //     } catch (Exception e) {
    //         rd.addError(e);
    //     }
    //
    //     return rd.getJsonString();
    // }
    //
    // private static void sendRefreshToken(String refreshToken) {
    //     if (endpoint == '' ||  method == '') {
    //         return;
    //     }
    //
    //     HttpRequest req = new HttpRequest();
    //     req.setEndpoint(endpoint);
    //     req.setMethod(method);
    //
    //     Map<String, Object> payload = new Map<String, Object> {
    //         'isSandbox' => constants.IS_SANDBOX,
    //         'namespace' => constants.NAMESPACE == 'c' ? '' : constants.NAMESPACE,
    //         'orgId' => constants.ORG_ID,
    //         'orgInstance' => 'https://' + constants.ORG_INSTANCE + '.salesforce.com',
    //         'refreshToken' => refreshToken
    //     };
    //
    //     String signature = 'v0:' + System.now().getTime()/1000 + ':' + JSON.serialize(payload);
    //     Blob encryptedValue = Crypto.generateMac('hmacSHA256', Blob.valueOf(signature), Blob.valueOf(constants.getSigningSecret()));
    //     payload.put('signature', EncodingUtil.convertToHex(encryptedValue));
    //
    //     req.setBody(JSON.serialize(payload));
    //     req.setHeader('Content-Type', 'application/json');
    //
    //     HttpResponse res = (new Http()).send(req);
    //
    //     if (200 == res.getStatusCode()) {
    //         return;
    //     }
    //
    //     throw new CalloutException(res.getStatus());
    // }

    private static String getOauthUri(String postMessageKey, String clientId) {
        String responseType = 'code';

        String oauthUri = String.format('/services/oauth2/authorize?client_id={0}&redirect_uri={1}&response_type={2}', new List<String> {
            clientId,
            redirectUri,
            responseType
        });

        return oauthUri;
    }

    // private static String getRefreshToken(String code, Setup_Configuration__mdt setupConfiguration) {
    //     String endpoint = constants.SALESFORCE_OAUTH_URI +'/token';
    //     String method = 'POST';
    //     String reqBody = String.format('code={0}&client_id={1}&client_secret={2}&grant_type={3}&redirect_uri={4}', new List<String> {
    //         code,
    //         setupConfiguration.Client_Id__c,
    //         setupConfiguration.Client_Secret__c,
    //         'authorization_code',
    //         redirectUri
    //     });
    //
    //     HttpRequest req = new HttpRequest();
    //     req.setEndpoint(endpoint);
    //     req.setMethod(method);
    //     req.setBody(reqBody);
    //
    //     HttpResponse res = (new Http()).send(req);
    //     Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
    //
    //     if (200 == res.getStatusCode()) {
    //         return (String)resBody.get('refresh_token');
    //     }
    //
    //     throw new CalloutException((String)resBody.get('error_description'));
    // }

    private static Map<String, Map<String, Set<String>>> accessChecks = new Map<String, Map<String, Set<String>>> {
        'Setup_Configuration__mdt' => new Map<String, Set<String>> {
            'Read' => new Set<String> {
                'Id', 'DeveloperName', 'Client_Id__c', 'Client_Secret__c', 'Signing_Secret__c'
            }
        }
    };

    private static void checkAccess(){
        dmlManager.checkAccess(accessChecks);
    }
}