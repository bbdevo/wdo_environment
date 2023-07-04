/**
 * @description       : 
 * @author            : shawn.butters
 * @group             : 
 * @last modified on  : 11-27-2020
 * @last modified by  : shawn.butters
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   11-09-2020   shawn.butters   Initial Version
**/
public without sharing class WdcDemo_WKFSLNotification {

    /**
     * Provided upon instantiation. Instructs WdcDemo_WKFSLNotification which Service Territory Members to send notifications to.
     */
    private final List<wkfsl__Facility_Plan__c> PLANS_TO_NOTIFY { get; set; }

    /**
     * Private member property with instance access initializer since it can be used multiple times per instance of this class
     */
    private final CustomNotificationType SHIFT_MGMT_NOTIFICATION { 
        get {
            if (SHIFT_MGMT_NOTIFICATION == null) { 
                return [Select Id,CustomNotifTypeName from CustomNotificationType where CustomNotifTypeName = 'PushForBoth' limit 1]; 
            }
            else {
                return SHIFT_MGMT_NOTIFICATION;
            }
        }
    }

    private Map<Id, Set<Id>> planIdToRecipientsMap { get; set; }

    private WdcDemo_WKFSLNotification() {} // cannot call an empty constructor
    
    /**
     * WdcDemo_WKFSLNotification constructor
     *
     * @param plansToNotify (List<wkfsl__Facility_Plan__c>): List of facility plans. Service territory members related to these plans that are IsDemoData = true will be pushed notifications
     */
    public WdcDemo_WKFSLNotification(List<wkfsl__Facility_Plan__c> plansToNotify) {
        this.PLANS_TO_NOTIFY = plansToNotify;
    }

    /**
    * @description Creates and publishes the Shift Accept Notification message for Employees on their mobile device. Underlying flow does not provide a response, therefore there is no return value.
    * @author shawn.butters | 11-25-2020 
    **/
    public void sendShiftAcceptNotification() {

        if (planIdToRecipientsMap == null ||  planIdToRecipientsMap.isEmpty()) {

            try {
                
                planIdToRecipientsMap = this.getRecipients();
            }
            catch (IllegalArgumentException e) {

                System.debug('UNRECOVERABLE EXCEPTION in WdcDemo_WKFSLNotification: ' +e.getMessage()+'  //  '+e.getStackTraceString());
            }
        }

        // overridden labels for demos
        String notificationTitle = Label.WdcDemo_EmployeeShiftAcceptNotificationTitle;
        String notificationBody = Label.WdcDemo_EmployeeShiftAcceptNotificationBody;

        for (Id fpId : planIdToRecipientsMap.keySet()) {
            
            sendNotification(fpId, notificationTitle, notificationBody, planIdToRecipientsMap.get(fpId), SHIFT_MGMT_NOTIFICATION);
        }
    } // sendShiftAcceptNotification
    
    /**
    * @description Private instance method that calls the flow responsible for publishing notifications for Shift Management App
    * @author shawn.butters | 11-26-2020 
    * @param Id fpId 
    * @param string notifciationTitle 
    * @param string notifciationBody 
    * @param Set<Id> recipientsIds 
    * @param CustomNotificationType notification 
    **/
    private void sendNotification(Id fpId, string notifciationTitle, string notifciationBody, Set<Id> recipientsIds, CustomNotificationType notification) {
        Map<String, Object> inputs = new Map<String, Object>();  
        if(fpId != null && recipientsIds != null && notification != null){
            inputs.put('recordId', fpId);
            inputs.put('notifciationTitle', notifciationTitle);
            inputs.put('notifciationBody', notifciationBody);
            inputs.put('apexRecipients', recipientsIds);
            inputs.put('notificationId', notification.Id);
            //Start the flow to send push notifications to recipients
            Flow.Interview.wkfsl.sendGeneralNotification sendPushFlow = new Flow.Interview.wkfsl.sendGeneralNotification(inputs);
            sendPushFlow.start();
        }
    } // sendNotification

    /**
    * @description 
    * @author shawn.butters | 11-26-2020 
    * @return Map<Id, Set<Id>> List of recipients keyed by the facility plan to send a notification to
    * @throws IllegalArgumentException
    **/
    private Map<Id,Set<Id>> getRecipients() {

        Map<Id,Set<Id>> result = new Map<Id,Set<Id>>();

        if (this.PLANS_TO_NOTIFY.isEmpty()) {
            throw new IllegalArgumentException('Instance final member PLANS_TO_NOTIFY cannot be empty. Re-initialize a new instance of WdcDemo_WKFSLNotification with a valid collection');
        }

        ServiceTerritoryMember[] stms = 
                                    [
                                    SELECT
                                        Id,
                                        ServiceResource.Id,
                                        ServiceResource.Name,
                                        ServiceResource.IsActive,
                                        ServiceResource.RelatedRecord.Id,
                                        ServiceTerritory.Id,
                                        ServiceTerritory.Name,
                                        ServiceTerritory.TopLevelTerritory.IsDemoData__c,
                                        ServiceTerritory.TopLevelTerritory.Name
                                    FROM
                                        ServiceTerritoryMember stm
                                    WHERE
                                        ServiceTerritory.TopLevelTerritory.IsActive = true
                                        AND 
                                        ServiceTerritory.TopLevelTerritory.IsDemoData__c = true
                                    ];

        /**
         * This method of processing facility plan and service territory member data resulted in a 650% perf improvement over the nested loops method
         * approx processing time = 6.87ms for 26 records
         */
        Map<Id, Set<Id>> territoryToUserId = new Map<Id, Set<Id>>();
        
        for (ServiceTerritoryMember stm : stms) {

            if (!territoryToUserId.containsKey(stm.ServiceTerritory.Id)) {

                territoryToUserId.put(stm.ServiceTerritory.Id, new Set<Id>());
            }
            territoryToUserId.get(stm.ServiceTerritory.Id).add(stm.ServiceResource.RelatedRecord.Id);
        }

        for (wkfsl__Facility_Plan__c fp : this.PLANS_TO_NOTIFY) {

            if (territoryToUserId?.get(fp.wkfsl__Service_Territory__r.Id) != null) {
                
                result.put(fp.Id, territoryToUserId.get(fp.wkfsl__Service_Territory__r.Id));
            }
            else {

                System.debug('could not find a recipient list for facility plan Id:' +fp.Id);
                continue;
            }
            
        }

        /**
         * @DEPRECATED nested loops method - took 44.67ms to process 26 rows of data
        for (ServiceTerritoryMember stm : stms) {

            for (wkfsl__Facility_Plan__c fp : plans) {

                if (fp.wkfsl__Service_Territory__r.Id != stm.ServiceTerritory.Id) {
                    System.debug('continuing');
                    continue;
                }
                
                if (!result.containsKey(fp.Id)) {

                    result.put(fp.Id, new Set<Id>());
                }

                result.get(fp.Id).add(stm.ServiceResource.RelatedRecord.Id);
                System.debug(result);
            }
        }
        */

        this.planIdToRecipientsMap = result;
        return result;
    }
    
} // WdcDemo_WKFSLNotification