public class TrailheadSetupScript {
    public static void createBadgesForUser(String userId, Integer numBadges) {
        // this record should show up in the results since it's completed 2 days ago
        trailheadapp__User_Badge__c ub4 = new trailheadapp__User_Badge__c();
        ub4.trailheadapp__Badge__c = [select id from trailheadapp__badge__c where name = 'Workflow Rule Migration'].Id;
        ub4.trailheadapp__User__c = userId;
        ub4.trailheadapp__External_ID__c = ub4.trailheadapp__User__c + '-' + ub4.trailheadapp__Badge__c;                        
        ub4.trailheadapp__Finished_Date__c = Date.today().addDays(-2);
        ub4.trailheadapp__First_Attempted_Date__c = Date.today();
        ub4.trailheadapp__Last_Attempted_Date__c = Date.today();
        ub4.trailheadapp__Status__c = 'Completed';
        insert ub4;        
        
        if (numBadges > 1) {
            // this record should show NOT up in the results since it's 'assigned'
            trailheadapp__User_Badge__c ub5 = new trailheadapp__User_Badge__c();
            ub5.trailheadapp__Badge__c = [select id from trailheadapp__badge__c where name = 'Apex Basics for Admins'].Id;
            ub5.trailheadapp__User__c = userId;
            ub5.trailheadapp__External_ID__c = ub5.trailheadapp__User__c + '-' + ub5.trailheadapp__Badge__c;                        
            ub5.trailheadapp__Finished_Date__c = Date.today().addDays(-2);
            ub5.trailheadapp__First_Attempted_Date__c = Date.today();
            ub5.trailheadapp__Last_Attempted_Date__c = Date.today();
            ub5.trailheadapp__Status__c = 'Assigned'; // <<<<--------------
            insert ub5;     
        }         
        
        if(numBadges > 2) {
            // this record should show NOT up in the results since it's completed 30 days ago
            trailheadapp__User_Badge__c ub6 = new trailheadapp__User_Badge__c();
            ub6.trailheadapp__Badge__c = [select id from trailheadapp__badge__c where name = 'Asynchronous Apex'].Id;
            ub6.trailheadapp__User__c = userId;
            ub6.trailheadapp__External_ID__c = ub6.trailheadapp__User__c + '-' + ub6.trailheadapp__Badge__c;                        
            ub6.trailheadapp__Finished_Date__c = Date.today().addDays(-30); // <<<<--------------
            ub6.trailheadapp__First_Attempted_Date__c = Date.today();
            ub6.trailheadapp__Last_Attempted_Date__c = Date.today();
            ub6.trailheadapp__Status__c = 'Completed'; 
            insert ub6;   
        }
    }
}