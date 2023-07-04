@isTest
public class EmployeeCTSetupTest {
    public static User testUser = null;
    static void testInit() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Health Cloud-Contact Tracer']; 
        List<User> users = [select Id from User where UserName = 'standarduser@testermorg.com' limit 1];
        if(users.size() < 1) {
	        testUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
    	        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        	    LocaleSidKey='en_US', ProfileId = p.Id, 
            	TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testermorg.com');
        }else {
            testUser = users.get(0);
        }
        EmployeeCTSetup.CleanUp();
    }
    
	@isTest static void testCTGraphSetup() {
        testInit();
        System.runAs(testUser) {
	        String objectName = 'CardView_Dropdown__c';
            EmployeeCTSetup.CTGraphSetup();
            EmployeeCTSetup.CTGraphSetup();
        }
    }    
    
    @isTest static void testGetFieldFullyQualifiedFieldName() {
        testInit();
        System.runAs(testUser) {
            String value = EmployeeCTSetup.getFieldFullyQualifiedFieldName(null,'Test');
			System.assert(value.equals('Test'));

            value = EmployeeCTSetup.getFieldFullyQualifiedFieldName('','Test');
			System.assert(value.equals('Test'));

            value = EmployeeCTSetup.getFieldFullyQualifiedFieldName('BD','Test');
			System.assert(value.equals('BD__Test'));
            
        }
    }    
    
    @isTest static void testGetFieldFullyQualifiedComponentName() {
        testInit();
        System.runAs(testUser) {
            String value = EmployeeCTSetup.getFieldFullyQualifiedComponentName(null,'Test');
			System.assert(value.equals('Test'));

            value = EmployeeCTSetup.getFieldFullyQualifiedComponentName('','Test');
			System.assert(value.equals('Test'));

            value = EmployeeCTSetup.getFieldFullyQualifiedComponentName('BD','Test');
			System.assert(value.equals('BD:Test'));
            
        }
    }    
    
	@isTest static void testSetup() {
        testInit();
        System.runAs(testUser) {
		    String dataUse = 'Employee Emergency Program Data Use';
            
            EmployeeCTSetup.Setup();
	        List<AuthorizationFormDataUse> authorizationFormDataUseList = [Select Id from AuthorizationFormDataUse where Name = :dataUse limit 1];
			System.assert(authorizationFormDataUseList.size() > 0);
            EmployeeCTSetup.Setup();
            
        }
    }    
	@isTest static void testCleanUp() {
        testInit();
        System.runAs(testUser) {
		    String dataUse = 'Employee Emergency Program Data Use';

            EmployeeCTSetup.Setup();
            EmployeeCTSetup.CleanUp();
	        List<AuthorizationFormDataUse> authorizationFormDataUseList = [Select Id from AuthorizationFormDataUse where Name = :dataUse limit 1];
            System.assert(authorizationFormDataUseList.size() < 1);
        }
    } 
}