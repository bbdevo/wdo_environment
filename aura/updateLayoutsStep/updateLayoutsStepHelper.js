({
    generateColumns: function (component) {
        var columns = [
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

        component.set('v.columns', columns);
    },
    getLayoutData: function(component, layoutId){
        return new Promise($A.getCallback(function(resolve, reject) {
            var action = component.get('c.getLayoutData');

            action.setParams({
                layoutId : layoutId
            });

            action.setCallback(this, function (res) {
                var parsedRes = JSON.parse(res.getReturnValue());
                resolve(parsedRes.results.layout.records[0]);
            });

            action.setBackground();
            $A.enqueueAction(action);
        }));
    },
    updateLayouts: function(component, layoutNames, responses){
        var helper = this;

        return new Promise($A.getCallback(function(resolve, reject) {
            var layoutName = layoutNames[0];
            
            var action = component.get('c.updateLayouts');

            action.setParams({
                layoutName : layoutName,
                useLightning : component.get('v.useLightning'),
                useClassic : component.get('v.useClassic')
            });

            action.setCallback(this, function (res) {
                var parsedRes = JSON.parse(res.getReturnValue());
                responses.push(parsedRes);
                layoutNames.splice(0, 1);
                if(layoutNames.length == 0){
                    resolve();
                } else {
                    return resolve(helper.updateLayouts(component, layoutNames, responses));
                }
            });

            action.setBackground();
            $A.enqueueAction(action);
        }));
    },
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