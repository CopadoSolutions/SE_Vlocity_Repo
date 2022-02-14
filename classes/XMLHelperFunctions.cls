public with sharing class XMLHelperFunctions {

	//public String searchPath = null;
	
	public XMLHelperFunctions() {
		
	}

	public static Map<String, Dom.XmlNode> getXpath(String xPath, String xml) {
		Dom.Document doc = new Dom.Document();
		doc.load(xml);
		return getXPath(xPath, doc);
	}

	public static Map<String, Dom.XmlNode> getXPath(String xPath, Dom.Document doc) {
		return getXPath(xPath, doc.getRootElement());
	}

	public static Map<String, Dom.XmlNode> getXPath(String xPath, Dom.XmlNode node) {
		String searchPath = xPath;
		Map<String, Dom.XmlNode> retNodes = new Map<String, Dom.XmlNode>();
		Map<String, Dom.XmlNode> indexNodes = smashXml(node,searchPath); 

		Integer nextTokenStart;
		Integer curTokenStart = 0; 
		String curToken = '';


		if (xPath.startsWith('//')) {
			node = getRootElement(node);
			return getAllNodes(indexNodes, xPath);

		} else if (xPath.startsWith('./')) {
			// Stay here
		} else if (xPath.startsWith('/')) {
			node = getRootElement(node);
			if (!xPath.contains('[') && !xPath.contains('*')) {
				return getAllNodes(indexNodes, xPath, false);
			}
		} else if (xPath.startsWith('.')) {
			// Stay here
		} else if (xPath.startsWith('.//')) {
			// Stay here recursive descent.
			return getAllNodes(indexNodes, xPath);
		}

		System.debug('xPath is: ' + xPath);
		if (xPath.contains('*')) {
			//REGEX
			
			String count = '[\\\\[\\\\]0-9]*';
			String wildcard = '[A-Za-z0-9\\\\-\\\\_\\\\[\\\\]]*';

			Boolean startsWithSlash = false;
			String pathRegex = xPath.replaceAll('\\*', wildcard);
			if (xPath.startsWith('/')) {
				startsWithSlash = true;
				pathRegex = pathRegex.removeStart('/');
			}
			pathRegex = pathRegex.replaceAll('/', count + '/'); 
			if (startsWithSlash) {
				pathRegex = '/' + pathRegex;
			}

			System.debug(pathRegex);
			Pattern p = Pattern.compile(pathRegex);

			for (String k : indexNodes.keySet()) {
				System.debug('Index path: ' + k);
				Matcher match = p.matcher(k);
				System.debug('match is: ' + match);
				if (match.matches()) {
					retNodes.put(k, indexNodes.get(k));
				}
			}
		}
		node = indexNodes.get(xPath);



		if (node!=null) {
			retNodes.put(xPath, node); 		
		}
		return retNodes;
	} 

	//private static String optimizeXPath(String xPath) {
		
	//}

	private static Dom.XmlNode getRootElement(Dom.XmlNode node) {
		Dom.XmlNode child = node;
		while (node != Null) {
			child = node;
			node = node.getParent();
		}

		return child;
	}

//	private static List<Dom.XmlNode> getNodes

	public static Map<String, Dom.XmlNode> smashXml(Dom.XmlNode node,String searchPath) {
		return smashXML('', node,searchPath);
	}

	public static Map<String, Dom.XmlNode> smashXML(Dom.Document doc,String searchPath) {
		return smashXML(doc.getRootElement(),searchPath);
	}

	public static Map<String, Dom.XmlNode> smashXML(String xml,String searchPath) {
		Dom.Document doc = new Dom.Document();
		doc.load(xml);
		return smashXML(doc,searchPath);
	}

	public static Map<String, Dom.XmlNode> smashXML(String xPath, Dom.XmlNode node,String searchPath) {
		Map<String, Dom.XmlNode> xPathMap = new Map<String, Dom.XmlNode>();
		String startPath = xPath + '/' + node.getName();
		xPathMap.put(startPath, node);
		xPathMap.putAll(smashXmlHelper(startPath, node,searchPath));
		return xPathMap;
	}

	private static Map<String, Dom.XmlNode> smashXmlHelper(String xPath, Dom.XmlNode node,String searchPath) {
		Map<String, Dom.XmlNode> retMap = new Map<String, Dom.XmlNode>();
		List<Dom.XmlNode> children = node.getChildren();

		for (Dom.XmlNode child : children) {
			if (child.getName() == null) {
				continue;
			}
			
			String path = xPath + '/' +child.getName();
			// TODO: This needs to use regex instead of indexOf to account for the addition of indexes.
			if (searchPath.indexOf(xpath) == -1 && !searchPath.startsWith('//') && !searchPath.contains('*')) {
//				return retMap;
			}
			if (retMap.containsKey(path)) {
				Dom.XmlNode old = retMap.remove(path);
				retMap.put(path+'[0]', old);
				path = path + '[1]';
			} else if (retMap.containsKey(path + '[0]')) {
				Integer i = 0;
				while (retMap.containsKey(path + '[' + i + ']')) {
					i++;
				}
				path = path + '[' + i + ']';
			} 
			
			retMap.put(path, child);			
		}

		Map<String, Dom.XmlNode> mapToAdd = new Map<String, Dom.XmlNode>();
		for (String k : retMap.keySet()) {
			mapToAdd.putAll(smashXmlHelper(k, retMap.get(k),searchPath));
		}

		retMap.putAll(mapToAdd);

		return retMap;
	}

	public static Map<String, Dom.XmlNode> getAllNodes(Map<String, Dom.XmlNode> hayStack, String needle) {
		return getAllNodes(hayStack, needle, true);
	}

	public static Map<String, Dom.XmlNode> getAllNodes(Map<String, Dom.XmlNode> hayStack, String needle, Boolean relative) {
		Map<String, Dom.XmlNode> needles = new Map<String, Dom.XmlNode>();

		String simplePath; 
		String simpleNeedle;
		for (String hay : hayStack.keySet()) {

// I don't think I need to do anything special for object indexes here. Consider
// wanting the second author of everybook that would be //book/author[1]
			simplePath = hay.replaceAll('\\[\\d+\\]', '^');
			simplePath = simplePath.remove('^');	
			simpleNeedle = needle.removeStart('/');
			simpleNeedle = needle.removeStart('/');

			if (relative && simplePath.endsWith(simpleNeedle)) {
				needles.put(hay, hayStack.get(hay));
			} else if (simplePath.equals(needle)) {
				needles.put(hay, hayStack.get(hay));
			}
		}

		return needles;
	}

	public static Map<String,String> nodeToString(Map<String,Dom.XmlNode> nodeMap) {
		Map<String,String> retval = new Map<String,String>();
		for (String key: nodeMap.keySet()) {
			Dom.XmlNode node = nodeMap.get(key);
			String nodeString = nodeToString(node);
			retval.put(key,nodeString);
		}
		return retval;
	}

	public static String nodeToString(Dom.XmlNode node) {
		// TODO namespace
		String value = '<' + node.getName() + '>';
		value += node.getText();
		for(Dom.XmlNode element: node.getChildElements()) {
			value += nodeToString(element);
		}
		value += '</' + node.getName() + '>';
		return value;
	}


}