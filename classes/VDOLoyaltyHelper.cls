global class VDOLoyaltyHelper implements vlocity_cmt.VlocityOpenInterface2{

    public Object InvokeMethod(String methodName,Map <String, Object> input,Map <String, Object> output,Map <String, Object> options){
        
        if(methodName == 'getMember'){
            List<Contact> c = [SELECT loyalty_member_id__c FROM Contact WHERE id = :(String)input.get('cid') LIMIT 1];
            if(c.size() > 0){
                output.put('result', makeGetCallout(c[0].loyalty_member_id__c, (String)input.get('URL'), (String)input.get('querystring')));
            }
        }
        else if(methodName == 'postActivity'){
            List<Contact> c = [SELECT loyalty_member_id__c FROM Contact WHERE id = :(String)options.get('cid') LIMIT 1];
            if(c.size() > 0){
                output.put('result', makePostCallout(c[0].loyalty_member_id__c, (String)options.get('URL'), (String)options.get('payload')));
            }
        }

        return true;
    }
    
    @RemoteAction
    global static String authenticateLoyalty() {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://vlocity-telco.demostellar.com/oauth/token?grant_type=client_credentials&client_id=601aa53054177cedb2ca1a8c92a605db65094a1de007b60240066a6b16c7d168&client_secret=556323aecbc88d7b72efb9a70bad43a5ef04f7972bb2d28a1bc9e416c56f2a6f');
        req.setMethod('POST');
        req.setHeader('Accept', 'application/vnd.stellar-v1+json');
        HttpResponse res = h.send(req);
        Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
        return (String)result.get('access_token');
    }
    
    @RemoteAction
    global static Object makeGetCallout(String memberid, String url, String querystring) {
        url = url.replace('cid', memberid);
        querystring = querystring.replace('cid', memberid);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url + '?access_token=' + authenticateLoyalty() + querystring);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/vnd.stellar-v1+json');
        HttpResponse res = h.send(req);
        Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
        return result;         
    }

    @RemoteAction
    global static Object makePostCallout(String memberid, String url, String payload) {
        url = url.replace('cid', memberid);
        payload = payload.replace('cid', memberid);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url + '?access_token=' + authenticateLoyalty() + payload);
        req.setMethod('POST');
        req.setHeader('Accept', 'application/vnd.stellar-v1+json');
        HttpResponse res = h.send(req);
        Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
        return result;         
    }

}