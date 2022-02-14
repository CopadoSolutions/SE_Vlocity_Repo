trigger VDODefaultAssetValues on Asset (before insert, before update) {
    for(Asset a: Trigger.new){
        
        //Fill in some default order values.
        if (a.SerialNumber == null) {
            a.SerialNumber = 'VLO-' + Math.Round(Math.Random()*9999);
        }
        if (a.vlocity_cmt__ConnectDate__c == null){
            a.vlocity_cmt__ConnectDate__c = System.TODAY();
            a.vlocity_cmt__ActivationDate__c = System.TODAY();
            a.PurchaseDate = System.TODAY();
            a.InstallDate = System.TODAY();
        }
        if (a.Status == null) {
            a.Status = 'Purchased';
        }
        
        //Add a phone number and picture for new mobile devices.
        if(a.name == 'iPhone X' || a.name == 'iPhone 8'){
            a.mobile_number__c = '415.832.0091';
            a.name = 'Jenny\'s ' + a.name;
            a.product_image__c = '/resource/VDOCommunityResources/images/profilepicjenny.png';
        }
        
        //Link the latest contract for the corresponding order to the new assets.
        if(a.vlocity_cmt__ContractId__c == null && a.vlocity_cmt__OrderProductId__c != null){
            try{
                List<OrderItem> allOrderItems = [SELECT id, OrderId FROM OrderItem WHERE Id = :a.vlocity_cmt__OrderProductId__c LIMIT 1];
                List<Contract> allContracts = new List<Contract>();
    
                if(allOrderItems.size() > 0){
                    allContracts = [SELECT id FROM Contract WHERE vlocity_cmt__OrderId__c = :allOrderItems[0].OrderId ORDER BY CreatedDate DESC LIMIT 1];
                }
                if(allContracts.size() > 0){
                    a.vlocity_cmt__ContractId__c = allContracts[0].Id;
                }
            }catch(Exception e){
                
            }
        }
    }
}