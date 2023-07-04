/**
 * @description       : 
 * @author            : butters@salesforce.com
 * @group             : 
 * @last modified on  : 11-05-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-05-2020   butters@salesforce.com   Initial Version
**/
public with sharing class UIThemeController {
    @AuraEnabled
    public static String getUIThemeDescription() {
        String themedesc;
        String theme = UserInfo.getUiThemeDisplayed();
        if(theme=='Theme3' || theme=='Theme2'){
            themedesc='Salesforce Classic';
        }else if(theme=='Theme4d'){
            themedesc='Lightning Experience';
        }else if(theme=='Theme4t'){
            themedesc='Salesforce1 Mobile';
        }
        return themedesc;
    }
}