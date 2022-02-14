/*
* VLOCITY, INC. CONFIDENTIAL
* __________________
*
*  2014-2017 Vlocity, Inc.
*  All Rights Reserved.
*
* NOTICE:  All information contained herein is, and remains
* the property of Vlocity, Inc. and its suppliers,
* if any. The intellectual and technical concepts contained
* herein are proprietary to Vlocity, Inc. and its suppliers and may be
* covered by U.S. and Foreign Patents, patents in process, and are
* protected by trade secret or copyright law. Dissemination of this
* information and reproduction, modification or reverse-engineering
* of this material, is prohibited unless prior written permission
* is obtained from Vlocity, Inc.
*
*
* ProductHierarchyPathUpdateBatch
*
* Manish
*
* This batch is to regenerate product hierarchy path of PromotionItem__c object.
* There are few common methods of cpq rewritten in this file to support it for managed and unmanged org.
* Before running this job, make sure to run product hierarchy maintenance job under Vlocity CMT Administration tab.
* Change nsPrefix variable according to org type.
*
*/
public class ProductHierarchyPathUpdateBatch implements Database.Batchable<sObject>
{

    private String query;
    /*
     * for Managed code, use this
     */
    private String nsPrefix = 'vlocity_cmt__';
    /*
     * for unmanaged code, use this
     */
    //String nsPrefix = ApplicationUtilities.getNameSpacePrefix();

    public ProductHierarchyPathUpdateBatch()
    {
        query = 'SELECT Id, '+ nsPrefix +'ProductHierarchyPath__c, '+ nsPrefix +'OfferId__c, '+ nsPrefix + 'ProductId__c from '+ nsPrefix +'PromotionItem__c ';
    }

    public Database.Querylocator start(Database.BatchableContext BC)
    {
        System.debug('start: batch started');
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<SObject> promotionItemList)
    {
        System.debug('Size of list' + promotionItemList.size());
        List<SObject> updateList = new List<SObject>();
        for (Integer i=0;i<promotionItemList.size();i++)
        {
            SObject pi = promotionItemList.get(i);
            Id offerId = (Id) pi.get(nsPrefix + 'OfferId__c');
            Id productId = (Id) pi.get(nsPrefix + 'ProductId__c');
            if (offerId != null)
            {
                String hierarchyPath = getProductHierarchyPath(offerId, productId);
                System.debug('old hierarchyPath: '+ (String) pi.get(nsPrefix + 'ProductHierarchyPath__c'));
                System.debug('new hierarchyPath: '+ hierarchyPath);
                pi.put(nsPrefix + 'ProductHierarchyPath__c', hierarchyPath);
                updateList.add(pi);
            }
        }
        update updateList;
        System.debug('done...');
    }

    public void finish(Database.BatchableContext BC)
    {
        System.debug('finished');
    }

    private String getProductHierarchyPath(Id offerId, Id productId)
    {
        Map<Id, List<Id>> parentProductToChildProds = new Map<Id, List<Id>>();
        Map<String, SObject> parentChildToProductChildItemMap = new Map<String, SObject>();
        Map<String, String> lineNumberToProductHierarchyPath = new Map<String, String>();
        Map<Id, SObject> productIdToRootPCI = new Map<Id, SObject>();
        Schema.SObjectType dataStoreType = Schema.getGlobalDescribe().get(nsPrefix + 'DataStore__c');
        ID hierarchyRecordtypeId  = dataStoreType.getDescribe().getRecordTypeInfosByName().get('Product Hierarchy').getRecordTypeId();
        Set<String> pciIds = new Set<String>();
        String dataStoreQuery = 'SELECT '+nsPrefix +'ProductId__c, '+nsPrefix +'Value__c, '+nsPrefix +'Key__c FROM '+nsPrefix +'DataStore__c WHERE  '+nsPrefix +'ProductId__c =:offerId  AND RecordTypeId =: hierarchyRecordtypeId';
        for (SObject dStoreItem : Database.query(dataStoreQuery))
        {
            String value = (String) dStoreItem.get(nsPrefix +'Value__c');
            pciIds.addAll(value.split(','));
        }

        List<String> pciFields =  new List<String>{'Id',
                                                    'Name',
                                                    nsPrefix+'ChildProductId__c',
                                                    nsPrefix+'IsVirtualItem__c',
                                                    nsPrefix+'IsOverride__c',
                                                    nsPrefix+'ParentProductId__c',
                                                    nsPrefix+'SeqNumber__c',
                                                    nsPrefix+'CollapseHierarchy__c',
                                                    nsPrefix+'IsRootProductChildItem__c'};

        String condition = '(ID IN :pciIds OR ('+ nsPrefix +'ParentProductId__c =: offerId AND '+ nsPrefix + 'IsRootProductChildItem__c = true))';

        String query = 'SELECT ' + String.join(pciFields, ',') + ' FROM '+ nsPrefix +'ProductChildItem__c WHERE '+ condition + ' AND '+ nsPrefix +'IsOverride__c = false ORDER BY '+ nsPrefix +'SeqNumber__c';
        List<SObject> childItemsList = Database.query(query);
        for (Integer index = 0; index < childItemsList.size(); index ++)
        {
            SObject childItem = childItemsList.get(index);
            Id parentProductId = (Id) childItem.get(nsPrefix + 'ParentProductId__c');
            Id childProductId = (Id) childItem.get(nsPrefix + 'ChildProductId__c');
            Boolean isRootProductChild = (Boolean) childItem.get(nsPrefix + 'IsRootProductChildItem__c');
            if (!isRootProductChild)
            {
                if (parentProductToChildProds.get(parentProductId) == null)
                {
                    parentProductToChildProds.put(parentProductId, new List<Id>());
                }
                parentProductToChildProds.get(parentProductId).add(childProductId);
                parentChildToProductChildItemMap.put(parentProductId + ',' + childProductId, childItem);
            }
        }

        List<String> possibleProductHierarchyList = new List<String>();
        findProducts(offerId, '0001', possibleProductHierarchyList, productId, parentProductToChildProds, parentChildToProductChildItemMap, lineNumberToProductHierarchyPath);
        if (possibleProductHierarchyList.size() > 0)
        {
            return possibleProductHierarchyList[0];
        } else
        {
            return '';
        }
    }

