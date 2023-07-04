({
    setComplete: function(component, completed) {
        component.set('v.disableNext', !completed);
        component.set('v.isComplete', completed);
    }
})