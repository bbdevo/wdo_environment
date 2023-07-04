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
({
    simAvail : function(component, event, helper) {
        var action = component.get('c.simulateAvailability');
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                console.log('Success');
                helper.showToast();
            }
            else {
                var errors = response.getError();
                if(errors[0] && errors[0].message) {
                    helper.showUnexpectedErrorToast(errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },

    fixWellness : function(component, event, helper) {
        var action = component.get('c.ctrlFixWellnessImmediate');
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                console.log('Success');
                helper.showToast();
            }
            else {
                var errors = response.getError();
                if(errors[0] && errors[0].message) {
                    helper.showUnexpectedErrorToast(errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },

    fixShiftMetrics : function(component, event, helper) {
        var action = component.get('c.ctrlFixShiftMetricsImmediate');
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                console.log('Success');
                helper.showToast();
            }
            else {
                var errors = response.getError();
                if(errors[0] && errors[0].message) {
                    helper.showUnexpectedErrorToast(errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },

    dropSMData : function(component, event, helper) {
        var dropSMDataAction = component.get('c.dropShiftData');
        dropSMDataAction.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                helper.showToast();
            }
            else {
                var errors = response.getError();
                if(errors[0] && errors[0].message) {
                    helper.showUnexpectedErrorToast(errors[0].message);
                }
            }
        });
        $A.enqueueAction(dropSMDataAction);
    },

    rebaseShiftData : function(component, event, helper) {
        var action = component.get('c.ctrlRebaseShiftData');
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                helper.showToast();
            }
            else {
                var errors = response.getError();
                if(errors[0] && errors[0].message) {
                    helper.showUnexpectedErrorToast(errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    dropNonDemoData : function(component, event, helper) {
        var action = component.get('c.ctrlClearNonDemoShiftData');
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                helper.showToast();
            }
            else {
                var errors = response.getError();
                if(errors[0] && errors[0].message) {
                    helper.showUnexpectedErrorToast(errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },

    takeSnapshot : function (component, event, helper) {
        
        var takeSnapshotAction = component.get('c.ctrlShiftDataSnapshot');
        
        takeSnapshotAction.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                helper.showToast();
            }
            else {
                var errors = response.getError();
                if(errors[0] && errors[0].message) {
                    helper.showUnexpectedErrorToast(errors[0].message);
                }
            }
        });
        $A.enqueueAction(takeSnapshotAction);
    },

    schedAllJobs : function (component, event, helper) {
        
        var schedAllJobsAction = component.get('c.ctrlScheduleJobs');
        
        schedAllJobsAction.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                helper.showToast();
            }
            else {
                var errors = response.getError();
                if(errors[0] && errors[0].message) {
                    helper.showExpectedErrorToast(errors[0].message);
                }
            }
        });
        $A.enqueueAction(schedAllJobsAction);
    },

    unschedAllJobs : function (component, event, helper) {
        
        var unschedAllJobsAction = component.get('c.ctrlUnscheduleJobs');
        
        unschedAllJobsAction.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                helper.showToast();
            }
            else {
                var errors = response.getError();
                if(errors[0] && errors[0].message) {
                    helper.showExpectedErrorToast(errors[0].message);
                }
            }
        });
        $A.enqueueAction(unschedAllJobsAction);
    },

    schedBouncer : function (component, event, helper) {
        
        var schedBouncerAction = component.get('c.ctrlScheduleDataBouncer');
        
        schedBouncerAction.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                helper.showToast();
            }
            else {
                var errors = response.getError();
                if(errors[0] && errors[0].message) {
                    helper.showExpectedErrorToast(errors[0].message);
                }
            }
        });
        $A.enqueueAction(schedBouncerAction);
    },

    unschedBouncer : function (component, event, helper) {
        
        var unschedBouncerAction = component.get('c.ctrlUnscheduleBouncer');
        
        unschedBouncerAction.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                helper.showToast();
            }
            else {
                var errors = response.getError();
                if(errors[0] && errors[0].message) {
                    helper.showExpectedErrorToast(errors[0].message);
                }
            }
        });
        $A.enqueueAction(unschedBouncerAction);
    },

    pushShiftData1Wk : function (component, event, helper) {
        
        var pushShiftData1WkAction = component.get('c.ctrlPushShiftData');
        
        pushShiftData1WkAction.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                helper.showToast();
            }
            else {
                var errors = response.getError();
                if(errors[0] && errors[0].message) {
                    helper.showUnexpectedErrorToast(errors[0].message);
                }
            }
        });
        $A.enqueueAction(pushShiftData1WkAction);
    },

    rewindShiftData1Wk : function (component, event, helper) {
        
        var rewindShiftData1WkAction = component.get('c.ctrlRewindShiftData');
        
        rewindShiftData1WkAction.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                helper.showToast();
            }
            else {
                var errors = response.getError();
                if(errors[0] && errors[0].message) {
                    helper.showUnexpectedErrorToast(errors[0].message);
                }
            }
        });
        $A.enqueueAction(rewindShiftData1WkAction);
    },

    clearStaggers : function (component, event, helper) {
        
        var clearStaggersAction = component.get('c.ctrlClearStaggers');
        
        clearStaggersAction.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                helper.showToast();
            }
            else {
                var errors = response.getError();
                if(errors[0] && errors[0].message) {
                    helper.showUnexpectedErrorToast(errors[0].message);
                }
            }
        });
        $A.enqueueAction(clearStaggersAction);
    },

    pushShiftAcceptNotifications : function (component, event, helper) {
        
        var action = component.get('c.ctrlSendShiftAcceptNotification');
        
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                helper.showToast();
            }
            else {
                var errors = response.getError();
                if(errors[0] && errors[0].message) {
                    helper.showUnexpectedErrorToast(errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },

     // this function automatic call by aura:waiting event  
     showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
         component.set("v.Spinner", true); 
    },
     
    // this function automatic call by aura:doneWaiting event 
     hideSpinner : function(component,event,helper){
      // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    }
})