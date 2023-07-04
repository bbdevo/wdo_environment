({
    closeAction: function (component) {
        var isClassic = component.get('v.isClassic');

        if(isClassic){
            window.location.href = '/' + component.get('v.recordId');
        } else {
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }
    }
})