/**
 * @description       : 
 * @author            : Shawn Butters (butters@salesforce.com)
 * @last modified on  : 10-14-2020
 * @last modified by  : Shawn Butters (butters@salesforce.com)
 * Modifications Log 
 * Ver   Date         Author                                   Modification
 * 1.0   10-14-2020   Shawn Butters (butters@salesforce.com)   Initial Version
**/
global class SyncEmployeesBatchable implements Database.Batchable<sObject>{

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator('Select Id from Employee');
   }

   global void execute(Database.BatchableContext BC, List<Employee> scope){
        Set<Id> empIds = new Set<Id>();
        for(Employee emp: scope) {
            empIds.add(emp.Id);
        }
        emptracing.EmployeeService empService = new emptracing.EmployeeService();
        //EmployeeService empService = new EmployeeService();
        empService.syncPersonAccountsFromEmployees(empIds);
   }

   global void finish(Database.BatchableContext BC){
   }
}