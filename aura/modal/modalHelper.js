({
    hide: function(component) {
        component.set('v.hidden', true);
        window.removeEventListener('keyup', component.keyUp);
    }
})