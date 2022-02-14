/**
 * This class follows the strategy documented at http://www.xml.com/lpt/a/1658
 * to convert xml to json. Since some times order can be lost using this method 
 * there is no guarantee that using the same strategy for a transoform from the 
 * produced json back to xml will return the original xml file.
 */
global with sharing class XmlToJson {
	private Dom.Document doc = new Dom.Document();
	private Map<String, Object> structure = new Map<String, Object>();

	public XmlToJson(String xml) {
		doc.load(xml);
		structure.put(doc.getRootElement().getName(), recursivelyParseXML(doc.getRootElement()));
	}

	//public Static 
	//public Static Map<String,Object> JsonToXPath(String jsonString) {
		
	//}
	/**
	*** @description This takes a XML imput string and produces both a xPath raptor map and a json map.  
	*				Note this uses a @ for attribute, : for path seperator (for data raptor compliance)
	*				#ns for namespace, and a # for namespace seperator
	*   @param xmlString The XML in string format to parse
	*   @return Map<String,Object> RaptorMap, json
	*/

	public Static Map<String,Object> ParseXML(String xmlString) {
		/* define all the variables up front.  This saves cpu time.
		*/
		String nsSep 	= '#';
		String nsPre 	= '#ns';
		String pathSep 	= ':';
		String attPre 	= '@';
		String xPathSep = '/';
		String name;
		String ns;
		String element;
		String path;
		String atName;
		String atNS;
		String atValue;
		String nsPrefix;
		String nsId;
		String text;
		Integer size;
		Map<String,Object> retval 		= new Map<String,Object>();
		Map<String,Object> raptorMap 	= new Map<String,Object>();
		Map<String,Object> jsonMap		= new Map<String,Object>();
		//Map<String,Object> jsonMapNoNS	= new Map<String,Object>();
		List<String>elementNames 		= new List<String>();
		List<String>elementNamesNoNS 	= new List<String>();
		List<Object> jsonObjects		= new List<Object>();
		//List<Object> jsonObjectsNoNS	= new List<Object>();
		XmlStreamReader reader 			= new XmlStreamReader(xmlString);
		Map<String,Object> jsonItem;
		Map<String,Object> jsonItemNoNS;
		List<Object> elementList;
		Map<String,Object> toAdd;
		Set<String> xPaths 				= new Set<String>();
		xPaths.add('/');
		Object item;
		retval.put('RaptorMap', raptorMap);
		retval.put('json', jsonMap);
		//retval.put('jsonNoNS', jsonMapNoNS);
		retval.put('xPaths',xPaths);
		jsonObjects.add(jsonMap);
		//jsonObjectsNoNS.add(jsonMapNoNS);
		while(reader.hasNext()) {
		    reader.next();
		    if (reader.isStartElement()) {
		      	name   	= reader.getLocalName();
		      	ns     	= reader.getPrefix();
		      	//text 	= reader.getText();
		      	if (ns == '') {
		      		element = name;
		      	} else {
		      		element = ns + nsSep + name;
		      	}

//System.debug('text is ' + text);

				//Add this element to the Raptor Stack
		      	elementNames.add(element);
		      	elementNamesNoNS.add(name);
		      	path = xPathSep + String.join(elementNamesNoNS, xPathSep);
		      	xPaths.add(path);

		      	path = String.join(elementNames, pathSep);
				raptorMap.put(path,'');

		      	//New element to add to the stack
		      	toAdd = new Map<String,Object>();
		      	//Get the last item on the stack to see if this is an array, ie same name
		      	jsonItem = (Map<String,Object>)jsonObjects.get(jsonObjects.size() -1);
		      	//jsonItemNoNS = (Map<String,Object>)jsonObjectsNoNS.get(jsonObjects.size() -1);
		      	
		      	//If an item of the name already exists on the parent object
		      	// this must be a array, list.  So convert it or add it.
		      	item = jsonItem.get(element);
		      	if (item != null) {
		      		
		      		if (item instanceof List<Object>) {
						elementList = (List<Object>)item;
						elementList.add(toAdd);
					} else {
						elementList = new List<Object>();
						elementList.add(item);
						elementList.add(toAdd);
						jsonItem.put(element,elementList);
					}
				} else {
		      		jsonItem.put(element,toAdd);
		      		//jsonItemNoNS.put(name,null);
		      	}

		      	jsonObjects.add(toAdd);

//System.debug('Element Path is ' + path);
		       
		      	//retval.put(path, null);
		      	// get the attributes and add them to the structure.  If they contain
		      	// a namespace add that too with a seperator.
		        for (integer atIndex = 0; atIndex < reader.getAttributeCount(); atIndex++) {
		            atName 	= reader.getAttributeLocalName(atIndex);
		            atNS 	= reader.getAttributePrefix(atIndex);
		            atValue = reader.getAttributeValueAt(atIndex);
		            if (atNS == '') {
		            	raptorMap.put(path + pathSep + attPre + atName,atValue);
		            	toAdd.put(attPre + atName,atValue);
		        	} else {
		            	raptorMap.put(path + pathSep + attPre + atNS + nsSep + atName,atValue);
		            	toAdd.put(attPre + atNS + nsSep + atName,atValue);	        		
		        	}
//System.debug('\tAttribute NS ' + atNS + ' name: ' + atName + ' associated with URI ' + atValue);        
				}

				// Add the namespaces to the json.  Needed to be a transient json.
		        for (integer nsIndex = 0; nsIndex < reader.getNamespaceCount(); nsIndex++) {
		            nsPrefix 	= reader.getNamespacePrefix(nsIndex);
		            nsId 		= reader.getNamespaceURIat(nsIndex);
		            raptorMap.put(path + pathSep + nsPre + nsSep + nsPrefix,nsId);
		            toAdd.put(nsPre + nsSep + nsPrefix,nsId);
//System.debug('\tNamepsace prefix: ' + nsPrefix + ' associated with URI ' + nsId);
		      	}

		    } else if (reader.isCharacters()) {
		    	if (!reader.isWhitespace()) {
		    		text = reader.getText();
		    		jsonItem = (Map<String,Object>)jsonObjects.get(jsonObjects.size() -1);
		    		if (jsonItem.isEmpty()) {
		    			// pop one level up and set the value to be the text.
		    			if (jsonObjects.size() > 1) {
		    				//jsonObjects.remove(jsonObjects.size() -1);
		    				jsonItem = (Map<String,Object>)jsonObjects.get(jsonObjects.size() -2);
		    			}
		    			jsonItem.put(element,text);
		    		} else {
		    			jsonItem.put('#text',text);
		    		}
		    	}
		    } else if (reader.isEndElement()) {
		    	size = elementNames.size();
		    	elementNames.remove(size -1);
		    	elementNamesNoNS.remove(size -1);
//		    	size = jsonObjects.size();
		    	jsonObjects.remove(jsonObjects.size() -1);
		    }
		}
		return retval;
	}

	public static Map<String,Object> recursivelyParseXML(Dom.XmlNode node) {
		Map<String, Object> struct = new Map<String, Object>();
		Dom.XmlNode[] childEls = node.getChildElements();
		if (node.getText() != Null) {
			struct.put('#text', node.getText());
		} 
		if (node.getAttributeCount() > 0) {
			Integer attribCount = node.getAttributeCount();
			String attrib, value, ns;
			for (Integer i = 0; i < attribCount; i++) {
				attrib = node.getAttributeKeyAt(i);
System.debug('BBBBB + element ' + attrib);
				ns = node.getAttributeKeyNsAt(i);
				value = node.getAttributeValue(attrib, ns);
				struct.put('@'+attrib, value);
			}
		}

		if (node.getNamespace() != Null) {
			struct.put('#ns', node.getNamespace());
		}

		for (Dom.XmlNode child : childEls) {
System.debug('BBBBB + child ' + child);
			if (struct.containsKey(child.getName())) {
				Object existingVal = struct.get(child.getName());
				if (existingVal instanceof List<Object>) {
					((List<Object>)existingVal).add(recursivelyParseXML(child));
				} else if (existingVal instanceof Map<String, Object>) {
					List<Object> newList = new List<Object>();
					newList.add(existingVal);
					newList.add(recursivelyParseXML(child));	
					struct.put(child.getName(), newList);
				}
			} else {
				struct.put(child.getName(), recursivelyParseXML(child));
			}
		}
		return struct;
	}

	public String getJsonString() {
		return JSON.serialize(structure);
	}

	global static String convertXMLToJson(String xml) {
		XmlToJson xtj = new XmlToJson(xml);
		return xtj.getJsonString();
		
	}
}