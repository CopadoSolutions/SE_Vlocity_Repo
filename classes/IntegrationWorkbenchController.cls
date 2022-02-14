global with sharing class IntegrationWorkbenchController {

    //public static String fileContents {get; set;}
    //public static Dom.Document doc = null;
    //public Object jsonString {get; set;}
    //public Object parsed {get; set;}
    //public Object jsonOut {get;set;}
    private Document contents;
    private String rawXML = null;
    public Id attachId {get;set;}
    public Id rawId {get;set;}
    //public Map<String,Object> raptorMap {get;set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public IntegrationWorkbenchController() {
        //parsed = new Map<String,String>();
    }

    public IntegrationWorkbenchController(ApexPages.StandardController controller) {

    }


    public Object loadDoc() {
        //fileContents = attach.body.toString();
        //Map<String,Object> parsed = XmlToJson.ParseXML(fileContents);
        //jsonString = parsed.get('json');
        //raptorMap  = (Map<String,Object>)parsed.get('RaptorMap');
        return null;
    }


    @RemoteAction
    global static Object describeObject(String objectName) {
        return DBHelper.getFieldLabelsNoAddress(objectName);     
    }

    @RemoteAction
    global static CalloutItem__c makeCallout(String Name, String context) {
        Object jsonContext = JSON.deserializeUntyped(context);
        return Callout.makeCallout(Name, jsonContext);
    }

    @RemoteAction 
    public static List<vlocity_cmt__DRBundle__c> getDataRaptors() {
        List<String> intFields  = DBHelper.getFieldsNoAddress('vlocity_cmt__DRBundle__c');
        String soql = 'SELECT '  + String.join(intFields, ',') 
                        + ' FROM vlocity_cmt__DRBundle__c order by Name';
        List<vlocity_cmt__DRBundle__c> retval;
        retval = database.query(soql);
        return retval;
    }

    @RemoteAction
    public static Object transformXML(String xml) {
        Map<String,Object> parsed = XmlToJson.ParseXML(xml);       
//        doc = new Dom.Document();
//        doc.load(xml);
        return parsed;
    }


    @RemoteAction
    public static Object makeDRIn(String drName,Id attachId, Id rawId) {
        String drResult;       
        Document doc = [SELECT Id, Name,Body FROM Document WHERE Id=:attachId];
        String jsonString = doc.Body.toString();
        jsonString = jsonString.replace('rawId="' + rawId + '";\n', '');
        jsonString = jsonString.replace('superJSON= ', '');
        jsonString = jsonString.replace(';'
                + '\ntransformResult2(superJSON,rawId);'
                + '\n', '');
        Map<String,Object> superJson = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
        Map<String,Object> raptorMap = (Map<String,Object>)superJson.get('RaptorMap');
        Object jsonObject   = superJson.get('json');
  
//        doc = new Dom.Document();
//        doc.load(xml);
        //query dataraptor to see if it a unique name.
        List<vlocity_cmt__DRBundle__c> bundle = [Select id,Name from vlocity_cmt__DRBundle__c where Name = :drName];
        if (!bundle.isEmpty()) {
            drResult = '{"error": "data rator name already in use","Name": "' + drName + '"}';
            Object retval = JSON.deserializeUntyped(drResult);
            return retval;
        }
        //create drbundle
        vlocity_cmt__DRBundle__c newBundle = new vlocity_cmt__DRBundle__c(Name=drName, vlocity_cmt__DRMapName__c=drName, vlocity_cmt__IsDefaultForInterface__c=true, vlocity_cmt__IsProcessSuperBulk__c=false);
        newBundle.vlocity_cmt__InterfaceObject__c = 'JSON';  // should be XML
        newBundle.vlocity_cmt__Type__c = 'Load (JSON)';
        newBundle.vlocity_cmt__InputJson__c = JSON.serialize(jsonObject);
        insert newBundle;
        //set json
        //create drmapitems
        Integer i = 0;
        List<vlocity_cmt__DRMapItem__c> mappings = new List<vlocity_cmt__DRMapItem__c>();
        for (String key: raptorMap.keySet()) {
            vlocity_cmt__DRMapItem__c item = new vlocity_cmt__DRMapItem__c(
                Name=drName,
                vlocity_cmt__MapId__c =drName + i,
                vlocity_cmt__DomainObjectCreationOrder__c = 1,
                vlocity_cmt__InterfaceFieldAPIName__c = key,
                vlocity_cmt__DefaultValue__c = (String)raptorMap.get(key),
                vlocity_cmt__DomainObjectAPIName__c = 'json', 
                vlocity_cmt__DomainObjectFieldAPIName__c = 'json'

            );
            mappings.add(item);
            i++;
        }
        insert mappings;

        drResult = '{"success" : "' + newBundle.Id + '"}';
        Object retval = JSON.deserializeUntyped(drResult);
        return retval;
    }

    @RemoteAction
    public static Object makeDROut(String drName,Id attachId, Id rawId) {
        String drResult;       
        Document doc = [SELECT Id, Name,Body FROM Document WHERE Id=:attachId];
        String jsonString = doc.Body.toString();
        jsonString = jsonString.replace('rawId="' + rawId + '";\n', '');
        jsonString = jsonString.replace('superJSON= ', '');
        jsonString = jsonString.replace(';'
                + '\ntransformResult2(superJSON,rawId);'
                + '\n', '');
        //jsonString = jsonString.replace('"','\\"');
        system.debug('BBBBB jsonString ' + jsonString);
        Map<String,Object> superJson = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
        Map<String,Object> raptorMap = (Map<String,Object>)superJson.get('RaptorMap');
        Object jsonObject   = superJson.get('json');
  
//        doc = new Dom.Document();
//        doc.load(xml);
        //query dataraptor to see if it a unique name.
        List<vlocity_cmt__DRBundle__c> bundle = [Select id,Name from vlocity_cmt__DRBundle__c where Name = :drName];
        if (!bundle.isEmpty()) {
            drResult = '{"error": "data rator name already in use","Name": "' + drName + '"}';
            Object retval = JSON.deserializeUntyped(drResult);
            return retval;
        }
        //create drbundle
        vlocity_cmt__DRBundle__c newBundle = new vlocity_cmt__DRBundle__c(Name=drName, vlocity_cmt__DRMapName__c=drName, vlocity_cmt__IsDefaultForInterface__c=true, vlocity_cmt__IsProcessSuperBulk__c=false);
        newBundle.vlocity_cmt__InterfaceObject__c = 'JSON';  // should be XML
        newBundle.vlocity_cmt__Type__c = 'Extract (JSON)';
        newBundle.vlocity_cmt__TargetOutJson__c = JSON.serialize(jsonObject);
        insert newBundle;
        //set json
        //create drmapitems
        Integer i = 0;
        List<vlocity_cmt__DRMapItem__c> mappings = new List<vlocity_cmt__DRMapItem__c>();
        for (String key: raptorMap.keySet()) {
            vlocity_cmt__DRMapItem__c item = new vlocity_cmt__DRMapItem__c(
                Name=drName,
                vlocity_cmt__MapId__c =drName + i,
                vlocity_cmt__DomainObjectCreationOrder__c = 1,
                vlocity_cmt__InterfaceFieldAPIName__c = 'json',
                vlocity_cmt__DefaultValue__c = (String)raptorMap.get(key),
                vlocity_cmt__DomainObjectAPIName__c = 'json', 
                vlocity_cmt__DomainObjectFieldAPIName__c = key

            );
            mappings.add(item);
            i++;
        }
        insert mappings;

        drResult = '{"success" : "' + newBundle.Id + '"}';
        Object retval = JSON.deserializeUntyped(drResult);
        return retval;
   }

    public Object transformXML2() {
       String fileName = Apexpages.currentPage().getParameters().get('fileName');
       String rawXML = Apexpages.currentPage().getParameters().get('fileContents');
        //System.debug('BBBBB contents ' + fileContents);

        Map<String,Object> parsed = XmlToJson.ParseXML(rawXML); 
        //XmlToJson x2j = new XmlToJson(rawXML);
//        jsonString = (Object)parsed.get('json');
//        raptorMap  = (Map<String,Object>)parsed.get('RaptorMap');    
//        doc = new Dom.Document();
//        doc.load(xml);
       //System.debug('BBBBB parsed ' + parsed);
       Document doc = new Document();
       rawXML = rawXML.replace('\'', '\\\'');
       doc.Body = Blob.valueOf('rawXML=\'' + rawXML + '\';\n'
                    + 'setRawXML(rawXML);\n');
       doc.Name = fileName + '.js';
       doc.FolderId = UserInfo.getUserId();
       insert doc;

//       rawXML = rawXML.replace('\"', '\\"');
       rawId = doc.id;
       doc = new Document();
       doc.Body = Blob.valueOf('rawId="' + rawId + '";\n'
//                + 'rawXML="' +rawXML+'";' 
                + 'superJSON= ' + JSON.serialize(parsed) + ';'
//                + 'superJSON= ' + x2j.getJsonString() + ';'
                + '\ntransformResult2(superJSON,rawId);'
                + '\n'
                );
       doc.Name = 'transform-' + fileName + '.js';
       doc.FolderId = UserInfo.getUserId();
       insert doc;
       attachId = doc.Id;
        //jsonString = (Object)JSON.serialize(parsed);
       //System.debug('BBBBB string ' + jsonString);

        return null;
    }

    @RemoteAction
    public static Object getXPath(String xPath, Id docId) {
        //This should probably be the document.Node
//        if (rawXML == null) {
//            return null;
//        }
        Document doc = [SELECT Id, Name,Body FROM Document WHERE Id = :docId];
        String xml = doc.Body.toString();
        xml = xml.replace('rawXML=\'', '');
        xml = xml.replace('\';\nsetRawXML(rawXML);\n', '');
        Dom.Document docNode = new Dom.Document();
        docNode.load(xml);
        xml = '';
        Map<String,dom.XmlNode> retval = XMLHelperFunctions.getXpath(xPath, docNode);

        return XMLHelperFunctions.nodeToString(retval);
    }

    @RemoteAction
    public static Object getDocuments() {
        Id myUserId = UserInfo.getUserId();
        List<Document> retval = [SELECT Id, Name FROM Document WHERE FolderId = :myUserId and name like 'transform-%'];
        return retval;
    }


    public Object setDocument() {
        String docId = Apexpages.currentPage().getParameters().get('docId');
        attachId = (Id)docId;
        return null;
    }
    public Object setRawDocument() {
        String docId = Apexpages.currentPage().getParameters().get('docId2');
        rawId = (Id)docId;
        return null;
    }

}