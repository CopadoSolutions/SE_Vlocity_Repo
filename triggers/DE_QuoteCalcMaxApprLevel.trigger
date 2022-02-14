trigger DE_QuoteCalcMaxApprLevel on Quote (before update) 
{

    Map<String, Integer> hierLvl     = New Map<String,  Integer>{'NONE' => 0, 'Manager' => 1, 'VP' => 2, 'CXO' => 3};
    Map<Integer, String> hierLvlBack = New Map<Integer, String>{0 => 'NONE', 1 => 'Manager', 2 => 'VP', 3 => 'CXO'};

    for (Quote q:Trigger.new)
    {
    List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        
        qliList = [SELECT Id, Approval_Needed__c, QuoteId FROM QuoteLineItem qli WHERE qli.QuoteId = :q.Id];
        Integer apprLvlCompare = 0;
        
        if (qliList.size() > 0)
    {
            for (QuoteLineItem qli:qliList)
        {
                if (hierLvl.get(qli.Approval_Needed__c) > apprLvlCompare) apprLvlCompare = hierLvl.get(qli.Approval_Needed__c);
            }
            q.Max_Approval_Level__c = hierLvlBack.get(apprLvlCompare);
        }
      } // for all of the updated quotes
    
}