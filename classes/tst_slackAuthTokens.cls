@isTest
public class tst_slackAuthTokens {
    @testSetup static void setupData() {
        utilities.generateEncryptionKey();
    }

    @isTest static void sendSlackTokens() {
        List<Map<String, Object>> payload = new List<Map<String, Object>>{
            new Map<String, Object>{
                'sfOrgId' => UserInfo.getOrganizationId(),
                'slackWorkspaceId' => 'slackWorkspaceId',
                'sfUserId' => UserInfo.getUserId(),
                'accessToken' => 'accessToken',
                'slackWorkspaceName' => 'slackWorkspaceName',
                'slackUserId' => 'slackUserId'
            }
        };

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(JSON.serialize(payload));
        RestContext.request = req;

        Test.startTest();
        slackAuthTokens.saveAuthTokens();
        Test.stopTest();

        Slack_Auth__c authToken = [SELECT Id, Access_Token__c, Workspace_Id__c, Workspace__c, User__c, Slack_User_Id__c
                                   FROM Slack_Auth__c];

        System.assertEquals('accessToken', utilities.decryptValue(authToken.Access_Token__c));
        System.assertEquals('slackWorkspaceId', authToken.Workspace_Id__c);
        System.assertEquals('slackWorkspaceName', authToken.Workspace__c);
        System.assertEquals(UserInfo.getUserId(), authToken.User__c);
        System.assertEquals('slackUserId', authToken.Slack_User_Id__c);
    }

    @isTest static void handleDuplicateTokens() {
        Slack_Auth__c existingAuth = new Slack_Auth__c(
            Workspace_Id__c = 'slackWorkspaceId',
            User__c = UserInfo.getUserId(),
            Access_Token__c = 'accessToken',
            Workspace__c = 'slackWorkspaceName',
            Slack_User_Id__c = 'slackUserId'
            );

        insert existingAuth;

        List<Map<String, Object>> payload = new List<Map<String, Object>>{
            new Map<String, Object>{
                'sfOrgId' => UserInfo.getOrganizationId(),
                'slackWorkspaceId' => 'slackWorkspaceId',
                'sfUserId' => UserInfo.getUserId(),
                'accessToken' => 'token2',
                'slackWorkspaceName' => 'slackWorkspaceName',
                'slackUserId' => 'slackUserId'
            }
        };

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(JSON.serialize(payload));
        RestContext.request = req;

        Test.startTest();
        slackAuthTokens.saveAuthTokens();
        Test.stopTest();

        Slack_Auth__c authToken = [SELECT Id, Access_Token__c, Workspace_Id__c, Workspace__c, User__c, Slack_User_Id__c
                                   FROM Slack_Auth__c
                                   WHERE Id =: existingAuth.Id];

        System.assertEquals('token2', utilities.decryptValue(authToken.Access_Token__c));
        System.assertEquals('slackWorkspaceId', authToken.Workspace_Id__c);
        System.assertEquals('slackWorkspaceName', authToken.Workspace__c);
        System.assertEquals(UserInfo.getUserId(), authToken.User__c);
        System.assertEquals('slackUserId', authToken.Slack_User_Id__c);
    }

