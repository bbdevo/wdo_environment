({
    init: function(component, event, helper) {
    }, // end init
	    
    handleNavigation : function(component, event, helper) {        
        helper.openModal(component);       
   	}, // end handleNavigation
    
	handleStatusChange : function (component, event, helper) {
        
        var status = event.getParam("status");
        component.set("v.flowStatus", status);
        console.log('RC_FlowButtonController > handleStatusChange - status: ' + component.get("v.flowStatus"));

        if(status == "FINISHED") {
           
            helper.closeModal(component);
            
            var doAction = component.get("v.doFlowActionWhenSubflowCompletes");
            console.log('RC_FlowButtonController > handleStatusChange - doFlowActionWhenSubflowCompletes: ' + doAction); 
            
            if (doAction) {
                // navigate in the flow
                helper.navigateFlow(component);
            }            
        }
        
    }, // end handleNavigation
    
    closeModal: function(component, event, helper) {

        // close modal
        helper.closeModal(component);

    }, // end closeModal
})