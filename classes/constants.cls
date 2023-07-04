/*** Strike Toolbelt v2.0.0 ***/
public with sharing class constants {
    // Namespaces
    private static FINAL String thisString = String.valueOf(constants.class);
    private static FINAL List<String> thisStrings = thisString.split('[.]', 2);
    public static FINAL String NAMESPACE = thisStrings.size() > 1 ? thisStrings[0] : 'c';
    public static FINAL String NAMESPACE_API = NAMESPACE == 'c' ? '' : NAMESPACE + '__';

    // Sandbox identifcation
    private static FINAL Organization ORG = [SELECT Id, InstanceName, IsSandbox FROM Organization LIMIT 1];
    public static FINAL String ORG_ID = ORG.Id;
    public static FINAL String ORG_INSTANCE = ORG.InstanceName;
    public static FINAL Boolean IS_SANDBOX = ORG.IsSandBox;

    // oAuth callout urls
    public static FINAL Boolean HAS_MY_DOMAIN = System.URL.getOrgDomainUrl().toExternalForm().contains('my.salesforce');
    public static FINAL String SALESFORCE_ORG_DOMAIN = HAS_MY_DOMAIN ? System.URL.getOrgDomainUrl().toExternalForm() : 'https://' + ORG_INSTANCE + '.salesforce.com';
    public static FINAL String SALESFORCE_INSTANCE_URI = System.URL.getSalesforceBaseURL().toExternalForm();
    public static FINAL String SALESFORCE_BASE_URI = 'https://' + (IS_SANDBOX ? 'test' : 'login') + '.salesforce.com';
    public static FINAL String SALESFORCE_OAUTH_URI = SALESFORCE_BASE_URI + '/services/oauth2';

    // Blur
    public static FINAL String BLUR_STRING = '********';

    //Slack_Constants
    public static FINAL Boolean IS_DEV = NAMESPACE == 'c';
    public static FINAL List<String> HERO_OBJECTS = new List<String>{'Account', 'Contact', 'Case', 'Lead', 'Opportunity', 'Task'};
    public static FINAL List<String> SLACK_CUSTOM_OBJECTS = new List<String>{'Setup_Data__c', 'Setup_Settings__c', 'Slack_Auth__c', 'Setup_Configuration__mdt', 'Recent_Channel__c'};
    public static FINAL List<String> NOTIFICATION_TYPES = new List<String>{'Assigned to Me', 'Date Overdue', 'Date Reached', 'Field Changed', 'Field is Value', 'New', 'Opportunity Won'};
    public static FINAL String NOTIFICATION_TYPE_ASSIGNED_TO_ME = NOTIFICATION_TYPES[0];
    public static FINAL String NOTIFICATION_TYPE_DATE_OVERDUE = NOTIFICATION_TYPES[1];
    public static FINAL String NOTIFICATION_TYPE_DATE_REACHED = NOTIFICATION_TYPES[2];
    public static FINAL String NOTIFICATION_TYPE_FIELD_CHANGED = NOTIFICATION_TYPES[3];
    public static FINAL String NOTIFICATION_TYPE_FIELD_IS_VALUE = NOTIFICATION_TYPES[4];
    public static FINAL String NOTIFICATION_TYPE_NEW = NOTIFICATION_TYPES[5];
    public static FINAL String NOTIFICATION_TYPE_OPPORTUNITY_WON = NOTIFICATION_TYPES[6];
    public static FINAL Integer TOTAL_ALLOWED_SUBSCRIPTIONS = 85;

    public static FINAL List<String> INVALID_AUTH_TYPES = new List<String>{'invalid_auth', 'account_inactive', 'token_revoked'};

    // Slack_Endpoints
    public static FINAL String SLACK_BASE_URI = IS_DEV ? 'https://dev.slack.com/interop-apps-dev/salesforce' : 'https://slack.com/interop-apps/salesforce';
    public static FINAL String SLACK_USER_AUTH_CALLBACK = SLACK_BASE_URI + '/auth/callback/salesforce';
    public static FINAL String SFDC_TO_SLACK_OAUTH = SLACK_BASE_URI + '/hooks/salesforce/orgToken';
    public static FINAL String SFDC_TO_SLACK_MESSGE = SLACK_BASE_URI + '/hooks/salesforce/postMessage';
    public static FINAL String CHANNEL_SEARCH_BASE_URI = 'https://edgeapi.slack.com';
    public static FINAL String CHANNEL_SEARCH_TYPES = 'channel,user,mpim';
    public static FINAL String SFDC_TO_SLACK_SUBSCRIPTION = SLACK_BASE_URI + '/hooks/salesforce/subscriptions';
    public static FINAL String SLACK_AUTH_TEST_BASE_URI = 'https://slack.com/api/auth.test';
    public static FINAL String SLACK_SF_OAUTH_URL = SLACK_BASE_URI + '/auth/callback/salesforce/admin';

    public String getNamespace() {
        return constants.NAMESPACE;
    }

    public String getNamespaceApi() {
        return constants.NAMESPACE_API;
    }

    public constants() {
        // empty
    }

    public constants(ApexPages.StandardController sc) {
        // empty
    }

    public static String getClientId(){
        Map<String, Map<String, Set<String>>> accessChecks = new Map<String, Map<String, Set<String>>> {
            'Setup_Configuration__mdt' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'DeveloperName', 'Client_Id__c'
                }
            }
        };

        dmlManager.checkAccess(accessChecks);

        String clientId = '';

        if(IS_DEV){
            Setup_Configuration__mdt configData = [SELECT Id, Client_Id__c
                                                   FROM Setup_Configuration__mdt
                                                   WHERE DeveloperName = 'Slack_Dev'];

            clientId = configData.Client_Id__c;
        } else {
            Setup_Configuration__mdt configData = [SELECT Id, Client_Id__c
                                                   FROM Setup_Configuration__mdt
                                                   WHERE DeveloperName = 'Slack_Prod'];

            clientId = configData.Client_Id__c;
        }

        return clientId;
    }

    public static String getSigningSecret(){
        Map<String, Map<String, Set<String>>> accessChecks = new Map<String, Map<String, Set<String>>> {
            'Setup_Configuration__mdt' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'DeveloperName', 'Signing_Secret__c'
                }
            }
        };

        dmlManager.checkAccess(accessChecks);

        String signingSecret = '';

        if(IS_DEV){
            Setup_Configuration__mdt configData = [SELECT Id, Signing_Secret__c
                                                           FROM Setup_Configuration__mdt
                                                           WHERE DeveloperName = 'Slack_Dev'];

            signingSecret = configData.Signing_Secret__c;
        } else {
            Setup_Configuration__mdt configData = [SELECT Id, Signing_Secret__c
                                                           FROM Setup_Configuration__mdt
                                                           WHERE DeveloperName = 'Slack_Prod'];

            signingSecret = configData.Signing_Secret__c;
        }

        return signingSecret;
    }
}