({
    init: function(component, event, helper) {
        helper.setSteps(component);
        helper.setModal(component);
        component.set('v.loading', false);
        component.getConcreteComponent().show();
    },

    /*** Actions ***/
    hide: function(component, event, helper) {
        component.set('v.hidden', true);

        var activeStep = component.get('v.activeStep');

        if (activeStep) {
            activeStep.component._hide();
        }

        component.set('v.activeStep', null);
    },
    show: function(component, event, helper) {
        var index = event.getParam('arguments').index;
        var steps = component.get('v.steps');

        if (!index || steps.length <= index) {
            index = 0;
        }

        helper.showStep(component, index);
        component.set('v.hidden', false);
    },
    /*** /Actions ***/

    /*** Navigation ***/
    handleBack: function(component, event, helper) {
        var activeStep = component.get('v.activeStep');

        helper.showStep(component, activeStep.index - 1);
    },
    handleCancel: function(component, event, helper) {
        var activeStep = component.get('v.activeStep');

        if (!activeStep.component.isDirty()) {
            helper.cancel(component);
        } else {
            component.get('v.modal')[0].show();
        }
    },
    handleNext: function(component, event, helper) {
        var activeStep = component.get('v.activeStep');

        helper.showStep(component, activeStep.index + 1);
    },
    handlePrimaryClick: function(component, event, helper) {
        helper.cancel(component);
    },
    _handlePrimaryClick: function(component, event, helper) {
        component.getConcreteComponent().handlePrimaryClick();
    },
    handleStepClick: function(component, event, helper) {
        if (component.get('v.allowJump')) {
            component.getConcreteComponent().show(event.currentTarget.dataset.index);
        }
    }
    /*** /Navigation ***/
})