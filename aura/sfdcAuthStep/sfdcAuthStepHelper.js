({
    addMessageListener: function(component, helper) {
        window.addEventListener('message', $A.getCallback(function(event) {
            if (event.origin === 'https://dev.slack.com' || event.origin === 'https://slack.com') {
                var data = component.get('v.data');
                data.setupData.SFDC_Auth_Step_Completed__c = true;
                helper.setComplete(component, data.setupData.SFDC_Auth_Step_Completed__c);
            }
        }));
    },
    getData: function(component, helper) {
        var action = component.get('c.getData');

        action.setCallback(this, function(res) {
            var responseData = JSON.parse(res.getReturnValue());
            if (responseData.isSuccess) {
                var results = responseData.results;
                var stateParams = {
                    namespace : results.namespace,
                    isSandbox : results.isSandbox,
                    origin : 'https://' + window.location.host
                }
                var oAuthUrl = results.oauthUri + '&state=' + encodeURIComponent(JSON.stringify(stateParams));

                component.set('v.oauthUri', oAuthUrl);
                component.set('v.postMessageKey', results.postMessageKey);

                helper.addMessageListener(component, helper);
            } else {
                helper.showToast(component, {
                    message: responseData.error,
                    type: 'error'
                });
            }

            component.set('v.loading', false);
        });

        component.set('v.loading', true);
        $A.enqueueAction(action);
    }
})