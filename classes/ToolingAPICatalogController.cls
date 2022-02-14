/**
 * Created by cristianduicu on 2018-10-11.
 */

public with sharing class ToolingAPICatalogController {

    /**
     *  Colors:
     *  - Offer or Product - blue (offer is a lighter blue)
     *  - Class -> white
     *  - CFS or RFS - green (CFS is a lighter shade)
     */
    private static Map<String, String> shapeStyles = new Map<String, String>
    {
            'Offer' =>     ' [$COLOR$, fontcolor="$FONTCOLOR$", href="$HREF$", tooltip="$TOOLTIP$", label="$LABEL$"]',
            'Product' =>   ' [$COLOR$, fontcolor="$FONTCOLOR$", href="$HREF$", tooltip="$TOOLTIP$", label="$LABEL$"]',
            'Service' =>   ' [$COLOR$, fontcolor="$FONTCOLOR$", href="$HREF$", tooltip="$TOOLTIP$", label="$LABEL$"]',
            'Resource' =>  ' [$COLOR$, fontcolor="$FONTCOLOR$", href="$HREF$", tooltip="$TOOLTIP$", label="$LABEL$"]',
            'Technical' => ' [$COLOR$, fontcolor="$FONTCOLOR$", href="$HREF$", tooltip="$TOOLTIP$", label="$LABEL$"]',
            'UNDEFINED' => ' [$COLOR$, fontcolor="$FONTCOLOR$", href="$HREF$", tooltip="$TOOLTIP$", label="$LABEL$"]',
            'Promotion' => ' [$COLOR$, href="$HREF$", label="$LABEL$"]',
            'Grant' =>     ' [color="#2252DC", href="$HREF$", tooltip="$TOOLTIP$", label="$LABEL$"]',
            'Repair Service' => ' [color="#838188", href="$HREF$", tooltip="$TOOLTIP$", label="$LABEL$"]',
            'Group' =>     ' [color="#E3F9F9", href="$HREF$", tooltip="$TOOLTIP$", label="$LABEL$"]'
    };

    private static Map<String, String> colorStrings = new Map<String, String>
    {
            'Offer' => 'color="#6baed6"', //'colorscheme="blues9", color="5"',
            'Offer.orderable' => 'color="#6baed6:#deebf7"', //'colorscheme="blues9", color="5:2"',
            'Product' => 'color="#4292c6"', //'colorscheme="blues9", color="6"',
            'Product.orderable' => 'color="#4292c6:#9ecae1"', //'colorscheme="blues9", color="6:4"',
            'Service' => 'color="#41ae76"', //'colorscheme="bugn9", color="6"',
            'Service.orderable' => 'color="#41ae76:#ccece6"', //'colorscheme="bugn9", color="6:3"',
            'Technical' => 'color="#99d8c9"', //'colorscheme="bugn9", color="4"',
            'Technical.orderable' => 'color="#99d8c9"', //'colorscheme="bugn9", color="4:3"', // ????
            'Resource' => 'colorscheme="bugn9", color="3"',
            'Resource.orderable' => 'colorscheme="bugn9", color="3:1"',
            'Promotion' => 'colorscheme="rdpu7", color="5"',
            'Promotion.orderable' => 'colorscheme="rdpu7", color="5:3"',
            'UNDEFINED' => 'color="#fd8d3c"', //'colorscheme="oranges6", color="4"',
            'UNDEFINED.orderable' => 'color="#fd8d3c:#fdd0a2"',//'colorscheme="oranges6", color="4:2"',
            'Virtual' => 'color="gray84"'
    };

    private static Map<String,String> fontColors = new Map<String,String>
    {
            'Normal' => 'black',
            'NotAssetizable' => '#aa00aa'
    };

    private static String classShapeStyle = ' [style="rounded,filled,dashed", fillcolor="#fffeea", color="black", href="$HREF$", tooltip="$TOOLTIP$", label="$LABEL$"]';
    private static String errorShapeStyle = ' [color="#ff0000", label="$LABEL$"]';
    private static String pciLinkStyle =    ' [color="#515252", arrowhead="ediamond", tooltip="$TOOLTIP$", xlabel="$LABEL$", labelURL="$URL$"]';
    private static String decompLinkStyle = ' [color="#039CD6", arrowhead="vee", tooltip="Decomposition relationship", xlabel="$LABEL$", labelURL="$URL$"]';
    private static String classLinkStyle =  ' [style=dashed, arrowhead="empty", arrowtail="empty", color="#2f5da8", tooltip="Parent class"]';
    private static String orchNodeStyle = '[label=<<table border="1" cellspacing="0" cellpadding="3">' +
            '<tr><td width="160" height="25" bgcolor="#6677ab"><font color="white">$NAME$</font></td></tr>' +
            '<tr><td height="35">$CONTENT$</td></tr><tr><td height="25" bgcolor="#c5d5ff"><font color="#777777">$ORCHPLAN$</font></td></tr></table>>]';

    private static Map<String, String> scopes = new Map<String, String>
    {
            'Account' => 'A',
            'Order Item' => 'OI',
            'Downstream Order item' => 'DOI'
    };

    public String productId {get; set;}

    private static String graph = ''; // stores the graph definition in DOT format
    private static String decompSubGraph = '';
    public static Map<Id,GraphNode> parentClassProducts = new Map<Id, GraphNode>();
    public static Map<Id,Scenario> scenarios = new Map<Id, Scenario>();
    public static Integer queryNo = 0;
    public static Integer MAX_GRAPH_DEPTH = 1;
    private static Integer depth = 0;
    private static List<Id> nextLevelIds = new List<Id>();
    private static Integer clusterId = 0;
    private static Graph jsonGraph;

    // orchestration plan information
    private static List<String> orchDepys = new List<String>();
    private static Map<String,String> orchItems = new Map<String,String>();
    private static Map<String,String> orchPlans = new Map<String,String>();

    /**
     * Orchestration Scenario Information
     */
    public class Scenario {
        public String Id;
        public String orchPlanId;
        public String orchPlanDef;
        public String orchPlan;
        public String action = '&nbsp;';
        public String subAction = '&nbsp;';
        public String product = '&nbsp;';
        public String conditionData = '';

        Scenario(String scenarioId, String orchPlanId, String orchPlanDef, String action, String subAction, String conditionData) {
            this.Id = scenarioId;
            this.orchPlanId = orchPlanId;
            this.orchPlanDef = orchPlanDef;
            this.orchPlan = '<a href="/' + orchPlanId + '">' + orchPlanDef + '</a>';
            if (action != null) this.action = action;
            if (subAction != null) this.subAction = subAction;
            if (conditionData != null) this.conditionData = conditionData;
        }

    }

    /**
     * Product details for the table
     */
    public class ProductDetails {
        public String productId;
        public String productName;
        public String recordType;
        public boolean isOrderable = false;
        public String objectType = 'UNDEFINED';
        public String specType = 'UNDEFINED';
        public String productPage;
        //public String productPageEPC;
        public String description;
        public String family;
        public String productCode;
        public String status;
        public String scope;
        public String globalKey;
        public boolean isNotAssetizable = false;

        ProductDetails(String productId, String productName) {
            this.productId = productId;
            this.productName = productName;
        }
    }

    /**
     * Decomposition Relationship Details for the table
     */
    public class DecompDetails {
        public String decompRelId;
        public String decompRelName;
        public String conditionData;
        public String sourceProdId;
        public String sourceProdName;
        public String destProdId;
        public String mappingsData;
        public String xorGroup;
        public String destProdName;
        public String decompRelPage;

        DecompDetails(String Id, String Name) {
            this.decompRelId = Id;
            this.decompRelName = Name;
        }
    }
    /**
     * Graph Node Definition.
     */
    public class GraphNode
    {
        public Id productId;
        public String productName;
        public boolean erroneous = false;
        public String specType = 'UNDEFINED'; //'Product';
        public boolean isClass = false;
        public Id parentClass;
        public String scope = 'E';
        public boolean isOrderable = false;
        public String objectType = 'UNDEFINED';
        public String pciMinMaxDef = null;
        public boolean isVirtualProduct = false;
        public boolean isNotAssetizable = false;
        public List<Scenario> relatedScenarios = new List<Scenario>();
        public String decompRelId; // only populated for destination product
        public boolean complete = true;

        public Map<Id,GraphNode> pciNodes = null;
        public Map<Id,GraphNode> decompNodes = null;

        GraphNode(Id productId, String productName, String specType, String scope)
        {
            this.productId = productId;
            this.productName = productName;
            if (specType != null) this.specType = specType;
            this.erroneous = false;
            this.isClass = false;
            this.parentClass = null;
            this.scope = scope;
        }

        GraphNode(boolean erroneous)
        {
            this.erroneous = erroneous;
        }

        public void addPCI(GraphNode pciNode)
        {
            if (pciNodes == null) pciNodes = new Map<Id,GraphNode>();
            if (pciNodes.get(pciNode.productId) == null)
            {
                pciNodes.put(pciNode.productId, pciNode);
            }
        }

        public void addDecomp(GraphNode decompNode)
        {
            if (decompNodes == null) decompNodes = new Map<Id,GraphNode>();
            if (decompNodes.get(decompNode.productId) == null)
            {
                decompNodes.put(decompNode.productId, decompNode);
            }
        }

        public void addScenario(Scenario scenario) {
            this.relatedScenarios.add(scenario);
        }

        public Integer getChildrenNo() {
            if (pciNodes == null) return 0;
            return pciNodes.size();
        }

        public String getNodeName() {
            return '"' + productId + '"';
        }

        public String getNodeLabel() {
            return escapeString(productName + '\n[' + objectType + ']');
        }

        public String escapeString(String s) {
            s = s.replace('"', '_'); // TODO how to escape RTL and LTR strings ???
            return s;
        }

        public String getScenariosLabel() {
            if (relatedScenarios.size() == 0) return '__Not Defined__';
            String lbl = '';
            Iterator<Scenario> it = relatedScenarios.iterator();
            while (it.hasNext()) {
                Scenario s = it.next();
                lbl += '\n\t- ' + s.orchPlanDef + '\n\t(' + s.action + ' / ' + s.subAction + ')';
            }
            return lbl;
        }

        public String getNodeStyle(boolean isTechnicalSpec) {
            if (specType == null) specType = 'UNDEFINED';
            String style = shapeStyles.get(specType);
            if (isClass) style = classShapeStyle;
            if (style == null) style = shapeStyles.get('Product'); // account for unknown spectypes

            style = style.replace('$HREF$', 'javascript:selectNode(\'' + String.valueOf(productId).substring(0, 15) + '\')');
            style = style.replace('$TOOLTIP$',
                    'Id:\t\t\t' + productId +
                            '\nSpec Type:\t' + specType +
                            '\nObject Type:\t' + objectType +
                            '\nOrderable:\t\t' + isOrderable +
                            '\nIsClass:\t\t' + isClass +
                            '\nChildren:\t\t' + getChildrenNo() +
                            '\nIsVirtual:\t\t' + isVirtualProduct +
                            '\nScope:\t\t' + scope +
                            '\nIsTechnicalSpec:\t' + isTechnicalSpec +
                            '\nScenarios:\t\t' + getScenariosLabel());

            if (style.contains('$COLOR$')) {
                String colorName = specType;
                if (isOrderable) colorName += '.orderable';
                colorName = colorStrings.get(colorName);
                if (colorName == null) {
                    colorName = 'color="#FAA105"'; // fall back color
                }
                if (isTechnicalSpec) colorName = colorStrings.get('Technical');
                //if (isNotAssetizable) colorName = colorStrings.get('NotAssetizable');
                if (isVirtualProduct) colorName = colorStrings.get('Virtual');
                style = style.replace('$COLOR$', colorName);
            }

            if (style.contains('$FONTCOLOR$')) {
                String colorName = fontColors.get('Normal');
                if (isNotAssetizable) colorName = fontColors.get('NotAssetizable');
                style = style.replace('$FONTCOLOR$', colorName);
            }
            style = style.replace('$LABEL$', getNodeLabel());
            return style;
        }

        public String getPCILinkStyle() {
            String pciStyle = pciLinkStyle;
            pciStyle = pciStyle.replace('$TOOLTIP$', 'PCI');
            if (pciMinMaxDef != null) {
                pciStyle = pciStyle.replace('$LABEL$', pciMinMaxDef);
            } else {
                pciStyle = pciStyle.replace('$LABEL$', '');
            }
            pciStyle = pciStyle.replace('$URL$', 'javascript:selectPCI()');
            return pciStyle;
        }

        public String getDecompRelStyle() {
            String decompStyle = decompLinkStyle;
            decompStyle = decompStyle.replace('$LABEL$', '?');
            decompStyle = decompStyle.replace('$URL$', 'javascript:selectDecompRel(\'' + decompRelId + '\')');
            return decompStyle;
        }

    }

    public class Graph {
        public Map<String,String> nodes = new Map<String,String>();
        public Map<String,SubGraph> clusters = new Map<String, SubGraph>();
        public Map<String,String> decompNodes = new Map<String,String>(); // need them separate to group them
        public Map<String,String> pciRels = new Map<String, String>();
        public Map<String,String> decompRels = new Map<String, String>();
        public Map<String,String> classRels = new Map<String, String>();

        Graph(){}
    }

    public class SubGraph {
        public Map<String,String> pciRels = new Map<String,String>();

        SubGraph() {}
    }

    /**
     *
     *
     * @param productId
     *
     * @return
     */
    @remoteAction
    public static String getGraphForProduct(String productId, Integer maxGraphDepth)
    {
        jsonGraph = new Graph();

        MAX_GRAPH_DEPTH = maxGraphDepth;
        GraphNode node = buildGraphNodeForProduct(productId);
        generateGraphForProduct(node, false);

        if (decompSubGraph.length() > 0) {
            graph += '\nsubgraph clusterTechCat{\ncolor="white"\n' + decompSubGraph + '\n}\n';
        }

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        //gen.writeStringField('graph', graph);
        gen.writeStringField('nextLevelNodes', JSON.serialize(nextLevelIds));
        gen.writeStringField('scenarios', JSON.serialize(scenarios));
        gen.writeStringField('graphJson', JSON.serialize(jsonGraph));
        gen.writeEndObject();
        System.debug(productId + ' nextLeveIds: ' + nextLevelIds);

        return gen.getAsString();
    }

    /**
     * Webservice method to retrieve product details
     *
     * @param productId
     *
     * @return
     */
    @remoteAction
    public static String getProductDetails(String productId) {
        Product2 p = [
                select Id, Name, Description, Family, ProductCode, vlocity_cmt__SpecificationType__c, RecordType.Name,
                        vlocity_cmt__ParentClassId__c, vlocity_cmt__ParentClassId__r.Id,
                        vlocity_cmt__Scope__c, vlocity_cmt__IsOrderable__c, vlocity_cmt__GlobalKey__c,
                        vlocity_cmt__ObjectTypeId__c, vlocity_cmt__ObjectTypeId__r.Name, vlocity_cmt__Status__c, vlocity_cmt__IsNotAssetizable__c
                from Product2 where Id = :productId
        ];
        ProductDetails pd = new ProductDetails(productId, p.Name);
        if (p.vlocity_cmt__ObjectTypeId__c != null) {
            pd.objectType = '<a href="/' + p.vlocity_cmt__ObjectTypeId__c + '">' +
                    p.vlocity_cmt__ObjectTypeId__r.Name + '</a>';
        }
        if (p.vlocity_cmt__IsNotAssetizable__c) pd.isNotAssetizable = true;
        if (p.vlocity_cmt__IsOrderable__c) pd.isOrderable = true;
        if (p.vlocity_cmt__SpecificationType__c != null) pd.specType = p.vlocity_cmt__SpecificationType__c;
        pd.recordType = p.RecordType.Name;
        pd.productPage = '<a href="/' + pd.productId + '">' + pd.productName + '</a>';
        // TODO: fix URL - starts with vlocity-cmt.
//        pd.productPageEPC = '<a target="_blank" href="/apex/EPCAdmin?objAPILabel=Product&objAPIName=Product2&id=' +
//                pd.productId + '&name=' + pd.productName + '">' + pd.productName + '</a>';
        pd.description = p.Description;
        pd.family = p.Family;
        pd.productCode = p.ProductCode;
        pd.status = p.vlocity_cmt__Status__c;
        pd.scope = p.vlocity_cmt__Scope__c;
        pd.globalKey = p.vlocity_cmt__GlobalKey__c;

        //vlocity_cmt.JSONAttributeUtili util = vlocity_cmt.JSONAttributeSupport();

        return JSON.serialize(pd);
    }

    /**
     * Webservice API to retrieve decomposition relationship details
     *
     * @param decompRelId
     *
     * @return
     */
    @remoteAction
    public static String getDecompRelDetails(String decompRelId) {
        vlocity_cmt__DecompositionRelationship__c dr = [
                select Id, Name, vlocity_cmt__ConditionData__c, vlocity_cmt__DestinationProductId__c,
                        vlocity_cmt__MappingsData__c, vlocity_cmt__Priority__c, vlocity_cmt__RequireReservation__c,
                        vlocity_cmt__SourceProductId__c, vlocity_cmt__XORGroup__c, vlocity_cmt__DestinationProductId__r.Name,
                        vlocity_cmt__SourceProductId__r.Name
                from vlocity_cmt__DecompositionRelationship__c
                where Id = :decompRelId
        ];

        DecompDetails dd = new DecompDetails(dr.Id, dr.Name);
        dd.conditionData = dr.vlocity_cmt__ConditionData__c;
        dd.destProdId = dr.vlocity_cmt__DestinationProductId__c;
        dd.mappingsData = dr.vlocity_cmt__MappingsData__c;
        dd.xorGroup = dr.vlocity_cmt__XORGroup__c;
        dd.destProdName = dr.vlocity_cmt__DestinationProductId__r.Name;
        dd.decompRelPage = '<a href="/' + dd.decompRelId + '">' + dd.decompRelName + '</a>';
        dd.sourceProdId = dr.vlocity_cmt__SourceProductId__c;
        dd.sourceProdName = dr.vlocity_cmt__SourceProductId__r.Name;

        return JSON.serialize(dd);
    }

    /**
     * Webservice API to retrieve a list of products. Used for autocomplete search.
     *
     * @param searchString
     *
     * @return
     */
    @remoteAction
    public static String getProductList(String searchString, Integer limitNo) {
        String likeString = '%' + searchString  + '%';
        List<Product2> products = [select Id, Name from Product2 where Name like :likeString order by Name limit :limitNo];
        String prodList = '{';
        Iterator<Product2> pItr = products.iterator();
        while (pItr.hasNext()) {
            Product2 p = pItr.next();
            prodList += (prodList.length() == 1 ? '' : ',') +  '"' + p.Name + ' (' + p.Id + ')":null';
        }
        return prodList + '}';
    }

    /**
     * Webservice API to retrieve a list of attributes. Used for autocomplete search.
     *
     * @param searchString
     * @param limitNo
     *
     * @return
     */
    @remoteAction
    public static String getAttrList(String searchString, Integer limitNo) {
        String likeString = '%' + searchString  + '%';
        List<vlocity_cmt__Attribute__c> attrs = [select Id, Name  from vlocity_cmt__Attribute__c
        where Name like :likeString limit :limitNo]; //vlocity_cmt__AttributeCategoryName__c
        String attrList = '{';
        Iterator<vlocity_cmt__Attribute__c> pItr = attrs.iterator();
        while (pItr.hasNext()) {
            vlocity_cmt__Attribute__c p = pItr.next();
            attrList += (attrList.length() == 1 ? '' : ',') +  '"' + p.Name + ' (' + p.Id + ')":null';
        }
        return attrList + '}';
    }

    @remoteAction
    public static String whereUsedAttr(String attrId) {
        List<vlocity_cmt__AttributeAssignment__c> attrAssignments = [select Id, vlocity_cmt__AttributeName__c,
                vlocity_cmt__AttributeId__c, vlocity_cmt__CategoryName__c, vlocity_cmt__ObjectId__c,
                vlocity_cmt__IsActive__c, vlocity_cmt__IsConfigurable__c
        from vlocity_cmt__AttributeAssignment__c where vlocity_cmt__ObjectType__c = 'Product2'
        and vlocity_cmt__AttributeId__c = :attrId];
        JSONGenerator gen = JSON.createGenerator(false);
        Iterator<vlocity_cmt__AttributeAssignment__c> it = attrAssignments.iterator();
        while (it.hasNext()) {
            vlocity_cmt__AttributeAssignment__c attrAssignment = it.next();
            gen.writeStringField('objectTypeId', attrAssignment.vlocity_cmt__ObjectId__c);
        }
        return gen.getAsString();
    }

    /**
     * Lists the Products based on a specific ObjectType
     *
     * @param objTypeName
     *
     * @return
     */
    @remoteAction
    public static String whereUsedObjType(String objTypeName) {
        List<Product2> products = [select Id, Name, ProductCode, vlocity_cmt__SpecificationType__c,
                vlocity_cmt__IsOrderable__c, vlocity_cmt__Status__c
        from Product2 where vlocity_cmt__ObjectTypeId__r.Name = :objTypeName order by Name limit 999];
        JSONGenerator gen = JSON.createGenerator(false);
        Iterator<Product2> it = products.iterator();
        while (it.hasNext()) {
            Product2 p = it.next();
            gen.writeStringField('Id', p.Id);
            gen.writeStringField('ProductName', p.Name);
            gen.writeStringField('ProductCode', p.ProductCode);
            gen.writeStringField('SpecType', p.vlocity_cmt__SpecificationType__c);
            gen.writeBooleanField('Orderable', p.vlocity_cmt__IsOrderable__c);
            gen.writeStringField('Status', p.vlocity_cmt__Status__c);
        }
        return gen.getAsString();
    }

    /**
     *
     *
     * @param scenarioIds
     *
     * @return
     */
    @remoteAction
    public static String getGraphForOrch(String scenarioIds) {
        buildOrchPlanGraph(scenarioIds);

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('dependencies', JSON.serialize(orchDepys));
        gen.writeStringField('orchItems', JSON.serialize(orchItems));
        gen.writeStringField('orchPlans', JSON.serialize(orchPlans));
        return gen.getAsString();
    }

    /**
     * Generates the graph for the selected product.{id:1,text:'Apple',img:'http://placehold.it/250x250'}
     *
     * @param GraphNode mainNode
     */
    private static void generateGraphForProduct(GraphNode mainNode, boolean isDecompTarget)
    {
        System.debug('generateGraphForProduct, where productId: '+mainNode.productId);

        String nodeString = mainNode.getNodeName() + mainNode.getNodeStyle(isDecompTarget) + ';\n';
        if (isDecompTarget) {
            jsonGraph.decompNodes.put(mainNode.getNodeName(), nodeString);
            //decompSubGraph += nodeString;
        } else {
            jsonGraph.nodes.put(mainNode.getNodeName(), nodeString);
            //graph += nodeString;
        }

        Map<Id,GraphNode> pcItems = mainNode.pciNodes;
        if (pcItems != null) {

            // group PCI relationship
            SubGraph sg = new SubGraph();
            //graph += '\nsubgraph cluster' + clusterId++ + '{\ncolor="white"\n';

            Iterator<GraphNode> pciItr = pcItems.values().iterator();
            while(pciItr.hasNext()) {
                GraphNode pciNode = pciItr.next();
                if (!pciNode.erroneous) {
                    String pciStyle = pciNode.getPCILinkStyle();
                    //graph+= mainNode.getNodeName() + ' -> ' + pciNode.getNodeName() + pciStyle + ';\n';
                    sg.pciRels.put(mainNode.getNodeName() + '-' + pciNode.getNodeName(),
                            mainNode.getNodeName() + ' -> ' + pciNode.getNodeName() + pciStyle + ';\n');

                    //if we are generating the graph for a specific product then we need to go deeper and
                    //repeat the process for each PCI
                    // if pci is incomplete - subsequent request adds the graph node
                    if (pciNode.complete) generateGraphForProduct(pciNode, false);
                } else {
                    System.debug('Error for node: ' + mainNode.getNodeName());
                    //graph+='"ERROR"' + errorShapeStyle + ';\n';
                    //graph+= mainNode.getNodeName() + ' -> "ERROR"' + pciLinkStyle + ';\n';
                }
            }

            //graph += '}\n';
            jsonGraph.clusters.put(mainNode.productId, sg);
        }

        Map<Id,GraphNode> decompItems = mainNode.decompNodes;
        if (decompItems != null) {
            Iterator<GraphNode> decompItr = decompItems.values().iterator();
            while(decompItr.hasNext()) {
                GraphNode decompNode = decompItr.next();
                if (!decompNode.erroneous) {

                    //graph+= mainNode.getNodeName() + ' -> ' + decompNode.getNodeName() + decompNode.getDecompRelStyle() +';\n';
                    jsonGraph.decompRels.put(mainNode.getNodeName() + '-' + decompNode.getNodeName(),
                            mainNode.getNodeName() + ' -> ' + decompNode.getNodeName() + decompNode.getDecompRelStyle() +';\n');

                    //if we are generating the graph for a specific product then we need to go deeper and
                    //repeat the process for each decomp
                    generateGraphForProduct(decompNode, true);
                } else {
                    System.debug('Error for node: ' + mainNode.getNodeName());
                    //graph+='"ERROR"' + errorShapeStyle + ';\n';
                    //graph+= mainNode.getNodeName() + ' -> "ERROR"'+decompLinkStyle+';\n';
                }
            }
        }

        if (mainNode.parentClass != null) {
            GraphNode classNode = parentClassProducts.get(mainNode.parentClass);
            if (classNode!=null) {
                //graph+= mainNode.getNodeName() + ' -> ' + classNode.getNodeName() + classLinkStyle + ';\n';
                jsonGraph.classRels.put(mainNode.getNodeName() + '-' + classNode.getNodeName(),
                        mainNode.getNodeName() + ' -> ' + classNode.getNodeName() + classLinkStyle + ';\n');
                generateGraphForProduct(classNode, false);
            }
        }
    }

    /**
     * @param productId the Id of the Product
     */
    private static GraphNode buildGraphNodeForProduct(String productId) {
        //System.debug('QueryNo: ' + queryNo++);
        Product2 product = [
                select Id, Name, vlocity_cmt__SpecificationType__c, RecordType.Name, vlocity_cmt__ParentClassId__r.Id,
                        vlocity_cmt__Scope__c, vlocity_cmt__IsOrderable__c, vlocity_cmt__IsNotAssetizable__c,
                        vlocity_cmt__ObjectTypeId__r.Name,
                (select Name, vlocity_cmt__ChildProductId__r.Name,
                        vlocity_cmt__ChildProductId__r.vlocity_cmt__SpecificationType__c,
                        vlocity_cmt__ChildProductId__r.vlocity_cmt__ParentClassId__r.Id,
                        vlocity_cmt__ChildProductId__r.vlocity_cmt__Scope__c,
                        vlocity_cmt__IsVirtualItem__c, vlocity_cmt__MinMaxDefaultQty__c
                from vlocity_cmt__ProductChildItems__r
                where not (name like 'Root%')
                ), (
                        select Id, vlocity_cmt__DestinationProductId__r.Id
                        from vlocity_cmt__DestinationDecompositionRelationships__r
                ), (
                        select Id, vlocity_cmt__OrchestrationPlanDefinitionId__c,
                                vlocity_cmt__OrchestrationPlanDefinitionId__r.Name, vlocity_cmt__Action__c,
                                vlocity_cmt__SubAction__c, vlocity_cmt__ConditionData__c
                        from vlocity_cmt__OrchestrationScenarios__r
                )
                from Product2
                where Id = :productId
        ];

        System.debug('Loading info for ' + product.Name + '; Id=' + productId);
        GraphNode mainNode = new GraphNode(product.Id, product.Name,
                product.vlocity_cmt__SpecificationType__c, product.vlocity_cmt__Scope__c);
        if (product.vlocity_cmt__IsOrderable__c) {
            mainNode.isOrderable = true;
        }
        if (product.vlocity_cmt__IsNotAssetizable__c) {
            mainNode.isNotAssetizable = true;
        }
        if (product.vlocity_cmt__ObjectTypeId__r.Name != null) {
            mainNode.objectType = product.vlocity_cmt__ObjectTypeId__r.Name;
        }

        if (product.RecordType.Name == 'Class') mainNode.isClass = true;
        if (product.vlocity_cmt__ParentClassId__c != null && !''.equals(product.vlocity_cmt__ParentClassId__c)) {
            mainNode.parentClass = product.vlocity_cmt__ParentClassId__c;
            GraphNode parentClassNode = buildGraphNodeForProduct(mainNode.parentClass);
            // the class is special - adding it to a generic list instead of adding it to a specific node
            parentClassProducts.put(mainNode.parentClass, parentClassNode);
        }

        // add children and their edges
        List<vlocity_cmt__ProductChildItem__c> pcItems = product.vlocity_cmt__ProductChildItems__r;
        Iterator<vlocity_cmt__ProductChildItem__c> pciItr = pcItems.iterator();
        if (pcItems.size() > 0) depth++;
        System.debug('Processing children: ' + pcItems.size() + '; depth = ' + depth);
        while (pciItr.hasNext()) {
            vlocity_cmt__ProductChildItem__c pci = pciItr.next();
            if (pci.vlocity_cmt__ChildProductId__r != null) {
                GraphNode pciNode;
                if (depth <= MAX_GRAPH_DEPTH || pci.vlocity_cmt__IsVirtualItem__c) {
                    pciNode = buildGraphNodeForProduct(pci.vlocity_cmt__ChildProductId__r.Id);
                } else {
                    pciNode = new GraphNode(pci.vlocity_cmt__ChildProductId__r.Id,
                            pci.vlocity_cmt__ChildProductId__r.Name,
                            pci.vlocity_cmt__ChildProductId__r.vlocity_cmt__SpecificationType__c,
                            pci.vlocity_cmt__ChildProductId__r.vlocity_cmt__Scope__c);
                    pciNode.complete = false;
                    nextLevelIds.add(pci.vlocity_cmt__ChildProductId__r.Id);
                    System.debug('aded to future processing: ' + pci.vlocity_cmt__ChildProductId__r.Id);
                }
                // add the relationship specific information
                if (pci.vlocity_cmt__MinMaxDefaultQty__c != null) {
                    pciNode.pciMinMaxDef = pci.vlocity_cmt__MinMaxDefaultQty__c;
                }
                if (pci.vlocity_cmt__IsVirtualItem__c != null) {
                    pciNode.isVirtualProduct = pci.vlocity_cmt__IsVirtualItem__c;
                }
                mainNode.addPCI(pciNode);
            } else {
                // error ...
                mainNode.addPCI(new GraphNode(true));
            }
        }

        // add decomposition relationships
        List<vlocity_cmt__DecompositionRelationship__c> decompItems = product.vlocity_cmt__DestinationDecompositionRelationships__r;
        System.debug('Loading decompositions ...' + decompItems.size());
        Iterator<vlocity_cmt__DecompositionRelationship__c> decompItr = decompItems.iterator();
        while (decompItr.hasNext()) {
            vlocity_cmt__DecompositionRelationship__c decomp = decompItr.next();
            if (decomp.vlocity_cmt__DestinationProductId__r != null) {
                GraphNode decompNode = buildGraphNodeForProduct(decomp.vlocity_cmt__DestinationProductId__r.Id);
                decompNode.decompRelId = decomp.Id;
                mainNode.addDecomp(decompNode);
            } else {
                mainNode.addDecomp(new GraphNode(true));
            }
        }

        // add scenario information if present
        List<vlocity_cmt__OrchestrationScenario__c> orchScenarios = product.vlocity_cmt__OrchestrationScenarios__r;
        Iterator<vlocity_cmt__OrchestrationScenario__c> scenarioIterator = orchScenarios.iterator();
        while (scenarioIterator.hasNext()) {
            vlocity_cmt__OrchestrationScenario__c scenario = scenarioIterator.next();
            Scenario s = new Scenario(scenario.Id, scenario.vlocity_cmt__OrchestrationPlanDefinitionId__c,
                    scenario.vlocity_cmt__OrchestrationPlanDefinitionId__r.Name, scenario.vlocity_cmt__Action__c,
                    scenario.vlocity_cmt__SubAction__c, scenario.vlocity_cmt__ConditionData__c);
            s.product = '<a href="/' + mainNode.productId + '">' + mainNode.productName + '</a>';
            mainNode.addScenario(s);
            if (scenarios.get(scenario.Id) == null) {
                scenarios.put(scenario.Id, s);
            }
        }

        return mainNode;
    }

    /**
     *
     *
     * @return a list of products. List is limited to under 1000 products.
     */
    public List<SelectOption> getProducts() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Select product'));

        List<Product2> products = [select Id, Name from Product2 order by Name limit 998];
        Iterator<Product2> productsItr = products.iterator();
        while (productsItr.hasNext())
        {
            Product2 product = productsItr.next();
            options.add(new SelectOption(String.valueOf(product.Id).substring(0, 15), product.Name));
        }

        if (options.size()>997) options.add(new SelectOption('...', '>>Too many products to display. Call the page from the required product'));

        return options;
    }

    /**
     *
     *
     * @param scenarios
     *
     * @return
     */
    private static void buildOrchPlanGraph(String scenarioIds) {
        Set<Id> orchItemIdLst = new Set<Id>();
        Set<Id> orchPlanList = new Set<Id>();

        List<String> scenarioIdLst = scenarioIds.split(',');
        List<vlocity_cmt__OrchestrationScenario__c> scenarioLst = [select vlocity_cmt__OrchestrationPlanDefinitionId__c
        from vlocity_cmt__OrchestrationScenario__c where Id in :scenarioIdLst];
        Iterator<vlocity_cmt__OrchestrationScenario__c> itScen = scenarioLst.iterator();
        while (itScen.hasNext()) {
            vlocity_cmt__OrchestrationScenario__c s = itScen.next();
            orchPlanList.add(s.vlocity_cmt__OrchestrationPlanDefinitionId__c);
        }

        List<vlocity_cmt__OrchestrationDependencyDefinition__c> depyLst = [select Id,
                vlocity_cmt__OrchestrationItemDefinitionId__c, vlocity_cmt__DependencyType__c,
                vlocity_cmt__DependencyItemDefinitionId__c
        from vlocity_cmt__OrchestrationDependencyDefinition__c
        where vlocity_cmt__OrchestrationItemDefinitionId__r.vlocity_cmt__OrchestrationPlanDefinitionId__c in :orchPlanList
        and vlocity_cmt__DependencyItemDefinitionId__r.vlocity_cmt__OrchestrationPlanDefinitionId__c in :orchPlanList];

        Iterator<vlocity_cmt__OrchestrationDependencyDefinition__c> itDepy = depyLst.iterator();
        while (itDepy.hasNext()) {
            vlocity_cmt__OrchestrationDependencyDefinition__c depy = itDepy.next();
            if (depy.vlocity_cmt__DependencyType__c == 'Depends On') {
                orchDepys.add(depy.vlocity_cmt__DependencyItemDefinitionId__c + ' -> ' + depy.vlocity_cmt__OrchestrationItemDefinitionId__c);
            } else {
                orchDepys.add(depy.vlocity_cmt__OrchestrationItemDefinitionId__c + ' -> ' + depy.vlocity_cmt__DependencyItemDefinitionId__c);
            }
            orchItemIdLst.add(depy.vlocity_cmt__OrchestrationItemDefinitionId__c);
            orchItemIdLst.add(depy.vlocity_cmt__DependencyItemDefinitionId__c);
        }

        List<vlocity_cmt__OrchestrationItemDefinition__c> oItems = [select Id, Name, RecordType.Name,
                vlocity_cmt__IsPointOfNoReturn__c, vlocity_cmt__Scope__c, vlocity_cmt__ConditionData__c,
                vlocity_cmt__OrchestrationPlanDefinitionId__r.Name
        from vlocity_cmt__OrchestrationItemDefinition__c where Id in :orchItemIdLst
        or vlocity_cmt__OrchestrationPlanDefinitionId__c in :orchPlanList];

        Iterator<vlocity_cmt__OrchestrationItemDefinition__c> itOrch = oItems.iterator();
        while (itOrch.hasNext()) {
            vlocity_cmt__OrchestrationItemDefinition__c orchItem = itOrch.next();
            String style = orchNodeStyle;
            style = style.replace('$NAME$', orchItem.Name);
            String content = orchItem.RecordType.Name;
            if (orchItem.vlocity_cmt__IsPointOfNoReturn__c) content += ' (PONR)';
            style = style.replace('$CONTENT$', content);
            style = style.replace('$ORCHPLAN$', orchItem.vlocity_cmt__OrchestrationPlanDefinitionId__r.Name);
            orchItems.put(orchItem.Id, orchItem.Id + ' ' + style + ';\n');

            // updated orchPlans .... used for proper ranking
            String itemsInplan = orchPlans.get(orchItem.vlocity_cmt__OrchestrationPlanDefinitionId__r.Name);
            if (itemsInplan == null) itemsInplan = '';
            if (!itemsInplan.contains(orchItem.Name)) {
                if (itemsInplan.length() != 0) itemsInplan += ',';
                itemsInplan += orchItem.Id;
            }
            orchPlans.put(orchItem.vlocity_cmt__OrchestrationPlanDefinitionId__r.Name, itemsInplan);
        }


    }
}