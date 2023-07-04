({
    showToast: function(component, event, helper) {
        var toast = JSON.parse(event.getParam('data'));

        helper.showToast(component, toast);
    },
    updateToasts: function(component, event, helper) {
        setTimeout($A.getCallback(() => {
            helper.updateToasts(component);
        }), 1);
    }
})