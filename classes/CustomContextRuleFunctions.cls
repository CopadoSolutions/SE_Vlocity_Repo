global class CustomContextRuleFunctions implements vlocity_cmt.VlocityOpenInterface{
    
    private static List<String> AllowanceType = new List<String>{'Data','Voice','Text'};
    private static string ATTR_PAYMENT_CODE = 'CH_PAYMENT_OPTION';
    private static string ATTR_DATA = 'Data';
    private static string ATTR_VOICE = 'Voice';
    private static string ATTR_TEXT = 'Text';
    private static string Unlimited = 'Unlimited';
    
    global Boolean invokeMethod(String methodName, 
                                Map<String, Object> inputMap, 
                                Map<String, Object> outMap, 
                                Map<String, Object> options){
        Boolean success = false;
        if(methodName.equals('evaluateAssetEntityFilter')){
            
            success = evaluateAssetEntityFilter(inputMap, outMap, options);
            System.debug('>>>>> inputMap::::' + inputMap);  
            System.debug('>>>>> outMap::::' + outMap);  
            System.debug('>>>>> options::::' + options);  
            System.debug('>>>>> success::::' + success);  

        }
        return success;  
    }
    
    private Boolean evaluateAssetEntityFilter(Map<String, Object> inputMap, 
                                Map<String, Object> outMap, 
                                Map<String, Object> options){
        
        List<Object> argList = (List<Object>)inputMap.get('arguments');
        String entityFilterCode = (String)argList.get(0);
        String accountId = (String)argList.get(1);
        String objectName = (String)argList.get(2);
        String orderId = (String)argList.get(3);
        outMap.put('result', false); 
        
        Map<Id, Set<Id>> entityFilterResult = evaluateEntityFilter(entityFilterCode, accountId, objectName, orderId);                  
        System.debug('>>>>> entityFilterResult::::' + entityFilterResult);  
        
        if(entityFilterResult != null && entityFilterResult.size() > 0){
            Set<Id> qualifiedEntity = new Set<Id>();
            for(Object obj : entityFilterResult.values()){
                qualifiedEntity.addAll((Set<Id>)obj);
            }
            if(qualifiedEntity.size()>0){
                outMap.put('result',true);
                return true; /* Jianting suggested edit - need to return true here and false below */
            }                                
        }
                                  
        return false; /* Jianting suggested edit - need to return false here and true above */
    }
    
    private Map<Id, Set<Id>> evaluateEntityFilter(String uniqueCode, String accountId, String objectName, String orderId){
       
        List<Id> objectItemIds   = new List<Id>();
        List<Id> filterItemIds   = new List<Id>();
        Map<Id, Set<Id>> filterIdToContextItemIds = new Map<Id, Set<Id>>();
        
/*
**  Get Entity Filter specified by uniqueCode parameter
*/
        //Below query should always return one unique record.
        String uniqueCodeWithWildCardChar = '%'+uniqueCode+'%';
        List<vlocity_cmt__EntityFilter__c> entityFilters = [SELECT Id, vlocity_cmt__FilterOnObjectName__c FROM vlocity_cmt__EntityFilter__c WHERE Name LIKE : uniqueCodeWithWildCardChar AND vlocity_cmt__IsActive__c = True];
        System.debug('>>>>> entityFilters::::' + entityFilters);  
/*
**      Build list of Entity Filters passed in.  Could probably use some validation logic to ensure only one record results
*/

        for(vlocity_cmt__EntityFilter__c entityFilter : entityFilters) {
            if (entityFilter.vlocity_cmt__FilterOnObjectName__c != null) {
                filterItemIds.add(entityFilter.Id);
            }
        }
        System.debug('filterItemIds ::::' + filterItemIds);

/*
**      Return null if no filter found
*/
        if(filterItemIds.isEmpty()) {
            System.debug('filterItemIds.isEmpty - No Entity Filters found ::::');
            return null;
        }
/*
**      Declare Entity Filter result variable  
*/      
        Vlocity_cmt.EntityFilterSupport filterEvaluator = new Vlocity_cmt.EntityFilterSupport();
/*
**      Loop to execute Entity Filters
*/        
        if(!filterItemIds.isEmpty()) {
            String query;
/*
**          Get list of assets or order items depending upon objectName parameter  
*/
            if(objectName.equals('Asset')){
                query = 'SELECT Id FROM Asset WHERE AccountId = :accountId';
            }else if(objectName.equals('OrderItem')){
                query = 'SELECT Id FROM OrderItem WHERE OrderId = :orderId';
            }
/*
**          Build list of asset/order item ids  
*/
            for(SObject so : Database.query(query)) {
                objectItemIds.add((Id)so.get('Id'));
            }
/*
**          If there are asset/order item ids
*/
            if(!objectItemIds.isEmpty()) {
/*
**              Declare input/output variables
*/
                Map<String, Object> filterInputVars = new Map<String, Object>();
                Map<String, Object> filterOutputVars = new Map<String, Object>();
/*
**              Set inputs
*/
                filterInputVars.put('objectIds', objectItemIds);
                filterInputVars.put('entityFilterIds', filterItemIds);
/*
**              Execute Entity Filter
*/
                filterEvaluator.invokeMethod('executeFilters',filterInputVars, filterOutputVars, null);
/*
**              Get output from Entity Filter
*/
                filterIdToContextItemIds = (Map<Id, Set<Id>>)filterOutputVars.get('filterIdToObjectIds');
                System.debug('filterIdToContextItemIds ::::' + filterIdToContextItemIds);
            }
        } 
        System.debug('>>>>> filterIdToContextItemIds::::'+filterIdToContextItemIds);       
/*
**      Return filtered list of item ids      
*/
        return filterIdToContextItemIds;
    }
    
}