    @isTest static void handleDuplicateTokensInPayload() {
        Slack_Auth__c existingAuth = new Slack_Auth__c(
            Workspace_Id__c = 'slackWorkspaceId',
            User__c = UserInfo.getUserId(),
            Access_Token__c = 'accessToken',
            Workspace__c = 'slackWorkspaceName',
            Slack_User_Id__c = 'slackUserId'
            );

        insert existingAuth;

        List<Map<String, Object>> payload = new List<Map<String, Object>>{
            new Map<String, Object>{
                'sfOrgId' => UserInfo.getOrganizationId(),
                'slackWorkspaceId' => 'slackWorkspaceId',
                'sfUserId' => UserInfo.getUserId(),
                'accessToken' => 'token2',
                'slackWorkspaceName' => 'slackWorkspaceName',
                'slackUserId' => 'slackUserId'
            },
            new Map<String, Object>{
                'sfOrgId' => UserInfo.getOrganizationId(),
                'slackWorkspaceId' => 'slackWorkspaceId',
                'sfUserId' => UserInfo.getUserId(),
                'accessToken' => 'token3',
                'slackWorkspaceName' => 'slackWorkspaceName',
                'slackUserId' => 'slackUserId'
            }
        };

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(JSON.serialize(payload));
        RestContext.request = req;

        Test.startTest();
        slackAuthTokens.saveAuthTokens();
        Test.stopTest();

        Slack_Auth__c authToken = [SELECT Id, Access_Token__c, Workspace_Id__c, Workspace__c, User__c, Slack_User_Id__c
                                   FROM Slack_Auth__c
                                   WHERE Id =: existingAuth.Id];

        System.assertEquals('token3', utilities.decryptValue(authToken.Access_Token__c));
        System.assertEquals('slackWorkspaceId', authToken.Workspace_Id__c);
        System.assertEquals('slackWorkspaceName', authToken.Workspace__c);
        System.assertEquals(UserInfo.getUserId(), authToken.User__c);
        System.assertEquals('slackUserId', authToken.Slack_User_Id__c);
    }

    @isTest static void handleNewWorkspace() {
        Slack_Auth__c existingAuth = new Slack_Auth__c(
            Workspace_Id__c = 'slackWorkspaceId',
            User__c = UserInfo.getUserId(),
            Access_Token__c = 'accessToken',
            Workspace__c = 'slackWorkspaceName',
            Slack_User_Id__c = 'slackUserId'
            );

        insert existingAuth;

        List<Map<String, Object>> payload = new List<Map<String, Object>>{
            new Map<String, Object>{
                'sfOrgId' => UserInfo.getOrganizationId(),
                'slackWorkspaceId' => 'otherWorkspaceId',
                'sfUserId' => UserInfo.getUserId(),
                'accessToken' => 'token',
                'slackWorkspaceName' => 'otherSpace',
                'slackUserId' => 'slackUserId'
            }
        };

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(JSON.serialize(payload));
        RestContext.request = req;

        Test.startTest();
        slackAuthTokens.saveAuthTokens();
        Test.stopTest();

        List<Slack_Auth__c> authTokens = [SELECT Id, Access_Token__c, Workspace_Id__c, Workspace__c, User__c, Slack_User_Id__c
                                          FROM Slack_Auth__c
                                          ORDER BY Workspace__c ASC];

        System.assertEquals(2, authTokens.size());

        Slack_Auth__c authToken = authTokens.get(0);

        System.assertEquals('token', utilities.decryptValue(authToken.Access_Token__c));
        System.assertEquals('otherWorkspaceId', authToken.Workspace_Id__c);
        System.assertEquals('otherSpace', authToken.Workspace__c);
        System.assertEquals(UserInfo.getUserId(), authToken.User__c);
        System.assertEquals('slackUserId', authToken.Slack_User_Id__c);
    }

    @isTest static void wrongOrgId() {
        List<Map<String, Object>> payload = new List<Map<String, Object>>{
            new Map<String, Object>{
                'sfOrgId' => '123',
                'slackWorkspaceId' => 'slackWorkspaceId',
                'sfUserId' => UserInfo.getUserId(),
                'accessToken' => 'accessToken',
                'slackWorkspaceName' => 'slackWorkspaceName',
                'slackUserId' => 'slackUserId'
            }
        };

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(JSON.serialize(payload));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        slackAuthTokens.saveAuthTokens();
        Test.stopTest();

        System.assertEquals(500, res.statusCode);

        Map<String, Object> errorObj = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
        List<Object> errors = (List<Object>)errorObj.get('errors');

        System.assertEquals('Incorrect org id for Slack User: slackUserId', (String)errors.get(0));
    }
}