    private void findProducts(Id rootproductId,
                                String rootLineNumber,
                                List<String> possibleProductHierarchyList,
                                Id productId,
                                Map<Id, List<Id>> parentProductToChildProds,
                                Map<String, SObject> parentChildToProductChildItemMap,
                                Map<String, String> lineNumberToProdHierarchyPath)
    {
        lineNumberToProdHierarchyPath.put(rootLineNumber, (String) rootproductId);

        //add root product to the productids
        getProductHierarchy(rootproductId, rootLineNumber, possibleProductHierarchyList, productId, parentProductToChildProds, parentChildToProductChildItemMap, lineNumberToProdHierarchyPath);
    }

    private void getProductHierarchy(ID parentProductId,
                                        String level,
                                        List<String> possibleProductHierarchyList,
                                        Id productId,
                                        Map<Id, List<Id>> parentProductToChildProds,
                                        Map<String, SObject> parentChildToProductChildItemMap,
                                        Map<String, String> lineNumberToProductHierarchyPath)
    {
        List<Id> childItems = parentProductToChildProds.get(parentProductId);
        if (childItems == null)
            return;

        for(Integer index = 0; index < childItems.size(); index ++)
        {
            SObject contextProductChildItem = parentChildToProductChildItemMap.get(parentProductId + ',' + childItems[index]);
            String lineNumber = nextChildLN(level, index + 1);
            String productHierarchyPath = generateProductHierarchyPath(lineNumber, contextProductChildItem, childItems[index], lineNumberToProductHierarchyPath);
            //get the line no for current child from the level and the index
            String lineNum = nextChildLN(level, index + 1);
            lineNumberToProductHierarchyPath.put(lineNumber, productHierarchyPath);
            if (childItems[index] == productId)
            {
                possibleProductHierarchyList.add(productHierarchyPath);
            }
            getProductHierarchy(childItems[index], nextChildLN(level, index + 1), possibleProductHierarchyList, productId, parentProductToChildProds, parentChildToProductChildItemMap, lineNumberToProductHierarchyPath);
        }
    }

    private String generateProductHierarchyPath(String lineNumber, SObject productChildItem, Id childProdId, Map<String, String> lineNumberToProdHierarchyPath)
    {
        String parentLineNum = lineNumber.substring(0, lineNumber.lastIndexOf('.'));
        String productHierarchyPath = lineNumberToProdHierarchyPath.get(parentLineNum);
        productHierarchyPath = productHierarchyPath + '<' + childProdId;
        return productHierarchyPath;
    }

    private String nextChildLN(String parentLN, Integer childNum)
    {
        String retval = '';
        retval  = parentLN+'.'+padLeft(childNum);
        return retval;
    }

    private String padLeft(Integer i)
    {
        String str = String.valueOf(i);
        while (str.length() < 4)
        {
            str = '0' + str;
        }
        return str;
    }

}