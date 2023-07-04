@RestResource(urlMapping='/slackAuthTokens')
global with sharing class slackAuthTokens {
    @HttpPost
    global static void saveAuthTokens() {
        checkAccess();

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            String jsonString = req.requestBody.toString();
            List<String> errors = new List<String>();
            List<Object> newAuths = (List<Object>)JSON.deserializeUntyped(jsonString);
            Map<String, Slack_Auth__c> newAuthByUserAndWorkspaceId = new Map<String, Slack_Auth__c>();
            Set<String> workspaceIds = new Set<String>();
            Set<String> userIds = new Set<String>();
            Organization org = [SELECT Id FROM Organization LIMIT 1];

            for(Object newAuthObj : newAuths) {
                Map<String, Object> newAuth = (Map<String, Object>)newAuthObj;

                if((String)newAuth.get('sfOrgId') != (String)org.Id) {
                    errors.add('Incorrect org id for Slack User: ' + (String)newAuth.get('slackUserId'));
                    continue;
                }

                String workspaceId = (String)newAuth.get('slackWorkspaceId');
                String userId = (String)newAuth.get('sfUserId');
                String encryptedToken = utilities.encryptValue((String)newAuth.get('accessToken'));

                Slack_Auth__c slackAuth = new Slack_Auth__c(
                    Access_Token__c = encryptedToken,
                    Workspace_Id__c = workspaceId,
                    Workspace__c = (String)newAuth.get('slackWorkspaceName'),
                    User__c = userId,
                    Slack_User_Id__c = (String)newAuth.get('slackUserId'),
                    Is_Most_Recent__c = true
                    );

                workspaceIds.add(workspaceId);
                userIds.add(userId);
                newAuthByUserAndWorkspaceId.put(slackAuth.User__c + '|' + slackAuth.Workspace_Id__c, slackAuth);
            }

            //update the existing auths with the new access token instead of inserting a duplicate
            //also check for any existing Is Most Recent auths
            List<Slack_Auth__c> existingSlackAuths = [SELECT Id, User__c, Workspace_Id__c, Is_Most_Recent__c
                                                      FROM Slack_Auth__c
                                                      WHERE User__c =: userIds
                                                          AND Workspace_Id__c =: workspaceIds];

            for(Slack_Auth__c existingAuth : existingSlackAuths) {
                String compoundKey = existingAuth.User__c + '|' + existingAuth.Workspace_Id__c;
                Slack_Auth__c newAuth = newAuthByUserAndWorkspaceId.get(compoundKey);

                if(newAuth != null){
                    newAuth.Id = existingAuth.Id;
                    
                    // we dont need this check since the slack auth trigger handles updating the most recent field
                    // if(existingAuth.Is_Most_Recent__c){
                    //     newAuth.Is_Most_Recent__c = false;
                    // }
                }
            }

            upsert newAuthByUserAndWorkspaceId.values();

            if(!errors.isEmpty()) {
                res.statusCode = 500;
                Map<String, Object> errorMap = new Map<String, Object>{
                    'errors' => errors
                };

                res.responseBody = Blob.valueOf(JSON.serialize(errorMap));
            }
        } catch (Exception e){
            res.statusCode = 500;
            Map<String, Object> errorMap = new Map<String, Object>{
                'errors' => new List<String>{ e.getMessage()},
                'line' => e.getLineNumber(),
                'trace' => e.getStackTraceString()
            };

            res.responseBody = Blob.valueOf(JSON.serialize(errorMap));
        }
    }

    @HttpDelete
    global static void deleteToken(){
        try {
            RestRequest req = RestContext.request;
            Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());

            delete [SELECT Id
                    FROM Slack_Auth__c
                    WHERE Workspace_Id__c =: (String)parsedRes.get('workspaceId')
                    AND Slack_User_Id__c =: (String)parsedRes.get('slackUserId')];
        } catch (Exception e){
            RestResponse res = RestContext.response;
            res.statusCode = 500;
            Map<String, Object> errorMap = new Map<String, Object>{
                'error' => e.getMessage(),
                'trace' => e.getStackTraceString()
            };

            res.responseBody = Blob.valueOf(JSON.serialize(errorMap));
        }
    }

    private static Map<String, Map<String, Set<String>>> accessChecks = new Map<String, Map<String, Set<String>>> {
        'Organization' => new Map<String, Set<String>> {
            'Read' => new Set<String> {
                'Id'
            }
        },
        'Slack_Auth__c' => new Map<String, Set<String>> {
            'Read' => new Set<String> {
                'Id', 'Access_Token__c', 'Workspace_Id__c', 'Workspace__c', 'User__c', 'Slack_User_Id__c',
                'Is_Most_Recent__c'
            },
            'Create' => new Set<String> {
                'Access_Token__c', 'Workspace_Id__c', 'Workspace__c', 'User__c', 'Slack_User_Id__c',
                'Is_Most_Recent__c'
            },
            'Update' => new Set<String> {
                'Access_Token__c', 'Workspace_Id__c', 'Workspace__c', 'User__c', 'Slack_User_Id__c',
                'Is_Most_Recent__c'
            }
        }
    };

    private static void checkAccess(){
        dmlManager.checkAccess(accessChecks);
    }
}