/**
 * Implements a json searchable path. http://goessner.net/articles/JsonPath/
 */
public with sharing class JsonPath {
	Map<String, String> flattenedMap = new Map<String,String>();

	public static Map<String, Object> read(String path, String jsonStr) {
		Map<String, Object> potentialMatches = new Map<String, Object>();
		List<String> currentPath = new List<String>();
		currentPath.add('$');
		
		JSONParser parser = JSON.createParser(jsonStr);
		return read_helper(path, parser, currentPath);
	}

	private static Map<String, Object> read_helper(String path, JSONParser parser, List<String> currentPath) {
		// Only save to retVals if the currentPath matches the desired path.
		Map<String, Object> retVals = new Map<String, Object>();
		String count = '[\\\\[\\\\]0-9]*';
		String wildcard = '[A-Za-z0-9\\\\-\\\\_\\\\[\\\\]]*';
		Boolean inArray = false;
		Boolean moreToParse = true;

		while (parser.nextToken() != null) {
			JSONToken curTok = parser.getCurrentToken();
			//System.debug('currentPath: ' + currentPath);

			if (curTok == JSONToken.START_OBJECT) {
				retVals.putAll(read_helper(path, parser, currentPath)); //TODO verify duplicate keys aren't added. 

			} else if (curTok == JSONToken.END_OBJECT) {
				if (!currentPath.get(currentPath.size() - 1).endsWith(']')){
					currentPath.remove(currentPath.size() - 1);
				} else {
					currentPath = incrementArray(currentPath);
				}
				return retVals;

			} else if (curTok == JSONToken.START_ARRAY) {
				// Append [] to currentPath last element.
				currentPath.remove(currentPath.size() - 1);
				currentPath.add(parser.getCurrentName() + '[0]');
				retVals.putAll(read_helper(path, parser, currentPath));
				inArray = true;

			} else if (curTok == JSONToken.END_ARRAY) {
				// pop last element off currentPath.
				currentPath.remove(currentPath.size() - 1);
				inArray = false;

			} else if (curTok == JSONToken.FIELD_NAME) {
				currentPath.add(parser.getCurrentName());
			} else if (curTok == JSONToken.NOT_AVAILABLE) {

			} else if (curTok == JSONToken.VALUE_EMBEDDED_OBJECT) {

			} else {
				// TODO: make this handle wild cards with regexes etc. 
				String curPathStr = String.join(currentPath, '.');
System.debug('BBBBB path ' + path + ' currentpath ' + currentPath);

				if (path == curPathStr) {
					retVals.put(curPathStr, parser.getText());
				
				} else if (path.contains('..')) {
					List<String> splitPath = path.split('\\.\\.');
					if (curPathStr.startsWith(splitPath[0]) && curPathStr.endsWith(splitPath[1])) {
						retVals.put(curPathStr, parser.getText());
					}
				}

				if (!currentPath.get(currentPath.size() - 1).endsWith(']')) {
					currentPath.remove(currentPath.size() -1); // Pop
				}

				if (inArray)
					currentPath = incrementArray(currentPath);
			}			
		}

		// This should only be reached when the full json parser has been iterated through. 
		return retVals;		
	}

	private static List<String> incrementArray(List<String> currentPath) {
		String endTok = currentPath.get(currentPath.size() - 1);
		Integer curIndex = 0;

		if (!endTok.contains('[')){
			return currentPath;
		}

		curIndex = Integer.valueOf(endTok.split('[\\]\\[]')[1]);

		if (endTok.endsWith(']')) {
			endTok = endTok.removeEnd(curIndex + ']');
			curIndex += 1;
			endTok = endTok + curIndex + ']';
			currentPath.set(currentPath.size() - 1, endTok);
		}


		return currentpath;
	}
}