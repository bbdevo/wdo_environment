({
    showToast: function(component, toast) {
        component.getEvent('showToast').setParams({
            data: JSON.stringify(toast)
        }).fire();
    }
})