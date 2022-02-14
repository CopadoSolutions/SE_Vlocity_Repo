@isTest(SeeAllData=false)
public with sharing class StandardIntegrationTest {

	private static testMethod void testIntegrationCode(){
		vlocity_cmt__TriggerSetup__c myTrigger = new vlocity_cmt__TriggerSetup__c(Name='AllTriggers', vlocity_cmt__IsTriggerOn__c=true);
        insert myTrigger;
		System__c sys = new System__c (Name = 'Matrixx', URL__c = 'http://52.53.210.16:8080');
		insert sys;

		CalloutMetadataHeader__c hdr = new CalloutMetadataHeader__c (
			Name = 'HeaderName',
			Value__c = 'HeaderValue',
			SystemId__c = sys.Id
		);
		insert hdr;

		vlocity_cmt__DRBundle__c transformURLDR = new vlocity_cmt__DRBundle__c(
			Name = 'AccountGetOID',
			vlocity_cmt__DRMapName__c = 'AccountGetOID',
			vlocity_cmt__InputJson__c = '',
			vlocity_cmt__InterfaceObject__c = 'json' ,
			vlocity_cmt__Type__c = 'Extract (JSON)'
		);
		insert transformURLDR;

		vlocity_cmt__DRBundle__c subsCreateDR = new vlocity_cmt__DRBundle__c(
			Name = 'SubscriberCreate',
			vlocity_cmt__DRMapName__c = 'SubscriberCreate',
			vlocity_cmt__InputJson__c = '',
			vlocity_cmt__InterfaceObject__c = 'json' ,
			vlocity_cmt__Type__c = 'Extract (JSON)'
		);
		insert subsCreateDR;

		vlocity_cmt__DRBundle__c acctUpdDR = new vlocity_cmt__DRBundle__c(
			Name = 'AccountCreateResponse',
			vlocity_cmt__DRMapName__c = 'AccountCreateResponse',
			vlocity_cmt__InputJson__c = '{ "AId": "12345", "$": "MtxResponseCreate", "DomainId": 1, "ObjectId": "0-1-5-49", "Result": 0, "ResultText": "OK", "_resultCode": 0, "_resultText": "OK", "_resultType": "create", "CalloutContext": { "Id": "1234" } }',
			vlocity_cmt__InterfaceObject__c = 'json' ,
			vlocity_cmt__Type__c = 'Load (JSON)'
		);
		insert acctUpdDR;

		vlocity_cmt__DRBundle__c subBalDR = new vlocity_cmt__DRBundle__c(
			Name = 'MatrixxBalance',
			vlocity_cmt__DRMapName__c = 'MatrixxBalance',
			vlocity_cmt__InputJson__c = '{ "AId": "12345", "$": "MtxResponseCreate", "DomainId": 1, "ObjectId": "0-1-5-49", "Result": 0, "ResultText": "OK", "_resultCode": 0, "_resultText": "OK", "_resultType": "create", "CalloutContext": { "Id": "1234" } }',
			vlocity_cmt__InterfaceObject__c = 'json' ,
			vlocity_cmt__TargetOutJson__c = '{ "value": [ { "AccountKey": "", "Id": "", "Amount": "", "AvailableAmount": "", "CreditLimit": "", "DisplayQuantityUnit": "", "Name": "", "ThresholdLimit": "", "ResourceId": "" } ] }',
			vlocity_cmt__Type__c = 'Transform'
		);
		insert subBalDR;

		CalloutMetadata__c subsCreateMdt = new CalloutMetadata__c (
			Name = 'SubscriberCreate',
			SystemId__c = sys.Id,
			HTTPAction__c = 'POST',
			OutboundDataRaptorBundleId__c = subsCreateDR.Id,
			ResultDataRaptorBundleId__c = acctUpdDR.Id,
			IntegrationProcessingClass__c = 'ExternalObjectProcessing',
			URI__c = '/rsgateway/data/json/subscriber',
			PersistCalloutData__c = TRUE
			);
		insert subsCreateMdt;

		CalloutMetadata__c balanceGetMdt = new CalloutMetadata__c (
			Name = 'SubscriptionBalance-Query',
			SystemId__c = sys.Id,
			HTTPAction__c = 'GET',
			OutboundDataRaptorBundleId__c = subBalDR.Id,
			ResultDataRaptorBundleId__c = acctUpdDR.Id,
			TransformURLDataRaptorBundleId__c = transformURLDR.Id,
			IntegrationProcessingClass__c = 'ExternalObjectProcessing',
			URI__c = '/rsgateway/data/json/service/{AccountType}/ObjectId+{AccountOID}',
			PersistCalloutData__c = TRUE
			);
		insert balanceGetMdt;

		List<CalloutMetadata__c> lst = [Select Id FROM CalloutMetadata__c];
 		System.assert (lst.size() == 2);		

		Test.startTest();

		// subscriber with no contact but does have phone
		// this insert tests most of the integration code
		Account testSubs = new Account(Name = 'TestSubs', Phone = '111222333', 
			ServiceSharingType__c = 'Individual');
		insert testSubs;

		// tests sic.trasnformUri()
		CalloutItem__c callItem = new CalloutItem__c(
			Name = 'SubscriptionBalance-Query',
			SystemId__c = sys.Id,
			CalloutContext__c = '{"Id":"' + testSubs.Id + '"}',
			TransformURLDRBundle__c = 'AccountGetOID',
			URI__c = '/rsgateway/data/json/service/{AccountType}/ObjectId+{AccountOID}'
		);
		insert callItem;

		String formattedURI = 'StringToFormat';
		try {			
			StandardIntegrationClass sic = getStandardIntegrationClass(callItem);
	 		formattedURI = sic.transformUri(callItem);
		} catch (Exception e) {}
		
 		// test rest of Callout.cls
 		Callout.makeCalloutFuture(callItem.Name, '{"Id":"' + testSubs.Id + '"}');

 		Callout.makeCalloutQueue(callItem.Name, '{"Id":"' + testSubs.Id + '"}');

 		Callout.saveCallout(callItem);
 		
 	// wrong parameter for call.  It isn't working in test code. Not called anywhere yet
 	//	Callout.saveCallout(callItem.Name);

		Test.stopTest();
	}
		
	static StandardIntegrationClass getStandardIntegrationClass(CalloutItem__c callItem) {
		StandardIntegrationClass retval = new StandardIntegrationClass();

		CalloutMetadata__c calloutMdt = new CalloutMetadata__c (
			Name = 'SubscriptionBalance-Query',
			//SystemId__c = sys.Id,
			HTTPAction__c = 'GET',
			//OutboundDataRaptorBundleId__c = subBalDR.Id,
			//ResultDataRaptorBundleId__c = acctUpdDR.Id,
			//TransformURLDataRaptorBundleId__c = transformURLDR.Id,
			IntegrationProcessingClass__c = 'ExternalObjectProcessing',
			URI__c = '/rsgateway/data/json/service/{AccountType}/ObjectId+{AccountOID}',
			PersistCalloutData__c = TRUE
		);
		insert calloutMdt;
system.debug('::calloutMdt: ' + calloutMdt);
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
		//Callout.makeCalloutFuture('SubscriberCreate', item.id);
	//}
}