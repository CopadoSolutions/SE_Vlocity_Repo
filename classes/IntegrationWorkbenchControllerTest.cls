@isTest
private class IntegrationWorkbenchControllerTest {

	Static String contents = '<?xml version="1.0" encoding="UTF-8"?>'
+ '<env:Envelope'
+ '    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"'
+ '    xmlns:xsd="http://www.w3.org/2001/XMLSchema"'
+ '    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
+ '    <env:Header />'
+ '    <env:Body>'
+ '        <ContractGetSummary'
+ '            xmlns="http://www.csc.com/graphtalk/aia/">'
+ '            <Environment>'
+ '                <EffectiveDate>2017-02-10</EffectiveDate>'
+ '                <Language>italian</Language>'
+ '                <UserID>KTONEV</UserID>'
+ '            </Environment>'
+ '            <Contract>'
+ '                <StartDate xsi:nil="true" />'
+ '                <Number>300000004000010</Number>'
+ '                <RoleList />'
+ '                <SignatureDate xsi:nil="true" />'
+ '            </Contract>'
+ '        </ContractGetSummary>'
+ '    </env:Body>'
+ '</env:Envelope>'
;
	
	@isTest static void TestDR() {
		IntegrationWorkbenchController controller = new IntegrationWorkbenchController();
		ApexPages.currentPage().getParameters().put('fileName', 'testFile');
		ApexPages.currentPage().getParameters().put('fileContents', IntegrationWorkbenchControllerTest.contents);
		controller.transformXML2();
		String attachId = controller.attachId;
		String rawId = controller.rawId;
		System.debug('BBBBB attachId ' + attachId);
		System.debug('BBBBB rawId ' + rawId);
		IntegrationWorkbenchController.makeDRIn('inDRTest',attachId,rawId);
		IntegrationWorkbenchController.makeDROut('inDRTest',attachId,rawId);
		IntegrationWorkbenchController.getXPath('//Contract',rawId);
	}
	
	@isTest static void TestRemoteActions() {
		IntegrationWorkbenchController.getDocuments();
		IntegrationWorkbenchController.getDataRaptors();
		IntegrationWorkbenchController.describeObject('Account');
		IntegrationWorkbenchController.TransformXML(IntegrationWorkbenchControllerTest.contents);

		// Implement test code
	}
	
}