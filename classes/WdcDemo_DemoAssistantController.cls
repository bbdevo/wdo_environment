/**
 * @description       : 
 * @author            : shawn.butters
 * @group             : 
 * @last modified on  : 12-01-2020
 * @last modified by  : shawn.butters
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   11-05-2020   shawn.butters   Initial Version
**/

public with sharing class WdcDemo_DemoAssistantController {
    
    @AuraEnabled
    public static Boolean simulateAvailability() {

        Boolean result = false;

        try {

            WdcDemo_DataServices.simulateAvailability();
            result = true;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    @AuraEnabled
    public static Boolean ctrlClearNonDemoShiftData (){

        Boolean result = false;

        try {
            
            WdcDemo_DataServices.cleanupNonDemoData();
            result = true;
        } 
        catch (Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    @AuraEnabled
    public static Boolean ctrlRebaseShiftData(){

        Boolean result = false;
        
        try {
            
            WdcDemo_AsyncRebaseEnv.rebaseEnv();
            result = true;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    @AuraEnabled
    public static Boolean dropShiftData() {

        Boolean result = false;
        
        try {

            WdcDemo_DataServices.dropShiftManagementSchedulingData();
            result = true;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    @AuraEnabled
    public static Boolean ctrlShiftDataSnapshot() {
        
        Boolean result = false;

        try {

            WdcDemo_DataServices.setShiftDemoDataSnapshot();
            result = true;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    @AuraEnabled
    public static Boolean  ctrlUnscheduleJobs() {
        Boolean result = false;
        try {
            WdcDemo_DataServices.unscheduleAllJobs();
            result = true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    @AuraEnabled
    public static Boolean  ctrlUnscheduleBouncer() {
        Boolean result = false;
        try {
            WdcDemo_DataServices.unscheduleBouncer();
            result = true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    @AuraEnabled
    public static Boolean  ctrlScheduleJobs() {
        Boolean result = false;
        try {
            WdcDemo_DataServices.scheduleAllJobs();
            result = true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    @AuraEnabled
    public static Boolean  ctrlScheduleDataBouncer() {
        Boolean result = false;
        try {
            WdcDemo_DataServices.scheduleBouncer();
            result = true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    @AuraEnabled
    public static Boolean  ctrlPushShiftData() {
        Boolean result = false;
        
        try {
            WdcDemo_DataServices.pushShiftManagementData(7);
            result = true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }
    
    @AuraEnabled
    public static Boolean  ctrlRewindShiftData() {
        Boolean result = false;
        
        try {
            WdcDemo_DataServices.pushShiftManagementData(-7);
            result = true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    @AuraEnabled
    public static Boolean  ctrlClearStaggers() {
        Boolean result = false;
        
        try {
            WdcDemo_DataServices.resetStaggers();
            result = true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    @AuraEnabled
    public static Boolean ctrlFixWellnessImmediate() {
        Boolean result = false;

        try {
            
            WdcDemo_DataServices.fixWellnessImmediate();
            result = true;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    @AuraEnabled
    public static Boolean ctrlFixShiftMetricsImmediate() {
        Boolean result = false;

        try {
            
            WdcDemo_DataServices.fixShiftMetricsImmediate();
            result = true;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    @AuraEnabled
    public static Boolean ctrlSendShiftAcceptNotification(){

        Boolean result = false;

        try {
        
            WdcDemo_DataServices.forcePushShiftAcceptNotifications();
        } catch (Exception e) {
        
            throw new AuraHandledException(e.getMessage()+ '  //  ' +e.getStackTraceString());
            //Attempt to de-reference a null object // Class.WdcDemo_WKFSLNotification.sendShiftAcceptNotification: line 51, column 1 Class.WdcDemo_DataServices.forcePushShiftAcceptNotifications: line 333, column 1 Class.WdcDemo_DemoAssistantController.ctrlSendShiftAcceptNotification: line 208, column 1

        }

        return result;
    }

} //WdcDemo_DemoAssistantController.cls