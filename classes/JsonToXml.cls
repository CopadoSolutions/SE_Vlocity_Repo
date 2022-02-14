/**
 * {
 *   "body": {
 *     "b": {
 *       "c": {
 *         "#text": "textC"
 *       },
 *       "@battr": "bAttrText",
 *       "#text": "textBTextBCONT"
 *     },
 *     "a": {
 *       "#text": ""
 *     },
 *     "#text": " "
 *   }
 * }
 * 
 * <body>
 *   <b battr="bAttrText">
 *     <c>
 *       textC
 *     </c>
 *     textBTextBcont
 *   </b>
 *   <a/>
 * </body>
 *
 * Things to be written to:
 *   start element: writeStartElement
 *   write attributes: writeAttribute
 *   text: writeCharacters
 *   start child elements: writeStartElement (see first step)
 *   close the element: writeEndElement
 */

public with sharing class JsonToXml {
	String jsonS;
	String xmlS;
	private JSONParser jParser; 
	private XmlStreamWriter xWriter;
	private Map<String, String> nameSpaces = new Map<String, String>();
	private Set<String> nsPrefixes = new Set<String>();
	private String lastElWritten = '';

	public JsonToXml(String jsonS, Boolean nsSupport) {
		this.jsonS = jsonS;
		jParser = JSON.createParser(jsonS);
		xWriter = new XmlStreamWriter();				
		xWriter.writeStartDocument(null, '1.0');
		
		if (nsSupport) {
			MapToXMLRecursive((Map<String, Object>)JSON.deserializeUntyped(jsonS));
		} else {
			buildXml();
		}

		xWriter.writeEndDocument();
		xmlS = xWriter.getXmlString();
		xWriter.close();
	}

	public JsonToXml(String jsonS) {
		this(jsonS, True);
	}

	public JsonToXml(Map<String, Object> data) {
		xWriter = new XmlStreamWriter();
		xWriter.writeStartDocument(null, '1.0');
	
		MapToXMLRecursive(data);

		xWriter.writeEndDocument();
		xmlS = xWriter.getXmlString();
		xWriter.close();
	}

	private void buildXml() {
		List<String> lastFieldName= new List<String>();
		System.JSONToken jTok;
		lastFieldName.add('');
		Boolean first = true;
		String writeChars = null;

		while (jParser.nextToken() != Null) {
			jTok = jParser.getCurrentToken();
			System.debug(jTok);
			if (jTok == JSONToken.START_OBJECT) {
				if (first) {
					first = false;
					continue;
				}
				// WEC -- Not sure if this is needed.  But I think it is.
				if (writeChars != null) {
					xWriter.writeCharacters(writeChars);
					writeChars = null;
				}
				xWriter.writeStartElement(Null, lastFieldName.get(lastFieldName.size()-1), Null);
			
			} else if (jTok == JSONToken.END_OBJECT) {
				try {
					if (writeChars != null) {
						xWriter.writeCharacters(writeChars);
						writeChars = null;
					}
					xWriter.writeEndElement();
				lastFieldName.remove(lastFieldName.size()-1);
				} catch(Exception ex) {
					//do nothing this is to handle the first block.
				}	
			
			} else if (jTok == JSONToken.FIELD_NAME) {
				lastFieldName.add(jParser.getText());
			
			} else if (jTok == JSONToken.START_ARRAY) {
				lastFieldName.add(lastFieldName.get(lastFieldName.size()-1));

			} else if (jTok == JSONToken.END_ARRAY) {
				lastFieldName.remove(lastFieldName.size()-1);

			} else if (jTok == JSONToken.NOT_AVAILABLE) {

			} else { // Handle all the values.
				String txtValue = jParser.getText();
				if (lastFieldName.get(lastFieldName.size()-1).startsWith('@')) {
					String attrName = lastFieldName.get(lastFieldName.size()-1).removeStart('@');
					xWriter.writeAttribute(Null, Null, attrName, txtValue);
					
				} else if (lastFieldName.get(lastFieldName.size()-1).equals('#text')) {
					writeChars = txtValue; //xWriter.writeCharacters(txtValue);
				
				} else {
					// Shouldn't be here. 
					System.debug('Should not ever be reached: ' + txtValue);		
				}
			}
		}		
	}

	@TestVisible
	private static String getNextPrefix(String pref) {
		List<Integer> chars = pref.getChars();
		Integer i;
		for (i = chars.size()-1; i >= 0; i--) {
			chars[i] = chars[i]+1;
			if (chars[i] <= 'z'.getChars()[0]) {
				break;
			} else {
				chars[i] = 'a'.getChars()[0];
				if (i == 0) {
					chars.add('a'.getChars()[0]);
				}
			}
		} 

		return String.fromCharArray(chars);
	}

	public void MapToXMLRecursive(Map<String, Object> data) {
		Object val;
		String ns = Null;
		String txt = Null;
		String prefix = Null;
		List<String> toWriteAfterAttribs = new List<String>();

		if (data.containsKey('#ns')) {
			ns = (String)data.remove('#ns');

			if (nameSpaces.containsKey(ns)) {
				prefix = nameSpaces.get(ns);
			} else {
				// Get a prefix that isn't already used.
				prefix = 'a';
				while (nsPrefixes.contains(prefix)) {
					prefix = getNextPrefix(prefix);
				} 

				nameSpaces.put(ns, prefix);
				nsPrefixes.add(prefix);
			}

			xWriter.writeNamespace(prefix, ns);
		}

		for (String k : data.keySet()) {
			val = data.get(k);
			if (val instanceof List<Object>) {
				toWriteAfterAttribs.add(k);

			} else if (val instanceof Map<String, Object>) {
				toWriteAfterAttribs.add(k);

			} else if (val instanceof String) {
				if (k.startsWith('@')) {
					xWriter.writeAttribute(Null, Null, k.removeStart('@'), (String)val);
				} else if (k.startsWith('#ns#')) {
					String temp = k.removeStart('#ns#');
					if (temp == 'null') {
						temp = '';
					}
					xWriter.writeNamespace(temp,(String)val);
				} else if (k.indexOf('#') != -1) {

				} else {
					toWriteAfterAttribs.add(k);
				} 

			}
		}

		for (String k : toWriteAfterAttribs) {
			val = data.get(k);
			String nsKey = k.replace('#',':');
			if (val instanceof List<Object>) {
				xWriter.writeStartElement(Null, nsKey, Null);
				lastElWritten = k;
				listToXMLRecursive((List<Object>)val);
				xWriter.writeEndElement();

			} else if (val instanceof Map<String, Object>) {
				xWriter.writeStartElement(Null, nsKey, Null);
				lastElWritten = k;
				MapToXMLRecursive((Map<String, Object>)val);
				xWriter.writeEndElement();
			
			} else if (val instanceof String) {
				if (k.equals('#text')) {
					xWriter.writeCharacters((String)val);		
				} else {			
					xWriter.writeStartElement('', nsKey, ''); // TODO: add NS support.
					xWriter.writeCharacters((String)val);
					xWriter.writeEndElement();
				}
			} else {
				// This shouldn't be possible.
				System.debug('Unknown object in map');
			}
		}
	}

	public void listToXMLRecursive(List<Object> data) {
		Integer ct = 0;
		for (Object li : data) {
			if (li instanceof Map<String, Object>) {
				MapToXMLRecursive((Map<String, Object>)li);
				if (ct < data.size() - 1) {
					xWriter.writeEndElement();
					xWriter.writeStartElement(Null, lastElWritten, Null);
				}
			}
			ct += 1;
		}
	}

	public String getXml() {
		return xmlS;
	}

	public static String convertJsonToXml(String jsonS) {
		return convertJsonToXml(jsonS, True);
	}

	public static String convertJsonToXml(String jsonS, Boolean nsSupport) {
		JsonToXml conv = new JsonToXml(jsonS, nsSupport);
		return conv.getXml();
	} 
}