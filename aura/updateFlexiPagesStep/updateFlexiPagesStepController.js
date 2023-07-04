({
    init : function(component, event, helper) {
        helper.generateColumns(component);
        var action = component.get('c.getFlexiPages');

        //clone the layout data so we don't mutate the data set for other steps when sorting
        var layouts = component.get('v.data').layouts;
        var clonedLayouts = [];

        layouts.forEach(function(layout, index){
            if(layout.TableEnumOrId != 'Global'){
                clonedLayouts.push(layout);
            }
        });

        component.set('v.layouts', clonedLayouts);

        action.setCallback(this, function (res) {
            var parsedRes = JSON.parse(res.getReturnValue());

            if (parsedRes.isSuccess) {
                var results = parsedRes.results;
                var flexiPages = results.flexiPages.records;

                var promises = [];

                flexiPages.forEach(function(flexiPage){
                    promises.push(helper.getFlexiData(component, flexiPage.Id));
                });

                Promise.all(promises).then($A.getCallback(function(responses){
                    var errMsg = '';
                    var flexiPageData = responses;
                    var selectedRows = [];

                    flexiPageData.forEach(function(flexiPage){
                        selectedRows.push(flexiPage.Id);
                    });

                    component.set('v.flexiPages', flexiPageData);
                    component.set('v.flexiSelectedRows', selectedRows);
                })).catch(function(error) {
                    helper.showToast(component, {
                        message: error,
                        type: 'error'
                    });
                });
            } else {

            }
        });

        $A.enqueueAction(action);
    },
    show: function(component, event, helper){
        var data = component.get('v.data');
        var setupData = data.setupData;
        var optionalSteps = JSON.parse(setupData.Optional_Steps_Completed__c);

        optionalSteps['updateFlexiPages'] = true;

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
    addComponent: function(component, event, helper){
        component.set('v.isUpdating', true);
        var flexiFullNames = [];
        var layoutFullNames = [];
        var useLightning = component.get('v.useLightning');
        var useClassic = component.get('v.useClassic');

        if(useLightning){
            var flexiTable = component.find('flexipages');

            var selectedFlexiPages = flexiTable.getSelectedRows();
            selectedFlexiPages.forEach(function(flexiPage){
                flexiFullNames.push(flexiPage.FullName);
            });
        }

        if(useClassic){
            var layoutTable = component.find('layouts');

            var selectedLayouts = layoutTable.getSelectedRows();
            selectedLayouts.forEach(function(layout){
                layoutFullNames.push(layout.FullName);
            });
        }

        if(flexiFullNames.length == 0 && layoutFullNames.length == 0){
            var toastParams = {
                title : 'Please select at least one row',
                type: 'error'
            }

            helper.showToast(component, toastParams);

            component.set('v.isUpdating', false);

            return;
        }

        var action = component.get('c.addViewMesssage');

        action.setParams({
            flexipageNames: flexiFullNames,
            layoutNames: layoutFullNames
        });

        action.setCallback(this, function (res) {
            var parsedRes = JSON.parse(res.getReturnValue());

            component.set('v.isUpdating', false);

            if(parsedRes.isSuccess){
                var toastParams = {
                    title : 'Successfully added the Slack Message Viewer component to the selected pages',
                    type: 'success'
                }

                helper.showToast(component, toastParams);
            } else {
                component.set('v.errorMessage', parsedRes.error);
                component.find('error-modal').show();
            }
        });

        $A.enqueueAction(action);

        //old code to do it one at a time;
        // var promises = [];
        //
        // flexiFullNames.forEach(function(flexiName){
        //     promises.push(helper.updateFlexiPage(component, flexiName));
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
        //             title : 'Successfully added the Slack Lightning component to the selected flexipages',
        //             type: 'success'
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
    sortFlexis: function (component, event, helper) {
        var sortedDirection = event.getParam('sortDirection');
        var sortedBy = event.getParam('fieldName');
        var flexiPages = component.get('v.flexiPages');

        component.set('v.flexiSortedDirection', sortedDirection);
        component.set('v.flexiSortedBy', sortedBy);

        helper.sortData(flexiPages, {
            sortedDirection : sortedDirection,
            sortedBy : sortedBy
        });

        component.set('v.flexiPages', flexiPages);
    },
    sortLayouts: function (component, event, helper) {
        var sortedDirection = event.getParam('sortDirection');
        var sortedBy = event.getParam('fieldName');
        var layouts = component.get('v.layouts');

        component.set('v.layoutSortedDirection', sortedDirection);
        component.set('v.layoutSortedBy', sortedBy);

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

        return optionalSteps['updateFlexiPages'];
    },
    closeModal: function(component, event, helper) {
        component.find('error-modal').hide();
    }
})