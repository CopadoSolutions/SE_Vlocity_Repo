@isTest
public class JsonPathTest {

	static String jsonStr = 
	'{' +
	'  "Product": [' +
	'    {' +
	'      "name": "IPhone",' +
	'      "Capacity": 16,' +
	'      "UOM": "Gig",' +
	'      "Color": "Space Gray",' +
	'      "Accessories": {' +
	'        "case": [' +
	'          "spec avenger",' +
	'          "Glittery thing"' +
	'        ],' +
	'        "devices": [' +
	'          "LG Voyager",' +
	'          "Beats By Drew Speaker",' +
	'          "Glass Screen protector"' +
	'        ]' +
	'      },' +
	'      "ProtectionPlan": "2 year Kinsey Plan"' +
	'    },' +
	'    {' +
	'      "name": "IPhone",' +
	'      "Capacity": 32,' +
	'      "UOM": "Gig",' +
	'      "Color": "Golden Goose",' +
	'      "Accessories": {' +
	'        "case": [' +
	'          ""' +
	'        ],' +
	'        "devices": [' +
	'          "LG Voyager",' +
	'          "Glass Screen protector"' +
	'        ]' +
	'      },' +
	'      "ProtectionPlan": "2 year battery replacement"' +
	'    }' +
	'  ],' +
	'  "NestedObjects": {' +
	'    "nest1": {' +
	'      "nest2": {' +
	'        "nest3": {' +
	'          "nest4": {' +
	'            "key": "value"' +
	'          }' +
	'        }' +
	'      }' +
	'    }' +
	'  }' +
	'}'; 
	

	static String bookStore = 
	'{' +
	'    "store": {' +
	'        "book": [' +
	'            {' +
	'                "category": "reference",' +
	'                "author": "Nigel Rees",' +
	'                "title": "Sayings of the Century",' +
	'                "price": 8.95' +
	'            },' +
	'            {' +
	'                "$": "fiction",' +
	'                "author": "Evelyn Waugh",' +
	'                "title": "Sword of Honour",' +
	'                "price": 12.99' +
	'            },' +
	'            {' +
	'                "category": "fiction",' +
	'                "author": "Herman Melville",' +
	'                "title": "Moby Dick",' +
	'                "isbn": "0-553-21311-3",' +
	'                "price": 8.99' +
	'            },' +
	'            {' +
	'                "category": "fiction",' +
	'                "author": "J. R. R. Tolkien",' +
	'                "title": "The Lord of the Rings",' +
	'                "isbn": "0-395-19395-8",' +
	'                "price": 22.99' +
	'            }' +
	'        ],' +
	'        "bicycle": {' +
	'            "color": "red",' +
	'            "price": 19.95' +
	'        }' +
	'    },' +
	'    "expensive": 10' +
	'}';


	@isTest static void getSecondAuthor() {
		String path = '$.store.book[1].author';
		Map<String, Object> retPath = JsonPath.read(path, bookStore);
		
		System.debug(retPath);
		System.assertEquals(retPath.get(path), 'Evelyn Waugh');	
	}

	@isTest static void getAllElements() {
		String path = '$..*';
		Map<String, Object> retPath = JsonPath.read(path, bookStore);
		System.debug(retPath);
	}


	@isTest static void getAllPricesInStore() {
		String path = '$.store..price';
		Map<String, Object> retPath = JsonPath.read(path, bookStore);
		System.debug(retPath);
		System.assertEquals(5, retPath.keySet().size());
	}

	@isTest static void getAllPrices() {
		String path = '$..price';
		Map<String, Object> retPath = JsonPath.read(path, bookStore);
		System.debug(retPath);
		System.assertEquals(5, retPath.keySet().size());
	}	

	@isTest static void getFirstBook() {
		String path = '$.store.book[1]';
		Map<String, Object> retPath = JsonPath.read(path, bookStore);
			
	}
}