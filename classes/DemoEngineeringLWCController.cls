public with sharing class DemoEngineeringLWCController {
    public DemoEngineeringLWCController() {

    }
    
    
    @AuraEnabled(cacheable=true)
    public static Document getDocumentImage(String documentName) {
        
        System.debug('Passed In: '+documentName);
        
        List<Document> doc = [SELECT Id  FROM Document WHERE DeveloperName = :documentName LIMIT 1];
        
        if(doc.size() ==1){
            System.debug(doc[0].Id);
            return doc[0];
        }
        else {
            return null;
        }
    }
}