global class VDOMobilePushNotificationAutoTask implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {

    global void executeBatch(List<vlocity_cmt__OrchestrationItem__c> items) {
    
        for (vlocity_cmt__OrchestrationItem__c item: items) {
            
            try{
            
                List<vlocity_cmt__OrchestrationItem__c> itemReference = [SELECT vlocity_cmt__AutoTaskParameters__c, vlocity_cmt__OrderItemId__r.Order.Account.Phone, vlocity_cmt__OrderItemId__r.Order.ShipToContact.FirstName, vlocity_cmt__OrderItemId__r.Order.ShipToContact.MobilePhone, vlocity_cmt__OrderItemId__r.Order.ShipToContact.Phone, vlocity_cmt__OrderItemId__r.Order.ShipToContactId, vlocity_cmt__OrderItemId__r.Order.AccountId, vlocity_cmt__OrchestrationItemDefinitionId__r.vlocity_cmt__SystemInterfaceId__r.Name, vlocity_cmt__OrchestrationItemDefinitionId__r.Message_Content__c FROM vlocity_cmt__OrchestrationItem__c WHERE Id = :item.Id];
                
                if(itemReference.size() > 0){
                
                    Contact c;
                    if(itemReference[0].vlocity_cmt__OrderItemId__r.Order.ShipToContactId == null){
                        c = [SELECT id, Phone, FirstName, LastName, MobilePhone, HomePhone FROM Contact WHERE Vlocity_Demo_Key__c = 'democontact1' LIMIT 1];
                    }else{
                        c = itemReference[0].vlocity_cmt__OrderItemId__r.Order.ShipToContact;
                    }
                    
                    String outboundMessage = itemReference[0].vlocity_cmt__AutoTaskParameters__c;
                    outboundMessage = outboundMessage.replace('{Company}', UserInfo.getOrganizationName() );
                    outboundMessage = outboundMessage.replace('{Name}', c.FirstName);      
                
                    Map<String, Object> applePayload = Messaging.PushNotificationPayload.apple(outboundMessage, 'default', 1, null);
                    applePayload.put('deeplinking', '{objectType:Order,objectId:'+item.vlocity_cmt__orderItemId__r.orderId+'}');
                    
                    Map<String, Object> androidPayload = new Map<String, Object>();
                    androidPayload.put('message', 'android: ' + outboundMessage);
                    androidPayload.put('deeplinking', '{objectType:Order,objectId:'+item.vlocity_cmt__orderItemId__r.orderId+'}');
                    
                    // Adding recipient users to list
                    Set<String> users = new Set<String>();
                    users.add(UserInfo.getUserId());
                    
                    connected_apps.VlocityMobileNotification.send(applePayload, androidPayload, users);
                    vlocity_mobile.VlocityMobileNotification.send(applePayload, androidPayload, users);
                    
                }
                
            }catch(exception e){}
        
        }
    
    }

}