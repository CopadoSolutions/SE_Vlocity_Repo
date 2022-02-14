@RestResource(urlMapping='/Callout/*')
global with sharing class Callout {
	public Callout() {
		
	}

	global static CalloutItem__c makeCallout(String CalloutName,Object context) {
		CalloutItem__c callItem 	= new CalloutItem__c();
		callItem.Name 				= CalloutName;
		callItem.CalloutContext__c 	= JSON.serialize(context);
system.Debug('BBBBB ' + callItem);		
		return Callout.makeCallout(callItem);
	}

	global static CalloutItem__c makeCallout(CalloutItem__c callItem) {
		try {
			StandardIntegrationProcess.processOutbound(callItem);
		} catch (Exception e) {
			// This message displayed in External Object RL if error
			callItem.ResponseMessage__c = ' **** Exception - Please notify your System Administrator';
	    	callItem.ResponseMessage__c += '\nMessage: ' + e.getMessage();     
	    	callItem.ResponseMessage__c += '\nStack trace: ' + e.getStackTraceString();
	    	callItem.Status__c = 'Failed';
		}
		if (callItem.PersistCalloutData__c) {
			upsert callItem;
		}
		return callItem;		
	}

	@future(callout=true)
	global static void makeCalloutFuture(String CalloutName,Id context) {
		Object contextObject = JSON.deserializeUntyped('{"Id" :"' + context + '"}');
		Callout.makeCallout(CalloutName, contextObject);
	}

	@future(callout=true)
	global static void makeCalloutFuture(String CalloutName,String context) {
		Object contextObject = JSON.deserializeUntyped(context);
		Callout.makeCallout(CalloutName, contextObject);
	}

	global static CalloutItem__c makeCalloutQueue(String CalloutName,Object context) {
		CalloutItem__c callItem 	= new CalloutItem__c();
		callItem.Name 				= CalloutName;
		callItem.CalloutContext__c 	= JSON.serialize(context);
		callItem.Status__c 			= 'Queued';
		insert callItem;
		return callItem;		
	}

	global static void saveCallout(CalloutItem__c ci) {
		Callout.saveCallout(JSON.serialize(ci));
	}

	@future
	global static void saveCallout(String callout) {
		CalloutItem__c ci = (CalloutItem__c)JSON.deserialize(callout, CalloutItem__c.class);
		upsert ci;
	}

/*  not in use curently.  Commenting out for test coverage
	@HttpGet
    global static String doGet() {
        //https://demo5147681.mockable.io/quicktest

        Integer i = 0;
     
        //Set HTTPRequest Method
		RestRequest req = RestContext.request;
	    RestResponse res = RestContext.response;
		String command = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		if (command == 'GetNext') {
			CalloutItem__c callItem = [Select id,Status__c from CalloutItem__c where Status__c = 'Queued' limit 1 For Update];
			callItem.Status__c = 'In Progress';
			update callItem;
			return callItem.id;
		} else {
			CalloutItem__c callItem = [Select id,Name ,CalloutContext__c from CalloutItem__c where id=:command];
			callItem = makeCallout(callItem);
			return JSON.serialize(callItem);
		}
	}
	*/

}