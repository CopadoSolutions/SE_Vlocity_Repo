public class VDOXOMDemoDashboardController{

    public void VDOXOMDemoDashboardController(){   
    }
    
    @RemoteAction
    public static vlocity_cmt__OrchestrationItem__c getNotifications(String itemId){ 
        return [SELECT id, Name, response__c, request__c, vlocity_cmt__TimestampReady__c, vlocity_cmt__TimestampRunning__c, vlocity_cmt__TimestampCompleted__c, vlocity_cmt__LeadTimeRunning__c, vlocity_cmt__LeadTimeCompleted__c, vlocity_cmt__ExecutionLog__c FROM vlocity_cmt__OrchestrationItem__c WHERE id = :itemId LIMIT 1][0];
    }
    
    @RemoteAction
    public static List<vlocity_cmt__OrchestrationPlan__c> getOrchestrationPlans(){   
        return [SELECT id, name, vlocity_cmt__OrderId__c, vlocity_cmt__OrderId__r.OrderNumber, vlocity_cmt__OrderId__r.EffectiveDate, vlocity_cmt__OrderId__r.Account.Name, vlocity_cmt__OrderId__r.Account.PhotoURL, vlocity_cmt__OrderId__r.vlocity_cmt__RecurringTotal__c, vlocity_cmt__OrderId__r.vlocity_cmt__OneTimeTotal__c FROM vlocity_cmt__OrchestrationPlan__c ORDER BY createddate ASC];     
    }
    
    @RemoteAction
    public static List<vlocity_cmt__OrchestrationItem__c> getOrchestrationPlanItems(String planId){   
        return [SELECT id, name, vlocity_cmt__OrchestrationItemDefinitionId__r.RecordType.Name, vlocity_cmt__State__c, vlocity_cmt__LeadTimeRunning__c, vlocity_cmt__LeadTimeCompleted__c, vlocity_cmt__SystemInterfaceId__r.vlocity_cmt__SystemId__r.Id FROM vlocity_cmt__OrchestrationItem__c WHERE vlocity_cmt__OrchestrationPlanId__c = :planId ORDER BY createddate];     
    }
    
    @RemoteAction
    public static List<vlocity_cmt__System__c> getOrchestrationPlanSystems(String planId){   
        Set<Id> theSystemIds = new Set<Id>();
        for(vlocity_cmt__OrchestrationItem__c theItem : [SELECT id, name, vlocity_cmt__SystemInterfaceId__r.vlocity_cmt__SystemId__r.Id FROM vlocity_cmt__OrchestrationItem__c WHERE vlocity_cmt__OrchestrationPlanId__c = :planId AND vlocity_cmt__SystemInterfaceId__c != NULL]){
            theSystemIds.add(theItem.vlocity_cmt__SystemInterfaceId__r.vlocity_cmt__SystemId__r.Id);
        }     
        return [SELECT id, name, image__c, online__c FROM vlocity_cmt__System__c WHERE Id IN :theSystemIds];     
    }

    @RemoteAction
    public static void toggleSystem(String systemid, Boolean online){
        vlocity_cmt__System__c theSystem = [SELECT id, name, image__c, online__c FROM vlocity_cmt__System__c WHERE Id = :systemid LIMIT 1][0];
        theSystem.Online__c = online;
        update theSystem;   
    }

    @RemoteAction
    public static void retryItem(String itemid){
        vlocity_cmt__OrchestrationItem__c theItem =  [SELECT id, name, vlocity_cmt__State__c FROM vlocity_cmt__OrchestrationItem__c WHERE id = :itemid][0];     
        theItem.vlocity_cmt__State__c = 'Ready';
        update theItem;   
    }

    @RemoteAction 
    public static void DeleteOrchestrationPlans(){   
        delete [select id from vlocity_cmt__OrchestrationDependency__c];
        delete [select id from vlocity_cmt__OrchestrationItem__c];
        delete [select id from vlocity_cmt__OrchestrationPlan__c];
        delete [select id from vlocity_cmt__FulfilmentRequestDecompRelationship__c];
        delete [select id from vlocity_cmt__FulfilmentRequest__c];
    }

}