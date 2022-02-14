public class ObjectDescriber
{
 
    /*
     Object token ( eg Account.sObjectType.) (ie object stub for further metadata calls)
    A Schema.sObjectType object is returned from the field describe result using 
    the getReferenceTo method, or from the sObject describe result using the getSObjectType method.
    **/
    private Schema.SObjectType objectToken; 

    /*
    described SOBJect. this will be lazy loaded+cached. ie  not described immediately.
      
     from Object token , Schema.DescribeSObjectResult object provides methods for further metadata query
     eg Account.sObjectType.getDescribe();
     **/
    private Schema.DescribeSObjectResult describedSObj {  
        get{
            if(describedSObj == null)
                describedSObj = objectToken.getDescribe();
            return describedSObj;
        }
        set;
    }
    
    
    //   Map of fieldname=>SObj to describe/already described
    private Map<String,Schema.SObjectField> fields {
        get{
            // fields call is subject to governor limit ,hence cache it
            if(fields == null)
                fields = describedSObj.fields.getMap(); // call getMap method in DescribeSObjectResult.fields 
            return fields;
        }
        set;
    }
 
    private DescribedFieldsMap wrappedFields {
        get{
            if(wrappedFields == null){
                wrappedFields = new DescribedFieldsMap(this.fields);
            }
            return wrappedFields;
        }
        set;
    }

    // constructor from objectToken
    private ObjectDescriber(Schema.SObjectType objectToken){    
        if(objectToken == null)
            throw new InvalidDescribeException('Invalid SObject type: null');
        if(objectDescriberCache.containsKey( String.valueOf(objectToken) ))
            throw new DuplicateDescribeException(objectToken + ' is already in the describedSObj cache');
        this.objectToken = objectToken;
        // create the describe definition to this name
        objectDescriberCache.put( String.valueOf(objectToken).toLowerCase() , this);
    }

    // get Field with useNamespace defaulted to true
    public Schema.SObjectField getField(String name){   return this.getField(name, true);   }
    // get full field definition with or without namespace
    public Schema.SObjectField getField(String fieldName, boolean useNamespace){
        //resolve custom field cross-object (__r) syntax
        Schema.SObjectField result = wrappedFields.get( 
            (fieldName.endsWithIgnoreCase('__r') ?  (fieldName.removeEndIgnoreCase('__r')+'__c') :  fieldName),
            useNamespace
        ); 
        if(result == null){
            result = wrappedFields.get(fieldName+'Id', useNamespace); //in case it's a standard lookup in cross-object format
        }
        return result;
    }
    //  Schema.DescribeSObjectResult instance ( cached or new)
    public Schema.DescribeSObjectResult getDescribe(){ return describedSObj; }
    public DescribedFieldsMap getFields(){  return wrappedFields; }

    /* Starting with Apex saved using Salesforce.com API version 28.0, the keys in the map that getGlobalDescribe returns are always prefixed with the namespace, if any, of the code in which it is running. For example, if the code block that makes the getGlobalDescribe call is in namespace NS1, and a custom object named MyObject__c is in the same namespace, the key returned is NS1__MyObject__c. For Apex saved using earlier API versions, the key contains the namespace only if the namespace of the code block and the namespace of the sObject are different. For example, if the code block that generates the map is in namespace N1, and an sObject is also in N1, the key in the map is represented as MyObject__c. However, if the code block is in namespace N1, and the sObject is in namespace N2, the key is N2__MyObject__c.
    */
    private static Map<String,Schema.SObjectType> globalDescribeObject {
        get{
            if(globalDescribeObject == null)
                globalDescribeObject = Schema.getGlobalDescribe();

            return globalDescribeObject;
        }
        set;
    }
    // cache ,indexed by namespaced Name => object
    private static DescribedObjectMap wrappedglobalDescribeObject{
        get{
            if(wrappedglobalDescribeObject == null){
                wrappedglobalDescribeObject = new DescribedObjectMap(globalDescribeObject);
            }
            return wrappedglobalDescribeObject;
        }
        set;
    }

    public Map<String,Schema.SObjectField> getFieldsMap(){
        return fields;
    }


 
/******************************************************************************************************

  CACHE CLASSES
  cache ObjectDescriber instances  

*****************************************************************************************************/

    //  cache to store sObjectName => ObjectDescriber
    private static Map<String,ObjectDescriber> objectDescriberCache {get{
            if(objectDescriberCache == null)
                objectDescriberCache = new Map<String,ObjectDescriber>();
            return objectDescriberCache;
        } 
        set;
    }

    public static Schema.SObjectType getSObjectType(String sObjectName){
        return wrappedglobalDescribeObject.get(sObjectName.toLowerCase());
    }

    // get the ObjectDescriberinstance for this sObjectName from Cache eg 'Account'
    // Use ObjectDescriber.getDescribe('Account')
    public static ObjectDescriber getDescribe(String sObjectName){
        ObjectDescriber result = objectDescriberCache.get(sObjectName.toLowerCase());
        if(result == null){
            Schema.SObjectType objectToken = wrappedglobalDescribeObject.get(sObjectName.toLowerCase());
            if(objectToken == null)
                result = null;
            else
                result = new ObjectDescriber(objectToken);
        }
        return result;
    }
    // get ObjectDescriberinstance  for this  SobjectType
    //  eg : ObjectDescriber.getDescribe(Contact.SObjectType);
    public static ObjectDescriber getDescribe(Schema.SObjectType objectToken){
        ObjectDescriber result = objectDescriberCache.get(String.valueOf(objectToken).toLowerCase());
        if(result == null)
            result = new ObjectDescriber(objectToken);      
        return result;
    }

    // API to get ObjectDescriber instance for this native Schema.DescribeSObjectResult
    //  eg : getDescribe( Account.sObjectType.getDescribe() )
    public static ObjectDescriber getDescribe(Schema.DescribeSObjectResult nativeDescribe){
        ObjectDescriber result = objectDescriberCache.get(nativeDescribe.getName().toLowerCase());
        if(result == null)
            result = new ObjectDescriber(nativeDescribe.getSobjectType());      
        return result;
    }
    // API to get ObjectDescriberInstance from SObject eg : getDescribe(instance of account)
    public static ObjectDescriber getDescribe(SObject instance){
        return getDescribe(instance.getSobjectType());
    }

    //returns the same results as the SFDC call  , just with caching built in to avoid governor limits
    public static Map<String,SObjectType> getglobalDescribedObject(){
        return globalDescribeObject;
    }
    public static DescribedObjectMap getProcessedGlobalDescribe(){
        return wrappedglobalDescribeObject;
    }
    //Existing references to SObjectDescribe instances will continue to work.
    public static void clearCache(){
        globalDescribeObject = null;
        objectDescriberCache = null;
    }

/*************************************************************************************************************************************************

  UTILITY CLASSES

*************************************************************************************************************************************************/

 
    private abstract class NSAttribBase{
        @testVisible
        protected String currentNamespace;
        protected Map<String,Object> values;

        protected NSAttribBase(Map<String,Object> values ){ 
            currentNamespace = ObjectDescriber.class.getName().substringBefore('ObjectDescriber').removeEnd('.').toLowerCase();
            this.values = values;
        }
        protected NSAttribBase(){
            this(new Map<String,Object>());
        }

        protected virtual Object getObject(String name){
            return this.getObject(name, true);
        }
 
        protected virtual Object getObject(String name, Boolean useNamespace){
            String preferredValue = ((useNamespace ? currentNamespace+'__' : '') + name).toLowerCase();

            if(values.containsKey(name.toLowerCase())){
                return values.get(name.toLowerCase());
            }else if(values.containsKey(preferredValue)){
                return values.get(preferredValue);
            }else if(useNamespace){
                return values.get(name.toLowerCase());
            }else{
                return null;
            }
        }
        public virtual Boolean containsKey(String name){
            return this.containsKey(name, true);
        }
        public virtual Boolean containsKey(String name, Boolean useNamespace){

            String preferredValue = ((useNamespace ? currentNamespace+'__' : '') + name).toLowerCase();
            return (
                values.containsKey(name.toLowerCase()) || values.containsKey(preferredValue) ||
                useNamespace && values.containsKey(name.toLowerCase())
            );
        }
        public virtual Integer size(){
            return values.size();
        }
        public virtual Set<String> keySet(){
            return values.keySet();
        }
    }
    // this map contains FieldName=>Schema.SObjectField
    public class DescribedFieldsMap extends NSAttribBase{

        @testVisible
        private DescribedFieldsMap(Map<String,Schema.SObjectField> values ){
            super(values);
        }

        public Schema.SObjectField get(String name){
            return this.get(name, true);
        }
        public Schema.SObjectField get(String name, Boolean useNamespace){
            return (Schema.SObjectField) this.getObject(name, useNamespace);
        }
        public List<Schema.SObjectField> values(){
            return (List<Schema.SObjectField>) values.values();
        }

    }
    //  ObjectName=>Schema.SObjectType map obtained using Schema.getGlobalDescribe
    // Schema.getGlobalDescribe retunrs all objectname=>objectresult map
    public class DescribedObjectMap extends NSAttribBase{
        @testVisible
        private DescribedObjectMap(Map<String,Schema.SObjectType> values){
            super(values);
        }

        public Schema.SObjectType get(String name){
            return this.get(name, true);
        }
        public Schema.SObjectType get(String name, Boolean useNamespace){
            return (Schema.SObjectType) this.getObject(name, useNamespace);
        }
        public List<Schema.SObjectType> values(){
            return (List<Schema.SObjectType>) values.values();
        }
    }


    public abstract class DescribeException extends Exception{}
    public class DuplicateDescribeException extends DescribeException{} //Test coverage for this requires APIv28's @testVisbile annotation to force exception cases.
    public class InvalidDescribeException extends DescribeException{}
}