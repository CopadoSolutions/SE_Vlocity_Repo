global virtual with sharing class StandardInterfaceClassXMLOut extends StandardIntegrationClass {

	//do nothing
	/*
	global void preOut(CalloutItem__c callout) {
	}
	*/

	global virtual override void postOutbound(CalloutItem__c callout) {
		String body = callout.CalloutBody__c;
		String newBody = JsonToXml.convertJsonToXml(body);
		callout.CalloutBody__c = newBody;
	}

	global virtual override void preResult(CalloutItem__c callout) {
		String body = callout.ResponseMessageRaw__c;
		//String newBody = XmlToJson.convertXMLToJson(body);
		Map<String,Object> temp = XMLToJson.ParseXML(body);
		Object temp2 = temp.get('json');
		callout.ResponseMessage__c = JSON.serialize(temp2);	
	}

	//do nothing
	/*
	global void postIn(CalloutItem__c callout) {
		
	}
	*/
}