public with sharing class updateLayoutsStep {
    @AuraEnabled
    public static String getLayouts() {
        responseData rd = new responseData();

        try {
            String whereClause = '';
            List<String> objTypes = new List<String>{'Global'};
            objTypes.addAll(constants.HERO_OBJECTS);
            for(String objType : objTypes) {
                whereClause += 'TableEnumOrId = \'' + objType +'\' OR ';
            }

            whereClause = whereClause.removeEnd(' OR ');
            String query = 'SELECT Id FROM Layout WHERE ' + whereClause + ' ORDER BY TableEnumOrId, Name';

            String endPoint  =  constants.SALESFORCE_ORG_DOMAIN + '/services/data/v44.0/tooling/query?q=' + EncodingUtil.urlEncode(query, 'UTF-8');
            Map<String, String> headers = new Map<String, String>{
                'Authorization' => 'Bearer ' + UserInfo.getSessionId()
            };

            HttpResponse res = utilities.makeCallout(endpoint, 'GET', headers);
            rd.put('layouts', JSON.deserializeUntyped(res.getBody()));
        } catch(Exception e){
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String getLayoutData(String layoutId) {
        responseData rd = new responseData();

        try {
            String query = 'SELECT Id, FullName, Name, TableEnumOrId, CreatedBy.Name FROM Layout WHERE Id = \'' + String.escapeSingleQuotes(layoutId) + '\'';

            String endPoint  =  constants.SALESFORCE_ORG_DOMAIN + '/services/data/v44.0/tooling/query?q=' + EncodingUtil.urlEncode(query, 'UTF-8');
            Map<String, String> headers = new Map<String, String>{
                'Authorization' => 'Bearer ' + UserInfo.getSessionId()
            };

            HttpResponse res = utilities.makeCallout(endpoint, 'GET', headers);
            rd.put('layout', JSON.deserializeUntyped(res.getBody()));
        } catch(Exception e){
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String updateLayouts(String layoutName, Boolean useClassic, Boolean useLightning) {
        responseData rd = new responseData();
        List<String> nameParts = layoutName.split('-');

        try {
            MetadataService.MetadataPort service = utilities.createService();
            List<MetadataService.Layout> queriedLayouts = (List<MetadataService.Layout>)service.readMetadata('Layout', new List<String>{layoutName}).getRecords();
            List<MetadataService.Metadata> modifiedLayouts = new List<MetadataService.Metadata>();
            MetadataService.Layout layout = queriedLayouts.get(0);
            String objType = nameParts[0];

            Boolean addedLightningButtons = false;
            Boolean addedClassicButtons = false;

            if(layout.FullName == null) {
                rd.addError('Unable to find layout : ' + nameParts[1]);
                return rd.getJsonString();
            }

            if(useLightning){
                addedLightningButtons = addLightningButtons(layout, objType);
            }

            if(useClassic && objType != 'Global'){
                addedClassicButtons = addClassicButtons(layout, objType);
            }

            if(addedLightningButtons || addedClassicButtons){
                modifiedLayouts.add(layout);//have to use a list for metadata api
            }

            if(!modifiedLayouts.isEmpty()) {
                List<MetadataService.SaveResult> results = service.updateMetadata(modifiedLayouts);

                for(MetadataService.SaveResult layoutResult : results) {
                    if(!layoutResult.success) {
                        rd.addError(nameParts[1]);
                    }
                }
            }

        } catch(Exception e){
            rd.put('apexError', e.getMessage());
            rd.put('trace', e.getStackTraceString());
            rd.addError(nameParts[1] + ': ' + e.getMessage());
        }

        return rd.getJsonString();
    }

    private static Boolean addLightningButtons(MetadataService.Layout layout, String objType){
        String sendToSlackButtonName = objType == 'Global' ? constants.NAMESPACE_API + 'Send_to_Slack' : objType + '.' + constants.NAMESPACE_API + 'Send_to_Slack';
        String slackSubscriptionsButtonName = objType + '.' + constants.NAMESPACE_API + 'Slack_Alerts';
        Boolean hasSendButton = false;
        Boolean hasSubscriptionButton = false;

        // if(objType == 'Task'){
        //     createTaskButtons();
        //     sendToSlackButtonName = 'Task.Send_to_Slack';
        //     slackSubscriptionsButtonName = 'Task.Slack_Alerts';
        // }

        if(layout.platformActionList == null) {
            layout.platformActionList = new MetadataService.PlatformActionList();
            layout.platformActionList.actionListContext = objType == 'Global' ? 'Global' : 'Record';
            layout.platformActionList.platformActionListItems = objType == 'Global' ? new List<MetadataService.PlatformActionListItem>() : generateDefaultPlatformActions();
        } else if(layout.platformActionList.platformActionListItems == null) {     //removed all the actions
            layout.platformActionList.platformActionListItems = new List<MetadataService.PlatformActionListItem>();
        }

        //check for duplicates
        for(MetadataService.PlatformActionListItem existingActionItem : layout.platformActionList.platformActionListItems) {
            if(existingActionItem.actionName == sendToSlackButtonName) {
                hasSendButton = true;
            } else if(existingActionItem.actionName == slackSubscriptionsButtonName) {
                hasSubscriptionButton = true;
            }
        }

        if(!hasSubscriptionButton && objType != 'Global') {
            MetadataService.PlatformActionListItem actionItem = new MetadataService.PlatformActionListItem();
            actionItem.actionName = slackSubscriptionsButtonName;
            actionItem.actionType = 'QuickAction';
            actionItem.sortOrder = 0;

            if(layout.platformActionList.platformActionListItems.isEmpty()) {
                layout.platformActionList.platformActionListItems.add(actionItem);
            } else {
                layout.platformActionList.platformActionListItems.add(0, actionItem);
            }
        }

        if(!hasSendButton) {
            MetadataService.PlatformActionListItem actionItem = new MetadataService.PlatformActionListItem();
            actionItem.actionName = sendToSlackButtonName;
            actionItem.actionType = 'QuickAction';
            actionItem.sortOrder = 0;

            if(layout.platformActionList.platformActionListItems.isEmpty()) {
                layout.platformActionList.platformActionListItems.add(actionItem);
            } else {
                layout.platformActionList.platformActionListItems.add(0, actionItem);
            }
        }

        //reorder all the action items so that we can put our quick action in the front
        if(!hasSendButton || !hasSubscriptionButton) {
            for(Integer i = 0; i < layout.platformActionList.platformActionListItems.size(); i++) {
                MetadataService.PlatformActionListItem actionItem = layout.platformActionList.platformActionListItems.get(i);
                actionItem.sortOrder = i;
            }
        }

        return (!hasSendButton || !hasSubscriptionButton);
    }

    private static Boolean addClassicButtons(MetadataService.Layout layout, String objType){
        String sendToSlackButtonName = constants.NAMESPACE_API + 'Send_to_Slack';
        String slackSubscriptionsButtonName =constants.NAMESPACE_API + 'Slack_Alerts';
        Boolean modifiedLayout = false;

        if(layout.customButtons == null){
            layout.customButtons = new List<String>();
        }

        if(!layout.customButtons.contains(sendToSlackButtonName)) {
            layout.customButtons.add(sendToSlackButtonName);
            modifiedLayout = true;
        }

        if(!layout.customButtons.contains(slackSubscriptionsButtonName)) {
            layout.customButtons.add(slackSubscriptionsButtonName);
            modifiedLayout = true;
        }

        return modifiedLayout;
    }

    // private static void createTaskButtons() {
    //     MetadataService.MetadataPort service = utilities.createService();
    //     List<MetadataService.SaveResult> results;
    //
    //     MetadataService.QuickAction sendAction = new MetadataService.QuickAction();
    //     sendAction.fullName = 'Task.Send_to_Slack';
    //     sendAction.height = 540;
    //     sendAction.label = 'Send to Slack';
    //     sendAction.lightningComponent = 'sendToSlackWrapper';
    //     sendAction.isProtected = false;
    //     sendAction.optionsCreateFeedItem = false;
    //     sendAction.type_x = 'LightningComponent';
    //     sendAction.Width = 600;
    //
    //
    //     MetadataService.QuickAction subscriptionAction = new MetadataService.QuickAction();
    //     subscriptionAction.fullName = 'Task.Slack_Alerts';
    //     subscriptionAction.height = 540;
    //     subscriptionAction.label = 'Slack Alerts';
    //     subscriptionAction.lightningComponent = 'slackAlertsWrapper';
    //     subscriptionAction.isProtected = false;
    //     subscriptionAction.optionsCreateFeedItem = false;
    //     subscriptionAction.type_x = 'LightningComponent';
    //     subscriptionAction.Width = 600;
    //
    //     results = service.createMetadata( new MetadataService.Metadata[] { sendAction, subscriptionAction } );
    // }


    /*
        Commented out for now.
        It seems like it does not work if the org does not have chatter enabled.
        We'll only add our button if the list is empty instead of mimicing salesforce
    */

    // private static List<MetadataService.PlatformActionListItem> generateDefaultGlobalPlatformActions(){
    //     List<MetadataService.PlatformActionListItem> defaultItems = new List<MetadataService.PlatformActionListItem>();
    //     MetadataService.PlatformActionListItem item;
    //
    //     item = new MetadataService.PlatformActionListItem();
    //     item.actionName = 'FeedItem.TextPost';
    //     item.actionType = 'QuickAction';
    //     item.sortOrder = 0;
    //     defaultItems.add(item);
    //
    //     item = new MetadataService.PlatformActionListItem();
    //     item.actionName = 'FeedItem.ContentPost';
    //     item.actionType = 'QuickAction';
    //     item.sortOrder = 1;
    //     defaultItems.add(item);
    //
    //     item = new MetadataService.PlatformActionListItem();
    //     item.actionName = 'NewEvent';
    //     item.actionType = 'QuickAction';
    //     item.sortOrder = 2;
    //     defaultItems.add(item);
    //
    //     item = new MetadataService.PlatformActionListItem();
    //     item.actionName = 'NewTask';
    //     item.actionType = 'QuickAction';
    //     item.sortOrder = 3;
    //     defaultItems.add(item);
    //
    //     item = new MetadataService.PlatformActionListItem();
    //     item.actionName = 'NewContact';
    //     item.actionType = 'QuickAction';
    //     item.sortOrder = 4;
    //     defaultItems.add(item);
    //
    //     item = new MetadataService.PlatformActionListItem();
    //     item.actionName = 'LogACall';
    //     item.actionType = 'QuickAction';
    //     item.sortOrder = 5;
    //     defaultItems.add(item);
    //
    //     item = new MetadataService.PlatformActionListItem();
    //     item.actionName = 'NewOpportunity';
    //     item.actionType = 'QuickAction';
    //     item.sortOrder = 6;
    //     defaultItems.add(item);
    //
    //     item = new MetadataService.PlatformActionListItem();
    //     item.actionName = 'NewCase';
    //     item.actionType = 'QuickAction';
    //     item.sortOrder = 7;
    //     defaultItems.add(item);
    //
    //     item = new MetadataService.PlatformActionListItem();
    //     item.actionName = 'NewLead';
    //     item.actionType = 'QuickAction';
    //     item.sortOrder = 8;
    //     defaultItems.add(item);
    //
    //     item = new MetadataService.PlatformActionListItem();
    //     item.actionName = 'FeedItem.RypplePost';
    //     item.actionType = 'QuickAction';
    //     item.sortOrder = 9;
    //     defaultItems.add(item);
    //
    //     item = new MetadataService.PlatformActionListItem();
    //     item.actionName = 'FeedItem.LinkPost';
    //     item.actionType = 'QuickAction';
    //     item.sortOrder = 10;
    //     defaultItems.add(item);
    //
    //     item = new MetadataService.PlatformActionListItem();
    //     item.actionName = 'FeedItem.PollPost';
    //     item.actionType = 'QuickAction';
    //     item.sortOrder = 11;
    //     defaultItems.add(item);
    //
    //     item = new MetadataService.PlatformActionListItem();
    //     item.actionName = 'FeedItem.QuestionPost';
    //     item.actionType = 'QuickAction';
    //     item.sortOrder = 12;
    //     defaultItems.add(item);
    //
    //     return defaultItems;
    // }

    private static List<MetadataService.PlatformActionListItem> generateDefaultPlatformActions(){
        List<MetadataService.PlatformActionListItem> defaultItems = new List<MetadataService.PlatformActionListItem>();
        MetadataService.PlatformActionListItem item;

        item = new MetadataService.PlatformActionListItem();
        item.actionName = 'NewTask';
        item.actionType = 'QuickAction';
        defaultItems.add(item);

        item = new MetadataService.PlatformActionListItem();
        item.actionName = 'LogACall';
        item.actionType = 'QuickAction';
        defaultItems.add(item);

        item = new MetadataService.PlatformActionListItem();
        item.actionName = 'NewCase';
        item.actionType = 'QuickAction';
        defaultItems.add(item);

        item = new MetadataService.PlatformActionListItem();
        item.actionName = 'NewLead';
        item.actionType = 'QuickAction';
        defaultItems.add(item);

        item = new MetadataService.PlatformActionListItem();
        item.actionName = 'NewNote';
        item.actionType = 'QuickAction';
        defaultItems.add(item);

        item = new MetadataService.PlatformActionListItem();
        item.actionName = 'NewEvent';
        item.actionType = 'QuickAction';
        defaultItems.add(item);

        item = new MetadataService.PlatformActionListItem();
        item.actionName = 'SendEmail';
        item.actionType = 'QuickAction';
        defaultItems.add(item);

        item = new MetadataService.PlatformActionListItem();
        item.actionName = 'Delete';
        item.actionType = 'StandardButton';
        defaultItems.add(item);

        item = new MetadataService.PlatformActionListItem();
        item.actionName = 'ChangeRecordType';
        item.actionType = 'StandardButton';
        defaultItems.add(item);

        item = new MetadataService.PlatformActionListItem();
        item.actionName = 'Clone';
        item.actionType = 'StandardButton';
        defaultItems.add(item);

        item = new MetadataService.PlatformActionListItem();
        item.actionName = 'Edit';
        item.actionType = 'StandardButton';
        defaultItems.add(item);

        item = new MetadataService.PlatformActionListItem();
        item.actionName = 'ChangeOwner';
        item.actionType = 'StandardButton';
        defaultItems.add(item);

        item = new MetadataService.PlatformActionListItem();
        item.actionName = 'Convert';
        item.actionType = 'StandardButton';
        defaultItems.add(item);

        item = new MetadataService.PlatformActionListItem();
        item.actionName = 'Share';
        item.actionType = 'StandardButton';
        defaultItems.add(item);

        item = new MetadataService.PlatformActionListItem();
        item.actionName = 'Submit';
        item.actionType = 'StandardButton';
        defaultItems.add(item);

        return defaultItems;
    }
}