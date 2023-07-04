/**
 * @description       : 
 * @author            : Shawn Butters (butters@salesforce.com)
 * @last modified on  : 10-14-2020
 * @last modified by  : Shawn Butters (butters@salesforce.com)
 * Modifications Log 
 * Ver   Date         Author                                   Modification
 * 1.0   10-14-2020   Shawn Butters (butters@salesforce.com)   Initial Version
**/
public with sharing class WdcDemo_SyncEmployeesSchedulable implements Schedulable {
    public WdcDemo_SyncEmployeesSchedulable() {

    }

    public void execute(SchedulableContext SC) {
        SyncEmployeesBatchable batch = new SyncEmployeesBatchable();
        Database.executeBatch(batch, 200);
    }
}