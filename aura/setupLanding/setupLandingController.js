({
    hide: function(component, event, helper) {
        component.set('v.hidden', true);
    },
    show: function(component, event, helper) {
        helper.calcProgress(component);

        component.set('v.hidden', false);
    },
    showWizard: function(component, event, helper) {
        component.getEvent('onShowWizard').setParams({
            data: event.getSource().get('v.value')
        }).fire();
    }
})