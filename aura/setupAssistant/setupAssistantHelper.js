({
    /*** Init ***/
    setWizards: function(component) {
        var wizardComponents = component.find('content').find({
            instancesOf: 'c:setupWizard'
        });
        var wizards = [];

        wizardComponents.forEach((wizardComponent, index) => {
            wizardComponent = wizardComponent.getConcreteComponent();

            wizardComponent.set('v.data', component.getReference('v.data'));
            wizardComponent.set('v.isClassic', component.get('v.isClassic'));

            wizardComponent.addEventHandler('onCancel', component.getReference('c.handleCancel'));
            wizardComponent.addEventHandler('onComplete', component.getReference('c.handleComplete'));

            wizardComponent.init();

            wizards.push({
                component: wizardComponent,
                index: index,
                nextStepIndex: 0,
                stepsCompleted: 0,
                stepsTotal: wizardComponent.get('v.steps').length,
                title: wizardComponent.get('v.title'),
                description: wizardComponent.get('v.description')
            });
        });

        component.set('v.setupWizards', wizards);
    },
    setLanding: function(component) {
        var setupLanding = component.find('landing');

        setupLanding.set('v.setupWizards', component.getReference('v.setupWizards'));
        setupLanding.addEventHandler('onShowWizard', component.getReference('c.handleShowWizard'));

        component.set('v.landing', setupLanding);
    },
    showLanding: function(component) {
        var activeWizard = component.get('v.activeWizard');
        var setupLanding = component.get('v.landing');

        if (activeWizard) {
            activeWizard.component.hide();
        }

        setupLanding.show();

        component.set('v.activeWizard', null);
    },
    getLayouts: function(component){
        return new Promise($A.getCallback(function(resolve, reject) {
            var action = component.get('c.getLayouts');

            action.setCallback(this, function (res) {
                var parsedRes = JSON.parse(res.getReturnValue());

                if (parsedRes.isSuccess) {
                    resolve(parsedRes.results.layouts.records);
                } else {
                    reject();
                }
            });

            $A.enqueueAction(action);
        }));
    },
    /*** /Init ***/
    getLayoutData: function(component, layoutId){
        return new Promise($A.getCallback(function(resolve, reject) {
            var action = component.get('c.getLayoutData');

            action.setParams({
                layoutId : layoutId
            });

            action.setCallback(this, function (res) {
                var parsedRes = JSON.parse(res.getReturnValue());
                resolve(parsedRes.results.layout.records[0]);
            });

            action.setBackground();
            $A.enqueueAction(action);
        }));
    }
})