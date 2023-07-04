/**
 * @description       :
 * @author            : Shawn Butters (butters@salesforce.com)
 * @last modified on  : 10-13-2020
 * @last modified by  : Shawn Butters (butters@salesforce.com)
 * Modifications Log
 * Ver   Date         Author                                   Modification
 * 1.0   10-13-2020   Shawn Butters (butters@salesforce.com)   Initial Version
**/
public with sharing class WdcDemo_ShiftStaggerBatchable implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    public final String QUERY;

    private final Integer EARLIEST_START_HOUR = 7;
    private final Integer LATEST_START_HOUR = 10;
    private final Integer EARLIEST_END_HOUR = 14; // 2 PM
    private final Integer LATEST_END_HOUR = 18; // 6 PM

    public WdcDemo_ShiftStaggerBatchable(String q) {
        this.QUERY = q;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('BC Query: ' +QUERY);
        return Database.getQueryLocator(QUERY);
    }

    public void execute(Database.BatchableContext BC, List<Shift> scope) {

        for (Shift s: scope) {

            Datetime currentStartTime = s.StartTime;
            Datetime currentEndTime = s.EndTime;

            // Randomize new starting time for the shift
            s.StartTime = Datetime.newInstance(currentStartTime.year(), currentStartTime.month(), currentStartTime.day(), Utils_Random.generateRandomFromRange(EARLIEST_START_HOUR, LATEST_START_HOUR), 0, 0);

            // Randomize new ending time for the shift
            s.EndTime = Datetime.newInstance(currentEndTime.year(), currentEndTime.month(), currentEndTime.day(), Utils_Random.generateRandomFromRange(EARLIEST_END_HOUR, LATEST_END_HOUR), 0, 0);

            // fix shifts that are too long
            while (s.EndTime.hour() - s.StartTime.hour() > 11) {
                s.EndTime = s.EndTime.addHours(-1);
            }

            // fix shifts that are too short
            while (s.EndTime.hour() - s.StartTime.hour() < 9) {
                s.EndTime = s.EndTime.addHours(1);
            }

            s.Status = 'Confirmed';
        }

        Database.update(scope);
    }

    public void finish(Database.BatchableContext BC) {
        // finish stuff here...
    }
}