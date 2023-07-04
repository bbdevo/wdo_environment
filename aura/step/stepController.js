({
    /*** Override Actions ***/
    hide: function(component, event, helper) {

    },
    init: function(component, event, helper) {

    },
    isDirty: function(component, event, helper) {
        return JSON.stringify(component.get('v._data')) !== JSON.stringify(component.get('v.data'));
    },
    show: function(component, event, helper) {

    },
    validate: function(component, event, helper) {
        return !component.get('v.hidden');
    },
    /*** /Actions ***/

    /*** Internal ***/
    _hide: function(component, event, helper) {
        component.set('v.hidden', true);
        component.set('v._data', null);
        component.getConcreteComponent().hide();
    },
    _show: function(component, event, helper) {
        component.set('v._data', JSON.parse(JSON.stringify(component.get('v.data'))));
        component.getConcreteComponent().show();
        component.set('v.hidden', false);
    },
    /*** /Internal ***/

    /*** Navigation ***/
    clickBack: function(component, event, helper) {
        component.getEvent('onBack').fire();
    },
    clickCancel: function(component, event, helper) {
        component.getEvent('onCancel').fire();
    },
    clickNext: function(component, event, helper) {
        if (component.getConcreteComponent().validate()) {
            component.getEvent('onNext').fire();
        } else {
            helper.showToast(component, {
                message: 'Please update invalid form entries and try again',
                type: 'error'
            });
        }
    }
    /*** /Navigation ***/
})