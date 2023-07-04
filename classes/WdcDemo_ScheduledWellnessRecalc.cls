/*
 *  Cron Expression Reference: Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
*/
public class WdcDemo_ScheduledWellnessRecalc implements Schedulable {

    private final String cronSchedule;

    private final String BATCH_JOB_METHOD_NAME = 'executeBatchJobs';

    public WdcDemo_ScheduledWellnessRecalc ( ) {
        // runs every weekday at 00:00:00 forever
        this.cronSchedule = '0 35 0 ? * MON-FRI *';
    }

    public WdcDemo_ScheduledWellnessRecalc ( String cron ) {
        this.cronSchedule = cron;
    }

    public void execute ( SchedulableContext SC_EXEC ) {
        
        WdcDemo_DataServices.fixWellnessImmediate();

    } // execute

} // class