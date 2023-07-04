public with sharing class updateFlexiPagesStep {
    private static List<String> flexiErrors;
    private static List<String> layoutErrors;

    @AuraEnabled
    public static String getFlexiPages() {
        responseData rd = new responseData();

        try {
            String whereClause = '';
            for(String objType : constants.HERO_OBJECTS) {
                whereClause += 'EntityDefinitionId = \'' + objType +'\' OR ';
            }

            whereClause = whereClause.removeEnd(' OR ');
            String query = 'SELECT Id FROM FlexiPage WHERE ' + whereClause + ' ORDER BY EntityDefinitionId, MasterLabel';

            String endPoint = constants.SALESFORCE_ORG_DOMAIN + '/services/data/v44.0/tooling/query?q=' + EncodingUtil.urlEncode(query, 'UTF-8');
            Map<String, String> headers = new Map<String, String>{
                'Authorization' => 'Bearer ' + UserInfo.getSessionId()
            };

            HttpResponse res = utilities.makeCallout(endpoint, 'GET', headers);
            rd.put('flexiPages', JSON.deserializeUntyped(res.getBody()));
        } catch(Exception e){
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String getFlexiData(String flexiId) {
        responseData rd = new responseData();

        try {
            String query = 'SELECT Id, MasterLabel, EntityDefinitionId, FullName FROM FlexiPage WHERE Id = \'' + String.escapeSingleQuotes(flexiId) + '\'';

            String endPoint  =  constants.SALESFORCE_ORG_DOMAIN + '/services/data/v44.0/tooling/query?q=' + EncodingUtil.urlEncode(query, 'UTF-8');
            Map<String, String> headers = new Map<String, String>{
                'Authorization' => 'Bearer ' + UserInfo.getSessionId()
            };

            HttpResponse res = utilities.makeCallout(endpoint, 'GET', headers);
            rd.put('flexiPage', JSON.deserializeUntyped(res.getBody()));
        } catch(Exception e){
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String addViewMesssage(List<String> flexipageNames, List<String> layoutNames) {
        responseData rd = new responseData();

        try {
            flexiErrors = new List<String>();
            layoutErrors = new List<String>();
            Map<String, String> flexiLabelByFullName = new Map<String, String>(); //need label for error handling
            List<MetadataService.Metadata> modifiedFlexiPages = new List<MetadataService.Metadata>();
            List<MetadataService.Metadata> modifiedLayouts = new List<MetadataService.Metadata>();
            MetadataService.MetadataPort service = utilities.createService();

            if(!flexipageNames.isEmpty()){
                for (String flexipageName : flexipageNames) {
                    List<String> flexipageList = new List<String>{flexipageName};
                    List<MetadataService.FlexiPage> queriedFlexiPages = (List<MetadataService.FlexiPage>)service.readMetadata('FlexiPage', flexipageList).getRecords();

                    for(MetadataService.FlexiPage flexiPage : queriedFlexiPages){
                        Boolean modifiedFlexi = addLightningComponent(flexiPage);
                        flexiLabelByFullName.put(flexiPage.fullName, flexiPage.masterLabel);

                        if(modifiedFlexi){
                            modifiedFlexiPages.add(flexiPage);
                        }
                    }
                }
            }

            if(!layoutNames.isEmpty()){
                for (String layoutName : layoutNames) {
                    List<String> layoutList = new List<String>{layoutName};
                    List<MetadataService.Layout> queriedLayouts = (List<MetadataService.Layout>)service.readMetadata('Layout', layoutList).getRecords();

                    for(MetadataService.Layout layout : queriedLayouts){
                        Boolean modifiedLayout = addVFPage(layout);

                        if(modifiedLayout){
                            modifiedLayouts.add(layout);
                        }
                    }
                }
            }

            if(!modifiedFlexiPages.isEmpty()) {
                for (MetadataService.Metadata modifiedFlexiPage : modifiedFlexiPages) {
                    List<MetadataService.Metadata> modifiedFlexiPageList = new List<MetadataService.Metadata>{modifiedFlexiPage};
                    List<MetadataService.SaveResult> results = service.updateMetadata(modifiedFlexiPageList);

                    for(MetadataService.SaveResult sr : results) {
                        if(!sr.success) {
                            flexiErrors.add(flexiLabelByFullName.get(sr.fullName));
                        }
                    }
                }
            }

            if(!modifiedLayouts.isEmpty()) {
                for (MetadataService.Metadata modifiedLayout : modifiedLayouts) {
                    List<MetadataService.Metadata> modifiedLayoutList = new List<MetadataService.Metadata>{modifiedLayout};
                    List<MetadataService.SaveResult> results = service.updateMetadata(modifiedLayoutList);

                    for(MetadataService.SaveResult sr : results) {
                        if(!sr.success) {
                            layoutErrors.add(sr.fullName.split('-')[1]);
                        }
                    }
                }
            }

            if(!flexiErrors.isEmpty() || !layoutErrors.isEmpty()){
                String errMsg = '';

                if(!flexiErrors.isEmpty()){
                    errMsg = String.join(flexiErrors, '\n') + '\n';
                }

                if(!layoutErrors.isEmpty()){
                    errMsg += String.join(layoutErrors, '\n');
                }

                rd.addError(errMsg);
            }
        } catch(Exception e){
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    private static Boolean addLightningComponent(MetadataService.FlexiPage flexiPage){
        Boolean modfiyFlexi = true;
        MetadataService.FlexiPageRegion lastRegion = flexiPage.flexiPageRegions.get(flexiPage.flexiPageRegions.size() - 1);
        List<MetadataService.ComponentInstance> componentInstances = lastRegion.componentInstances;
        String viewerName = constants.NAMESPACE + ':messageViewer';
        String componentName = constants.NAMESPACE == 'c' ? 'messageViewer' : viewerName;
        
        if(flexiPage.FullName == null) {
            flexiErrors.add('Unable to find FlexiPage : ' + flexiPage.masterLabel);
            return false;
        }

        //if its empty it'll come in as null instead of an empty list
        if(componentInstances == null){
            componentInstances = new List<MetadataService.ComponentInstance>();
            lastRegion.componentInstances = componentInstances;
        } else {
            for(MetadataService.ComponentInstance existingInstance : componentInstances) {
                if(existingInstance.componentName == componentName) {
                    modfiyFlexi = false;
                    break;
                }
            }
        }

        if(modfiyFlexi) {
            MetadataService.ComponentInstance instance = new MetadataService.ComponentInstance();
            instance.componentName = viewerName;



            if(componentInstances.isEmpty()) {
                componentInstances.add(instance);
            } else {
                componentInstances.add(0, instance);
            }
        }

        return modfiyFlexi;
    }

    private static Boolean addVFPage(MetadataService.Layout layout){
        Boolean modifyLayout = true;
        List<String> nameParts = layout.fullName.split('-');
        String objType = nameParts[0];
        String pageName = constants.NAMESPACE_API + objType.toLowerCase() + 'MessageViewer';

        if(layout.fullName == null) {
            layoutErrors.add(nameParts[1]);
        }

        for(MetadataService.LayoutSection layoutSection : layout.layoutSections){
            if(layoutSection.layoutColumns != null){
                for(MetadataService.LayoutColumn layoutColumn : layoutSection.layoutColumns){
                    if(layoutColumn.layoutItems != null){
                        for(MetadataService.LayoutItem layoutItem : layoutColumn.layoutItems){
                            if(layoutItem.page_x == pageName){
                                modifyLayout = false;
                                break;
                            }
                        }
                    }

                    if(!modifyLayout){
                        //found a dupe so break out
                        break;
                    }
                }
            }

            if(!modifyLayout){
                //found a dupe so break out
                break;
            }
        }

        if(modifyLayout){
            MetadataService.LayoutItem vfItem = new MetadataService.LayoutItem();
            vfItem.height = 450;
            vfItem.page_x = pageName;
            vfItem.showLabel = false;
            vfItem.showScrollbars = false;
            vfItem.width = '100%';

            MetadataService.LayoutColumn newColumn = new MetadataService.LayoutColumn();
            newColumn.layoutItems = new List<MetadataService.LayoutItem>{vfItem};

            MetadataService.LayoutSection newSection = new MetadataService.LayoutSection();
            newSection.customLabel = true;
            newSection.detailHeading = true;
            newSection.editHeading = false;
            newSection.label = 'Slack Messages';
            newSection.style = 'OneColumn';
            newSection.layoutColumns = new List<MetadataService.LayoutColumn>{newColumn};

            layout.layoutSections.add(newSection);
        }

        return modifyLayout;
    }

    // private static String getErrorMessage(MetadataService.SaveResult saveResult) {
    //     // Construct error message and throw an exception
    //     if(saveResult.errors != null) {
    //         String statusCode = saveResult.errors.get(0).statusCode;
    //         if(statusCode == 'DUPLICATE_VALUE' || statusCode == 'DUPLICATE_DEVELOPER_NAME') {
    //             return 'Duplicate';
    //         } else {
    //             return saveResult.errors.get(0).message;
    //         }
    //     }
    //
    //     return '';
    // }
}