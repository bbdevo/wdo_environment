//no real way to validate that the metadata was created so just run through for coverage
@isTest
public class tst_updateFlexiPagesStep {
    private static Map<String, Object> responsesByResponseType = new Map<String, Object>();
    private static Map<String, Object> responsesByEndpoint = new Map<String, Object>();

    public class successWebCallout implements WebServiceMock {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {
            response.put('response_x', responsesByResponseType.get(responseType));
        }
    }

    public class failWebCallout implements WebServiceMock {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {

            response.put('response_x', responsesByResponseType.get(responseType));
        }
    }

    public class successCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();

            if(req.getEndPoint().contains(constants.SALESFORCE_ORG_DOMAIN + '/services/data/v44.0/tooling/query')){
                Map<String, Object> pages = new Map<String, Object>{
                    'records' => new List<Object> {
                        new Map<String, Object> {
                            'Id' => '123',
                            'Name' => 'FlexiPage',
                            'FullName' => 'FlexiPage'
                        }
                    }
                };

                res.setBody(JSON.serialize(pages));
            }

            res.setStatusCode(200);

            return res;
        }
    }

    @isTest static void getPages() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new successCallout());
        String jsonString = updateFlexiPagesStep.getFlexiPages();
        Test.stopTest();

        Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        System.assertEquals(true, (Boolean)parsedRes.get('isSuccess'));

        Map<String, Object> results = (Map<String, Object>)parsedRes.get('results');
        Map<String, Object> flexiPages = (Map<String, Object>)results.get('flexiPages');
        List<Object> records = (List<Object>)flexiPages.get('records');
        Map<String, Object> page = (Map<String, Object>)records.get(0);

        System.assertEquals('123', (String)page.get('Id'));
    }

    @isTest static void updateFlexi() {
        createFlexiResponse();
        createLayoutResponse();
        Test.startTest();
        Test.setMock(WebServiceMock.class, new successWebCallout());
        List<String> flexiPages = new List<String>{'Account Page'};
        List<String> layouts = new List<String>{'Account-Account Layout'};
        String jsonString = updateFlexiPagesStep.addViewMesssage(flexiPages, layouts);
        Test.stopTest();

        Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        System.assertEquals(true, (Boolean)parsedRes.get('isSuccess'));
    }

    private static void createFlexiResponse(){
        MetaDataService.ReadFlexiPageResult result = new MetaDataService.ReadFlexiPageResult();

        MetaDataService.FlexiPageRegion region = new MetaDataService.FlexiPageRegion();
        region.componentInstances = new List<MetadataService.ComponentInstance>();

        MetaDataService.FlexiPage record = new MetaDataService.FlexiPage();
        record.fullName = 'Account Page';
        record.flexiPageRegions = new List<MetadataService.FlexiPageRegion>{region};

        result.records = new List<MetaDataService.FlexiPage>{record};

        MetaDataService.readFlexiPageResponse_element responseEl = new MetaDataService.readFlexiPageResponse_element();
        responseEl.result = result;

        responsesByResponseType.put('MetadataService.readFlexiPageResponse_element', responseEl);

        MetaDataService.SaveResult updateSaveResult = new MetaDataService.SaveResult();
        updateSaveResult.success = true;
        MetaDataService.updateMetadataResponse_element updateResponseEl = new MetaDataService.updateMetadataResponse_element();
        updateResponseEl.result = new List<MetaDataService.SaveResult>{updateSaveResult};

        responsesByResponseType.put('MetadataService.updateMetadataResponse_element', updateResponseEl);
    }

    private static void createLayoutResponse(){
        MetaDataService.ReadLayoutResult result = new MetaDataService.ReadLayoutResult();
        MetaDataService.Layout record = new MetaDataService.Layout();
        record.layoutSections = new List<MetadataService.LayoutSection>{new MetadataService.LayoutSection()};
        record.fullName = 'Account-Account Layout';
        result.records = new List<MetaDataService.Layout>{record};
        MetaDataService.readLayoutResponse_element responseEl = new MetaDataService.readLayoutResponse_element();
        responseEl.result = result;

        responsesByResponseType.put('MetadataService.readLayoutResponse_element', responseEl);

        MetaDataService.SaveResult updateSaveResult = new MetaDataService.SaveResult();
        updateSaveResult.success = true;
        MetaDataService.updateMetadataResponse_element updateResponseEl = new MetaDataService.updateMetadataResponse_element();
        updateResponseEl.result = new List<MetaDataService.SaveResult>{updateSaveResult};

        responsesByResponseType.put('MetadataService.updateMetadataResponse_element', updateResponseEl);
    }
}