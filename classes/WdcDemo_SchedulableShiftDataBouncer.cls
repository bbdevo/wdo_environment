/**
 * @description       : 
 * @author            : shawn.butters
 * @group             : 
 * @last modified on  : 11-07-2020
 * @last modified by  : shawn.butters
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   11-06-2020   shawn.butters   Initial Version
**/
public class WdcDemo_SchedulableShiftDataBouncer implements Schedulable {

    private final Integer daysToPush = 7;

    public void execute(SchedulableContext sc) {

        // cleanup all non-demo data
        WdcDemo_DataServices.cleanupNonDemoData();

        // Push shift management data forward 7 days
        WdcDemo_DataServices.pushShiftManagementData(daysToPush);
        
        
    }
}