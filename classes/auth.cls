public with sharing class auth {
    @AuraEnabled
    public static responseData getAuthData() {
        responseData rd = new responseData();

        try {
            rd.put('isSandbox', constants.IS_SANDBOX);
            rd.put('slackClientId', constants.getClientId());
            rd.put('slackBaseUrl', constants.SLACK_BASE_URI);
        } catch(Exception e){
            rd.addError(e);
        }

        return rd.getStrippedResults();
    }
}