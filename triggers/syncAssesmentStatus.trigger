trigger syncAssesmentStatus on EmployeeCrisisAssessment (after insert, after update) {
    emptracing.EmployeeService empService = new emptracing.EmployeeService();
    empService.syncAssesmentStatus(Trigger.New);
}