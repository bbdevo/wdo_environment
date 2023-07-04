({
    handleClick : function(component, event, helper) {
        var win = window.open(component.get("v.profileURL"), '_blank');
        win.focus();
    },
    
    toggleLatestBadges: function(component, event, helper){
        $A.util.toggleClass(component.find("showLatestBadges"), "slds-hide");
        $A.util.toggleClass(component.find("latestBadgesDetailsActions"), "slds-hide");
        $A.util.toggleClass(component.find("latestBadgesDetails"), "slds-hide");
    },
    
    toggleAssignedLearnings: function(component, event, helper){
        $A.util.toggleClass(component.find("showAssignedLearnings"), "slds-hide");
        $A.util.toggleClass(component.find("assignedLearningsDetailsActions"), "slds-hide");
        $A.util.toggleClass(component.find("assignedLearningsDetails"), "slds-hide");
    },
    
    
    toggleRecommended: function(component, event, helper){
        $A.util.toggleClass(component.find("showRecommended"), "slds-hide");
        $A.util.toggleClass(component.find("recommendedDetailsActions"), "slds-hide");
        $A.util.toggleClass(component.find("recommendedDetails"), "slds-hide");
    },
})