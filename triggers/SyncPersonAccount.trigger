trigger SyncPersonAccount on Employee (after insert, after update) {
    emptracing.EmployeeService empService = new emptracing.EmployeeService();
    empService.syncPersonAccountsFromEmployees(Trigger.New);
}