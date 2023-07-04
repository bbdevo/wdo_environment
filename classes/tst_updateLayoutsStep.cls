//no real way to validate that the metadata was created so just run through for coverage
@isTest
public class tst_updateLayoutsStep {
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
                Map<String, Object> layouts = new Map<String, Object>{
                    'records' => new List<Object> {
                        new Map<String, Object> {
                            'Id' => '123',
                            'Name' => 'Layout',
                            'FullName' => 'FullName'
                        }
                    }
                };

                res.setBody(JSON.serialize(layouts));
            }

            res.setStatusCode(200);

            return res;
        }
    }

    @isTest static void getLayouts() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new successCallout());
        String jsonString = updateLayoutsStep.getLayouts();
        Test.stopTest();

        Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        System.assertEquals(true, (Boolean)parsedRes.get('isSuccess'));

        Map<String, Object> results = (Map<String, Object>)parsedRes.get('results');
        Map<String, Object> layouts = (Map<String, Object>)results.get('layouts');
        List<Object> records = (List<Object>)layouts.get('records');
        Map<String, Object> layout = (Map<String, Object>)records.get(0);

        System.assertEquals('123', (String)layout.get('Id'));
    }

    @isTest static void updateStandardLayout() {
        MetaDataService.ReadLayoutResult result = new MetaDataService.ReadLayoutResult();
        MetaDataService.Layout record = new MetaDataService.Layout();
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

        Test.startTest();
        Test.setMock(WebServiceMock.class, new successWebCallout());
        String jsonString = updateLayoutsStep.updateLayouts('Account-Account Layout', true, true);
        Test.stopTest();

        Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        System.assertEquals(true, (Boolean)parsedRes.get('isSuccess'));
    }

    @isTest static void updateGlobalLayout() {
        MetaDataService.ReadLayoutResult result = new MetaDataService.ReadLayoutResult();
        MetaDataService.Layout record = new MetaDataService.Layout();
        record.fullName = 'Global-Global Layout';
        result.records = new List<MetaDataService.Layout>{record};
        MetaDataService.readLayoutResponse_element responseEl = new MetaDataService.readLayoutResponse_element();
        responseEl.result = result;

        responsesByResponseType.put('MetadataService.readLayoutResponse_element', responseEl);

        MetaDataService.SaveResult updateSaveResult = new MetaDataService.SaveResult();
        updateSaveResult.success = true;
        MetaDataService.updateMetadataResponse_element updateResponseEl = new MetaDataService.updateMetadataResponse_element();
        updateResponseEl.result = new List<MetaDataService.SaveResult>{updateSaveResult};

        responsesByResponseType.put('MetadataService.updateMetadataResponse_element', updateResponseEl);

        Test.startTest();
        Test.setMock(WebServiceMock.class, new successWebCallout());
        String jsonString = updateLayoutsStep.updateLayouts('Global-Global Layout', true, true);
        Test.stopTest();

        Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        System.assertEquals(true, (Boolean)parsedRes.get('isSuccess'));
    }

    @isTest static void noLayoutFound() {
        MetaDataService.ReadLayoutResult result = new MetaDataService.ReadLayoutResult();
        MetaDataService.Layout record = new MetaDataService.Layout();
        result.records = new List<MetaDataService.Layout>{record};
        MetaDataService.readLayoutResponse_element responseEl = new MetaDataService.readLayoutResponse_element();
        responseEl.result = result;

        responsesByResponseType.put('MetadataService.readLayoutResponse_element', responseEl);

        Test.startTest();
        Test.setMock(WebServiceMock.class, new successWebCallout());
        String jsonString = updateLayoutsStep.updateLayouts('Account-Fake', true, true);
        Test.stopTest();

        Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        System.assertEquals(false, (Boolean)parsedRes.get('isSuccess'));
        System.assertEquals('Unable to find layout : Fake', (String)parsedRes.get('error'));
    }

    @isTest static void failLayoutUpdate() {
        MetaDataService.ReadLayoutResult result = new MetaDataService.ReadLayoutResult();
        MetaDataService.Layout record = new MetaDataService.Layout();
        record.fullName = 'Account-Account Layout';
        result.records = new List<MetaDataService.Layout>{record};
        MetaDataService.readLayoutResponse_element responseEl = new MetaDataService.readLayoutResponse_element();
        responseEl.result = result;

        responsesByResponseType.put('MetadataService.readLayoutResponse_element', responseEl);

        MetaDataService.Error error = new MetaDataService.Error();
        error.message = 'fail err msg';

        MetaDataService.SaveResult updateSaveResult = new MetaDataService.SaveResult();
        updateSaveResult.success = false;
        updateSaveResult.errors = new List<MetaDataService.Error>{error};
        MetaDataService.updateMetadataResponse_element updateResponseEl = new MetaDataService.updateMetadataResponse_element();
        updateResponseEl.result = new List<MetaDataService.SaveResult>{updateSaveResult};

        responsesByResponseType.put('MetadataService.updateMetadataResponse_element', updateResponseEl);

        Test.startTest();
        Test.setMock(WebServiceMock.class, new failWebCallout());
        String jsonString = updateLayoutsStep.updateLayouts('Account-Account Layout', true, true);
        Test.stopTest();

        Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        System.assertEquals(false, (Boolean)parsedRes.get('isSuccess'));
        System.assertEquals('Account Layout', (String)parsedRes.get('error'));
    }
}