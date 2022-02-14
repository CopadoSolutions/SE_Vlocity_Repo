@isTest
private with sharing class CalloutTest {
	
	@isTest static void TestCallout() {
		// Implement test code
		System__c sys = new System__c();
		sys.Name = 'TestSystem';
		sys.URL__C = 'http://www.google.com';
		insert sys;
		List<vlocity_cmt__drbundle__c> drb = [select id from vlocity_cmt__drbundle__c];
		CalloutMetadata__c cmd = new CalloutMetadata__c();
		cmd.Name = 'testCallout';
		cmd.HTTPAction__c = 'Post';
//		cmd.IntegrationProcessingClass__c = 'StandardInterfaceClassXMLOut';
		cmd.OutboundDataRaptorBundleId__c = 'a0x0P00000BMf7gQAD';
		cmd.ResultDataRaptorBundleId__c = 'a0x0P00000BMf7gQAD';
		cmd.TransformURLDataRaptorBundleId__c = 'a0x0P00000BMf7gQAD';
		cmd.SystemId__c = sys.Id;
		cmd.URI__c = '/12345/{test1}';
		insert cmd;

		String temp = '{"Id":"00112345678912"}';
		Object o = JSON.deserializeUntyped(temp);
		System.debug('BBBBB before send ' + temp);

		callout.makeCallout('testCallout',o);
	}
/*	
	@isTest static void TestMakeCallout() {
		String temp = '{"Id" : "0010P00001oI6RG"}';
		Object o = JSON.deserializeUntyped(temp);
		System.debug('BBBBB before send ' + temp);
		callout.makeCallout('SubscriberGetBalances', o);
	}
*/	
}