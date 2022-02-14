trigger DE_QuoteLineItemApprovalLevel on QuoteLineItem (before update) 
{

    // LOCATION FACTOR MATRICES
    Map<Integer, String> prodNameMap         = new Map<Integer, String>();
    Map<Integer, String> chargeTypeMap       = new Map<Integer, String>();
    Map<Integer, Double> aboveValMap         = new Map<Integer, Double>();
    Map<Integer, Double> atOrBelowValMap     = new Map<Integer, Double>();
    Map<Integer, String> approvalLevelReqMap = new Map<Integer, String>();
    List<Integer> idxList = new List<Integer>();
    Set<String> prodNameSet = new Set<String>();
    Integer rowCnt = 0;

    List<vlocity_cmt__CalculationMatrix__c> lMatrixId          = new List<vlocity_cmt__CalculationMatrix__c>();
    List<vlocity_cmt__CalculationMatrixVersion__c> lMatrixVsId = new List<vlocity_cmt__CalculationMatrixVersion__c>();
    List<vlocity_cmt__CalculationMatrixRow__c> lMatrixRows     = new List<vlocity_cmt__CalculationMatrixRow__c>();    

    lMatrixId = [SELECT Id,Name FROM vlocity_cmt__CalculationMatrix__c WHERE Name = 'Approval Discount Matrix' LIMIT 1];

    if (lMatrixId.size() > 0){
        lMatrixVsId = [SELECT Id,Name,vlocity_cmt__CalculationMatrixId__c,vlocity_cmt__CurrentStatus__c,vlocity_cmt__EndDateTime__c,vlocity_cmt__IsEnabled__c,vlocity_cmt__Priority__c,vlocity_cmt__StartDateTime__c,vlocity_cmt__VersionNumber__c 
                       FROM vlocity_cmt__CalculationMatrixVersion__c 
                       WHERE vlocity_cmt__CalculationMatrixId__c = :lMatrixId[0].Id AND vlocity_cmt__IsEnabled__c = true 
                       ORDER BY vlocity_cmt__Priority__c DESC LIMIT 1];

        // if the most recent version was found
        if (lMatrixVsId.size() > 0){
            lMatrixRows = [SELECT Id,Name,vlocity_cmt__CalculationMatrixVersionId__c,vlocity_cmt__InputData__c,vlocity_cmt__OutputData__c 
                            FROM vlocity_cmt__CalculationMatrixRow__c 
                            WHERE vlocity_cmt__CalculationMatrixVersionId__c = :lMatrixVsId[0].Id];

           if (lMatrixRows.size() > 0){
                for (vlocity_cmt__CalculationMatrixRow__c calcRow:lMatrixRows){
                    if (calcRow.Name != 'Header'){
                            String tmp1, tmp2, tmpProduct;
                            Map<String, Object> tmpInput = new Map<String, Object>();
                            Map<String, Object> tmpOutput = new Map<String, Object>();

                            tmp1 = calcRow.vlocity_cmt__InputData__c;
                            tmp2 = calcRow.vlocity_cmt__OutputData__c;

                            tmpInput = (Map<String, Object>)JSON.deserializeUntyped(tmp1);
                            tmpOutput = (Map<String, Object>)JSON.deserializeUntyped(tmp2);

                            prodNameMap.put(rowCnt, (String)tmpInput.get('ProductName'));
                            chargeTypeMap.put(rowCnt, (String)tmpInput.get('ChargeType'));
                            aboveValMap.put(rowCnt, Double.ValueOf(tmpInput.get('AboveValue')));
                            atOrBelowValMap.put(rowCnt, Double.ValueOf(tmpInput.get('AtOrBelowValue')));
                            approvalLevelReqMap.put(rowCnt, (String)tmpOutput.get('ApprovalLevelRequired'));
                            if (!prodNameSet.contains((String)tmpInput.get('ProductName')))
                                prodNameSet.add((String)tmpInput.get('ProductName'));
                            idxList.add(rowCnt);
                            rowCnt++;

                        } // just process the data rows  
                    } // for all the rows
                } // there are rows  
            } // if there are some versions of the matrix org
        else return;
        } // if there is a calc matrix with the name


    List<QuoteLineItem> updList       = new List<QuoteLineItem>();
    Map<String, String> maxApprLvlMap = new Map<String, String>();  // QteId - MaxLvl
    List<String> qteNumList           = new List<String>();  // list of quoteIDs that need to be updated for max apprv lvl
    Map<String, Integer> hierLvl      = New Map<String, Integer>{'NONE' => 0, 'Manager' => 1, 'VP' => 2, 'CXO' => 3};

    for (QuoteLineItem qli: trigger.new){
        // if it's one of the products with changes defined
        if (prodNameSet.contains(qli.ProductName__c)){

            // compare old to new values on service location, update children with SL
            QuoteLineItem OLDqli = Trigger.oldMap.get(qli.Id);

            // if the one time charge has changed
            if (qli.vlocity_cmt__OneTimeCharge__c != Oldqli.vlocity_cmt__OneTimeCharge__c){

                Double otc = (Double)qli.vlocity_cmt__OneTimeCharge__c;
                String appLvl = 'NONE';
                // go through the list of matrix discount ranges to see where / if this fits
                for (Integer i:idxList){
                    if (prodNameMap.get(i) == qli.ProductName__c && chargeTypeMap.get(i) == 'OneTime' && otc > aboveValMap.get(i) && otc <= atOrBelowValMap.get(i)) {
                        QuoteLineItem tmp = new QuoteLineItem();
                        tmp.id = qli.id;
                        tmp.Approval_Needed__c = approvalLevelReqMap.get(i);
                        updList.add(tmp);
                        qli.Approval_Needed__c = approvalLevelReqMap.get(i);

                        // save away the quoteID and approval level to set at header level
                        if (maxApprLvlMap.get(qli.QuoteId) == null){
                            maxApprLvlMap.put(qli.QuoteId, approvalLevelReqMap.get(i));
                            qteNumList.add(qli.QuoteId);
                            } // need to add it to the list and map
                        else{ // it's already in the list and map, so need to update it
                            if (hierLvl.get((String)approvalLevelReqMap.get(i)) > hierLvl.get((String)maxApprLvlMap.get(qli.QuoteId))){
                                maxApprLvlMap.put(qli.QuoteId, approvalLevelReqMap.get(i));
                                } // update the existing slot with the higher level
                            } // else - it's already in the list and map - update it

                        } // if we need to record this matrix line approval level
                    } // for all the matrix entries
                } // if onetime changed


            // recurring charge changed on this line
            if (qli.vlocity_cmt__RecurringCharge__c != Oldqli.vlocity_cmt__RecurringCharge__c){
                
                Double rec = (Double)qli.vlocity_cmt__RecurringCharge__c;
                String appLvl = 'NONE';
                for (Integer i:idxList){
                    if (prodNameMap.get(i) == qli.ProductName__c && chargeTypeMap.get(i) == 'Recurring' && rec > aboveValMap.get(i) && rec <= atOrBelowValMap.get(i)) {
                        QuoteLineItem tmp = new QuoteLineItem();
                        tmp.id = qli.id;
                        tmp.Approval_Needed__c = approvalLevelReqMap.get(i);
                        updList.add(tmp);
                        qli.Approval_Needed__c = approvalLevelReqMap.get(i);

                        // save away the quoteID and approval level to set at header level
                        if (maxApprLvlMap.get(qli.QuoteId) == null){
                            maxApprLvlMap.put(qli.QuoteId, approvalLevelReqMap.get(i));
                            qteNumList.add(qli.QuoteId);
                            } // need to add it to the list and map
                        else{ // it's already in the list and map, so need to update it
                            if (hierLvl.get(approvalLevelReqMap.get(i)) > hierLvl.get(maxApprLvlMap.get(qli.QuoteId))){
                                maxApprLvlMap.put(qli.QuoteId, approvalLevelReqMap.get(i));
                                } // update the existing slot with the higher level
                            } // else - it's already in the list and map - update it

                        } // if we need to record this matrix line approval level
                    } // for all the matrix entries
                } // if recurring charged changed on this line
            } // if product name set contains the line's product

        } // end for each quotelineItem passed in

    // if we need to update any of the quote line items approval levels

    // if we have quote header level approval levels that need to be updated
    if (qteNumList.size() > 0){
        List<Quote> qList = new List<Quote>();

        for (String q:qteNumList){
            Quote tmp = new Quote();
            List<Quote> lQte = new List<Quote>();

            lQte = [SELECT Id, Max_Approval_Level__c FROM Quote WHERE Id = :q LIMIT 1];

            if (hierLvl.get(maxApprLvlMap.get(q)) > hierLvl.get(lQte[0].Max_Approval_Level__c)){
                tmp.Id = (String)q;
                tmp.Max_Approval_Level__c = maxApprLvlMap.get(q);
                tmp.MaxApprovalText__c = maxApprLvlMap.get(q); 
                qList.add(tmp);
                } // update the max approval level on the quote header IF it's higher than what is stored

            } // for each quote header in the list

        if (qList.size() > 0)
            update qList;
    } // if there are quote headers that need updated approval levels

} // trigger