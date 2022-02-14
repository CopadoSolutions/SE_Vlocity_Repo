@isTest
private class DBHelperTest {
	
	@isTest static void TestAll() {
		Account act = new Account();
		act.Name = 'Test';
		insert act;

		// Implement test code
		DBHelper.query('Account','');
		DBHelper.getFieldsNoAddress('Account');
		DBHelper.getFieldLabelsNoAddress('Account');
		System.debug([SELECT id FROM Account LIMIT 1]);
		Id theId = [SELECT id FROM Account LIMIT 1][0].Id;
		DBHelper.buildQueryFromId(theId,'Account=1234');
	}
	
	
}