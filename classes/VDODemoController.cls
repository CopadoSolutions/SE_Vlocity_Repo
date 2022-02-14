global class VDODemoController{

    //Home page widgets
    public Contact currentContact {get; set;}
    public Account currentAccount {get; set;}
    public Account demoAccount1 {get; set;}
    public Account demoAccount2 {get; set;}
    public Account demoAccount3 {get; set;}
    public List<Attachment> listAttachments {get;set;}
    public List<Product2> listProducts {get;set;}
    public List<vlocity_cmt__OmniScriptInstance__c> listScripts {get;set;}
    public List<vlocity_cmt__StatementLineItem__c> listUsage {get;set;}
    public List<vlocity_cmt__VlocityAction__c> listActionsSales {get;set;}
    public List<vlocity_cmt__VlocityAction__c> listActionsService {get;set;}
    public List<vlocity_cmt__VlocityAction__c> listActions {get;set;}
    public String accountKey {get;set;}
    public User currentUser {get;set;}
    public vlocity_cmt__OmniScriptInstance__c latestScript {get;set;}
    
    //Card properties
    public String layout {get;set;}
    public String sfInstanceUrl {get; private set;}
    public String currentInstanceUrlWithPath {get; private set;}
    
    public VDODemoController(){
        DemoSetup();
    }
    
    public VDODemoController(ApexPages.StandardController stdController) {
        DemoSetup();  
    }
    
    public void DemoSetup(){  
        //Widget configuration
        try{
            accountKey = ApexPages.currentPage().getParameters().get('vid') != NULL? ApexPages.currentPage().getParameters().get('vid'): 'demoaccount2';
            currentAccount = [SELECT id, name, shippingcity, recordtype.name FROM Account WHERE vlocity_demo_key__c = :accountKey LIMIT 1];
            currentContact = [SELECT firstname, lastname, name, id, phone, email FROM Contact WHERE vlocity_demo_key__c = 'democontact1' LIMIT 1];
            currentUser = [SELECT id, fullphotourl, smallphotourl, name FROM User WHERE id = :userinfo.getuserId()];
            demoAccount1 = [SELECT name, shippingcity, Vlocity_Demo_Image__c, Vlocity_Demo_Image_ID__c, Vlocity_Demo_Name__c FROM Account WHERE Vlocity_Demo_Key__c = 'demoaccount1' LIMIT 1];
            demoAccount2 = [SELECT name, shippingcity FROM Account WHERE Vlocity_Demo_Key__c = 'demoaccount2' LIMIT 1];
            demoAccount3 = [SELECT name, shippingcity FROM Account WHERE Vlocity_Demo_Key__c = 'demoaccount3' LIMIT 1];
            listProducts = [SELECT id, name FROM Product2 WHERE product_channel__c = 'Web' LIMIT 5];
            listActionsSales = [SELECT id, vlocity_cmt__DisplayLabel__c, vlocity_cmt__VlocityIcon__c, vlocity_cmt__URL__c FROM vlocity_cmt__VlocityAction__c WHERE vlocity_cmt__ApplicableTypes__c INCLUDES ('Retail') AND vlocity_cmt__URL__c != null ORDER BY vlocity_cmt__DisplayLabel__c];
            listActionsService = [SELECT id, vlocity_cmt__DisplayLabel__c, vlocity_cmt__VlocityIcon__c, vlocity_cmt__URL__c FROM vlocity_cmt__VlocityAction__c WHERE vlocity_cmt__ApplicableTypes__c INCLUDES ('Community Home') AND vlocity_cmt__URL__c != null ORDER BY vlocity_cmt__DisplayLabel__c];
            listActions = [SELECT id, vlocity_cmt__DisplayLabel__c, vlocity_cmt__VlocityIcon__c, vlocity_cmt__URL__c FROM vlocity_cmt__VlocityAction__c WHERE vlocity_cmt__ApplicableTypes__c INCLUDES ('Mobile Launch Pad') AND vlocity_cmt__URL__c != null ORDER BY vlocity_cmt__DisplayLabel__c];
            listAttachments = [SELECT id, parent.name, parentid FROM Attachment WHERE parentid IN :listProducts AND name LIKE '%TN%'];
            listScripts = [SELECT vlocity_cmt__Status__c, vlocity_cmt__OmniScriptSubType__c, vlocity_cmt__OmniScriptType__c, vlocity_cmt__ObjectId__c, vlocity_cmt__ResumeLink__c, vlocity_cmt__LastSaved__c FROM vlocity_cmt__OmniScriptInstance__c ORDER BY vlocity_cmt__LastSaved__c DESC LIMIT 10];
            listUsage = [SELECT Id, name, vlocity_cmt__AccountId__c, vlocity_cmt__Type__c, vlocity_cmt__Amount__c FROM vlocity_cmt__StatementLineItem__c WHERE vlocity_cmt__StatementId__r.vlocity_cmt__AccountId__c = :currentAccount.id AND vlocity_cmt__StatementId__r.name = 'Current Usage Statement'];
            
            for(vlocity_cmt__VlocityAction__c action : listActionsSales){
                action.vlocity_cmt__URL__c = action.vlocity_cmt__URL__c.replace('{0}', demoAccount2.id);
            }
            for(vlocity_cmt__VlocityAction__c action : listActionsService){
                action.vlocity_cmt__URL__c = action.vlocity_cmt__URL__c.replace('{0}', demoAccount2.id);
            }
            for(vlocity_cmt__VlocityAction__c action : listActions){
                action.vlocity_cmt__URL__c = action.vlocity_cmt__URL__c.replace('{0}', demoAccount2.id);
            }
            for(vlocity_cmt__OmniScriptInstance__c script : listScripts){
                script.vlocity_cmt__ResumeLink__c = script.vlocity_cmt__ResumeLink__c.replace(script.vlocity_cmt__ResumeLink__c.substring(script.vlocity_cmt__ResumeLink__c.indexOf('/apex/'), script.vlocity_cmt__ResumeLink__c.indexOf('?')), '/apex/c__VDOOmniscript');
            }
            if(listScripts.size() > 0){
                latestScript = listScripts[0];
                latestScript.vlocity_cmt__ResumeLink__c = latestScript.vlocity_cmt__ResumeLink__c.subString(latestScript.vlocity_cmt__ResumeLink__c.indexOf('/apex'));
            }
        
        }catch(Exception e){
            System.debug(e);
        }  
        //Card configuration
        layout = ApexPages.currentPage().getParameters().get('layout') != NULL? ApexPages.currentPage().getParameters().get('layout'): 'layout-grid';
        sfInstanceUrl = 'https://' + ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To');
        String currentRequestUrl = System.URL.getCurrentRequestUrl().toExternalForm();
        Integer posOfApexPath = currentRequestUrl.indexOf('/apex');
        currentInstanceUrlWithPath = (posOfApexPath > -1)?currentRequestUrl.substring(0,posOfApexPath):currentRequestUrl;

    }
    
    @RemoteAction
    global static String getLatestScript(){
        List<vlocity_cmt__OmniScriptInstance__c> listScripts = [SELECT vlocity_cmt__Status__c, vlocity_cmt__OmniScriptSubType__c, vlocity_cmt__OmniScriptType__c, vlocity_cmt__ObjectId__c, vlocity_cmt__ResumeLink__c, vlocity_cmt__LastSaved__c FROM vlocity_cmt__OmniScriptInstance__c ORDER BY vlocity_cmt__LastSaved__c DESC LIMIT 10];
        for(vlocity_cmt__OmniScriptInstance__c script : listScripts){
                script.vlocity_cmt__ResumeLink__c = script.vlocity_cmt__ResumeLink__c.replace(script.vlocity_cmt__ResumeLink__c.substring(script.vlocity_cmt__ResumeLink__c.indexOf('/apex/'), script.vlocity_cmt__ResumeLink__c.indexOf('?')), '/apex/c__VDOOmniscript');
        }
        if(listScripts.size() > 0){
            vlocity_cmt__OmniScriptInstance__c latestScript = listScripts[0];
            latestScript.vlocity_cmt__ResumeLink__c = latestScript.vlocity_cmt__ResumeLink__c.subString(latestScript.vlocity_cmt__ResumeLink__c.indexOf('/apex'));
            return latestScript.vlocity_cmt__ResumeLink__c;
        }
        return '#';
    }
    
    //Create a new b2b order and redirect to the Hybrid CPQ
    global PageReference newB2BOrder(){
        vlocity_cmt__Pricelist__c p = new vlocity_cmt__Pricelist__c();
        List<vlocity_cmt__Pricelist__c> pl = [SELECT id FROM vlocity_cmt__Pricelist__c WHERE Name = '2017'];
        if(pl.size() > 0){
            p = pl[0];
        }
        Order o = new Order(AccountId = ApexPages.currentPage().getParameters().get('Id'), Status = 'Draft',  vlocity_cmt__PricelistId__c = p.id, EffectiveDate = System.TODAY(), Name = 'New Upsell Order',  VDOPriceChildItems__c = true);
        insert o;
        return new PageReference('/apex/vlocity_cmt__HybridCPQ?id=' + o.id);
    }
      
}