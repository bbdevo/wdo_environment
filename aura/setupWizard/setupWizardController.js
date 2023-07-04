({
    init: function(component, event, helper) {
        helper.setSteps(component);

        var steps = component.get('v.steps');
        steps.forEach((step) => {
            step.isCompleted = step.component.validate();
        });

        helper.setModal(component);
        component.set('v.loading', false);
    },
    /*** Navigation ***/
    handleBack: function(component, event, helper) {
        var activeStep = component.get('v.activeStep');

        if (!activeStep.component.isDirty()) {
            helper.back(component);
        } else {
            component.set('v.modalAction', 'back');
            component.get('v.modal')[0].show();
        }
    },
    handleCancel: function(component, event, helper) {
        var activeStep = component.get('v.activeStep');

        if (!activeStep.component.isDirty()) {
            helper.cancel(component);
        } else {
            component.set('v.modalAction', 'cancel');
            component.get('v.modal')[0].show();
        }
    },
    handleNext: function(component, event, helper) {
        helper.saveData(component, event, helper)
        .then($A.getCallback(function() {
            var activeStep = component.get('v.activeStep');
            activeStep.isCompleted = true;

            helper.showStep(component, activeStep.index + 1);
        })).catch($A.getCallback(function(e) {
            helper.showToast(component, {
                message: e.message,
                type: 'error'
            });
        }));
    },
    handlePrimaryClick: function(component, event, helper) {
        var activeStep = component.get('v.activeStep');

        component.set('v.data', JSON.parse(JSON.stringify(activeStep.component.get('v._data'))));

        switch(component.get('v.modalAction')) {
            case 'back':
                helper.back(component);
                break;
            case 'cancel':
                helper.cancel(component);
                break;
            default:
        }
    }
    /*** /Navigation ***/
})