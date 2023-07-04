({
    authorize: function(component, event, helper) {
        // this function should be overwritten by the concrete
        helper.setComplete(component, true);
    },
    _authorize: function(component, event, helper) {
        component.getConcreteComponent()._authorize();
    }
})