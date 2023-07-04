/**
 * @description       : 
 * @author            : shawn.butters
 * @group             : 
 * @last modified on  : 11-08-2020
 * @last modified by  : shawn.butters
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   11-08-2020   shawn.butters   Initial Version
**/
public class WdcDemo_AsyncRebaseEnv {
    
    @Future
    public static void rebaseEnv() {

        String targetDay = 'Mon';
        Date firstDate;
        DateTime today = System.now();
        String currDayOfWeek = today.formatGmt('EEE'); // Mon,Tues,Weds, etc.
        Date lastMonday;

        Integer daysElapsed;
        
        // first, make sure the environment is clean
        WdcDemo_DataServices.cleanupNonDemoData();

        // go get all of the data. It needs to be sorted correctly for rebasing
        // calculate rebase days based on an arbitrary shift start date
        List<Shift> shifts = [SELECT Id,s.StartTime,s.EndTime FROM Shift s WHERE IsDemoData__c = true ORDER BY s.StartTime ASC NULLS LAST];

        Shift rebaseSampling = shifts?.get(0);
        
        if (rebaseSampling == null) {
            // If for whatever reason we cannot find a base to resample from, the data is crap, just give up.
            return;
        }

        firstDate = rebaseSampling.StartTime.date(); // will always be a monday n days in the past
        System.debug('Debug: firstDate = ' +firstDate);

        // Find the current weeks Monday Date
        DateTime iterableDay = System.now();

        while (currDayOfWeek != targetDay) {

            iterableDay = iterableDay.addDays(-1); // decrement day of week
            currDayOfWeek = iterableDay.formatGmt('EEE');
        }

        // Will produce either a positive or negative integer representing the number of days elapsed since or until the firstDate of a demo shift
        daysElapsed = firstDate.daysBetween(Date.valueOf(iterableDay));
        System.debug('Debug: daysElapsed = ' +daysElapsed);

        // This will re-base the shift management data dates from the first occurrence of demo data all the way to the current week's Monday occurrence
        WdcDemo_DataServices.pushShiftManagementData(daysElapsed);
    }
}