({
    /*** Init ***/
    setModal: function(component, event, helper) {
        var modal = component.get('v.modal');

        if ($A.util.isEmpty(modal)) {
            modal = component.getSuper().find('modal');
        } else {
            modal[0].addEventHandler('onPrimaryClick', component.getReference('c.handlePrimaryClick'));
        }

        component.set('v.modal', modal);
    },
    /*** /Init ***/
    /*** Navigation ***/
    back: function(component) {
        var activeStep = component.get('v.activeStep');

        this.showStep(component, activeStep.index - 1);
    },
    saveData: function(component, event, helper) {
        return new Promise($A.getCallback((resolve, reject) => {
            var activeStep = component.get('v.activeStep');

            if (!activeStep.component.isDirty()) {
                resolve();
            } else {
                var action = component.get('c.saveData');
                var data = component.get('v.data');

                action.setParams({
                    jsonString: JSON.stringify(data)
                });

                action.setCallback(this, function(res) {
                    var responseData = JSON.parse(res.getReturnValue());

                    if (responseData.isSuccess) {
                        component.set('v.data', JSON.parse(JSON.stringify(responseData.results)));

                        resolve();
                    } else {
                        // error handle
                        reject(responseData.error);
                    }

                    component.set('v.loading', false);
                });

                component.set('v.loading', true);
                $A.enqueueAction(action);
            }
        }));
    }
    /*** /Navigation ***/
})