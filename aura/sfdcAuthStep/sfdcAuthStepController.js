({
    init: function(component, event, helper) {
        var data = component.get('v.data');

        helper.setComplete(component, data.setupData.SFDC_Auth_Step_Completed__c);
        helper.getData(component, helper);
    },
    authorize: function(component, event, helper) {
        var width = 500;
        var height = 500;
        var left = (screen.width / 2) - (width / 2);
        var top = (screen.height / 2) - (height / 2);

        window.open(component.get('v.oauthUri'), component.get('v.postMessageKey'), 'height=' + height + ',width=' + width + ',left=' + left + ',top=' + top);
    },
    validate: function(component) {
        return component.get('v.data').setupData.SFDC_Auth_Step_Completed__c;
    }
})