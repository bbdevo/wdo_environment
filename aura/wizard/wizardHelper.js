({
    /*** Init ***/
    setSteps: function(component) {
        var steps = [];
        var stepComponents = component.find({
            instancesOf: 'c:step'
        });

        stepComponents.forEach((stepComponent, index) => {
            stepComponent = stepComponent.getConcreteComponent();

            stepComponent.set('v.data', component.getReference('v.data'));

            stepComponent.addEventHandler('onBack', component.getReference('c.handleBack'));
            stepComponent.addEventHandler('onCancel', component.getReference('c.handleCancel'));
            stepComponent.addEventHandler('onNext', component.getReference('c.handleNext'));

            stepComponent.init();

            steps.push({
                component: stepComponent,
                index: index,
                title: stepComponent.get('v.title'),
            });
        });

        if (steps.length) {
            var activeStep = steps[0];

            activeStep.component.set('v.isFirst', true);
            steps[steps.length - 1].component.set('v.isLast', true);

            if (!component.get('v.hidden')) {
                activeStep.component._show();
                component.set('v.activeStep', activeStep);
            }
        }

        component.set('v.steps', steps);
    },
    setModal: function(component, event, helper) {
        var modal = component.get('v.modal');

        if ($A.util.isEmpty(modal)) {
            modal = component.find('modal');
        } else {
            modal[0].addEventHandler('onPrimaryClick', component.getReference('c.handlePrimaryClick'));
        }

        component.set('v.modal', modal);
    },
    /*** /Init ***/

    /*** Navigation ***/
    cancel: function(component) {
        component.getEvent('onCancel').fire();
    },
    showStep: function(component, index) {
        var activeStep = component.get('v.activeStep');
        var steps = component.get('v.steps');

        if (steps.length <= index) {
            component.getEvent('onComplete').fire();
        } else {
            if (activeStep) {
                activeStep.component._hide();
            }

            activeStep = steps[index];
            activeStep.component._show();

            component.set('v.activeStep', activeStep);
        }
    },
    /*** /Navigation ***/
    showToast: function(component, toast) {
        if (!component.get('v.hidden')) {
            component.getEvent('showToast').setParams({
                data: JSON.stringify(toast)
            }).fire();
        }
    }
})