({
    init: function(component, event, helper) {
        var action = component.get('c.getData');

        action.setCallback(this, function(res) {
            var responseData = JSON.parse(res.getReturnValue());

            if (responseData.isSuccess) {
                if ($A.util.isEmpty(responseData.results.setupData.Optional_Steps_Completed__c)) {
                    responseData.results.setupData.Optional_Steps_Completed__c = '{}';
                }

                helper.getLayouts(component)
                .then($A.getCallback(function(layouts){
                    var promises = [];

                    layouts.forEach(function(layout){
                        promises.push(helper.getLayoutData(component, layout.Id));
                    });

                    Promise.all(promises).then($A.getCallback(function(layoutData){
                        var selectedRows = [];

                        layoutData.forEach(function(layout){
                            if(layout.CreatedBy){
                                layout.createdByName = layout.CreatedBy.Name;
                            } else {
                                layout.createdByName = 'Salesforce';
                            }

                            selectedRows.push(layout.Id);
                        });

                        responseData.results.layouts = layoutData;
                        responseData.results.selectedRows = selectedRows;

                        component.set('v.data', responseData.results);

                        helper.setWizards(component);
                        helper.setLanding(component);
                        helper.showLanding(component);

                        component.set('v.loading', false);
                    }));
                })).catch($A.getCallback(function(){
                    helper.showToast(component, {
                        message: 'Failed to load setup',
                        type: 'error'
                    });

                    component.set('v.loading', false);
                }));
            } else {
                helper.showToast(component, {
                    message: responseData.error,
                    type: 'error'
                });

                component.set('v.loading', false);
            }
        });

        $A.enqueueAction(action);
    },
    handleShowWizard: function(component, event, helper) {
        var activeWizard;
        var index = event.getParam('data');
        var landing = component.get('v.landing');
        var wizards = component.get('v.setupWizards');

        if (null != index) {
            activeWizard = wizards[index];
        } else {
            activeWizard = wizards[0];

            wizards.some((wizard) => {
                if (wizard.stepsCompleted < wizard.stepsTotal) {
                    activeWizard = wizard;
                    return true;
                }
            });
        }

        landing.hide();
        activeWizard.component.show(activeWizard.nextStepIndex);

        component.set('v.activeWizard', activeWizard);
    },
    handleCancel: function(component, event, helper) {
        helper.showLanding(component);
    },
    handleComplete: function(component, event, helper) {
        helper.showLanding(component);
    }
})