global with sharing class DBHelper {
	global static String nsp {
		get {
			return ApplicationUtilities.getNameSpacePrefix();
		}
		 private set;
	}


	/**
	 * @description generate a query string based upon the object name.  This obtains all the fields from the object.
	 * @param ObjectName the name of the object to query
	 * @param WhereClause the were clause to append to the query
	 */
	global static String query(String ObjectName,String WhereClause) {
        String soql = DBHelper.getBaseQuery(ObjectName);
        if (WhereClause != null) {
        	// TODO need to process arguments such as {0}
        	soql += ' where ' + WhereClause;
        }
        
        return soql;
	}
	/**
	 * @description generate a query with NO where clause
	 * @param ObjectName the object to obtain the list of fields from.
	 */
	global static String getBaseQuery(String ObjectName) {
		List<String> fields = DBHelper.getFields(ObjectName);
		String soql = ''	
        	+ ' select ' + String.join(fields, ',')
        	+ ' from ' + ObjectName;
		return soql;		
	}
	
	/**
	 * @description obtsin the list of fields based upon the object name.  Interesting this may not work if the object has no records.
	 * @param ObjectName the name of the object to generate the list of objects from
	 */
	global static List<String> getFields(String objectName) {
		//String query1 = 'Select Id from ' + ObjectName + ' limit 1';
		//SObject s = database.query(query1);
		SObjectType objectType = Schema.getGlobalDescribe().get(nsp+objectName);
		
//Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap(); Bill commented out
		//List<String> fields = new List<String>(objectType.getDescribe().fields.getMap().keySet());  GS commented out
		Map<String, Schema.SObjectField> fields = objectType.getDescribe().fields.getMap();
		List<String> retFields = new List<String>();
		
		for (Schema.SObjectField sof : fields.values()) {
			Schema.DescribeFieldResult dfr = sof.getDescribe();
			if (dfr.isAccessible() && dfr.getType() != Schema.DisplayType.base64) {
				retFields.add(String.valueOf(dfr.getname()));
			}
		}				
		return retFields;	
	}


	/**
	 * @description obtsin the list of fields based upon the object name.  Interesting this may not work if the object has no records.
	 * @param ObjectName the name of the object to generate the list of objects from
	 */
	public static List<String> getFieldsNoAddress(String ObjectName) {
		List<String> fields = getFields(ObjectName);
		//For Telstra -- loop to remove the "address fields as they cannot be serialized.  Stupid salesforce.
		String field;
		for (Integer i = 0; i < fields.size(); i++) {
    		field = fields.get(i);
    		if (field.contains('address')) {
    			if (!field.contains('__c')) {
    				// need to add in the fields
    				fields.remove(i);
    				i--; // I think
    			}
    		}
		}
		
		return fields;
	}
	
	public static Map<String, String> getFieldLabelsNoAddress(String ObjectName){
		List<String> fields = getFields(ObjectName);
		Map<String, String> mapFieldLabels = new Map<String, String>();
		String field;
		String label;
		for (Integer i = 0; i < fields.size(); i++) {
    		field = fields.get(i);
    		if (field.contains('address')) {
    			if (!field.contains('__c')) {
    				// need to add in the fields
    				fields.remove(i);
    				i--; // I think
    			}
    		}
    		else {
				Schema.SObjectField fld = ObjectDescriber.getDescribe(objectName).getField(field);
    			DescribeFieldResult dfr = fld.getDescribe();
    			label = dfr.getLabel();
    			mapFieldLabels.put(field, label);
    		}
		}
 		return mapFieldLabels;
	}	

	public static String buildQueryFromId(ID objId,String WhereClause) {
 
		Schema.SObjectType token = objId.getSObjectType();
		Schema.DescribeSObjectResult dr = token.getDescribe(); 
		String objectName = dr.getName();		
        String soql = DBHelper.getBaseQuery(objectName);
        if (WhereClause != null) {
        	// TODO need to process arguments such as {0}
        	soql += ' where ' + WhereClause;
        }
        
        return soql;
	}	
	//   helper that identifies any ID,gets Sobject & gets fields
	public static SObject getSobject(ID objId, List<String> fields)
	{
		List<String> queryFields = fields;
		Schema.SObjectType token = objId.getSObjectType();
		Schema.DescribeSObjectResult dr = token.getDescribe(); 
		String objectName = dr.getName();
 
		if (fields == null) // get all fields
		{
			queryFields =  DBHelper.getFields(objectName);
		} 
		String queryString = ''	
        	+ ' SELECT ' + String.join(queryFields, ',')
        	+ ' FROM ' + objectName  + ' WHERE ID = :objId ' ;	

        sObject qObj = Database.query(queryString);
        return qObj;	
	}
}