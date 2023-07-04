({
    clickPrimary: function(component, event, helper) {
        helper.hide(component);
        component.getEvent('onPrimaryClick').fire();
    },
    clickSecondary: function(component, event, helper) {
        helper.hide(component);
        component.getEvent('onSecondaryClick').fire();
    },
    hide: function(component, event, helper) {
        helper.hide(component);
    },
    show: function(component, event, helper) {
        component.keyUp = $A.getCallback(function(event) {
            if (event.keyCode == 27) {
                helper.hide(component);
                component.getEvent('onSecondaryClick').fire();
            }
        });
        window.addEventListener('keyup', component.keyUp);
        component.set('v.hidden', false);
    }
})