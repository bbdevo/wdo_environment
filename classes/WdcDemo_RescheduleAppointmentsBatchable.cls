/**
 * @description       : 
 * @author            : shawn.butters
 * @group             : 
 * @last modified on  : 11-25-2020
 * @last modified by  : shawn.butters
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   11-25-2020   shawn.butters   Initial Version
**/
public with sharing class WdcDemo_RescheduleAppointmentsBatchable implements Database.Batchable<SObject>, Database.Stateful {
    
    private final String QUERY;
    private final Set<Id> SA_IDS;

    /**
    * @description Constructor
    * @author shawn.butters | 11-25-2020 
    * @param Set<Id> records 
    * @throws IllegalArgumentException
    **/
    public WdcDemo_RescheduleAppointmentsBatchable(Set<Id> records) {
        
        if (!records.isEmpty()) {
            this.SA_IDS = records; 
        }
        else {
            throw new IllegalArgumentException('cannot instantiate WdcDemo_RescheduleAppointmentsBatchable with a null argument');
        }

        this.QUERY = 'SELECT Id FROM ServiceAppointment WHERE Id IN :SA_IDS';
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {

        Database.QueryLocator result;

        if (this?.QUERY == null) {
            result = null;
            return result;
        }

        result = Database.getQueryLocator(QUERY);

        return result;

    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {

        // execution safety check
        if (
            scope.isEmpty() || 
            scope[0].getSObjectType().getDescribe().getName() != 'ServiceAppointment'
        ) {
            return;
        }

        if(scope.size() > 1) {
            throw new LimitException('Scope size too large, make your batch sizes smaller.');
        }

        FSL__Scheduling_Policy__c btwPolicy = [SELECT Id, Name FROM FSL__Scheduling_Policy__c WHERE Name = 'Back to Work' LIMIT 1];

        List<ServiceAppointment> appts =
            [
            SELECT
                ActualEndTime,
                ActualStartTime,
                AppointmentType,
                AppointmentNumber,
                ArrivalWindowEndTime,
                ArrivalWindowStartTime,
                DueDate,
                Duration,
                EarliestStartTime,
                FSL__Scheduling_Policy_Used__c,
                Id,
                IsDeleted,
                IsDemoData__c,
                SchedEndTime,
                SchedStartTime,
                ServiceTerritoryId,
                Status,
                wkfsl__Facility_Plan__c,
                wkfsl__Reject_type__c,
                WorkTypeId
            FROM
                ServiceAppointment sa
            WHERE
                sa.Id IN :scope
                AND
                sa.IsDeleted = false
                AND
                sa.IsDemoData__c = true
            ];

        for (ServiceAppointment sa : appts) {
            
            try {
            
                FSL.ScheduleResult schedResult = FSL.ScheduleService.schedule(sa.FSL__Scheduling_Policy_Used__c, sa.Id);
            
            } catch (Exception e) {

                System.debug(e.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext BC){

        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
        TotalJobItems, CreatedBy.Email
        FROM AsyncApexJob WHERE Id =
        :BC.getJobId()];

        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Work.com Demo Org: Clear Arrival Times Results ' + a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with '+ a.NumberOfErrors + ' failures.');

        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
     }
}