/**
 * @description       : 
 * @author            : shawn.butters
 * @group             : 
 * @last modified on  : 11-23-2020
 * @last modified by  : shawn.butters
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   11-06-2020   shawn.butters   Initial Version
**/
({
    showToast : function() {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The action succeeded",
            "type": "success"
        });
        toastEvent.fire();
    },

    showExpectedErrorToast : function(message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "No big deal",
            "message": message,
            "type": "warning"
        });
        toastEvent.fire();
    },

    showUnexpectedErrorToast : function(message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Houston, we have a problem.",
            "message": message,
            "type": "error"
        });
        toastEvent.fire();
    }
})