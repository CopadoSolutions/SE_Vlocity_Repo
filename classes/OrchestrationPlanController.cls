global class OrchestrationPlanController implements Vlocity_cmt.VlocityOpenInterface
{
    public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    {
        try 
        {
            if (methodName.equals('populateorchestrationitemdefrecordtype'))
            {
                populateorchestrationitemdefrecordtype(input, outMap, options);
            }  
            else if (methodName.equals('populateitemimplementations'))
            {
                populateitemimplementations(input, outMap, options);
            }  
             else if (methodName.equals('populatemanualqueue'))
            {
                populatemanualqueue(input, outMap, options);
            }  
             else if (methodName.equals('populatesysteminterface'))
            {
                populatesysteminterface(input, outMap, options);
            }  
             else if (methodName.equals('getorchestrationitemdefinitions'))
            {
                getorchestrationitemdefinitions(input, outMap, options);
            }   
            else if (methodName.equals('getproducts'))
            {
                getproducts(input, outMap, options);
            }
           
        }
        catch (Exception e) 
        {
            System.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }

       return true;
    }
    
    
    public void populateorchestrationitemdefrecordtype(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options1)
    {
        List<Map<String,String>> options = new List<Map<String, String>>();

        list<RecordType> rt = new list<RecordType>();
        rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='vlocity_cmt__OrchestrationItemDefinition__c'];

        System.debug('rt..'+rt);
        
        for(RecordType r: rt){
            Map<String, String> tempMap = new Map<String, String>();

            tempMap.put('name', r.Name); // Language Independent 
            tempMap.put('value', r.Name); // Displayed in Picklist UI

            options.add(tempMap);
        }

        outMap.put('options',options);    
    }
    
    public void populateitemimplementations(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options1)
    {
        List<Map<String,String>> options = new List<Map<String, String>>();

        list< vlocity_cmt__ItemImplementation__c > rt = new list< vlocity_cmt__ItemImplementation__c >();
        rt = [SELECT Id,Name FROM vlocity_cmt__ItemImplementation__c ];

        System.debug('rt..'+rt);
        
        for(vlocity_cmt__ItemImplementation__c r: rt){
            Map<String, String> tempMap = new Map<String, String>();

            tempMap.put('name', r.Id); // Language Independent 
            tempMap.put('value', r.Name); // Displayed in Picklist UI

            options.add(tempMap);
        }

        outMap.put('options',options);    
    }
    
    public void populatemanualqueue(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options1)
    {
        List<Map<String,String>> options = new List<Map<String, String>>();

        list< vlocity_cmt__ManualQueue__c > rt = new list< vlocity_cmt__ManualQueue__c >();
        rt = [SELECT Id,Name FROM vlocity_cmt__ManualQueue__c ];

        System.debug('rt..'+rt);
        
        for(vlocity_cmt__ManualQueue__c r: rt){
            Map<String, String> tempMap = new Map<String, String>();

            tempMap.put('name', r.Id); // Language Independent 
            tempMap.put('value', r.Name); // Displayed in Picklist UI

            options.add(tempMap);
        }

        outMap.put('options',options);    
    }
    
    public void populatesysteminterface(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options1)
    {
        List<Map<String,String>> options = new List<Map<String, String>>();

        list< vlocity_cmt__SystemInterface__c > rt = new list< vlocity_cmt__SystemInterface__c >();
        rt = [SELECT Id,Name FROM vlocity_cmt__SystemInterface__c ];

        System.debug('rt..'+rt);
        
        for(vlocity_cmt__SystemInterface__c r: rt){
            Map<String, String> tempMap = new Map<String, String>();

            tempMap.put('name', r.Id); // Language Independent 
            tempMap.put('value', r.Name); // Displayed in Picklist UI

            options.add(tempMap);
        }

        outMap.put('options',options);    
    }
    
     public void getorchestrationitemdefinitions(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options1)
    {
        List<Map<String,String>> options = new List<Map<String, String>>();

        list< vlocity_cmt__OrchestrationItemDefinition__c > rt = new list< vlocity_cmt__OrchestrationItemDefinition__c >();
        rt = [SELECT Id,Name FROM vlocity_cmt__OrchestrationItemDefinition__c ];

        System.debug('rt..'+rt);
        
        for(vlocity_cmt__OrchestrationItemDefinition__c r: rt){
            Map<String, String> tempMap = new Map<String, String>();

            tempMap.put('name', r.Id); // Language Independent 
            tempMap.put('value', r.Name); // Displayed in Picklist UI

            options.add(tempMap);
        }

        outMap.put('options',options);    
    }
    
    public void getproducts(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options1)
    {
        List<Map<String,String>> options = new List<Map<String, String>>();

        list< product2 > rt = new list< product2 >();
        rt = [SELECT Id,Name FROM product2 ];

        System.debug('rt..'+rt);
        
        for(product2 r: rt){
            Map<String, String> tempMap = new Map<String, String>();

            tempMap.put('name', r.Id); // Language Independent 
            tempMap.put('value', r.Name); // Displayed in Picklist UI

            options.add(tempMap);
        }

        outMap.put('options',options);    
    }
   

}