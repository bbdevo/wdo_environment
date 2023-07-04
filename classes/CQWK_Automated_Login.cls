public class CQWK_Automated_Login {

    public PageReference routeToReport() {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://cq-proxy.herokuapp.com/getToken?orgid=00D5w0000079XE3EAM&username=sfdcdemo@blitz-data.cq.com&CQKey=TestCQKey&CQSecret=TestCQSecret');
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        String response = res.getBody();
        Map<String, Object> resp = (Map<String, Object>)JSON.deserializeUntyped(response);
        String accessToken = (String) resp.get('accessToken');
        String instanceUrl = (String) resp.get('instanceUrl');
        String retUrl =     ApexPages.currentPage().getParameters().get('redirectTo');
        String fv0 = ApexPages.currentPage().getParameters().get('fv0');
        if(!String.isBlank(fv0)) {
            retUrl = retUrl + '&fv0=' + EncodingUtil.urlEncode(fv0, 'UTF-8');
        }

        String finalUrl = instanceUrl + '/secur/frontdoor.jsp?sid=' + EncodingUtil.urlEncode(accessToken, 'UTF-8') + '&retURL=' + EncodingUtil.urlEncode(retUrl, 'UTF-8');
        PageReference pr = new PageReference(finalUrl); 
        
        return pr;
    }
}