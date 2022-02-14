@isTest
private class ObjectDescriberTest {
    @isTest
    static void NSList(){
        ObjectDescriber.DescribedObjectMap gdm = ObjectDescriber.getProcessedGlobalDescribe();
        Schema.SObjectType ctype = gdm.get('Contact');
        System.assertEquals(ctype, Contact.SobjectType);
        //System.assertEquals(Schema.getGlobalDescribe().size(), gdm.size());

        ObjectDescriber accountDescribe = ObjectDescriber.getDescribe(ctype);
        ObjectDescriber.DescribedFieldsMap fields = accountDescribe.getFields();
        System.assert( fields.keySet().containsAll(accountDescribe.getFieldsMap().keySet()) );
        System.assertEquals(fields.get('name'), Contact.SObjectType.fields.name);  
        //System.assertEquals(Schema.SObjectType.Contact.fields.getMap().size(), fields.size());
    }

    @isTest
    static void Fields1() 
{
        String tempNameSpace = 'source_test';
        Map<String,Schema.SObjectField> fakeFieldData = new Map<String,Schema.SObjectField>{
            'name__c' => Contact.SObjectType.fields.name, 
            tempNameSpace+'__name__c' => Account.SObjectType.fields.name,
            'createddate' => Contact.SObjectType.fields.CreatedDate
        };
        ObjectDescriber.DescribedFieldsMap fields = new ObjectDescriber.DescribedFieldsMap(fakeFieldData);
        fields.currentNamespace = tempNameSpace;
        System.assertEquals(true, fields.containsKey('name__c') );
        System.assertEquals(true, fields.containsKey(tempNameSpace+'__name__c') );
    }

    @isTest  
    static void getAccountDescribes(){

        ObjectDescriber d = ObjectDescriber.getDescribe('Contact');
        ObjectDescriber d2 = ObjectDescriber.getDescribe(Contact.SObjectType);
        ObjectDescriber d3 = ObjectDescriber.getDescribe(Schema.SObjectType.Contact);
        Schema.DescribeSObjectResult dso = d.getDescribe();
//        Logger.dbg(dso);
        System.assertEquals('Contact', d.getDescribe().getName());
        System.assert( (d === d2 && d2 === d3) ,'All three getDescribe calls should return the same cached instance.');
    }

    @isTest  
    static void getNSDescribes(){
        // assumes this namespaced object exists 

        ObjectDescriber to1 = ObjectDescriber.getDescribe('Account');
        ObjectDescriber to2 = ObjectDescriber.getDescribe(Account.SObjectType );
  
        System.assert( (to1 == to2) , 'both getDescribe calls should return the same cached instance.');
    }

    @isTest
    static void simpleDescribe(){
        ObjectDescriber d = ObjectDescriber.getDescribe(Contact.SObjectType);
        Map<String,Schema.SObjectField> fields;
        for(integer i = 0; i < 10; i++){
            fields = d.getFieldsMap();
        }
//        System.assertEquals(1, Limits.getFieldsDescribes() );
        System.assertEquals(false,fields.isEmpty());
    }


    @isTest
    static void clearCache(){
        ObjectDescriber d = ObjectDescriber.getDescribe('Account');
        ObjectDescriber.clearCache();
        ObjectDescriber d2 = ObjectDescriber.getDescribe('Account');
        System.assert(d !== d2, 'Second object should be a fresh instance after a cache flush.' );
    }
    @isTest
    static void globalDescribe(){
        Map<String,Schema.SObjectType> systemGd = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectType> cachedGd = ObjectDescriber.getglobalDescribedObject();
        //System.assertEquals(systemGd.size(),cachedGd.size());
    }
}