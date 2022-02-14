@isTest
public class DR_CustomFunctionsTest {
    static testmethod void GetJSONAttributeMapTest (){
        String methodName = 'GetJSONAttributeMap';
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        DR_CustomFunctions ser = new DR_CustomFunctions();
        Test.startTest();
        List<Object> arguments = new List<Object>();
        arguments.add('{"VLO-PRO-0001":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4P000008CouBQAS","attributeid__c":"a0J4P00000PZZX3UAP","attributecategoryid__c":"a0I4P00000vUZkCUAW","categorycode__c":"VLO-PRO-0001","categoryname__c":"TV Channels","attributeuniquecode__c":"ATTRIBUTE-021","attributeconfigurable__c":true,"attributedisplaysequence__c":"2","attributefilterable__c":false,"isactive__c":true,"attributedisplayname__c":"Genre","displaysequence__c":"9","formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a0H4P00000Zbe83UAB","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":"Movies, Kids, Entertainment","valuedatatype__c":"Text","valuedescription__c":"The type of genres that are included in this package","attributecloneable__c":false,"customconfiguitemplate__c":null,"categorydisplaysequence__c":9,"isnottranslatable__c":false,"attributeRunTimeInfo":{"dataType":"Text","default":"Movies, Kids, Entertainment","value":"Movies, Kids, Entertainment"},"$$AttributeDefinitionEnd$$":null}],"VLO-PRO-0015":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4P000008CouBQAS","attributeid__c":"a0J4P00000PZZYUUA5","attributecategoryid__c":"a0I4P00000vUZkRUAW","categorycode__c":"VLO-PRO-0015","categoryname__c":"Logistics","attributeuniquecode__c":"ATTRIBUTE-124","attributeconfigurable__c":true,"attributedisplaysequence__c":"4","attributefilterable__c":true,"isactive__c":true,"attributedisplayname__c":"Provider","displaysequence__c":"23","formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0H4P00000ZbeHkUAJ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":"Amazon","valuedatatype__c":"Text","valuedescription__c":null,"attributecloneable__c":false,"customconfiguitemplate__c":null,"categorydisplaysequence__c":23,"isnottranslatable__c":false,"attributeRunTimeInfo":{"dataType":"Text","default":"Amazon","value":"Amazon"},"$$AttributeDefinitionEnd$$":null}]}');        
        inputMap.put('arguments',arguments);
        ser.invokeMethod(methodName,inputMap,outputMap,options);
        system.debug(outputMap);
        Test.stopTest();
        system.assertEquals('Amazon', ((String)((Map<String,Object>)outputMap.get('result')).get('Provider')));
    }
    
     static testmethod void GetJSONMapKeysTest (){
        String methodName = 'GetJSONMapKeys';
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        DR_CustomFunctions ser = new DR_CustomFunctions();
        Test.startTest();
        List<Object> arguments = new List<Object>();
        Map<String,Object> TestMap = new Map<String,Object>();
        TestMap.put('1234', 'yes');
        TestMap.put('2456', 'no');
        arguments.add(TestMap);        
        arguments.add('Id');
        inputMap.put('arguments',arguments);
        ser.invokeMethod(methodName,inputMap,outputMap,options);
        system.debug(outputMap);
        Test.stopTest();
        system.assertEquals(2, ((List<Object>)outputMap.get('result')).size());
    }
}