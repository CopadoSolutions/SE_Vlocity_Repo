@isTest
public with sharing class XMLHelperFuncWalletTest {
	static String wallet = '<MtxResponseWallet><BalanceArray><MtxBalanceInfoSimple><ThresholdArray><MtxThresholdInfo><ThresholdId>95</ThresholdId><Name>postpaidFamilySpendLimit</Name><Amount>100.0000</Amount><IsPct>false</IsPct><IsRecurring>false</IsRecurring><IsCreditLimit>true</IsCreditLimit><IsCustom>false</IsCustom><NotificationState>true</NotificationState><Type>Notify_Gross,Notify_BalIncr</Type><GroupNotificationPreference>Use_Group_Setting</GroupNotificationPreference></MtxThresholdInfo></ThresholdArray><SimpleBalanceGrantCreditFloorAdjust>grant_amount_plus_balance_amount</SimpleBalanceGrantCreditFloorAdjust><ResourceId>1</ResourceId><Amount>18.9800</Amount><ReservedAmount>0.0000</ReservedAmount><CreditLimit>100.0000</CreditLimit><ThresholdLimit>100.0000</ThresholdLimit><AvailableAmount>81.0200</AvailableAmount><TemplateId>21007</TemplateId><Name>PostpaidEuro</Name><ClassId>978</ClassId><ClassName>Euro</ClassName><Category>1</Category><IsPrepaid>false</IsPrepaid><IsPeriodic>false</IsPeriodic><IsAggregate>true</IsAggregate><IsVirtual>false</IsVirtual><QuantityUnit>none</QuantityUnit></MtxBalanceInfoSimple><MtxBalanceInfoSimple><ThresholdArray><MtxThresholdInfo><ThresholdId>15</ThresholdId><Name>familyAdminThreshold</Name><Amount>0.0000</Amount><IsPct>false</IsPct><IsRecurring>false</IsRecurring><IsCreditLimit>true</IsCreditLimit><IsCustom>false</IsCustom><NotificationState>true</NotificationState><Type>Notify_Gross,Notify_BalIncr,Notify_IncrEq</Type><GroupNotificationPreference>Use_Group_Setting</GroupNotificationPreference></MtxThresholdInfo><MtxThresholdInfo><ThresholdId>90</ThresholdId><Name>subscriberPersonalizedThreshold</Name><Amount>0.0000</Amount><IsPct>false</IsPct><IsRecurring>false</IsRecurring><IsCreditLimit>false</IsCreditLimit><IsCustom>false</IsCustom><NotificationState>true</NotificationState><Type>Notify_Gross,Notify_BalIncr,Notify_IncrEq</Type><GroupNotificationPreference>Use_Group_Setting</GroupNotificationPreference></MtxThresholdInfo></ThresholdArray><SimpleBalanceGrantCreditFloorAdjust>grant_amount_plus_balance_amount</SimpleBalanceGrantCreditFloorAdjust><ResourceId>2</ResourceId><Amount>-1015.0000</Amount><ReservedAmount>0.0000</ReservedAmount><CreditLimit>0.0000</CreditLimit><ThresholdLimit>1015.0000</ThresholdLimit><AvailableAmount>1015.0000</AvailableAmount><TemplateId>21011</TemplateId><Name>D1000PO-Domestic-Balance</Name><ClassId>20008</ClassId><ClassName>Data</ClassName><Category>2</Category><IsPrepaid>true</IsPrepaid><IsPeriodic>false</IsPeriodic><IsAggregate>false</IsAggregate><IsVirtual>false</IsVirtual><StartTime>2016-07-12T18:00:57.000000Z</StartTime><EndTime>2016-08-12T18:00:57.000000Z</EndTime><QuantityUnit>megabytes</QuantityUnit></MtxBalanceInfoSimple><MtxBalanceInfoSimple><ThresholdArray><MtxThresholdInfo><ThresholdId>11</ThresholdId><Name>familyAdminThreshold</Name><Amount>0.0000</Amount><IsPct>false</IsPct><IsRecurring>false</IsRecurring><IsCreditLimit>true</IsCreditLimit><IsCustom>false</IsCustom><NotificationState>true</NotificationState><Type>Notify_Gross,Notify_BalIncr,Notify_BalDecr,Notify_IncrEq,Notify_DecrEq</Type><GroupNotificationPreference>Use_Group_Setting</GroupNotificationPreference></MtxThresholdInfo><MtxThresholdInfo><ThresholdId>80</ThresholdId><Name>subscriberPersonalizedThreshold</Name><Amount>0.0000</Amount><IsPct>false</IsPct><IsRecurring>false</IsRecurring><IsCreditLimit>false</IsCreditLimit><IsCustom>false</IsCustom><NotificationState>true</NotificationState><Type>Notify_Gross,Notify_BalIncr,Notify_BalDecr,Notify_IncrEq,Notify_DecrEq</Type><GroupNotificationPreference>Use_Group_Setting</GroupNotificationPreference></MtxThresholdInfo></ThresholdArray><SimpleBalanceGrantCreditFloorAdjust>grant_amount_plus_balance_amount</SimpleBalanceGrantCreditFloorAdjust><ResourceId>3</ResourceId><Amount>-500.0000</Amount><ReservedAmount>0.0000</ReservedAmount><CreditLimit>0.0000</CreditLimit><ThresholdLimit>500.0000</ThresholdLimit><AvailableAmount>500.0000</AvailableAmount><TemplateId>21008</TemplateId><Name>V500PO-MTX-Balance</Name><ClassId>20006</ClassId><ClassName>Voice</ClassName><Category>2</Category><IsPrepaid>true</IsPrepaid><IsPeriodic>false</IsPeriodic><IsAggregate>false</IsAggregate><IsVirtual>false</IsVirtual><StartTime>2016-07-12T18:00:57.000000Z</StartTime><EndTime>2016-08-12T18:00:57.000000Z</EndTime><QuantityUnit>minutes</QuantityUnit></MtxBalanceInfoSimple></BalanceArray><Result>0</Result><ResultText>OK</ResultText></MtxResponseWallet>';

	@isTest
	static void balanceNodesTest() {
        /*
		String path = '/MtxResponseWallet/BalanceArray/MtxBalanceInfoSimple';

		Dom.Document doc = new Dom.Document();
		doc.load(wallet);
		Map<String, Dom.XmlNode> foundNodes = XMLHelperFunctions.getXPath(path, doc);
//system.debug('foundNodes: ' + foundNodes);

		Integer cnt = foundNodes.keySet().size();
system.debug(':::cnt: ' + cnt);
		String path2 = '';
		HTTPResponse res = new HttpResponse();
		String bodyJson = '{' + '\n';
        bodyJson += '  "value": [' + '\n';
        if (cnt == 0) {
          	bodyJson += '  ]' +'\n';
            bodyJson += '}' + '\n'; 
            res.setBody(bodyJson);        // return      
        }
        List<VlocityExternalFieldMap__mdt> fieldLst =  [SELECT JsonFieldGet__c, JsonFieldPut__c 
                FROM VlocityExternalFieldMap__mdt  WHERE ExternalSystem__c = 'Matrixx'
                AND ExternalObject__c = 'MatrixxBalance'];

		for (Integer i = 0; i < cnt; i++){
// process node
			
			Map<String, Dom.XmlNode> els = XMLHelperFunctions.getXPath(path2, doc);			
System.debug(':::els'+ i +': ' + els);

        	String acctKey = '101_1001';
            String balRow = '{';
            balRow += '"Id" : "' + (i + 100) + '",';
            balRow += '"AccountKey" : "' + acctKey + '",';
            for(VLocityExternalFieldMap__mdt fieldItem : fieldLst){

                String field = fieldItem.JsonFieldGet__c;
                if ((field == 'Id')|| (field == 'AccountKey')){
                    continue;
                }
                path2 = '/MtxResponseWallet/BalanceArray/MtxBalanceInfoSimple[' + i + ']';
                path2 += '/' + field;
//    system.debug(':::path2: ' + path2);
    			Map<String, Dom.XmlNode> elsVal = XMLHelperFunctions.getXPath(path2, doc);
        system.debug(':::els indiv:' + elsVal);
    			if (elsVal.size() == 0){
    				continue;
    			}

    			elsVal.get(path2).getText();
    system.debug(':::els get:' + elsVal.get(path2).getText());
                balRow += '"' + field + '" : "' + elsVal.get(path2).getText() + '",';

            }  // for fieldList
            Integer len = balRow.length();
            balRow = balRow.left(len-2);
            balRow = balRow + '"';
            balRow += '}';
  system.debug(':::balRow: ' + balRow);
            bodyJson += balRow;
		}//for loop iterate through nodes
		bodyJson += '  ]' +'\n';
        bodyJson += '}' + '\n'; 
        res.setBody(bodyJson);
        res.setStatusCode(200);
system.debug(':::bodyJson end: ' + bodyJson);
	*/
	} 
}