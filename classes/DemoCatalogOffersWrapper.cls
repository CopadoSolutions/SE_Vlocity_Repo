global with sharing class DemoCatalogOffersWrapper implements vlocity_cmt.VlocityOpenInterface
{
global DemoCatalogOffersWrapper() { }

    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try
        {
            
            if (methodName.equalsIgnoreCase('getOfferDetails'))
            {
                getOfferDetails(inputMap,outMap);
            }
            else if(methodName.equalsIgnoreCase('getUserSessionParameters'))
            {
                getUserSessionParameters(outMap);
            }
            else if(methodName.equalsIgnoreCase('getCatalogItems'))
            {
                getCatalogItems(inputMap,outMap);
            }
            else if(methodName.equalsIgnoreCase('getIPandDCSafeBasketParameterString'))
            {
                getIPandDCSafeBasketParameterString(inputMap,outMap);
            }
            //addOfferToBasketViaDCAPI
            else if(methodName.equalsIgnoreCase('addOfferToBasketViaDCAPI'))
            {
                addOfferToBasketViaDCAPI(inputMap,outMap);
            }
            else if(methodName.equalsIgnoreCase('getOffersViaDCAPI'))
            {
                getOffersViaDCAPI(inputMap,outMap);
            }
            else
            {
                result = false;
            } 
        } 
        catch(Exception e)
        {
            System.debug('invokeMethod -> exception: '+e);
            result = false;
        }
        
        return result;
    }
    
    void getOffersViaDCAPI(Map<String,Object> inputMap,Map<String,Object> outputMap)
    {
    
        String catalogcode=  '' ; 
        String pruneByCode ='';
        
        
        //if the context is passed in, take as is
        if(inputMap.containsKey('catalogcode'))
        {
            catalogcode = (String)inputMap.get('catalogcode');
        }
        
        if(inputMap.containsKey('pruneByCode'))
        {
            pruneByCode = (String)inputMap.get('pruneByCode');
        }
        
        String strFQDN =  System.Url.getSalesforceBaseUrl().toExternalForm() ; 
        
        //if we are invoking internally, we will have some -- silliness
        if(strFQDN.indexOf('--') != -1)
        {
            System.debug('removing -- : ' + strFQDN.substringBeforeLast('--') );
            strFQDN = strFQDN.substringBeforeLast('--') + '.my.salesforce.com';
            System.debug('strFQDN: ' + strFQDN);
        }
        
        String token = UserInfo.getSessionId();
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String endPoint = strFQDN+'/services/apexrest/vlocity_cmt/v3/catalogs/'+catalogcode+'/offers?'+costructQueryStringParameter(inputMap);
        
        system.debug('GetOffersViaDCAPI::ENDPOINT--'+ endPoint);
        
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        req.setCompressed(false);
        req.setHeader('Content-Type', 'application/json');  
        req.setHeader('Authorization', 'Bearer '+UserInfo.getSessionId());  
        
        
        try 
        {
            //DemoEngineeringUtils.LogtoSumo(JSON.serialize(postSpinSignup));
            res = http.send(req);
        } 
        catch(System.CalloutException e) 
        {
           //DemoEngineeringUtils.LogtoSumo('SignUp: The following exception has occurred: ' + e.getMessage());
            System.debug('Callout error: '+ e);
        }  
        String responseBody = res.getBody();
        System.debug(responseBody);
        
        Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(responseBody); 
        
        if(result!= null)
        {
            for(String key : result.keyset()) 
            { 
               system.debug('DC::API::Key::'+key);
               if(key == 'Offers' && pruneByCode != '')
               {
                   //system.debug('DC::API::Key::Offers'+result.get(key));
                   
                   List<Object> offers = (List<Object>) result.get(key);
                   List<Object> prunedOffers = new List<Object>();
                   
                   for(Object offersObj : offers)
                   {
                      // system.debug('DC::API::Key::Offers'+offersObj);
                       
                       Map<String,Object> offerMap = (Map<String,Object>)offersObj;
                       
                       //We are now in the offer entity
                       if(offerMap.containskey('ProductCode'))
                       {
                           String offerProductCode = (String)offerMap.get('ProductCode');
                           
                           //We will treat prunby as a double side wild card. If we do not have it anywhere, remove it.
                           if(offerProductCode.indexOf(pruneByCode) != -1)
                           {
                               prunedOffers.add(offersObj);
                           }
                       }     
                   }
                   outputMap.put(key,prunedOffers);
               }
               else
               {
                //Add to the outbound
                outputMap.put(key,result.get(key));
               }
            } 
        }
    }
    void addOfferToBasketViaDCAPI(Map<String,Object> inputMap,Map<String,Object> outputMap)
    {
    
        String catalogcode=  '' ; 
        
        
        //if the context is passed in, take as is
        if(inputMap.containsKey('catalogcode'))
        {
            catalogcode = (String)inputMap.get('catalogcode');
        }
        
        String strFQDN =  System.Url.getSalesforceBaseUrl().toExternalForm() ; 
        
        //if we are invoking internally, we will have some -- silliness
        if(strFQDN.indexOf('--') != -1)
        {
            System.debug('removing -- : ' + strFQDN.substringBeforeLast('--') );
            strFQDN = strFQDN.substringBeforeLast('--') + '.my.salesforce.com';
            System.debug('strFQDN: ' + strFQDN);
        }
        
        String token = UserInfo.getSessionId();
        
        String contextString = '{\"accountId\":\"'+(String)inputMap.get('accountId')+'\"}';
        
        Map<string, object> mapToSerialize = new Map<string, object>();
        mapToSerialize.put('context', contextString);
        mapToSerialize.put('offer', (String)inputMap.get('offerCode'));
        mapToSerialize.put('basketAction', (String)inputMap.get('basketAction'));

        string basketCall = JSON.serialize(mapToSerialize);
        
        system.debug('basketCall'+basketCall);
        
        String basketId ='';
        
        if(inputMap.containsKey('basketId'))
        {
            if(((String)inputMap.get('basketId')) != '')
            {
                 basketId='/'+(String)inputMap.get('basketId');
            }
        }
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String endPoint = strFQDN+'/services/apexrest/vlocity_cmt/v3/catalogs/'+catalogcode+'/basket'+basketId+'?'+costructQueryStringParameter(inputMap);
        
        system.debug('addOfferToBasketViaDCAPI::ENDPOINT--'+ endPoint);
        
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setCompressed(false);
        req.setHeader('Content-Type', 'application/json');  
        req.setHeader('Authorization', 'Bearer '+UserInfo.getSessionId());  
        req.setBody(basketCall);
        
        try 
        {
            //DemoEngineeringUtils.LogtoSumo(JSON.serialize(postSpinSignup));
            res = http.send(req);
        } 
        catch(System.CalloutException e) 
        {
           //DemoEngineeringUtils.LogtoSumo('SignUp: The following exception has occurred: ' + e.getMessage());
            System.debug('Callout error: '+ e);
        }  
        String responseBody = res.getBody();
        System.debug(responseBody);
        
        Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(responseBody); 
        
        if(result!= null)
        {
            for(String key : result.keyset()) 
            { 
                //Add to the outbound
                outputMap.put(key,result.get(key));
            } 
        }
    }
    
    String costructQueryStringParameter(Map<String,Object> inputMap)
    {
    
        String str=  'a=a' ; 
        
        system.debug('parameters:'+inputMap);
        
        //if the context is passed in, take as is
        if(inputMap.containsKey('context'))
        {
            str = str +'&context='+(String)inputMap.get('context');
        }
        
        //passing in the accountid, build the inline json to get around the url encode (ism) in the DC api...sigh
        //Yes you are wondering WHY....ask why someone would take query string parameters as part of a POST and we can have a debate.
        
        if(inputMap.containsKey('accountId')) 
        {
            str = str +'&context={"accountId":"'+(String)inputMap.get('accountId')+'"}';
        }

        if(inputMap.containsKey('contextkey'))
        {
            str = str +'&contextkey='+(String)inputMap.get('contextkey');
        }
        
        if(inputMap.containsKey('returnBasket'))
        {
            str +='&returnBasket='+inputMap.get('returnBasket');
        }
        
        if(inputMap.containsKey('isloggedin'))
        {
            str = str +'&isloggedin='+inputMap.get('isloggedin');
        }
        
        if(inputMap.containsKey('offerCode'))
        {
            str = str +'&offer='+(String)inputMap.get('offerCode');
        }
        
         if(inputMap.containsKey('multiTransactionKey'))
        {
            str = str +'&multiTransactionKey='+(String)inputMap.get('multiTransactionKey');
        }
        
        
        system.debug('querystring:'+str);
        return str;
    
    }
    
    void getIPandDCSafeBasketParameterString(Map<String,Object> inputMap,Map<String,Object> outputMap)
    {
        outputMap.put('queryStringParameter',costructQueryStringParameter(inputMap));
    }
    
    void getCatalogItems(Map<String,Object> inputMap,Map<String,Object> outputMap)
    {
    
        String catalogCode = (String)inputMap.get('catalogCode');
        
        String pruneByCode = '';
            
        if(inputMap.containsKey('pruneByCode'))
                pruneByCode = (String)inputMap.get('pruneByCode');
                
        
        List<vlocity_cmt__CatalogProductRelationship__c> catalogItems = [select id,Name, vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__PromotionId__r.vlocity_cmt__Code__c 
                                  from vlocity_cmt__CatalogProductRelationship__c 
                                  where vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c = :catalogCode];
        
        
        List<Map<String,String>> products = new List<Map<String,String>>();
        List<Map<String,String>> promtions = new List<Map<String,String>>();
        
        for(vlocity_cmt__CatalogProductRelationship__c catItem:catalogItems)
        {
            if(catItem.vlocity_cmt__Product2Id__r.ProductCode != null)
            {
                String code = catItem.vlocity_cmt__Product2Id__r.ProductCode;
                Map<String,String> tmp = new Map<String,String>();
                
                if(pruneByCode != null && pruneByCode !='')
                {
                    if(code.indexOf(pruneByCode) != -1)
                    {
                        tmp.put('productcode',code);
                        products.add(tmp);
                    }
                }
                else
                {
                    tmp.put('productcode',code);
                    products.add(tmp);
                }
            }
            
            if(catItem.vlocity_cmt__PromotionId__r.vlocity_cmt__Code__c != null)
            {
                String code = catItem.vlocity_cmt__PromotionId__r.vlocity_cmt__Code__c;
                Map<String,String> tmp = new Map<String,String>();
                
                if(pruneByCode != null && pruneByCode !='')
                {
                    if(code.indexOf(pruneByCode) != -1)
                    {
                        tmp.put('promotioncode',code);
                        promtions.add(tmp);
                    }
                }
                else
                {
                    tmp.put('promotioncode',code);
                    promtions.add(tmp);
                }
            }
        }
        
      
        outputMap.put('products',products);
        outputMap.put('promotions',promtions);
    }
    
    void getUserSessionParameters(Map<String,Object> outputMap)
    {
    
        String str=  System.Url.getSalesforceBaseUrl().toExternalForm() ; 
        
        //if we are invoking internally, we will have some -- silliness
        if(str.indexOf('--') != -1)
        {
            System.debug('removing -- : ' + str.substringBeforeLast('--') );
            str = str.substringBeforeLast('--') + '.my.salesforce.com';
            System.debug('str: ' + str);
        }
        
        String token = UserInfo.getSessionId();
        
        outputMap.put('baseUrl',str);
        outputMap.put('token',token);
    }
    void getOfferDetails(Map<String,Object> inputMap,Map<String,Object> outMap)
    {
            String catalogCode = (String)inputMap.get('catalogCode');
            String productCode = (String)inputMap.get('productCode');
            
           
                
            Map<String,Object> input = new Map<String,Object>();
            Map<String,Object> output = new Map<String,Object>();
            Map<String,Object> options = new Map<String,Object>();
            
            input.put('isloggedin ','true');
            input.put('apiName ','getOfferDetails');
            input.put('catalogCode ',catalogCode);
            input.put('context','{"accountId":"0014W000025P3pzQAC"}');
            input.put('requestURL','/v3/catalogs/'+catalogCode+'/offers/'+productCode);
            
            
            vlocity_cmt.CpqAppHandler appHandler  = new vlocity_cmt.CpqAppHandler();
            appHandler.invokeMethod('getOfferDetailsByCatalogCode',input,outMap,options);
            
            system.debug('output:'+output);
            for(String key:output.keySet())
                system.debug('output-Key:'+key);
    }
    
     
    }