public with sharing class setupAssistant {
    public String remoteName { get; set; }
    public String orgDomain { get; set; }
    public String namespace { get; set; }

    public Boolean createRemote { get; set; }

    public setupAssistant() {
        remoteName = 'slack_org_domain';
        orgDomain = constants.SALESFORCE_ORG_DOMAIN;
        namespace = constants.NAMESPACE;

        try {
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
            List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
            MetadataService.ListMetadataQuery remoteSites = new MetadataService.ListMetadataQuery();
            remoteSites.type_x = 'RemoteSiteSetting';
            queries.add(remoteSites);
            service.listMetadata(queries, 28);
            createRemote = false;
		} catch (Exception e) {
            //it'll throw an unauthorized exception if we don't have the remote and are on a sandbox
			createRemote = true;
		}
    }

    @AuraEnabled
    public static String getData() {
        responseData rd = new responseData();

        try {
            checkAccess();
            Setup_Settings__c settings = Setup_Settings__c.getOrgDefaults();

            if(!settings.Fixed_Description__c){
                fixDescription();
            }

            for (Schema.SObjectField field : Setup_Settings__c.sObjectType.getDescribe().fields.getMap().values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

                if (fieldDescribe.isCustom() && fieldDescribe.getType() == Schema.DisplayType.String) {
                    String fieldName = fieldDescribe.getName();

                    if (null != settings.get(fieldName)) {
                        settings.put(fieldName, constants.BLUR_STRING);
                    }
                }
            }

            rd.put('setupData', getSetupData());
            rd.put('setupSettings', settings);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String getLayouts() {
        responseData rd = new responseData();

        try {
            String whereClause = '';
            List<String> objTypes = new List<String>{'Global'};
            objTypes.addAll(constants.HERO_OBJECTS);
            for(String objType : objTypes) {
                whereClause += 'TableEnumOrId = \'' + objType +'\' OR ';
            }

            whereClause = whereClause.removeEnd(' OR ');
            String query = 'SELECT Id FROM Layout WHERE ' + whereClause + ' ORDER BY TableEnumOrId, Name';

            String endPoint  =  constants.SALESFORCE_ORG_DOMAIN + '/services/data/v44.0/tooling/query?q=' + EncodingUtil.urlEncode(query, 'UTF-8');
            Map<String, String> headers = new Map<String, String>{
                'Authorization' => 'Bearer ' + UserInfo.getSessionId()
            };

            HttpResponse res = utilities.makeCallout(endpoint, 'GET', headers);
            rd.put('layouts', JSON.deserializeUntyped(res.getBody()));
        } catch(Exception e){
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String getLayoutData(String layoutId) {
        responseData rd = new responseData();

        try {
            String query = 'SELECT Id, FullName, Name, TableEnumOrId, CreatedBy.Name FROM Layout WHERE Id = \'' + String.escapeSingleQuotes(layoutId) + '\'';

            String endPoint  =  constants.SALESFORCE_ORG_DOMAIN + '/services/data/v44.0/tooling/query?q=' + EncodingUtil.urlEncode(query, 'UTF-8');
            Map<String, String> headers = new Map<String, String>{
                'Authorization' => 'Bearer ' + UserInfo.getSessionId()
            };

            HttpResponse res = utilities.makeCallout(endpoint, 'GET', headers);
            rd.put('layout', JSON.deserializeUntyped(res.getBody()));
        } catch(Exception e){
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String saveData(String jsonString) {
        responseData rd = new responseData();

        try {
            checkAccess();

            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(jsonString);

            Map<String, Object> setupData = (Map<String, Object>)params.get('setupData');
            Map<String, Object> setupSettings = (Map<String, Object>)params.get('setupSettings');

            Setup_Data__c dataObj = (Setup_Data__c)utilities.getSobjectByMap(setupData, constants.NAMESPACE_API + 'Setup_Data__c');

            for (String field : setupSettings.keySet()) {
                if (constants.BLUR_STRING == setupSettings.get(field)) {
                    setupSettings.remove(field);
                }
            }
            Setup_Settings__c settingsObj = (Setup_Settings__c)utilities.getSobjectByMap(setupSettings, constants.NAMESPACE_API + 'Setup_Settings__c');
            settingsObj.Id = Setup_Settings__c.getOrgDefaults().Id;

            saveSetupData(dataObj);
            upsert settingsObj;

            return getData();
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    public static Setup_Data__c getSetupData() {
        checkAccess();

        Set<String> fields = new Set<String> { 'Id' };

        // Get all the custom fields.
        for (Schema.SObjectField field : Setup_Data__c.sObjectType.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            if (fieldDescribe.isCustom()) {
                fields.add(fieldDescribe.getName());
            }
        }

        String query = 'SELECT ' + String.join(new List<String>(fields), ',') + ' FROM ' + constants.NAMESPACE_API + 'Setup_Data__c WHERE Name = \'Default\'';
        List<Setup_Data__c> data = Database.query(query);
        Setup_Data__c setupData = new Setup_Data__c();

        if (!data.isEmpty()) {
            setupData = data[0];
        }

        setupData.Name = 'Default';

        if (String.isEmpty(setupData.Optional_Steps_Completed__c)) {
            setupData.Optional_Steps_Completed__c = '{}';
        }

        return setupData;
    }

    public static void saveSetupData(Setup_Data__c setupData) {
        checkAccess();

        List<Setup_Data__c> data = [SELECT Id FROM Setup_Data__c WhERE Name = 'Default'];

        if (!data.isEmpty()) {
            setupData.Id = data[0].Id;
        }
        setupData.Name = 'Default';

        upsert setupData;
    }

    private static void checkAccess() {
        Set<String> dataReadFields = new Set<String>();
        Set<String> dataUpdateFields = new Set<String>();

        for (Schema.SObjectField field : Setup_Data__c.sObjectType.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            if (fieldDescribe.isCustom()) {
                if (fieldDescribe.isAccessible()) {
                    dataReadFields.add(fieldDescribe.getName());
                }
                if (fieldDescribe.isUpdateable()) {
                    dataUpdateFields.add(fieldDescribe.getName());
                }
            }
        }

        dataReadFields.add('Name');
        dataUpdateFields.add('Name');

        Set<String> settingsReadFields = new Set<String>();
        Set<String> settingsUpdateFields = new Set<String>();

        for (Schema.SObjectField field : Setup_Settings__c.sObjectType.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            if (fieldDescribe.isCustom()) {
                if (fieldDescribe.isAccessible()) {
                    settingsReadFields.add(fieldDescribe.getName());
                }
                if (fieldDescribe.isUpdateable()) {
                    settingsUpdateFields.add(fieldDescribe.getName());
                }
            }
        }

        settingsReadFields.add('Name');
        settingsUpdateFields.add('Name');

        dmlManager.checkAccess(new Map<String, Map<String, Set<String>>> {
            'Setup_Data__c' => new Map<String, Set<String>> {
                'Read' => dataReadFields,
                'Create' => dataUpdateFields,
                'Update' => dataUpdateFields
            },
            'Setup_Settings__c' => new Map<String, Set<String>> {
                'Read' => settingsReadFields,
                'Create' => settingsUpdateFields,
                'Update' => settingsUpdateFields
            }
        });
    }

    @future (callout=true)
    public static void fixDescription() {
        try{
            MetadataService.MetadataPort service = utilities.createService();
            MetadataService.RemoteSiteSetting remoteSite = (MetadataService.RemoteSiteSetting)service.readMetadata('RemoteSiteSetting', new String[] { 'slack_org_domain' }).getRecords()[0];
            remoteSite.description = 'Used by Slack to make webservice callouts';

            service.updateMetadata(new List<MetadataService.RemoteSiteSetting>{remoteSite});
        } catch(Exception e){
            //if we don't find one then its fine to fail silently.
        }

        Setup_Settings__c settings = Setup_Settings__c.getOrgDefaults();
        settings.Fixed_Description__c = true;

        upsert settings;
    }
}