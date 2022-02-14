global with sharing class CalloutMetadataTestController {

    global CalloutMetaData__c calloutMetadata {get;set;}

    global CalloutMetadataTestController(ApexPages.StandardController controller) {
        calloutMetadata = (CalloutMetadata__c)controller.getRecord();
        calloutMetaData = [select id,Name from CalloutMetaData__c where id=:calloutMetadata.Id];
    }

    @RemoteAction
    global static Object describeObject(String objectName) {
        return DBHelper.getFieldLabelsNoAddress(objectName);     
    }

    @RemoteAction
    global static CalloutItem__c makeCallout(String Name, String context) {
        Object jsonContext = JSON.deserializeUntyped(context);
        return Callout.makeCallout(Name, jsonContext);
    }


}