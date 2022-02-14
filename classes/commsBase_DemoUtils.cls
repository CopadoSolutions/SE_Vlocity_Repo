/**
 * This will provide some useful utilities when building demonstrations and/or Proof-of-Concepts
 * 
 * 
 * @author Joe McMaster (jmcmaster@vlocity.com)
 * @version 1.0
 * 
 * History
 * -------
 * v1.0 - May 4, 2020 - Initial Version
 * 
 */
public with sharing class commsBase_DemoUtils {

    public class MissingDataException extends Exception {}
    public class DataMismatchException extends Exception {}

    /**
     * Returns a mandatory value from a map
     * 
     * @param key   The key to look for
     * @param data  The map to look in
     * 
     * @return The value corresponding to the key
     * 
     * @throws MissingDataException if the key doesn't exist in the map or corresponds to a null value
     */
    public static Object getMandatory(String key, Map<String, Object> data) {

        if (data != null) {
        
            if (data.containsKey(key)) return data.get(key);

            throw new MissingDataException('key "' + key + '" was not found in the data provided');
        }
        
        throw new MissingDataException('No data provided');
    }
    
    /**
     * Returns a mandatory String value from a map
     * 
     * @param key   The key to look for
     * @param data  The map to look in
     * 
     * @return The String value corresponding to the key
     * 
     * @throws MissingDataException if the key doesn't exist in the map or corresponds to a null value
     * @throws DataMismatchException if the corresponding value is not a String
     */
    public static String getMandatoryString(String key, Map<String, Object> data) {

        Object obj = getMandatory(key, data);
        if (obj instanceof String) return (String)obj;

        throw new DataMismatchException('key "' + key + '=' + obj + '" is not a String');
    }

    /**
     * Returns a mandatory Id value from a map
     * 
     * @param key   The key to look for
     * @param data  The map to look in
     * 
     * @return The Id value corresponding to the key
     * 
     * @throws MissingDataException if the key doesn't exist in the map or corresponds to a null value
     * @throws DataMismatchException if the corresponding value is not an Id
     */
    public static String getMandatoryId(String key, Map<String, Object> data) {

        Object obj = getMandatory(key, data);
        if (obj instanceof Id) return (Id)obj;
        else if (obj instanceof String) return Id.valueOf((String)obj);  // Attempt to convert from String -> Id

        throw new DataMismatchException('key "' + key + '=' + obj + '" is not an Id');
    }

    /**
     * Determines the SObject Type for a given Id 
     * 
     * @param id  The SObject Id
     * 
     * @return The SObject Type
     */
    public static String getType(Id id) {

        return id.getSobjectType().getDescribe().getName();
    }
}