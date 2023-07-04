global class ScheduleEmployeeSync implements Schedulable {
    global void execute(SchedulableContext ctx) {
        SyncEmployeesBatchable syncEmployees = new SyncEmployeesBatchable();
        Database.executeBatch(syncEmployees);
    }
}