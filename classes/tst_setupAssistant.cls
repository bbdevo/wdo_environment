@isTest
public with sharing class tst_setupAssistant {
    @isTest
    static public void testSetupAssistant() {
        Test.startTest();
        setupAssistant con = new setupAssistant();
        Test.stopTest();

        System.assertEquals(constants.NAMESPACE, con.namespace);
    }

    @isTest
    static public void testSetupAssistant_saveData() {
        Setup_Data__c data = new Setup_Data__c();
        Setup_Settings__c settings = new Setup_Settings__c();

        String jsonString = JSON.serialize(new Map<String, Object> {
            'setupData' => data,
            'setupSettings' => settings
        });

        Test.startTest();
        String response = setupAssistant.saveData(jsonString);
        Test.stopTest();

        List<Setup_Data__c> newData = [SELECT Id, Name FROM Setup_Data__c];
        System.assert(0 < newData.size(), '`data` not found');
        System.assert(2 > newData.size(), 'multiple `data` found');

        System.assertEquals('Default', newData.get(0).Name);

        System.assert(null != Setup_Settings__c.getOrgDefaults(), '`settings` not found');
    }

    @isTest
    static public void testSetupAssistant_getData() {
        Setup_Data__c data = new Setup_Data__c();
        Setup_Settings__c settings = new Setup_Settings__c();

        String jsonString = JSON.serialize(new Map<String, Object> {
            'setupData' => data,
            'setupSettings' => settings
        });

        setupAssistant.saveData(jsonString);

        Test.startTest();
        String response = setupAssistant.getData();
        Test.stopTest();

        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.assert((Boolean)responseMap.get('isSuccess'), responseMap.get('error'));

        Map<String, Object> resultsMap = (Map<String, Object>)responseMap.get('results');
        System.assert(resultsMap.containsKey('setupData'), '`data` not found');
        System.assert(resultsMap.containsKey('setupSettings'), '`settings` not found');
    }
}