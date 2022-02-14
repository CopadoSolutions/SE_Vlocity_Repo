@isTest
private class JsonToXmlTest {
	static String jsonStr = '{"body":{"b":{"@battr":"bAttrText","c":{"#text":"textC"},"#text":"textBTextBCONT"},"a":{"#text":""},"#text":" "}}';
	static String jsonStrList = '{"e":{"a":[{"#text":"text1"},{"#text":"text2"}],"#text":""}}';
	static String jsonStrListNS = '{"e":{"li":[{"#text":"text1"},{"#text":"text2", "#ns":"www.test.org/test", "k": {"#ns":"www.test.org/test"}}],"#text":""}}';

	@isTest 
	static void testJsonToXmlListNS() {
		String retXml = JsonToXml.convertJsonToXml(jsonStrListNS);
		System.debug('testJsonToXMLListNS');
		System.debug(retXml);
		//System.assert(retXml.equals('<?xml version="1.0"?><e><li>text1</li><li xmlns:a="www.test.org/test">text2<k xmlns:a="www.test.org/test"></k></li></e>'));
	}

	@isTest 
	static void testJsonToXmlListMixedNS() {
	    String jStr = '{"e":{"li":[{"#text":"text1"},{"#text":"text2", "#ns":"www.test.org/test", "k": {"#ns":"www.test.org/test1"}}],"#text":""}}';		
		String retXml = JsonToXml.convertJsonToXml(jStr);
		System.debug('testJsonToXMLListMixedNS');
		System.debug(retXml);
		//System.assert(retXml.equals('<?xml version="1.0"?><e><li>text1</li><li xmlns:a="www.test.org/test">text2<k xmlns:b="www.test.org/test1"></k></li></e>'));
	}

	@isTest 
	static void testJsonToXmlTextAttrComplexVanillaNS() {
		JsonToXml conv = new JsonToXml((Map<String, Object>)JSON.deserializeUntyped(jsonStr));
		String retXml = conv.getXml();
		System.debug('testJsonToXmlTextAttrComplexVanillaNS');
		System.debug(retXml);
		//System.assert(retXml.equals('<?xml version="1.0"?><body><b battr="bAttrText"><c>textC</c>textBTextBCONT</b><a></a> </body>'));
	}	

	@isTest 
	static void testJsonToXmlListVanillaNS() {
		String retXml = JsonToXml.convertJsonToXml(jsonStrList);
		System.debug('testJsonToXmlListVanillaNS');
		System.debug(retXml);
		//System.assert(retXml.equals('<?xml version="1.0"?><e><a>text1</a><a>text2</a></e>'));
	}

	@isTest 
	static void testJsonToXmlTextAttrComplex() {
		String retXml = JsonToXml.convertJsonToXml(jsonStr, False);
		System.debug(retXml);
		System.assert(retXml.equals('<?xml version="1.0"?><body><b battr="bAttrText"><c>textC</c>textBTextBCONT</b><a></a> </body>'));
	}	

	@isTest 
	static void testJsonToXmlList() {
		String retXml = JsonToXml.convertJsonToXml(jsonStrList, False);
		System.debug('testJsonToXmlList');
		System.debug(retXml);
		System.assert(retXml.equals('<?xml version="1.0"?><e><a>text1</a><a>text2</a></e>'));
	}


	@isTest 
	static void testPrefixIncrement() {
		String s = JsonToXml.getNextPrefix('a');
		System.assert(s.equals('b'));

		s = JsonToXml.getNextPrefix('z');
		System.assert(s.equals('aa'));

		s = JsonToXml.getNextPrefix('aj');
		System.assert(s.equals('ak'));

		s = JsonToXml.getNextPrefix('zzzz');
		System.assert(s.equals('aaaaa'));

	}
}