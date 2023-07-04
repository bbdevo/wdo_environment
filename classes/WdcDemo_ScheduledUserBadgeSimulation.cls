/**
 * @description       : 
 * @author            : Shawn Butters (butters@salesforce.com)
 * @last modified on  : 10-16-2020
 * @last modified by  : Shawn Butters (butters@salesforce.com)
 * Modifications Log 
 * Ver   Date         Author                                   Modification
 * 1.0   10-16-2020   Shawn Butters (butters@salesforce.com)   Initial Version
**/
public with sharing class WdcDemo_ScheduledUserBadgeSimulation implements Schedulable {
    public WdcDemo_ScheduledUserBadgeSimulation() {}

    public static void execute(SchedulableContext sc) {
        datetime cDate = DateTime.now();
 		Integer diff;

        List<trailheadapp__User_Badge__c> badge = [SELECT Id, db_hours_trailheadapp_Finished_Date__c ,trailheadapp__Finished_Date__c FROM trailheadapp__User_Badge__c];
        for(trailheadapp__User_Badge__c s : badge){
            diff = Integer.valueOf(s.db_hours_trailheadapp_Finished_Date__c);
            if(diff!=null){
                s.trailheadapp__Finished_Date__c = cDate.addDays(Integer.valueOf(diff/24));
            }else{
                s.trailheadapp__Finished_Date__c = cDate;
            }
        }
        try{
            Database.update(badge);

        }catch(DMLException e){
            system.debug('DML Exception when trying to shift User Badge Finished Date values:  '+e.getStackTraceString());
        }
    }
}