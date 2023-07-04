({
    init : function(component, event, helper) {
        helper.generateColumns(component);
        //clone the layout data so we don't mutate the data set for other steps when sorting
        var layouts = component.get('v.data').layouts;
        component.set('v.layouts', JSON.parse(JSON.stringify(layouts)));
    },
    show: function(component, event, helper){
        var data = component.get('v.data');
        var setupData = data.setupData;
        var optionalSteps = JSON.parse(setupData.Optional_Steps_Completed__c);

        optionalSteps['updateLayouts'] = true;

        setupData.Optional_Steps_Completed__c = JSON.stringify(optionalSteps);
        component.set('v.data', data);
        //flicker the table to remove the width snapping issue
        window.setTimeout($A.getCallback(function(){
            var showTable = component.get('v.showTable');

            if(!showTable){
                component.set('v.showTable', true);
                component.set('v.isLoading', false);
            }
        }), 1);
    },
    updateLayoutsAction: function(component, event, helper){
        component.set('v.isUpdating', true);

        var hasGlobal = false;
        var layoutTable = component.find('layouts');
        var layoutFullNames = [];

        var selectedLayouts = layoutTable.getSelectedRows();
        selectedLayouts.forEach(function(layout){
            layoutFullNames.push(layout.FullName);

            if(layout.TableEnumOrId == 'Global'){
                hasGlobal = true;
            }
        });

        if(layoutFullNames.length == 0){
            var toastParams = {
                title : 'Please select at least one layout',
                type: 'error'
            }

            helper.showToast(component, toastParams);

            component.set('v.isUpdating', false);
            return;
        }

        var responses = [];
        //we were encounter IO timeout issues so do the layouts one at at time.
        helper.updateLayouts(component, layoutFullNames, responses)
        .then($A.getCallback(function(){
            var errMsg = '';

            responses.forEach(function(response){
                if (!response.isSuccess) {
                    errMsg += decodeURIComponent(response.error) + '\n';
                }
            });

            if(errMsg){
                component.set('v.errorMessage', errMsg);
                component.find('error-modal').show();
            } else {
                var toastParams = {
                    title : 'Successfully added Slack actions to the selected page layouts',
                    type: 'success'
                }

                if(hasGlobal && component.get('v.useLightning')){
                    toastParams.message =  'To see the updated Global Layout, you\'ll first need to refresh the page';
                }

                helper.showToast(component, toastParams);
            }

            component.set('v.isUpdating', false);
        }));

        // layoutFullNames.forEach(function(layoutName){
        //     promises.push(helper.updateLayouts(component, layoutName));
        // });
        //
        // Promise.all(promises).then($A.getCallback(function(responses){
        //     var errMsg = '';
        //
        //     responses.forEach(function(response){
        //         if (!response.isSuccess) {
        //             errMsg += decodeURIComponent(response.error) + '\n';
        //         }
        //     });
        //
        //     if(errMsg){
        //         component.set('v.errorMessage', errMsg);
        //         component.find('error-modal').show();
        //     } else {
        //         var toastParams = {
        //             title : 'Successfully added Slack actions to the selected page layouts',
        //             type: 'success'
        //         }
        //
        //         if(hasGlobal){
        //             toastParams.message =  'To see the updated Global Layout, you\'ll first need to refresh the page';
        //         }
        //
        //         helper.showToast(component, toastParams);
        //     }
        //     component.set('v.isUpdating', false);
        // })).catch(function(error) {
        //     helper.showToast(component, {
        //         message: error,
        //         type: 'error'
        //     });
        // });
    },
    sortTable: function (component, event, helper) {
        var sortedDirection = event.getParam('sortDirection');
        var sortedBy = event.getParam('fieldName');
        var layouts = component.get('v.layouts');

        component.set('v.sortedDirection', sortedDirection);
        component.set('v.sortedBy', sortedBy);

        helper.sortData(layouts, {
            sortedDirection : sortedDirection,
            sortedBy : sortedBy
        });

        component.set('v.layouts', layouts);
    },
    validate: function(component, event, helper) {
        var data = component.get('v.data');
        var setupData = data.setupData;
        var optionalSteps = JSON.parse(setupData.Optional_Steps_Completed__c);

        return optionalSteps['updateLayouts'];
    },
    closeModal: function(component, event, helper) {
        component.find('error-modal').hide();
    }
})