/**
 * @description       :
 * @author            : Shawn Butters (butters@salesforce.com)
 * @last modified on  : 11-04-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                                   Modification
 * 1.0   10-16-2020   Shawn Butters (butters@salesforce.com)   Initial Version
**/
public with sharing class WdcDemo_ShiftManagementMetricSchedulable implements Schedulable{
    public void execute(SchedulableContext ctx) {
        List<wkfsl__Shift_Management_Metric__c> shifts = [SELECT Id, wkfsl__Date__c,wkfsl__Calculated_as_of__c
                                                          FROM wkfsl__Shift_Management_Metric__c];

        Date todaysDate = system.today();
        Date yesterdayDate = system.today()-1;

        for(wkfsl__Shift_Management_Metric__c s : shifts){
            s.wkfsl__Date__c = todaysDate;
            s.wkfsl__Calculated_as_of__c = todaysDate;
            system.debug('success'+s.wkfsl__Calculated_as_of__c);
        }

        try{
            update(shifts);

        }catch(DMLException e){
            system.debug(e);
        }
    }
}