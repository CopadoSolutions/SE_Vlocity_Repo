/***
* @group ATG
*
* @description The StandardIntegrationProcess class used to implement callouts to external <br>
* systems based on details described in the CalloutMetadata and CalloutItem objects  <br>
* Global - visible outside the package. <br>
* With sharing - sharing rules will apply based on user profile.<br>
**/
global with sharing class StandardIntegrationProcess {
	Map<String,Object> context;
	String calloutName;
	CalloutMetadata__c calloutMdt;
	CalloutItem__c callItem;
	StandardIntegrationClass sic;

	/**
	* @description  Constructor for the StandardIntegrationProcess that obtains the details <br>
	* of the callout - the HTTP action, class, DR Bundles, Remote Site and URI information
	* @param CalloutItem object
	*/  

	global StandardIntegrationProcess(CalloutItem__c callItem) {
		this.callItem = callItem;
		context = (Map<String,Object>)JSON.deserializeUntyped(callItem.CalloutContext__c);
 system.debug(':::context: ' + context);
 		calloutName = callItem.Name;
 		List<String> intFields 	= DBHelper.getFieldsNoAddress('CalloutMetadata__c');
		String soql = 'SELECT '  + String.join(intFields, ',') 
						+ ',OutboundDataRaptorBundleId__r.Name'
						+ ',ResultDataRaptorBundleId__r.Name'
						+ ',TransformURLDataRaptorBundleId__r.Name'
						+ ' FROM CalloutMetadata__c WHERE Name = :calloutName LIMIT 1';
		calloutMdt = database.query(soql);


		// map meta data to calloutItem.  Potentially remove the need for the class.
		// perhaps field mapper could work here.
		callItem.HTTPAction__c 					= calloutMDT.HTTPAction__c;
		callItem.IntegrationProcessingClass__c 	= calloutMDT.IntegrationProcessingClass__c;
		callItem.OutboundDRBundleName__c 		= calloutMDT.OutboundDataRaptorBundleId__r.Name;
		callItem.PersistCalloutData__c 			= calloutMDT.PersistCalloutData__c;
		callItem.ResultDRBundleName__c 			= calloutMDT.ResultDataRaptorBundleId__r.Name;
		callItem.TransformURLDRBundle__c 		= calloutMDT.TransformURLDataRaptorBundleId__r.Name;
		callItem.URI__c 						= calloutMDT.URI__c;
		callItem.CalloutMetadataId__c           = calloutMdt.Id;
		callItem.SystemId__c                    = calloutMdt.SystemId__c;
		
		sic = getStandardIntegrationClass(callItem);
	}

	/**
	* @description Method that processes the callout - makes the call to the remote site, <br>
	*  pre and post processes the request and response  by making the calls to DR bundles defined. <br>
	*  Updates the Callout Item record with the details of the response
	* @param CalloutItem object
	*/ 
	global static void processOutbound(CalloutItem__c callItem) {

		StandardIntegrationProcess sip = new StandardIntegrationProcess(callItem);
		
system.debug(':::process:callItem: ' + callItem);
		StandardIntegrationClass sic = sip.sic;

        Integer resultCode;   
		MAp<String,Object> context = (Map<String,Object>)JSON.deserializeUntyped(callItem.CalloutContext__c);
////  OutboundDRPost
        List<Map<String, Object>> objectList = new List<Map<String, Object>>();

		sic.preOutbound(callItem);
		if (callItem.OutboundDRBundleName__c != null) {

			vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(context, callItem.OutboundDRBundleName__c);

			String reqBody = JSON.Serialize(result.toJson());
system.debug(':::reqBody1: ' + reqBody);
			callItem.CalloutBody__c = reqBody;
		}

		sic.postOutbound(callItem);

////// Actual call out here
        HttpResponse res = sip.getResponse(callItem);

		String respBody = res.getBody();
system.debug(':::responseBodyOrig: ' + respBody.left(150));

 		callItem.ResponseMessageRaw__c = respBody;
        callItem.ResponseMessage__c = respBody;

        callItem.HTTPStatus__c = res.getStatus();
        callItem.HTTPStatusCode__c = res.getStatusCode();

        if (res.getStatusCode() != 200) {
        	callItem.Status__c = 'Failed';

        	throw new calloutException('Error in callout');

        	// Bill need to collect the codes.  callItem.ResponseMessage__c;
        	if (callItem.PersistCalloutData__c) {
        		upsert callItem;
        	}
        	// BC probably throw exception
        	return;
        }

    	if (callItem.PersistCalloutData__c) {
    		upsert callItem;
    	}
 
        sic.preResult(callItem);
  system.debug(':::RespMsg.length: ' + callItem.ResponseMessage__c.length());
////  when get DR bundle working maybe won'e have any rows so won't need this check
        if(callItem.Status__c == 'No Rows'){
        	if (!Test.isRunningTest()) {
        		return;
        	}
        }

		if (callItem.ResultDRBundleName__c != null) {

			// test code gets here but not through the next line.  Don't know why        	
        	Map<String,Object> respJson = (Map<String,Object>)JSON.deserializeUntyped(callItem.ResponseMessage__c);
system.debug(':::respJson: ' + respJson);
			respJson.put('CalloutContext', sip.context);
			callItem.ResponseMessage__c = JSON.serialize(respJson);
		// call Data raptor
			vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(respJson, callItem.ResultDRBundleName__c);

			callItem.ResponseMessage__c = JSON.Serialize(result.toJson());
system.debug(':::RespMsg after DR: ' + callItem.ResponseMessage__c);
		}
        sic.postResult(callItem);

		callItem.Status__c = 'Succeeded';

    	if (callItem.PersistCalloutData__c) {
    		upsert callItem;
    	}
 	}

	/**
	* @description  Method that gets an instance of the StandardIntegrationClass as defined <br>
	* in the IntegrationProcessingClass__c field of the Callout Item record
	* @param CalloutItem object.
	* @return The instance of the StandardIntegration class
	*/  

	StandardIntegrationClass getStandardIntegrationClass(CalloutItem__c callItem) {
		StandardIntegrationClass retval = new StandardIntegrationClass();
       	if (calloutMdt.IntegrationProcessingClass__c != null) {
        	// transformClass = 'SimpleTransformation'
        	String transformClass = calloutMdt.IntegrationProcessingClass__c;
			Type t = Type.forName(transformClass);

			// This is the virtual class which SimpleTransformation extends
			StandardIntegrationClass st = (StandardIntegrationClass)t.newinstance();
			retval = st;
		} 

		return retval;
	}

	/**
	* @description  Method that gets the HTTPResponse for the callout made based on the <br>
	*  details in the Callout Item record
	* @param CalloutItem object
	* @return HttpResponse
	*/  

	HttpResponse getResponse(CalloutItem__c callItem) {

		Map<String, String> headerMap = new Map<String, String>();
		if (callItem.OutboundHeaders__c != null) {
			headerMap = (Map<String, String>)JSON.deserializeUntyped(callItem.OutboundHeaders__c);
		}

		List<CalloutMetadataHeader__c> hdrLst = [SELECT Name, Value__c FROM CalloutMetadataHeader__c 
				WHERE SystemId__c = :callItem.SystemId__c ];
system.debug(':::hdrLst: ' + hdrLst);
		for (CalloutMetadataHeader__c item : hdrLst){
			headerMap.put(item.Name, item.Value__c);
		}
		hdrLst = [SELECT Name, Value__c FROM CalloutMetadataHeader__c
			WHERE CalloutMetadataId__c = :callItem.CalloutMetadataId__c];
		for (CalloutMetadataHeader__c item : hdrLst){
			headerMap.put(item.Name, item.Value__c);
		}

system.debug(':::headerMap ' + headerMap);

		callItem.OutboundHeaders__c = JSON.serialize(headerMap);
system.debug(':::CI.Headers: ' + callItem.OutboundHeaders__c);

        HTTP objhttp = new Http();
        HTTPRequest req = new HttpRequest();
        HTTPResponse res = new HttpResponse(); 

        String formattedURI = callItem.URI__c;
 		formattedURI = sic.transformUri(callItem);
system.debug(':::formattedURIafter : ' + formattedURI);
        callItem.URI__c = formattedURI;

        System__c ip = [SELECT Id, URL__c FROM System__c WHERE Id = :callItem.SystemId__c LIMIT 1];
        String call = ip.URL__c + callItem.URI__c;

        Set <String> keySet = new Set<String>();
        keySet = headerMap.keySet();
        for (String item : keySet){
            req.setHeader(item, headerMap.get(item));
        }

        req.setMethod(callItem.HTTPAction__c);
system.debug(':::call: ' + call);
        req.setEndpoint(call);
        req.setTimeout(120000);

		if (callItem.CalloutBody__c != null) {
			req.setBody(callItem.CalloutBody__c);
			callItem.CalloutBody__c = req.getBody();
		}
		callItem.URI__c = call;

		//Bill -- Not catching exception here since we want to capture the error in the Callout class
       
		if (Test.isRunningTest()) {
            String body = '<Hello World><ObjectId>MtxId123</ObjectId><MtxRequired><ResourceId>2</ResourceId>';
            res.setStatus('OK') ;
            res.setStatusCode(200);
            res.setBody(body);
            res.setHeader('Key', 'Value');
        } 
        else {
            res = objhttp.send(req);
        }

        List<String> hdrKeys = res.getHeaderKeys();
        Map<String, String> hdrMap = new Map<String, String>();
		for (String key : hdrKeys){
			if (key == null){
				continue;
			}
			String keyVal = res.getHeader(key);

			hdrMap.put(key, keyVal);
		}
		callItem.ResponseHeaders__c = JSON.serialize(hdrMap);

system.debug(':::headers: ' + hdrMap);

        return res;
	}

	public class calloutException extends Exception {}


}