global with sharing class CreatePromotion implements vlocity_cmt.VlocityOpenInterface{
       public List<Map<string,string>> OptionMap = new List<Map<string,string>>();
        public Map<string,string> tempMap = new Map<string,string>();
   public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)    {
        
        if (methodName.equals('getpricelist')){
            return getpricelist(input,output,options);
        }
        else if (methodName.equals('getproduct')){
            return getproductlist(input,output,options);
        }
        else if (methodName.equals('getpromotionItem')){
            return getpromotionItem(input,output,options);
        }
        else if (methodName.equals('createPLE')){
            return createPLE(input,output,options);
        }
        return true;
    }
    
      public Boolean getpricelist(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap){
      List<vlocity_cmt__PriceList__c> ActivePL = new List<vlocity_cmt__PriceList__c>();
     ActivePL = [select id,name from vlocity_cmt__PriceList__c where vlocity_cmt__IsActive__c =true];
     if(!ActivePL.isEmpty()){
      for(vlocity_cmt__PriceList__c p : ActivePL){
      tempMap = new Map<string,string>();
      tempMap.put('name',p.id);
      tempMap.put('value',P.Name);
      OptionMap.add(tempMap);
      }
      }
      else{
      tempMap.put('name','NA');
      tempMap.put('value','No Active PriceList');
      OptionMap.add(tempMap);
      }
      outputMap.put('options',OptionMap);
      return true;
      }
      
      public Boolean getproductlist(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap){
      
     List< vlocity_cmt__PriceListEntry__c > PriceListEntry = new List< vlocity_cmt__PriceListEntry__c >();
      
      Map<string,object> Promotion=(Map<string,object>)inputMap.get('CreatePromotion');
      
      Id SelectPLE = (Id)Promotion.get('Promotion_PriceList');
      system.debug('InputMap'+inputmap+'Promotion'+SelectPLE);
      List<vlocity_cmt__PriceListEntry__c> ProdList = new List<vlocity_cmt__PriceListEntry__c>();
     ProdList = [select id,name,vlocity_cmt__ProductId__r.Name,vlocity_cmt__ProductId__c from vlocity_cmt__PriceListEntry__c where vlocity_cmt__IsActive__c =true and vlocity_cmt__PriceListId__c =:SelectPLE];
     if(!ProdList.isEmpty()){
      for(vlocity_cmt__PriceListEntry__c p : ProdList){
      tempMap = new Map<string,string>();
      tempMap.put('name',p.vlocity_cmt__ProductId__c);
      tempMap.put('value',p.vlocity_cmt__ProductId__r.Name);
      OptionMap.add(tempMap);
      system.debug('OptionMap'+OptionMap);
      }
      }
      else{
      tempMap.put('name','NA');
      tempMap.put('value','NA');
      OptionMap.add(tempMap);
      }
      system.debug('OptionMapFinal'+OptionMap);
      outputMap.put('options',OptionMap);
      system.debug('outputMap'+outputMap);
      return true;
      }
       public Boolean getpromotionItem(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap){
      
     List< vlocity_cmt__PromotionItem__c > ProItem = new List< vlocity_cmt__PromotionItem__c >();
      string PromotionId=(string)inputMap.get('DRId_vlocity_cmt__Promotion__c');
      
      
      system.debug('InputMap'+inputmap+'PromotionId'+PromotionId);
     ProItem = [select id,name,vlocity_cmt__ProductId__r.Name,vlocity_cmt__ProductId__c from vlocity_cmt__PromotionItem__c where vlocity_cmt__PromotionId__c=:PromotionId];
     if(!ProItem.isEmpty()){
      for(vlocity_cmt__PromotionItem__c p : ProItem){
      tempMap = new Map<string,string>();
      tempMap.put('name',p.id);
      tempMap.put('name1',p.vlocity_cmt__ProductId__c);
      tempMap.put('value',p.vlocity_cmt__ProductId__r.Name);
      OptionMap.add(tempMap);
      system.debug('OptionMap'+OptionMap);
      }
      }
      else{
      tempMap.put('name','NA');
      tempMap.put('value','NA');
      OptionMap.add(tempMap);
      }
      system.debug('OptionMapFinal'+OptionMap);
      outputMap.put('options',OptionMap);
      system.debug('outputMap'+outputMap);
      return true;
      }
      
      public Boolean createPLE(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap){
      system.debug('inputMap'+inputmap);
      List< vlocity_cmt__PriceListEntry__c > PLEList = new List< vlocity_cmt__PriceListEntry__c >();
       Boolean IsOverride = (boolean)optionsMap.get('Override');
      string PromotionId=(string)inputMap.get('DRId_vlocity_cmt__Promotion__c');
      vlocity_cmt__PriceListEntry__c NewPLE = new vlocity_cmt__PriceListEntry__c();
      system.debug('optionsMap'+optionsMap);
      //try{
      if(IsOverride == false){
       //Map<string,object> PLE = (Map<String, Object>)((Map<String, Object>)inputMap.get('AddAdjustment')).get('AddNewAdjustment');
       Map<string,object> PLE = (Map<String, Object>)inputMap.get('AddAdjustment');
       system.debug('promItem'+ PLE.get('ProductPricingAdjustment'));
      Id ProdId = [select vlocity_cmt__ProductId__c from vlocity_cmt__PromotionItem__c where id =:(string) PLE.get('ProductPricingAdjustment')].vlocity_cmt__ProductId__c;
      //Id ProdId='01t1I0000014JXR';
      system.debug('Prod Id'+ ProdId+'AdjustmentEffectiveFrom'+PLE.get('AdjustmentEffectiveFrom'));
      //DateTime d = (Datetime)PLE.get('AdjustmentEffectiveFrom');
      NewPLE.Name = '123' ;
      NewPLE.vlocity_cmt__IsActive__c = (boolean)PLE.get('AdjustmentActive');
      NewPLE.vlocity_cmt__DisplayText__c = (string)PLE.get('AdjustmentDisplayText');
      if(PLE.get('AdjustmentEffectiveFrom')!=null)
      NewPLE.vlocity_cmt__EffectiveFromDate__c = (DateTime)Json.deserialize('"'+(PLE.get('AdjustmentEffectiveFrom'))+'"', DateTime.class);
      if(PLE.get('AdjustmentEffectiveUntil')!=null)
      NewPLE.vlocity_cmt__EffectiveUntilDate__c = (DateTime)Json.deserialize('"'+(PLE.get('AdjustmentEffectiveUntil'))+'"', DateTime.class);
      //NewPLE.vlocity_cmt__EffectiveFromDate__c =(Datetime)PLE.get('AdjustmentEffectiveFrom');
      //NewPLE.vlocity_cmt__EffectiveUntilDate__c= (Datetime)PLE.get('AdjustmentEffectiveUntil');
      NewPLE.vlocity_cmt__IsBasePrice__c =(Boolean) PLE.get('BasePrice');
      NewPLE.vlocity_cmt__PriceListId__c =(Id) PLE.get('PriceList');
      NewPLE.vlocity_cmt__PromotionItemId__c = (Id)PLE.get('ProductPricingAdjustment');
      NEWPLE.vlocity_cmt__PricingElementId__c = (Id)PLE.get('SelectPricingElement');
      NEWPLE.vlocity_cmt__TimePlanId__c = (Id)PLE.get('TimePlan');
      NEWPLE.vlocity_cmt__TimePolicyId__c = (Id)PLE.get('TimePolicy');
      NEWPLE.vlocity_cmt__IsVirtualPrice__c =(Boolean) PLE.get('VirtualPrice');
      NEWPLE.vlocity_cmt__PromotionId__c = (Id)inputMap.get('DRId_vlocity_cmt__Promotion__c');
      NEWPLE.vlocity_cmt__ProductId__c = ProdId;
      insert NEWPLE ;
      NEWPLE.Name = NEWPLE.Id;
      update NEWPLE ;
      PLEList = [select vlocity_cmt__PromotionId__r.Name,vlocity_cmt__PriceListId__r.Name,vlocity_cmt__DisplayText__c,
       vlocity_cmt__PricingElementId__r.Name, vlocity_cmt__PricingElementId__r.vlocity_cmt__Code__c, vlocity_cmt__PricingElementId__r.vlocity_cmt__DisplayText__c, vlocity_cmt__PricingElementId__r.vlocity_cmt__CalculationType__c, vlocity_cmt__PricingElementId__r.vlocity_cmt__AdjustmentValue__c
       from vlocity_cmt__PriceListEntry__c where vlocity_cmt__PromotionId__c=:(Id)inputMap.get('DRId_vlocity_cmt__Promotion__c') and vlocity_cmt__IsOverride__c=false];
       outputMap.put('AdjustmentListEntry',PLEList);
        outputMap.put('IsNew',false);
      }
     else {
      //Map<string,object> PLE = (Map<String, Object>)((Map<String, Object>)inputMap.get('AddOverride')).get('AddNewOverride');
      Map<string,object> PLE = (Map<String, Object>)inputMap.get('AddOverride');
      Id ProdId = [select vlocity_cmt__ProductId__c from vlocity_cmt__PromotionItem__c where id =:(string) PLE.get('PricingOverride')].vlocity_cmt__ProductId__c;
      system.debug('Prod Id'+ ProdId);
      NewPLE.Name = '123' ;
      NewPLE.vlocity_cmt__IsActive__c = (boolean)PLE.get('OverrideActive');
      NewPLE.vlocity_cmt__DisplayText__c = (string)PLE.get('OverrideDisplayText');
      if(PLE.get('OverrideEffectiveFrom')!=null)
      NewPLE.vlocity_cmt__EffectiveFromDate__c = (DateTime)Json.deserialize('"'+(PLE.get('OverrideEffectiveFrom'))+'"', DateTime.class);
      if(PLE.get('OverrideEffectiveUntill')!=null)
      NewPLE.vlocity_cmt__EffectiveUntilDate__c = (DateTime)Json.deserialize('"'+(PLE.get('OverrideEffectiveUntill'))+'"', DateTime.class);
      //NewPLE.vlocity_cmt__EffectiveFromDate__c = (Datetime)PLE.get('OverrideEffectiveFrom');
      //NewPLE.vlocity_cmt__EffectiveUntilDate__c= (Datetime)PLE.get('OverrideEffectiveUntill');
      NewPLE.vlocity_cmt__IsBasePrice__c =(Boolean) PLE.get('BasePrice2');
      NewPLE.vlocity_cmt__PriceListId__c =(Id) PLE.get('PriceList2');
      NewPLE.vlocity_cmt__PromotionItemId__c = (Id)PLE.get('PricingOverride');
      NEWPLE.vlocity_cmt__PricingElementId__c = (Id)PLE.get('PricingElement_Override');
      NEWPLE.vlocity_cmt__TimePlanId__c = (Id)PLE.get('TimePlan2');
      NEWPLE.vlocity_cmt__TimePolicyId__c = (Id)PLE.get('TimePolicy2');
      NEWPLE.vlocity_cmt__IsVirtualPrice__c =(Boolean) PLE.get('VirtualPrice2');
      NEWPLE.vlocity_cmt__PromotionId__c = (Id)inputMap.get('DRId_vlocity_cmt__Promotion__c');
      NEWPLE.vlocity_cmt__ProductId__c = ProdId;
      NEWPLE.vlocity_cmt__IsOverride__c = true;
      insert NEWPLE ;
      NEWPLE.Name = NEWPLE.Id;
      update NEWPLE ;
      PLEList = [select vlocity_cmt__PromotionId__r.Name,vlocity_cmt__PriceListId__r.Name,vlocity_cmt__DisplayText__c,
       vlocity_cmt__PricingElementId__r.Name, vlocity_cmt__PricingElementId__r.vlocity_cmt__Code__c, vlocity_cmt__PricingElementId__r.vlocity_cmt__DisplayText__c, vlocity_cmt__PricingElementId__r.vlocity_cmt__CalculationType__c, vlocity_cmt__PricingElementId__r.vlocity_cmt__AdjustmentValue__c
       from vlocity_cmt__PriceListEntry__c where vlocity_cmt__PromotionId__c=:(Id)inputMap.get('DRId_vlocity_cmt__Promotion__c') and vlocity_cmt__IsOverride__c=true];
        outputMap.put('OverridePriceListEntry',PLEList);
        outputMap.put('IsNewOverride',false);
       }  
      if(NEWPLE.Id != null){
      outputMap.put('PLE',NEWPLE.Id);
 
      }
      /*}
      catch(exception e){
      system.debug('Exception'+e);
      }*/
      return true;
      }
      }