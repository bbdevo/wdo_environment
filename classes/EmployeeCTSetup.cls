public class EmployeeCTSetup {
    public static final String careProgramName = 'Employee Health Emergency Program';
    public static final String dataUsePurposeName = 'Employee Emergency Program Consent Forms';
    public static final String dataUsePurposeDesc = 'Employee Emergency Program Consent Forms';
    public static final String dataUse = 'Employee Emergency Program Data Use';
    public static final String authFromName = 'Employee Emergency Form';
    public static final String summaryAuthFormText = 'Our infection care program provides';
    public static final String consentName = 'Consent Form for Employee Emergency';
    public static final String description = 'Makana Inc care program to respond to emergency';
    
    
    public static String getNameSpace(SObjectType sObj) {
        String nameSpace=null;
        
        String objectName = sObj.getDescribe().getName();
        List<String> parts = objectName.split('__');
        if(parts.size() == 3) {
            nameSpace = parts.get(0);
        }
        System.debug(LoggingLevel.DEBUG,'Card View DropDown ' + sObj.getDescribe().getName());
        System.debug(LoggingLevel.DEBUG,'NameSpace ' + nameSpace);
        
        return nameSpace;
    }
    
    public static String getFieldFullyQualifiedFieldName(String nameSpace, String fieldName) {
        if(nameSpace == null || nameSpace.trim().length() <1) {
            return fieldName;
        }
        return nameSpace+'__'+fieldName;
    }
    
    public static String getFieldFullyQualifiedComponentName(String nameSpace, String component) {
        if(nameSpace == null || nameSpace.trim().length() <1) {
            return component;
        }
        return nameSpace+':'+component;
    }

    public static void CTNavigationSetup() {
        String objectName = 'CardView_Dropdown__c';
        Map<String, SObjectType> sObjects = Schema.getGlobalDescribe();
        SObjectType cardViewDropDownObj = null;
        for (String apiName : sObjects.keySet())
        {
            if(apiName.toLowerCase().endsWith(objectName.toLowerCase())) {
                cardViewDropDownObj = sObjects.get(apiName);
            }
        }
        System.debug(LoggingLevel.DEBUG,'Card View DropDown ' + cardViewDropDownObj);  
        
        String ctName='Contact Tracing Graph';
        String soql = 'Select Id from ' + cardViewDropDownObj +' where Name not in (:ctName)';
        System.debug(LoggingLevel.DEBUG,'SOQL: ' + soql);  
        System.debug(LoggingLevel.DEBUG,'cardViewDropDownObj: ' + cardViewDropDownObj);  
        System.debug(LoggingLevel.DEBUG,'ctName: ' + ctName);  
        List<sObject> ctList = Database.query(soql);        
        delete ctList;
    } 
    
    public static void CTGraphSetup() {
        String objectName = 'CardView_Dropdown__c';
        Map<String, SObjectType> sObjects = Schema.getGlobalDescribe();
        SObjectType cardViewDropDownObj = null;
        for (String apiName : sObjects.keySet())
        {
            if(apiName.toLowerCase().endsWith(objectName.toLowerCase())) {
                cardViewDropDownObj = sObjects.get(apiName);
            }
        }
        System.debug(LoggingLevel.DEBUG,'Card View DropDown ' + cardViewDropDownObj);
        String nameSpace=getNameSpace(cardViewDropDownObj);
        sObject ctGraph = cardViewDropDownObj.newSObject() ;
        ctGraph.put('Name','Contact Tracing Graph');
        ctGraph.put(getFieldFullyQualifiedFieldName(nameSpace,'Category__c'),'Contact Tracing Graph');
        ctGraph.put(getFieldFullyQualifiedFieldName(nameSpace,'DefaultSubtab__c'),true);
        ctGraph.put(getFieldFullyQualifiedFieldName(nameSpace,'Sub_Category__c'),'Contact Tracing Graph');
        ctGraph.put(getFieldFullyQualifiedFieldName(nameSpace,'Type__c'),'LWC');
        ctGraph.put(getFieldFullyQualifiedFieldName(nameSpace,'Rec_Open_Type__c'),'Subtab');
        ctGraph.put(getFieldFullyQualifiedFieldName(nameSpace,'Url__c'),getFieldFullyQualifiedComponentName(nameSpace,'contactTracing'));
        
        List<Sobject> configList;
        String configName = 'Contact Tracing Graph';
        String configObjectName = cardViewDropDownObj.getDescribe().getName();
        String soql = 'Select Id from ' + cardViewDropDownObj.getDescribe().getName() + ' where Name = :configName limit 1';
        List<sObject> ctList = Database.query(soql);
        
        if(ctList.size() < 1) {
            System.debug(LoggingLevel.DEBUG,'Inserting');
            insert ctGraph;
        }else {
            System.debug(LoggingLevel.DEBUG,'Skipping Inserting');
        }
    }
    
    public static void CleanUp() {
        delete [Select Id from AuthorizationFormDataUse where Name = :dataUse];
        delete [Select Id from AuthorizationFormText where Name = :consentName];
        delete [Select Id from AuthorizationForm where Name = :authFromName];
        delete [Select Id from DataUsePurpose where Name = :dataUsePurposeName];
        delete [Select Id from CareProgram where Name = :careProgramName];
    }
    
    public static void Setup() {
        //Create Care Program
        CareProgram cProgram=new CareProgram(Name = careProgramName, StartDate = System.Today(), Description = description, Status = 'New');
        Id careProgramId = null;
        List<CareProgram> programs = [Select Id from CareProgram where Name = :careProgramName limit 1];
        if(programs.size() >0) {
            careProgramId = programs.get(0).Id;
        }else {
            insert cProgram;
            careProgramId = cProgram.id;
        }
        System.debug(LoggingLevel.DEBUG,'Care Program ' + careProgramId);
        
        //Create Data Use Purpose and link it to the care program
        DataUsePurpose dataUsePurpose = new DataUsePurpose(Name = dataUsePurposeName, Description = dataUsePurposeDesc, PurposeId = careProgramId);
        Id dataUsePurposeId = null;
        List<DataUsePurpose> dataUsePurposeList = [Select Id from DataUsePurpose where Name = :dataUsePurposeName and PurposeId=:careProgramId limit 1];
        if(dataUsePurposeList.size() >0) {
            dataUsePurposeId = dataUsePurposeList.get(0).Id;
        }else {
            insert dataUsePurpose;
            dataUsePurposeId = dataUsePurpose.id;
        }
        System.debug(LoggingLevel.DEBUG,'Created Data Use Purpose ' + dataUsePurposeId);
        
        //Insert the Form
        AuthorizationForm authForm = new AuthorizationForm(Name = authFromName, EffectiveFromDate = System.Today());
        Id authFormId = null;
        List<AuthorizationForm> authFormList = [Select Id from AuthorizationForm where Name = :authFromName limit 1];
        if(authFormList.size() >0) {
            authFormId = authFormList.get(0).Id;
        }else {
            insert authForm;
            authFormId = authForm.id;
        }
        System.debug(LoggingLevel.DEBUG,'Created Auth Form ' + authFormId);
        
        //Insert Auth form Text
        AuthorizationFormText authFormText = new AuthorizationFormText(Name = consentName,SummaryAuthFormText = summaryAuthFormText, AuthorizationFormId = authForm.id);
        Id authFormTextId = null;
        List<AuthorizationFormText> authorizationFormTextList = [Select Id from AuthorizationFormText where Name = :consentName and AuthorizationFormId = :authFormId limit 1];
        if(authorizationFormTextList.size() >0) {
            authFormTextId = authorizationFormTextList.get(0).Id;
        }else {
            insert authFormText;
            authFormTextId = authFormText.id;
        }
        System.debug(LoggingLevel.DEBUG,'Created Auth Form text' + authFormTextId);
        
        AuthorizationFormDataUse afDataUse = new AuthorizationFormDataUse(Name = dataUse, DataUsePurposeId = dataUsePurposeId, AuthorizationFormId = authFormId);
        Id afDataUseId = null;
        List<AuthorizationFormDataUse> authorizationFormDataUseList = [Select Id from AuthorizationFormDataUse where Name = :dataUse and AuthorizationFormId = :authFormId limit 1];
        if(authorizationFormDataUseList.size() >0) {
            afDataUseId = authorizationFormDataUseList.get(0).Id;
        }else {
            insert afDataUse;
            afDataUseId = afDataUse.id;
        }
        System.debug(LoggingLevel.DEBUG,'Created Auth Form data use' + afDataUse.id);
    }
}