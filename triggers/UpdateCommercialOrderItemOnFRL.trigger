trigger UpdateCommercialOrderItemOnFRL on vlocity_cmt__FulfilmentRequestLineDecompRelationship__c (after insert, after update) 
{   
    // get list of FRLs
    list<vlocity_cmt__FulfilmentRequestLine__c> newFRLlist = new list<vlocity_cmt__FulfilmentRequestLine__c>();
    // keep track of already updated FRL Ids to check against
    set<String> updIds = new set<String>();
   
    // go through all inserted or updated Decomp FRL records
    for(vlocity_cmt__FulfilmentRequestLineDecompRelationship__c newFRLDecompReltn : Trigger.New) 
    {
     
        // creating a list to store the related FRL objects to the FRL Decomp Relationship object
        list<vlocity_cmt__FulfilmentRequestLine__c> foundDestinationFRL = new list<vlocity_cmt__FulfilmentRequestLine__c>();
       
        // if #1 OrderItemID is not null and the Destination FRL Id is not null on the FRL Decomp Relationship Line object
        if (newFRLDecompReltn.vlocity_cmt__SourceOrderItemId__c != null && newFRLDecompReltn.vlocity_cmt__DestinationFulfilmentRequestLineId__c != null)
        {
            foundDestinationFRL = [SELECT Id, Commercial_Order_Line__c FROM vlocity_cmt__FulfilmentRequestLine__c FRL
                        WHERE FRL.id = :newFRLDecompReltn.vlocity_cmt__DestinationFulfilmentRequestLineId__c LIMIT 1];
            system.debug('Inside IF #1 - foundDestinationFRL Id, CommercialProductId'+foundDestinationFRL[0].Id+' ,'+foundDestinationFRL[0].Commercial_Order_Line__c);
           
            if (foundDestinationFRL.size() > 0 && foundDestinationFRL[0].Commercial_Order_Line__c == null){
                system.debug('Inside IF #2 - foundDestinationFRL Id, OrderProductId'+foundDestinationFRL[0].Id+' ,'+foundDestinationFRL[0].Commercial_Order_Line__c);

                if (updIds.contains(foundDestinationFRL[0].Id) != true)
                {
                    system.debug('Inside IF #3 updIds ='+updIds);
                    vlocity_cmt__FulfilmentRequestLine__c newUpdFRL = new vlocity_cmt__FulfilmentRequestLine__c();
                    newUpdFRL.Id = newFRLDecompReltn.vlocity_cmt__DestinationFulfilmentRequestLineId__c;
                    newUpdFRL.Commercial_Order_Line__C = newFRLDecompReltn.vlocity_cmt__SourceOrderItemId__c;
                    newFRLlist.add(newUpdFRL);
                    updIds.add(foundDestinationFRL[0].Id);
                    }
                }
        } // if data exists
    } // for loop  
   
    if (newFRLlist.size() > 0)
    {
        system.debug('newFRLList='+newFRLList);
        update(newFRLlist);
    }
}