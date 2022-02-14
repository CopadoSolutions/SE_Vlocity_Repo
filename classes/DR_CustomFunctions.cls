global class DR_CustomFunctions implements vlocity_cmt.VlocityOpenInterface
{
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options)
    {
        if (methodName == 'GetJSONAttributeMap') {
           GetJSONAttributeMap(inputs,output,options);
            return true;
        } else if(methodName == 'GetJSONMapKeys'){
            output.put('result', GetJSONMapKeys((List<Object>)inputs.get('arguments')));
            return true;
        }
        return false;
    }
    
    private void GetJSONAttributeMap(Map<String,Object> inputs, Map<String,Object> output, Map<String,Object> options){
          
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            String JSONAttrString = (String) arguments[0];
            if (arguments.size() != 1 ) {
             
                InvalidParameterValueException e = new InvalidParameterValueException('GetJSONAttributeMap', 'The function must be called with at 1 arguments');
                throw e;
            }
            
            if (JSONAttrString != null && JSONAttrString.length() > 0) {
                
                List<Vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest> actionRequestsList = new List<Vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest>();
                Map<String, object> inputMap = new Map<String, object>(); 
                Map<String, object> outputMap = new Map<String, object>(); 
                Map<String, object> optionsMap = new Map<String, object>();
                inputMap.put('JSONString', JSONAttrString);
                Vlocity_cmt.JSONAttributeSupport jsonSupport = new Vlocity_cmt.JSONAttributeSupport();
                jsonSupport.invokeMethod('getAttributeValuesFromJSON', inputMap, outputMap, optionsMap); 
                Map<String,Object> attributeCodeToDisplayName = (Map<String,Object>)outputMap.get('attributeCodeToDisplayName');
                Map<String,Object> attributeCodeToValue = (Map<String,Object>)outputMap.get('attributeCodeToValue');
                Map<String,Object> AttriNameToValueMap = new Map<String,Object>();
                for(String attriCode : attributeCodeToDisplayName.keySet()){
                    AttriNameToValueMap.put((String)attributeCodeToDisplayName.get(attriCode),attributeCodeToValue.get(attriCode));
                }
              
                output.put('result', AttriNameToValueMap);
              
            }
    }
    
    private List<Object> GetJSONMapKeys(List<Object> arguments) {
            
        List<Object> theList = new List<Object>();
        
        Map<String,Object> JSONMap;
        String newNodeName;
        
        //check 
        if (arguments.size() >= 2) {
            JSONMap = (Map<String,Object>)(arguments.get(0));
            newNodeName  = String.valueOf(arguments.get(1));
        }
        else {
            InvalidParameterValueException e = new InvalidParameterValueException('GetJSONMapKeys', 'The function must be called with at least 2 arguments');
            throw e;
        }
         
         if(null != JSONMap && JSONMap.size()>0){
             for(String key : JSONMap.keySet() ){
               Map<String,Object> newJSONMap = new Map<String,Object>();
               newJSONMap.put(newNodeName,(String)key);
               theList.add(newJSONMap);
             }
         }
          system.debug('theList '+theList);     
        return theList;
    }
}