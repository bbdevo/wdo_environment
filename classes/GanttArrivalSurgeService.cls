/**
 * @description       :
 * @author            : Shawn Butters (butters@salesforce.com)
 * @last modified on  : 11-06-2020
 * @last modified by  : shawn.butters
 * Modifications Log
 * Ver   Date         Author                                   Modification
 * 1.0   10-13-2020   Shawn Butters (butters@salesforce.com)   Initial Version
**/
global with sharing class GanttArrivalSurgeService implements FSL.CustomGanttServiceAppointmentAction {

    global String action(List<Id> serviceAppointmentIds, DateTime ganttStartDate, DateTime ganttEndDate, Map<String, Object> additionalParameters) {

        String result = '';

        if (serviceAppointmentIds.isEmpty() || serviceAppointmentIds.size() < 1) {
            return result = 'No Service Appointments were provided for staggering, no action was performed';
        }

        List<ServiceAppointment> ganttAppointments =
                                                    [
                                                        SELECT
                                                            Id,
                                                            ActualEndTime,
                                                            ActualStartTime,
                                                            AppointmentNumber,
                                                            ArrivalWindowEndTime,
                                                            ArrivalWindowStartTime,
                                                            Days__c,
                                                            DueDate,
                                                            EarliestStartTime,
                                                            wkfsl__Facility_Plan__r.Id,
                                                            wkfsl__Facility_Plan__r.Name,
                                                            wkfsl__Facility_Plan__r.wkfsl__PlanType__c,
                                                            wkfsl__Facility_Plan__r.wkfsl__Shifts_Were_Generated__c,
                                                            wkfsl__Facility_Plan__r.wkfsl__Days_of_the_week__c,
                                                            wkfsl__Facility_Plan__r.wkfsl__Related_Top_Level_Territory__r.Id,
                                                            wkfsl__Facility_Plan__r.wkfsl__Timezone__c,
                                                            wkfsl__Facility_Plan__r.wkfsl__Start_Date__c,
                                                            wkfsl__Facility_Plan__r.wkfsl__Service_Territory__r.Id,
                                                            wkfsl__Facility_Plan__r.wkfsl__Time_Interval__c,
                                                            FSL__InJeopardy__c,
                                                            SchedEndTime,
                                                            SchedStartTime,
                                                            Status,
                                                            ServiceTerritory.Id
                                                        FROM ServiceAppointment
                                                        WHERE Id IN :serviceAppointmentIds
                                                    ];

        List<Id> relatedTopLevelTerritoryIds = new List<Id>();

        Map<Id, wkfsl__Facility_Plan__c> facilityPlans;

        for (ServiceAppointment sa : ganttAppointments) {

            relatedTopLevelTerritoryIds.add(sa.wkfsl__Facility_Plan__r.wkfsl__Related_Top_Level_Territory__r.Id);
            //facilityPlans.put(sa.wkfsl__Facility_Plan__r.Id, sa.wkfsl__Facility_Plan__r);
        }

        facilityPlans = new Map<Id, wkfsl__Facility_Plan__c>(
                                                        [
                                                            SELECT
                                                                Id,
                                                                Name,
                                                                wkfsl__AvailabilityRequestsSentDate__c,
                                                                wkfsl__Capacity_Overide__c,
                                                                wkfsl__Capacity__c,
                                                                wkfsl__Completion_Date__c,
                                                                wkfsl__Days_of_the_week__c,
                                                                wkfsl__End_Date__c,
                                                                wkfsl__Generate_Shift__c,
                                                                wkfsl__Max_Number_Of_Allowed_Employees__c,
                                                                wkfsl__Percentage_Allocation__c,
                                                                wkfsl__Related_Top_Level_Territory__c,
                                                                wkfsl__Related_Top_Level_Territory__r.OperatingHours.TimeZone,
                                                                wkfsl__Service_Territory__c,
                                                                wkfsl__Shifts_Were_Generated__c,
                                                                wkfsl__Stagger_End_Time__c,
                                                                wkfsl__Stagger_Start_Time__c,
                                                                wkfsl__Start_Date__c,
                                                                wkfsl__Timezone__c,
                                                                wkfsl__Time_Interval__c,
                                                                wkfsl__Time_To_Stagger__c,
                                                                wkfsl__Work_Type__c
                                                            FROM wkfsl__Facility_Plan__c
                                                            WHERE wkfsl__Related_Top_Level_Territory__r.Id IN :relatedTopLevelTerritoryIds AND wkfsl__Time_Interval__c != NULL
                                                        ]);


        for (wkfsl__Facility_Plan__c plan : facilityPlans.values()) {
            List<wkfsl__Facility_Plan__c> planList = new List<wkfsl__Facility_Plan__c>();
            planList.add(plan);
            Date planStart = plan.wkfsl__Start_Date__c;
            TimeZone planTimeZone = TimeZone.getTimeZone(plan.wkfsl__Related_Top_Level_Territory__r.OperatingHours.TimeZone);
            Date dateToStagger = Date.valueOf(ganttStartDate);
            String dayOfWeekToStartFrom = plan.wkfsl__Days_of_the_week__c.split(';')[0];
            Id thisPlanId = plan.Id;

            // each surge must be on one top level territory plan at a time
            wkfsl.BatchArrivalSurge newSurge = new wkfsl.BatchArrivalSurge(planList, planStart, planTimeZone, dateToStagger, dayOfWeekToStartFrom, thisPlanId);
            System.Database.executeBatch(newSurge);
        }

        result = 'Successfully queued job to calculate arrivals. You might need to refresh to see results if you are viewing weekly.';
        return result;
    }//action()

}//class