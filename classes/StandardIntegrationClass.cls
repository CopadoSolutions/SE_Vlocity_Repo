/***
* @group ATG
*
* @description The StandardIntegrationClass is a virtual class to be extended by any <br>
* Integration Processing Class set in the Callout Metadata <br>
* Global - visible outside the package. <br>
* With sharing - sharing rules will apply based on user profile.<br>
**/
global virtual with sharing class StandardIntegrationClass {

	global virtual void preOutbound(CalloutItem__c callItem) {
	}

	global virtual void postOutbound(CalloutItem__c callItem) {		
	}

	global virtual void preResult(CalloutItem__c callItem) {		
	}

	global virtual void postResult(CalloutItem__c callItem) {		
	}

	/**
	* @description  Virtual method that does standard transformation of the URI <br>
	* based on the TransformURL DR bundle <br>
	* Right now this only uses first level map items.
	* @param CalloutItem object
	* @return String (transformed URI)
	*/  
	global virtual string transformURI(CalloutItem__c callItem) {
		String retval = callItem.URI__c;
		if (retval == null) {
			return '';
		}
		Map<String,Object> items;
		String token;
		Map<String,Object> context = (Map<String,Object>)JSON.deserializeUntyped(callItem.CalloutContext__c);
System.debug(':::Callout body ' + callItem.CalloutContext__c);
		if (callItem.TransformURLDRBundle__c != null) {
			vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(context, callItem.TransformURLDRBundle__c);

			items = (Map<String,Object>)result.toJson();

			for (String key: items.keySet()) {
				token = '{' + key + '}';
				retval = retval.replace(token, (String)items.get(key));
			}
		}
System.debug(':::post DR URL ' + retval);
			// do the same thing for context to make it easy for developers.
		for (String key: context.keySet()) {
			token = '{' + key + '}';
			if (context.get(key) instanceOf String) {
				retval = retval.replace(token, (String)context.get(key));
			}
		}
System.debug(':::post context URL ' + retval);
		callItem.URI__c = retval;
		return retval;
	}
}