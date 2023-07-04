/**
 * @description       :
 * @author            : Shawn Butters (butters@salesforce.com)
 * @last modified on  : 11-27-2020
 * @last modified by  : shawn.butters
 * Modifications Log
 * Ver   Date         Author                                   Modification
 * 1.0   10-13-2020   Shawn Butters (butters@salesforce.com)   Initial Version
**/
public without sharing class WdcDemo_DataServices {

    private static final List<String> JOB_NAMES = new List<String>{'Hourly Scheduled Wellness Recalculation','Hourly Employee-PersonAccount Sync','Daily User Badge Completion Job','Daily Shift Management Metric Recalculation','Weekly Shift Data Bouncer'};
    private static final String BOUNCER_JOB_NAME = 'Weekly Shift Data Bouncer';

    /**
    * @description 
    * @author shawn.butters | 11-07-2020 
    **/
    public static void scheduleAllJobs() {

        WdCDemo_ScheduledWellnessRecalc schedWellness = new WdCDemo_ScheduledWellnessRecalc();
        String cronExp = '0 15 0/1 1/1 * ? *';
        String jobId01 = System.schedule('Hourly Scheduled Wellness Recalculation', cronExp, schedWellness);

        WdcDemo_SyncEmployeesSchedulable syncEmployeePA = new WdcDemo_SyncEmployeesSchedulable();
        cronExp = '0 25 0/1 1/1 * ? *';
        String jobId02 = System.schedule('Hourly Employee-PersonAccount Sync', cronExp, syncEmployeePA);

        WdcDemo_ScheduledUserBadgeSimulation resetUserBadge = new WdcDemo_ScheduledUserBadgeSimulation();
        //daily job at 01:18:00
        cronExp = '0 18 1 1/1 * ? *';
        String jobId03 = System.schedule('Daily User Badge Completion Job', cronExp, resetUserBadge);

        WdcDemo_ShiftManagementMetricSchedulable setSmm = new WdcDemo_ShiftManagementMetricSchedulable();
        // daily job at 02:21:00
        cronExp = '0 21 2 1/1 * ? *';
        String jobId04 = System.schedule('Daily Shift Management Metric Recalculation', cronExp, setSmm);

        // schedule weekly data bouncer
        scheduleBouncer();
    }

    /**
    * @description 
    * @author shawn.butters | 11-07-2020 
    **/
    public static void unscheduleAllJobs() {

        // gather all of the cron jobs
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name  FROM CronTrigger WHERE CronJobDetail.Name IN :JOB_NAMES];
        
        if (jobs.isEmpty()) {
            return;
        }
        
        for (CronTrigger j : jobs) {

            System.abortJob(j.Id);
        }
    }

    /**
    * @description 
    * @author shawn.butters | 11-07-2020 
    **/
    public static void scheduleBouncer() {

        WdcDemo_SchedulableShiftDataBouncer dataBouncer = new WdcDemo_SchedulableShiftDataBouncer();
        // Run every Sunday at 22:55
        String cron = '0 55 22 ? * SUN *';
        String dataBouncerJobId = System.schedule('Weekly Shift Data Bouncer', cron, dataBouncer);
    }

    /**
    * @description 
    * @author shawn.butters | 11-07-2020 
    **/
    public static void unscheduleBouncer() {

        CronTrigger bouncerJob = [SELECT Id,CronJobDetail.Id,CronJobDetail.Name  FROM CronTrigger WHERE CronJobDetail.Name = :BOUNCER_JOB_NAME LIMIT 1];
        
        if (bouncerJob == null) {
            return;
        }

        System.abortJob(bouncerJob.Id);
    }

    
    /**
    * @description 
    *   Pushes all shift management data the number of days specified. Used primarily by weekly scheduled routine to prep demo environments weekly
    * @author shawn.butters | 11-07-2020 
    * @param Integer days 
    * @return void
    **/
    public static void pushShiftManagementData(Integer days) {

        if (days == null || days == 0) {
            days = 7;
        }

        // push facility plans forward n days
        wkfsl__Facility_Plan__c[] plans = [SELECT Id,wkfsl__End_Date__c,wkfsl__Start_Date__c,wkfsl__AvailabilityRequestsSentDate__c,wkfsl__Completion_Date__c FROM wkfsl__Facility_Plan__c];
        
        for (wkfsl__Facility_Plan__c p : plans) {

            p.wkfsl__Start_Date__c = p.wkfsl__Start_Date__c?.addDays(days);
            p.wkfsl__End_Date__c = p.wkfsl__End_Date__c?.addDays(days);
            p.wkfsl__AvailabilityRequestsSentDate__c?.addDays(days);
            p.wkfsl__Completion_Date__c?.addDays(days);
        }
        update plans;

        // Push shifts forward days days
        Shift[] shifts = [SELECT Id, s.StartTime, s.EndTime FROM Shift s];
        
        for (Shift s : shifts) {

            s.StartTime = s.StartTime?.addDays(days);
            s.EndTime = s.EndTime?.addDays(days);
        }
        update shifts;

        // Push service appointments forward days days
        ServiceAppointment[] appts = [SELECT Id, sa.SchedStartTime, sa.ArrivalWindowStartTime, sa.EarliestStartTime, sa.SchedEndTime, sa.ArrivalWindowEndTime, sa.DueDate FROM ServiceAppointment sa];

        for (ServiceAppointment sa : appts) {

            sa.SchedStartTime = sa.SchedStartTime?.addDays(days);
            sa.ArrivalWindowStartTime = sa.ArrivalWindowStartTime?.addDays(days);
            sa.EarliestStartTime = sa.EarliestStartTime?.addDays(days);
            sa.SchedEndTime = sa.SchedEndTime?.addDays(days);
            sa.ArrivalWindowEndTime = sa.ArrivalWindowEndTime?.addDays(days);
            sa.DueDate = sa.DueDate?.addDays(days);
        }
        update appts;

        // Push work orders forward n days
        WorkOrder[] orders = [SELECT Id,StartDate,EndDate FROM WorkOrder];

        for (WorkOrder w : orders) {

            w.StartDate = w.StartDate?.addDays(days);
            w.EndDate = w.EndDate?.addDays(days);
        }
        update orders;
    }

    /**
    * @description 
    *       Sets IsDemoData = true on current shift management data state in DB.
    *       This is useful if you want to 'tweak' the data environment for shift management and want the weekly job to update your data as part of the snapshot.
    * @author shawn.butters | 11-06-2020
    * @return void
    **/
    public static void setShiftDemoDataSnapshot() {

        Shift[] shifts = [SELECT Id,IsDemoData__c FROM Shift];
        for(Shift s : shifts) {
            s.IsDemoData__c = true;
        }
        update shifts;

        ServiceAppointment[] appts = [SELECT Id,IsDemoData__c FROM ServiceAppointment];
        for(ServiceAppointment sa : appts) {
            sa.IsDemoData__c = true;
        }
        update appts;

        wkfsl__Facility_Plan__c[] plans = [SELECT Id,IsDemoData__c FROM wkfsl__Facility_plan__c];
        for(wkfsl__Facility_Plan__c p : plans) {
            p.IsDemoData__c = true;
        }
        update plans;

        AssignedResource[] res = [SELECT Id,IsDemoData__c FROM AssignedResource];
        for(AssignedResource ar : res) {
            ar.IsDemoData__c = true;
        }
        update res;

        WorkOrder[] orders = [SELECT Id,IsDemoData__c FROM WorkOrder];
        for(WorkOrder w : orders) {
            w.IsDemoData__c = true;
        }
        update orders;
    }

    /**
    * @description 
    *       Fully destructive truncation of all shift management scheduling specific data **including demo data**
    * @author shawn.butters | 11-06-2020 
    * @return void
    **/
    public static void dropShiftManagementSchedulingData() {

        Database.delete([SELECT Id FROM ServiceAppointment]);
        Database.delete([SELECT Id FROM Shift]);
        Database.delete([SELECT Id FROM wkfsl__Facility_Plan__c]);
        Database.delete([SELECT Id FROM wkfsl__PlanningPeriod__c]);
        Database.delete([SELECT Id FROM AssignedResource]);
        Database.delete([SELECT Id FROM wkfsl__ShiftAcceptNotification__c]);
        Database.delete([SELECT Id FROM WorkOrder]);
    }

    /**
    * @description 
    *       Clears shift management data that is -NOT- marked as IsDemoData__c = true
    * @author shawn.butters | 11-06-2020 
    * @return void
    **/
    public static void cleanupNonDemoData() {
        
        Database.delete([SELECT Id FROM ServiceAppointment WHERE IsDemoData__c = false]);
        Database.delete([SELECT Id FROM Shift WHERE IsDemoData__c = false]);
        Database.delete([SELECT Id FROM wkfsl__Facility_Plan__c WHERE IsDemoData__c = false]);
        Database.delete([SELECT Id FROM wkfsl__PlanningPeriod__c]);
        Database.delete([SELECT Id FROM AssignedResource WHERE IsDemoData__c = false]);
        Database.delete([SELECT Id FROM wkfsl__ShiftAcceptNotification__c]);
        Database.delete([SELECT Id FROM WorkOrder WHERE IsDemoData__c = false]);
    }

    /**
    * @description 
    * @author shawn.butters | 11-06-2020 
    **/
    public static void simulateAvailability() {

        // only simulate shifts that haven't already been simulated or manually set
        String q = 'SELECT Id,Status,StartTime,EndTime FROM Shift WHERE Status != \'Confirmed\'';

        WdcDemo_ShiftStaggerBatchable batchable = new WdcDemo_ShiftStaggerBatchable(q);
        Database.executeBatch(batchable);
    }

    /**
    * @description 
    *       Resets the arrival surge job state on all Service Appointments.
    *       After using this, you can re-stagger from the gantt using "Re-Stagger Shifts"
    * @author shawn.butters | 11-06-2020 
    **/
    public static void resetStaggers() {

        ServiceAppointment[] appts = [SELECT s.Id, s.Status, s.ArrivalWindowEndTime, s.ArrivalWindowStartTime FROM ServiceAppointment s WHERE s.IsDemoData__c = true AND s.Status = 'Scheduled' ];
        
        Set<Id> ids = new Set<Id>();

        for (ServiceAppointment sa : appts) {
        
            sa.ArrivalWindowStartTime = null;
            sa.ArrivalWindowEndTime = null;

            ids.add(sa.Id);
        }
        update appts;
        
        WdcDemo_RescheduleAppointmentsBatchable rescheduler = new WdcDemo_RescheduleAppointmentsBatchable(ids);
        Database.executeBatch(rescheduler, 1);
    }


    /**
    * @description
    * @author Shawn Butters (butters@salesforce.com) | 10-14-2020
    *
    **/
    public static void recalcWellnessFacts() {
        WdCDemo_WellnessRecalcBatchable wellnessBatch = new WdCDemo_WellnessRecalcBatchable();
        Database.executeBatch(wellnessBatch);
    }

    /**
    * @description
    * @author Shawn Butters (butters@salesforce.com) | 10-14-2020
    **/
    public static void syncPersonAccounts() {
        List<Employee> empList = [Select Id from Employee];
        Set<Id> empIds = new Set<Id>();
        for(Employee emp: empList) {
            empIds.add(emp.Id);
        }
        emptracing.EmployeeService empService = new emptracing.EmployeeService();
        empService.syncPersonAccountsFromEmployees(empIds);
    }

    /**
    * @description Uses the b2w api to fix wellness staging and fact tables. Takes about 5 mins in total.
    * @author shawn.butters | 11-19-2020 
    **/
    public static void fixWellnessImmediate() {

        Type t = Type.forName('wkcc', 'b2w_AdminSettingsSetupAPI');
        if (t == null) {
            // This means that the Work.com Command Center Package isn't present
            return;
        }
    
        Callable api = (Callable) t.newInstance();
        api.call('executeBatchJobs', null);
    }

    /**
    * @description re-bases the shift management metric data relative to today
    * @author shawn.butters | 11-25-2020 
    **/
    public static void fixShiftMetricsImmediate() {
        List<wkfsl__Shift_Management_Metric__c> shifts = [SELECT Id, wkfsl__Date__c,wkfsl__Calculated_as_of__c
                                                          FROM wkfsl__Shift_Management_Metric__c];

        Date todaysDate = system.today();
        Date yesterdayDate = system.today()-1;

        for(wkfsl__Shift_Management_Metric__c s : shifts){
            s.wkfsl__Date__c = todaysDate;
            s.wkfsl__Calculated_as_of__c = todaysDate;
            system.debug('success'+s.wkfsl__Calculated_as_of__c);
        }

        update(shifts);
    }

    /**
    * @description Forces the shift management flow to publish mobile and in-app notifications to accept/reject shifts or that new shifts are available after employee submits availability
    * @author shawn.butters | 11-25-2020
    * 
    **/
    public static void forcePushShiftAcceptNotifications() {

        wkfsl__Facility_Plan__c[] plansToNotify = [SELECT Id, p.wkfsl__Service_Territory__r.Id FROM wkfsl__Facility_Plan__c p WHERE p.IsDemoData__c = true AND p.wkfsl__Start_Date__c > :System.today()-7];

        WdcDemo_WKFSLNotification notify = new WdcDemo_WKFSLNotification(plansToNotify);
        notify.sendShiftAcceptNotification();
    }

}