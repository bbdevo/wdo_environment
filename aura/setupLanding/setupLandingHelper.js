({
    calcProgress: function(component) {
        var stepsCompleted = 0;
        var stepsTotal = 0;
        var setupWizards = component.get('v.setupWizards');

        setupWizards.forEach((setupWizard, i) => {
            var progressRings = component.find('progress-ring-container');

            if (setupWizard.stepsCompleted == setupWizard.stepsTotal) {
                if (1 == setupWizards.length) {
                    progressRings = [progressRings];
                }

                $A.util.removeClass(progressRings[i], 'strike-progress-ring_completed-container');
            } else {
                $A.util.addClass(progressRings[i], 'strike-progress-ring_completed-container');
            }

            setupWizard.stepsCompleted = 0;
            setupWizard.component.get('v.steps').forEach((step, index) => {
                if (step.isCompleted) {
                    setupWizard.stepsCompleted++;
                } else if (setupWizard.nextStepIndex != 0) {
                    setupWizard.nextStepIndex = index;
                }
            });

            stepsCompleted += setupWizard.stepsCompleted;
            stepsTotal += setupWizard.stepsTotal;
        });

        component.set('v.setupWizards', setupWizards);

        if (0 == stepsTotal) {
            component.set('v.progress', 0);
        } else {
            component.set('v.progress', stepsCompleted / stepsTotal);
        }
    }
})