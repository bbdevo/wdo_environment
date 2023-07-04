({
    generateColumns: function (component) {
        var flexiColumns = [{
                label: 'Lightning Page Name',
                fieldName: 'MasterLabel',
                type: 'text',
                sortable: true
            },
            {
                label: 'Type',
                fieldName: 'EntityDefinitionId',
                type: 'text',
                sortable: true
            }
        ];

        var layoutColumns = [
            {
                label : 'Layout Name',
                fieldName : 'Name',
                type : 'text',
                sortable : true
            },
            {
                label : 'Type',
                fieldName : 'TableEnumOrId',
                type : 'text',
                sortable : true
            },
            {
                label : 'Created By',
                fieldName : 'createdByName',
                type : 'text',
                sortable : true
            }
        ];

        component.set('v.flexiColumns', flexiColumns);
        component.set('v.layoutColumns', layoutColumns)
    },
    getFlexiData: function (component, flexiId) {
        return new Promise($A.getCallback(function (resolve, reject) {
            var action = component.get('c.getFlexiData');

            action.setParams({
                flexiId: flexiId
            });

            action.setCallback(this, function (res) {
                var parsedRes = JSON.parse(res.getReturnValue());

                resolve(parsedRes.results.flexiPage.records[0]);
            });

            action.setBackground();
            $A.enqueueAction(action);
        }));
    },
    // old code to do it one at at time
    // updateFlexiPage: function (component, flexiName) {
    //     return new Promise($A.getCallback(function (resolve, reject) {
    //         var action = component.get('c.updateFlexiPage');
    //
    //         action.setParams({
    //             flexipageName: flexiName
    //         });
    //
    //         action.setCallback(this, function (res) {
    //             var parsedRes = JSON.parse(res.getReturnValue());
    //             resolve(parsedRes);
    //         });
    //
    //         action.setBackground();
    //         $A.enqueueAction(action);
    //     }));
    // },
    sortData: function (data, sortParams) {
        var reverse = sortParams.sortedDirection !== 'asc';
        var sortFunction = this.sortBy(sortParams.sortedBy, reverse);
        data.sort(sortFunction);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function (x) {
                return primer(x[field])
            } :
            function (x) {
                return x[field]
            };
        var reverse = !reverse ? 1 : -1;

        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
})