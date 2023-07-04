@isTest
public class tst_postInstall {

    @isTest
    static void firstInstall() {
        PostInstall postInstall = new PostInstall();

        Test.testInstall(postInstall, null);

        Setup_Settings__c setupSettings = Setup_Settings__c.getOrgDefaults();

        System.assertNotEquals(null, setupSettings.Encryption_Key__c);
    }

    @isTest
    static void updateInstall(){
        Setup_Settings__c setupSettings = Setup_Settings__c.getOrgDefaults();

        Blob keyBlob = Crypto.generateAesKey(256);
        setupSettings.Encryption_Key__c = EncodingUtil.base64Encode(keyBlob);
        insert setupSettings;

        PostInstall postInstall = new PostInstall();

        Test.testInstall(postInstall, new Version(1, 0));

        Setup_Settings__c infoAfterInstall = Setup_Settings__c.getOrgDefaults();

        System.assertEquals(setupSettings.Encryption_Key__c, infoAfterInstall.Encryption_Key__c);
    }

}