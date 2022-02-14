/**
 * This class attempts to split-up an order, quote, or opportunity line item and assign separate service accounts to each instance.
 * It is called by an OmniScript which gathered information about the cart and service accounts.  This information is expected to be passed
 * into this class so that it can perform the split.
 *
 * @author  Joe McMaster (jmcmaster@vlocity.com)
 * @version 3.0
 *
 * This class was imported by Lars on 6 Apr 2020 from a file emailed to him by Joe on the same day. 
 *
 * History
 * -------
 * v1.0 - 09-04-2018 - Initial Version built for Rogers Demo
 * v2.0 - 10-22-2018 - Scaleability Improvements (avoids Governor Limit exceptions)
 *                     Cart pricing now updates properly
 * v3.0 - 12-06-2019 - Added support for Quotes and Opportunities
 * 
 * @todo - Look at merging in productized interface (https://docs.vlocity.com/en/SplitProductInterface.html)
 */
global with sharing class SplitByServiceAccount implements vlocity_cmt.VlocityOpenInterface {
    
    public class BadInputDataException extends Exception {}
        
    private static String LINEITEM_IGNORE_FIELDS = ',CreatedById,CreatedDate,LastModifiedById,LastModifiedByDate,LastReferencedDate,LastViewedDateDate,SystemModstamp,';
    
    // These can hold OrderItem, QuoteLineItem, or OpportunityLineItem objects, depending on the type of cart we run against
    private Map<ID, SObject> lineItems;              // holds all line items from the cart
    private Map<String, SObject> updatedLineItems;   // holds any existing line items that have been updated
    private Map<String, SObject> insertedLineItems;  // holds any new line items that have been created
    
    /**
     * Default Constructor
     * 
     */
    public SplitByServiceAccount() {
    
        updatedLineItems  = new Map<String, SObject>();
        insertedLineItems = new Map<String, SObject>();
    }
    
    /**
     * Top level call by a Vlocity Remote Action
     *
     * @param inputMap  - The input provided to the Remote Action
     * @param outputMap - Any output to be provided back to the Remote Action
     * @param options   - Any options to aid in the execution of this class
     *
     * @returns true if the method completes successfully, false otherwise
     */ 
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        
        try {
        
            // Split the Order Item
            if (methodName == 'split') return split(inputMap);  
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'ERROR ' + e.getMessage() + ' Line: ' + e.getLineNumber());
        }
        
        return false;
    }
     
    /**
     * Splits a line item quantity > 1 into individual line items and assigns a service account to each.  The inputMap data
     * is expected to be in the form:
     *
     * {
     *   "lineItemId": "8020b000000zniBAAQ",
     *   "serviceAccounts": [
     *     {
     *       "serviceAccountId": "id1"
     *     },
     *     {
     *       "serviceAccountId": "id2"
     *     }
     *   ]
     * }
     *
     * @param inputMap  The input data
     *
     * @return true if the method completes successfully, false otherwise
     */
    private Boolean split(Map<String, Object> inputMap) {
    
        String lineItemId = (String)inputMap.get('lineItemId');
        List<Object> serviceAccounts = (List<Object>)inputMap.get('serviceAccounts');
        Integer numOfSplits = serviceAccounts.size();

        // Determine the type of line item we are dealing with
        String cartType     = 'Order';
        String lineItemType = 'OrderItem';
        if (lineItemId.startsWithIgnoreCase('0QL')) {
            cartType     = 'Quote';
            lineItemType = 'QuoteLineItem';
        }
        else if (lineItemId.startsWithIgnoreCase('00k')) {
            cartType     = 'Opportunity';
            lineItemType = 'OpportunityLineItem';
        }
        System.debug('Split - processing ' + cartType + ' / ' + lineItemType);

        // Get the source line item we will split
        SObject sourceLineItem = Database.query('SELECT ' + getColumnNames(lineItemType, LINEITEM_IGNORE_FIELDS) + ' FROM ' + lineItemType + ' WHERE Id=\'' + lineItemId + '\' LIMIT 1').get(0);

        // Get the cart Id
        ID cartId = null;
        if (cartType == 'Order')      cartId = (ID)sourceLineItem.get('OrderId');
        else if (cartType == 'Quote') cartId = (ID)sourceLineItem.get('QuoteId');
        else                          cartId = (ID)sourceLineItem.get('OpportunityId');
        
        // Get all line items in the cart, and specifically the one we are splitting
        lineItems = new Map<ID, SObject>((List<SObject>)Database.query('SELECT ' + getColumnNames(lineItemType, LINEITEM_IGNORE_FIELDS) + ' FROM ' + lineItemType + ' WHERE ' + cartType + 'Id=\'' + cartId + '\''));

        // Make sure we have sufficient quantity of the product to split the desired number of times
        if (Integer.valueOf(sourceLineItem.get('Quantity')) < numOfSplits) throw new BadInputDataException(sourceLineItem.get('ProductName__c') + ' Line Item Quantity (' + sourceLineItem.get('Quantity') + ') cannot be split ' + numOfSplits+ ' times.');

        // Get the Line Number of the line item to split (i.e. 0001.0001)
        // When duplicating, we will need to properly increment the line numbers for each new entry and 'bump' any pre-existing line items down the list
        String  lineNumberPrefix = getLineNumberPrefix((String)sourceLineItem.get('vlocity_cmt__LineNumber__c'));
        Integer lineNumberIndex  = getLineNumberIndex((String)sourceLineItem.get('vlocity_cmt__LineNumber__c'));

        // Make room for the line item clones by bumping any line items in the way
        // The source line item will remain so we start at 1
        for (Integer i=1; i<numOfSplits; i++) {
            
            lineNumberIndex++;
            String targetLineNumber = buildLineNumberString(lineNumberPrefix, lineNumberIndex);
            
            // Make room for the clone by bumping any pre-existing line items further down
            bump(targetLineNumber);
        }
        
        // Configure and Clone the Order Items, reset the line number index
        lineNumberIndex  = getLineNumberIndex((String)sourceLineItem.get('vlocity_cmt__LineNumber__c'));
        for (Integer i=0; i<numOfSplits; i++) {
            
            SObject item;
            ID serviceAccountId = (ID)((Map<String, Object>)serviceAccounts.get(i)).get('serviceAccountId');
            
            // If this is the first item it already exists as the original source line item so don't create a clone, but change it's configuration as needed
            if (i == 0) {
            
                item = sourceLineItem;
                
                // Save the original quantity and update it on the line item object based on the number of splits we will perform
                Integer originalQuantity = Integer.valueOf(item.get('Quantity'));
                item.put('Quantity', Integer.valueOf(item.get('Quantity')) - numOfSplits + 1);
                item.put('vlocity_cmt__EffectiveQuantity__c', Integer.valueOf(item.get('Quantity')));
                
                // Update the pricing manually - quick hack as the CPQ API calls don't seem to change anything and I was running out of time!                
                item.put('vlocity_cmt__RecurringTotal__c',          (Double.valueOf(item.get('vlocity_cmt__RecurringTotal__c'))/originalQuantity)*Integer.valueOf(item.get('Quantity')));
                item.put('vlocity_cmt__OneTimeTotal__c',            (Double.valueOf(item.get('vlocity_cmt__OneTimeTotal__c'))/originalQuantity)*Integer.valueOf(item.get('Quantity')));
                item.put('vlocity_cmt__EffectiveOneTimeTotal__c',   (Double.valueOf(item.get('vlocity_cmt__EffectiveOneTimeTotal__c'))/originalQuantity)*Integer.valueOf(item.get('Quantity')));
                item.put('vlocity_cmt__EffectiveRecurringTotal__c', (Double.valueOf(item.get('vlocity_cmt__EffectiveRecurringTotal__c'))/originalQuantity)*Integer.valueOf(item.get('Quantity')));
    
                // Set the Service Account on this line item (+ children)
                setServiceAccount(item, serviceAccountId);
                
                updatedLineItems.put(item.Id, item);
            }            
            else {

                // Create a clone from the original source line item
                System.debug('Cloning -> ' + sourceLineItem.get('vlocity_cmt__LineNumber__c') + ' - ' + sourceLineItem.get('ProductName__c'));
                item = sourceLineItem.clone(false, true, false, false);                
                
                // Save the original quantity (came from source line item and may not be 1)
                // update it on the cloned line item object by setting to 1
                Integer originalQuantity = Integer.valueOf(item.get('Quantity'));
                item.put('Quantity', 1);
                item.put('vlocity_cmt__EffectiveQuantity__c', 1);
                
                // Update the pricing manually - quick hack as the CPQ API calls don't seem to change anything and I was running out of time!
                item.put('vlocity_cmt__RecurringTotal__c', (Double.valueOf(item.get('vlocity_cmt__RecurringTotal__c'))/originalQuantity)*Integer.valueOf(item.get('Quantity')));
                item.put('vlocity_cmt__OneTimeTotal__c',   (Double.valueOf(item.get('vlocity_cmt__OneTimeTotal__c'))/originalQuantity)*Integer.valueOf(item.get('Quantity')));
                item.put('vlocity_cmt__EffectiveOneTimeTotal__c', (Double.valueOf(item.get('vlocity_cmt__EffectiveOneTimeTotal__c'))/originalQuantity)*Integer.valueOf(item.get('Quantity')));
                item.put('vlocity_cmt__EffectiveRecurringTotal__c', (Double.valueOf(item.get('vlocity_cmt__EffectiveRecurringTotal__c'))/originalQuantity)*Integer.valueOf(item.get('Quantity')));
                
                // Increment the line number index and calculate the new target Line Number for this clone
                lineNumberIndex++;
                String cloneLineNumber = buildLineNumberString(lineNumberPrefix, lineNumberIndex);
                
                // Configure the clone
                item.put('vlocity_cmt__LineNumber__c', cloneLineNumber);
                item.put('vlocity_cmt__ServiceAccountId__c', serviceAccountId);
                insertedLineItems.put((String)item.get('vlocity_cmt__LineNumber__c'), item);
                
                // OpportunityLineItem Fix to avoid the following error:
                // -> UnitPrice (only one of unit price or total price may be specified): [UnitPrice]
                if (item instanceof OpportunityLineItem) item.put('TotalPrice', null);

                // Clone any children
                cloneChildren(sourceLineItem, item, serviceAccountId);
            }
        }
       
        // Update any Line Items
        List<SObject> updates = new List<SObject>();
        Iterator<String> iter = updatedLineItems.keySet().iterator();
        while (iter.hasNext()) updates.add(updatedLineItems.get(iter.next()));
        System.debug('Split - Updating ' + updates.size() + ' Line Items');
        update updates;
        
        // Insert any Line Items
        List<SObject> inserts = new List<SObject>();
        iter = insertedLineItems.keySet().iterator();
        while (iter.hasNext()) inserts.add(insertedLineItems.get(iter.next()));
        System.debug('Split - Inserting ' + inserts.size() + ' cloned Line Items');
        insert inserts;
        
        return true;
    }

    /*
     * This method will look for any existing line items with a given line number, bump it by incrementing it's index (and any child line items)
     *
     * @param lineNumber The line number to look for
     *
     */
     private void bump(String lineNumber) {
     
         // Generate a new target Line Number Prefix for any line items we need to bump
         String newPrefix = buildLineNumberString(getLineNumberPrefix(lineNumber), getLineNumberIndex(lineNumber) + 1);
         
         // Identify any line items we need to bump
         Iterator<ID> allLineItems = lineItems.keySet().iterator();
         while (allLineItems.hasNext()) {
   
             SObject li = lineItems.get(allLineItems.next());

             // Check if this line item needs to be bumped
             String itemLineNumber = (String)li.get('vlocity_cmt__LineNumber__c');
             if (itemLineNumber.startsWith(lineNumber)) {

                 // Bump it!  Determine the new line number where the line item will be bumped
                 String targetLineNumber = itemLineNumber.replaceFirst(lineNumber, newPrefix);
                 
                 // Check for pre-existing line items at the target line number and subequently bump them as well in a chain reaction!
                 bump(targetLineNumber);

                 // Update the Line Number of this bumped order item
                 li.put('vlocity_cmt__LineNumber__c', targetLineNumber);
                 updatedLineItems.put(li.Id, li);
              }
          }
     }

    /*
     * This method will clone any children on the source line item and re-parent them under the destination line item
     *
     * @param sourceParent      The line item being cloned
     * @param targetParent      The target line item under which the clones will be added
     * @param serviceAccountId  The Service Account ID to apply during the clone
     */
     private void cloneChildren(SObject sourceParent, SObject targetParent, ID serviceAccountId) {
         
         String sourceParentLineNumber = (String)sourceParent.get('vlocity_cmt__LineNumber__c');
         String targetParentLineNumber = (String)targetParent.get('vlocity_cmt__LineNumber__c');
         
         // Identify any source children under the source parent and generate clones under the target parent
         // Examine the line numbers (i.e. 0001.0002) to find the children
         Iterator<ID> allLineItems = lineItems.keySet().iterator();
         while (allLineItems.hasNext()) {
             
             SObject li = lineItems.get(allLineItems.next());
             
             // Check if this line item is a child
             String itemLineNumber = (String)li.get('vlocity_cmt__LineNumber__c');
             if (itemLineNumber.startsWith(sourceParentLineNumber + '.')) {
                  
                 // It is a child, clone it
                 System.debug('Cloning -> ' + li.get('vlocity_cmt__LineNumber__c') + ' - ' + li.get('ProductName__c'));
                 SObject clone = li.clone(false, true, false, false);
                 
                 // Re-Parent this cloned line item and set a proper LineNumber as it is now under a new parent
                 // targetLineNumber is the cloneLineNumber with sourceParent Line Number replaced by the targetParent Line Number
                 String targetLineNumber = ((String)clone.get('vlocity_cmt__LineNumber__c')).replaceFirst(sourceParentLineNumber, targetParentLineNumber);
                 clone.put('vlocity_cmt__LineNumber__c', targetLineNumber);
                 clone.put('vlocity_cmt__ServiceAccountId__c', serviceAccountId);
                 
                // OpportunityLineItem Fix to avoid the following error:
                // -> UnitPrice (only one of unit price or total price may be specified): [UnitPrice]
                if (clone instanceof OpportunityLineItem) clone.put('TotalPrice', null);

                // Track each clone we insert
                insertedLineItems.put((String)clone.get('vlocity_cmt__LineNumber__c'), clone);
              }
         }
     }
     
     /*
      * This method will update the Service Account on the Line Item provided as well as any child line items
      *
      * @param lineItem          The line item on which to set the Service Account
      * @param serviceAccountId  The Service Account Identifier
      *
      */
      private void setServiceAccount(SObject lineItem, String serviceAccountId) {

          // Update the serviceAccountId of this line item
          lineItem.put('vlocity_cmt__ServiceAccountId__c', serviceAccountId);
          updatedLineItems.put(lineItem.Id, lineItem);
          
          // Identify and update this line item and any child line items by examining the line numbers (i.e. 0001.0002)
          String prefix = (String)lineItem.get('vlocity_cmt__LineNumber__c');
          Iterator<ID> allLineItems = lineItems.keySet().iterator();
          while (allLineItems.hasNext()) {
           
              SObject li = lineItems.get(allLineItems.next());
              
              // Check if this line item is a child
              String itemLineNumber = (String)li.get('vlocity_cmt__LineNumber__c');
              if (itemLineNumber.startsWith(prefix + '.')) {
                  // It is a child, so update the service account
                  li.put('vlocity_cmt__ServiceAccountId__c', serviceAccountId);
                  updatedLineItems.put(li.Id, li);
              }
          }
      }
      
    /*
     * Builds a new line number given a prefix and index
     *
     * @param prefix  The line number prefix (can be blank for a top-level item)
     * @param index   The index
     *
     * @return The new line number string in the format 0001.0002.0003
     */
     private static String buildLineNumberString(String prefix, Integer index) {
     
         if (!String.isBlank(prefix)) return prefix + '.' + String.valueOf(index).leftPad(4, '0');
         else return String.valueOf(index).leftPad(4, '0');
     }
     
    /*
     * Returns the Line Number Prefix
     * For example if the LineNumber is 0001.0002.0001, the prefix is 0001.0002
     * For top-level line items (i.e. Line Number 0001), the prefix is an empty string
     *
     * @param lineNumber  The line item line number
     *
     * @return The line number prefix
     */
    private static String getLineNumberPrefix(String lineNumber) {
        
        if (lineNumber.contains('.')) return lineNumber.substring(0, lineNumber.lastIndexOf('.'));
        else return '';
    }
    

    /*
     * Returns the Line Number Index
     * For example if the LineNumber is 0001.0002.0003, the index is 3
     *
     * @param lineNumber  The line item line number
     *
     * @return The line number index
     */
    private static Integer getLineNumberIndex(String lineNumber) {
            
        if (lineNumber.contains('.')) return Integer.valueOf(lineNumber.substring(lineNumber.lastIndexOf('.') + 1));
        else return Integer.valueOf(lineNumber);
    }
        
    /*
     * Get a string containing all the columns in an SObject except for ones we don't want (i.e. if we are duplicating objects)
     *
     * @param sObjectName  The name of the SObject to query
     * @param ignoreFields A list of fields to ignore (** Note, each field name MUST start/end with a comma ... even the first and last fields in the list)
     *
     * @return a string that can be used in a select statement
     */
    private static String getColumnNames(String sObjectName, String ignoreFields) {
    
        // Query the Salesforce Schema object
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectName).getDescribe().fields.getMap();
        
        // Build the list of columns
        String columns = '';
        for (String column : fieldMap.keyset()) {

            // Check if this field is to be ignored        
            if (ignoreFields.containsIgnoreCase(',' + column + ',')) continue;

            // Add this column to the list
            if (columns != '') columns += ',';            
            columns += column;
        }
        
        return columns;
    }
}