/**
 * This will provide some useful utilities related to Vlocity CPQ
 * 
 * 
 * @author Joe McMaster (jmcmaster@vlocity.com)
 * @version 1.0
 * 
 * History
 * -------
 * v1.0 - May 4, 2020 - Initial Version built for B2B Demo to improve CPQ performance
 * 
 */
global with sharing class commsBase_CPQUtils implements vlocity_cmt.VlocityOpenInterface {
    
    public class CpqUtilException extends Exception {}

    // Methods & Parameters
    public static final String METHOD_UPDATE_LINEITEM  = 'updateLineItem';   // Sets fields and attributes on a line item
    public static final String METHOD_INHERIT_ACCOUNTS = 'inheritAccounts';  // Inherits the Service & Billing Accounts to all child line items
    public static final String PARAM_LINE_ITEM_ID      = 'lineItemId';
    public static final String PARAM_CART_ID           = 'cartId';
    public static final String PARAM_FIELD_NAMES       = 'fieldNames';       // can be a single field name or list of field names
    public static final String PARAM_FIELD_VALUES      = 'fieldValues';      // can be a single field value or list of field values
    public static final String PARAM_ATTRIBUTE_CODES   = 'attributeCodes';   // can be a single attribute code or list of attribute codes
    public static final String PARAM_ATTRIBUTE_VALUES  = 'attributeValues';  // can be a single attribute value or list of attribute values

    // Line Item Fields
    private static final String FIELD_JSON_ATTRIBUTE  = 'vlocity_cmt__JSONAttribute__c';
    private static final String FIELD_BILLING_ACCOUNT = 'vlocity_cmt__BillingAccountId__c';
    private static final String FIELD_SERVICE_ACCOUNT = 'vlocity_cmt__ServiceAccountId__c';
    private static final String FIELD_ROOT_ITEM_ID    = 'vlocity_cmt__RootItemId__c';

    /**
     * Top level call
     *
     * @param methodName  The method to call in this class
     * @param inputMap    The input data provided in the call to this method
     * @param outputMap   The output object where any results will be stored
     * @param optionsMap  Any options to aid in the execution of this class
     *
     * @returns true if the method completes successfully, false otherwise
     */ 
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        
        try {
        
            if      (methodName.equalsIgnoreCase(METHOD_UPDATE_LINEITEM))  updateLineItem(inputMap, outputMap, optionsMap);
            else if (methodName.equalsIgnoreCase(METHOD_INHERIT_ACCOUNTS)) inheritAccounts(inputMap, outputMap, optionsMap);
            else {

                // Unknown Method
                System.debug(LoggingLevel.WARN, commsBase_CPQUtils.class.getName() + ' - Unknown Method (' + methodName + ')');
                return false;
            }
        }
        catch (Exception e) {

            System.debug(LoggingLevel.ERROR, commsBase_CPQUtils.class.getName() + ' - ' + e.getMessage());
            return false;
        }

        // Assume everything is A-Ok!
        return true;
    }

    /**
     * Configures fields and/or attributes on a line item.  This method bypasses 
     * the standard CPQ APIs and sets values directly.  It expects the following input.
     * This examples shows how single values can be provided (i.e. Quantity = 2) or lists
     * of values (ATT-DEV-CL = Black, ATT-DEV-SZ = 128GB).  The attribute category code is optional.
     * 
     * {
     *   "lineItemId": "8023h000000c8ywAAA",
     *   "fieldNames": "Quantity",
     *   "fieldValues": 2,
     *   "attributeCodes": ["ATT-CAT-001::ATT-DEV-CL", "ATT-DEV-SZ"],
     *   "attributeValues": ["Black", "128GB"]
     * }
     *
     * @param inputMap   - The input data provided in the call to this method
     * @param outputMap  - The output object where any results will be stored
     * @param optionsMap - Any options to aid in the execution of this class
     * 
     * @throws CpqUtilException if any problems occur trying to update the field(s) and/or attribute(s)
     */ 
    global void updateLineItem(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {

        Id lineItemId;
        List<String> fieldNames  = new List<String>();
        List<String> fieldValues = new List<String>();
        List<String> attributeCodes  = new List<String>();
        List<String> attributeValues = new List<String>();

        // Extract the input arguments
        // Line Item Id
        lineItemId = commsBase_DemoUtils.getMandatoryId(PARAM_LINE_ITEM_ID, inputMap);
        if (String.isBlank(lineItemId)) throw new CpqUtilException('Missing Input Map parameter "' + PARAM_LINE_ITEM_ID + '"');

        // Fields to update - we will accept a single field name or list of names
        Object obj = inputMap.get(PARAM_FIELD_NAMES);
        if (obj instanceof String) fieldNames.add((String)obj);
        else if (obj instanceof List<Object>) {
            
            List<Object> objList = (List<Object>)obj;
            for(Object o: objList) fieldNames.add((String)o);
        }

        // Field Value(s) to update - we will accept a single field value or list of values
        obj = inputMap.get(PARAM_FIELD_VALUES);
        if (obj instanceof String) fieldValues.add((String)obj);
        else if (obj instanceof List<Object>) {
            
            List<Object> objList = (List<Object>)obj;
            for(Object o: objList) fieldValues.add((String)o);
        }

        // Confirm we have an equal number of fields and values
        if (fieldNames.size() != fieldValues.size()) throw new CpqUtilException('Mismatch in number of fields (' + fieldNames.size() + ') compared to number of values (' + fieldValues.size() + ')');

        // Attribute Code(s) to update - we will accept a single attribute code or list of codes
        obj = inputMap.get(PARAM_ATTRIBUTE_CODES);
        if (obj instanceof String) attributeCodes.add((String)obj);
        else if (obj instanceof List<Object>) {
            
            List<Object> objList = (List<Object>)obj;
            for(Object o: objList) attributeCodes.add((String)o);
        }
    
        // Attribute Value(s) to update - we will accept a single attribute value or list of values
        obj = inputMap.get(PARAM_ATTRIBUTE_VALUES);
        if (obj instanceof String) attributeValues.add((String)obj);
        else if (obj instanceof List<Object>) {
            
            List<Object> objList = (List<Object>)obj;
            for(Object o: objList) attributeValues.add((String)o);
        }

        // Confirm we have an equal number of attribute codes and values
        if (attributeCodes.size() != attributeValues.size()) throw new CpqUtilException('Mismatch in number of attribute codes (' + attributeCodes.size() + ') compared to number of attribute values (' + attributeValues.size() + ')');        
        
        // Build the SOQL Query for the Line Item
        String fieldQuery = '';
        for (String fname: fieldNames) {
            if (!String.isBlank(fieldQuery)) fieldQuery += ', ';
            fieldQuery += fname;
        }
        if (!attributeCodes.isEmpty()) {
            if (!String.isBlank(fieldQuery)) fieldQuery += ', ';
            fieldQuery += FIELD_JSON_ATTRIBUTE;
        }

        // Query for the line item
        SObject[] lineItem = Database.query('SELECT ' + fieldQuery + ' FROM ' + commsBase_DemoUtils.getType(lineItemId) + ' WHERE Id=\'' + lineItemId + '\' LIMIT 1'); 
        if (!lineItem.isEmpty()) {
            
            // Update any fields
            for(Integer i=0; i<fieldNames.size(); i++) lineItem[0].put(fieldNames.get(i), fieldValues.get(i));

            // Update any attributes
            if (!attributeCodes.isEmpty()) {
            
                String json = (String)lineItem[0].get(FIELD_JSON_ATTRIBUTE);
                if (!String.isBlank(json)) {

                    // Decode Attribute JSON and update
                    Map<String, Object> jsonAttributes = (Map<String, Object>)System.JSON.deserializeUntyped(json);
                    updateAttributes(attributeCodes, attributeValues, jsonAttributes);

                    lineItem[0].put(FIELD_JSON_ATTRIBUTE, System.JSON.serialize(jsonAttributes));
                }
                else throw new CpqUtilException('No configurable attributes were found on line item ' + lineItemId);
            }

            // Commit Changes
            update lineItem[0];
        }
        else throw new CpqUtilException('No line item with Id = ' + lineItemId + ' was found');
    }

    /**
     * Updates one or more attributes in the attribute JSON of a Line Item
     *
     * @param attributeCodes  List of attribute codes to update
     * @param attributeValues List of attribute values to update
     * @param jsonAttributes  The JSON blob containing a line items attributes
     * 
     * @throws CpqUtilException if any problems occur trying to update the attribute(s)
     */
    private void updateAttributes(List<String> attributeCodes, List<String> attributeValues, Map<String, Object> jsonAttributes) {

        // Update all the attributes
        for (Integer i=0; i<attributeCodes.size(); i++) {

            Map<String, Object> attribute = findAttribute(attributeCodes[i], jsonAttributes);
            if (attribute == null) throw new CpqUtilException('Attribute Code "' + attributeCodes[i] + '" was not found on line item');

            // How we update will depend on the attribute type
            Map<String, Object> runtimeInfo = (Map<String, Object>)attribute.get('attributeRunTimeInfo');
            String dataType = (String)runtimeInfo.get('dataType');

            if (dataType.equalsIgnoreCase('Text')) runtimeInfo.put('value', String.valueOf(attributeValues[i]));
            else if (dataType.equalsIgnoreCase('Picklist')) {

                // Locate the PickList option
                Iterator<Object> options = ((List<Object>)runtimeInfo.get('values')).iterator();
                while (options.hasNext()) {

                    Map<String, Object> option = (Map<String, Object>)options.next();
                    if (option.get('value').equals(attributeValues[i])) {

                        runtimeInfo.put('selectedItem', option);
                        break;
                    }
                }
            }
            else throw new CpqUtilException(commsBase_CPQUtils.class.getName() + ' - Unsupported Attribute Data Type "' + dataType + '"');
        }
    }

    /**
     * Finds an attribute in a Line Item's JSON field.  The attribute code to look for
     * can have two flavours:
     * 
     * (1) Just the code (i.e. ATT-DEVICE-COLOR)
     * (2) The attribute category code, followed by the code (i.e. VLO-PRO-0015::ATT-DEVICE-COLOR)
     * 
     * In the first form, this function will simply return the first attribute with a matching code in
     * any category.  This should work in 99% of cases, but just in case two attributes share the same
     * code (but sit in different categories), we can use the more qualified second form above which
     * will only look in the specific category for the attribute.
     * 
     * @param attributeCode  The attribute code (or category_code::attribute_code) to look for
     * @param jsonAttributes The JSON blob containing all the attribute data for the line item
     * 
     * @return The attribute object, or null if it wasn't found
     */
    private Map<String, Object> findAttribute(String attributeCode, Map<String, Object> jsonAttributes) {

        // Handle both forms of an attribute code
        String searchGroup = null;
        String searchCode  = attributeCode;
        if (attributeCode.contains('::')) {
            searchGroup = attributeCode.split('::')[0];
            searchCode  = attributeCode.split('::')[1];
        }

        // Go through the list of Attribute Groups
        Iterator<String> attributeGroupNames = jsonAttributes.keySet().iterator();
        while (attributeGroupNames.hasNext()) {
        
            String groupName = attributeGroupNames.next();
        
            // Search this group's attributes we are performing a global search accross all groups or if this group is the one we are interested in
            if (searchGroup == null || searchGroup.equalsIgnoreCase(groupName)) {

                // Go through the list of Attributes
                Iterator<Object> attributes = ((List<Object>)jsonAttributes.get(groupName)).iterator();
                while (attributes.hasNext()) {                
            
                    // Check if this is the attribute we want to update
                    Map<String, Object> attribute = (Map<String, Object>)attributes.next();
                    if (((String)attribute.get('attributeuniquecode__c')).equalsIgnoreCase(searchCode)) return attribute;
                }
            }
        }

        // If we make it here, we didn't find the attribute
        return null;
    }

    /**
     * Copies (Inherits) the Service & Billing Account information from a root line item
     * to all of its children, granchildren, etc.  This function can be passed a
     * specific line item Id (lineItemId) or a cart Id (cartId) to process all root 
     * line items currently in the cart
     *
     * @param inputMap   - The input data provided in the call to this method
     * @param outputMap  - The output object where any results will be stored
     * @param optionsMap - Any options to aid in the execution of this class
     * 
     * @throws CpqUtilException if any problems occur trying to inherit the account information
     */
    global void inheritAccounts(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {

        // Extract the input arguments
        // Line Item Id or Cart Id
        Id cartId = (Id)inputMap.get(PARAM_CART_ID);
        Id lineItemId = (Id)inputMap.get(PARAM_LINE_ITEM_ID);

        if (String.isBlank(cartId) && String.isBlank(lineItemId)) throw new CpqUtilException('Missing Input Map parameter ' + PARAM_CART_ID + '" or "' + PARAM_LINE_ITEM_ID + '"');

        // If we have been given a cart Id, process all root line items
        SObject[] lineItems = null;
        if (!String.isBlank(cartId)) {

            // Get all the line items in the cart
            lineItems = Database.query('SELECT ' + FIELD_BILLING_ACCOUNT + ', ' + FIELD_SERVICE_ACCOUNT + ', ' + FIELD_ROOT_ITEM_ID + ' FROM ' + getLineItemType(cartId) + ' WHERE ' + commsBase_DemoUtils.getType(cartId) + 'Id=\'' + cartId + '\'');
        }
        else {

            // Get all the child line items of a particular line item
            lineItems = Database.query('SELECT ' + FIELD_BILLING_ACCOUNT + ', ' + FIELD_SERVICE_ACCOUNT + ', ' + FIELD_ROOT_ITEM_ID + ' FROM ' + commsBase_DemoUtils.getType(lineItemId) + ' WHERE ' + FIELD_ROOT_ITEM_ID + '=\'' + lineItemId + '\'');
        }

        // Process the line items
        if (!lineItems.isEmpty()) {

            // Build a set of root line items
            Map<Id, SObject> rootLineItems = new Map<Id, SObject>();
            for (SObject li: lineItems) {
                if (li.Id == li.get(FIELD_ROOT_ITEM_ID)) rootLineItems.put(li.Id, li);
            }

            // Update Billing & Service Account information for all line items
            List<SObject> updatedLineItems = new List<SObject>();
            for (SObject li: lineItems) {

                // If this isn't a root line item, update the accounts
                if (li.Id != li.get(FIELD_ROOT_ITEM_ID)) {

                    SObject rootItem = rootLineItems.get((Id)li.get(FIELD_ROOT_ITEM_ID));
                    li.put(FIELD_SERVICE_ACCOUNT, rootItem.get(FIELD_SERVICE_ACCOUNT));
                    li.put(FIELD_BILLING_ACCOUNT, rootItem.get(FIELD_BILLING_ACCOUNT));

                    updatedLineItems.add(li);
                }
            }

            update updatedLineItems;
        }
    }

    /**
     * Determines the SObject type of the line items for a given cart
     * 
     * @param cartId  The cart Id
     * 
     * @return The type of SObject used for line items in this cart
     */
    private String getLineItemType(Id cartId) {

        String cartType = commsBase_DemoUtils.getType(cartId);
        if (cartType.equalsIgnoreCase('Opportunity')) return 'OpportunityLineItem';
        else if (cartType.equalsIgnoreCase('Quote')) return 'QuoteLineItem';
        else if (cartType.equalsIgnoreCase('Order')) return 'OrderItem';

        // If we make it here, the cart type isn't supported by this code
        throw new CpqUtilException('Unknown Cart Type "' + cartType + '"');
    }
}