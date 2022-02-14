global with sharing class VPLCreatePlan implements vlocity_cmt.VlocityOpenInterface
{
global VPLCreatePlan() { }

    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try
        {
            if (methodName.equals('createPlanMethod'))
            {
                createPlanMethod(inputMap,outMap,options);
            }
            else if (methodName.equals('startPlanByOrderId'))
            {
                startPlanByOrderId(inputMap,outMap,options);
            }
            
            else{
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
    
      void createPlanMethod(Map<String, Object> inputMap, Map<String, Object> outMap,Map<String,Object> options)
      {
          String sOrderId = (String)inputMap.get('OrderId');
          System.debug('createPlanMethod::OrderId:->'+sOrderId);
          
          String PlanId = vlocity_cmt.SimpleDecompositionController.decomposeAndCreatePlan(sOrderId);
          
          //have to love cart horse bs.
          //vlocity_cmt__OrchestrationPlan__c Plan= [Select Name FROM vlocity_cmt__OrchestrationPlan__c WHERE Id=:PlanId];
          outMap.put('PlanName',PlanId);
          
      } 
      
     
      
      void startPlanByOrderId(Map<String, Object> inputMap, Map<String, Object> outMap,Map<String,Object> options)
      {
      
          String sOrderId = (String)inputMap.get('OrderId');
          System.debug('startPlanByOrderId::OrderId:->'+sOrderId);
          List<vlocity_cmt__orchestrationplan__c> plan = [select id from vlocity_cmt__orchestrationplan__c where vlocity_cmt__OrderId__c = :sOrderId];
          
          if(plan.size() == 1)
          {
              List<vlocity_cmt__OrchestrationItem__c> itemsToStart = [select id, CreatedBy.Name,Name,vlocity_cmt__State__c 
                                      from vlocity_cmt__OrchestrationItem__c 
                                      where vlocity_cmt__OrchestrationPlanId__c  = :plan[0].Id 
                                      and Name in('Start Order','Start Consumer Order')
                                      and vlocity_cmt__State__c = 'Pending'];
                                      
              if(itemsToStart.size() == 1)
              {
                  itemsToStart[0].vlocity_cmt__State__c = 'Completed';
                  update itemsToStart;
                  outMap.put('PlanStarted','true');
              }
          }                                      
      }
    }