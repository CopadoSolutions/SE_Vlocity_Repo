public with sharing class VDODemoEngineeringRemoteSitesDefault{

    
    public static void createDefaultRemoteSiteSettings()
    {   
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String baseNoProt = baseURL.remove('https://');
        String[] domainSplit = baseNoProt.split('\\.');
        String vfURLIns = 'https://'+domainSplit[0]+'--vlocity-ins.visualforce.com';
        String vfURLCMT = 'https://'+domainSplit[0]+'--vlocity-cmt.visualforce.com';
        String lightningURL = 'https://'+domainSplit[0]+'.lightning.force.com';

        system.debug(baseNoProt);
        system.debug(domainSplit);
        system.debug(baseURL);
        system.debug(vfURLIns);
        system.debug(vfURLCMT);
        system.debug(lightningURL);
        
        VDODemoEngineeringRemoteSitesDefault.addRemoteSiteSettings('de_self_base',baseURL,'de_self_base');
        VDODemoEngineeringRemoteSitesDefault.addRemoteSiteSettings('de_vfURLINS',vfURLIns ,'de_vfURLIns');
        VDODemoEngineeringRemoteSitesDefault.addRemoteSiteSettings('de_vfURLCMT',vfURLCMT ,'de_vfURLCMT');
        VDODemoEngineeringRemoteSitesDefault.addRemoteSiteSettings('de_lightningURL',lightningURL,'de_lightningURL');
        VDODemoEngineeringRemoteSitesDefault.addRemoteSiteSettings('de_demodxcdn', 'https://vlocitydemodx.herokuapp.com','de_demodxcdn');
    }
    
    public static void createDefaultCorsSiteSettings()
    {   
        addSiteToCors('de_visualforce_cors','https://*.visualforce.com');
        addSiteToCors('de_sfbase_cors','https://*.my.salesforce.com');
        addSiteToCors('de_force_cors','https://*.*.force.com');
    }
    
    public static void addRemoteSiteSettings(string name,String url,String description)
    {   
        try {

            MetadataService.MetadataPort service = createService();
            MetadataService.RemoteSiteSetting remoteSiteSettings = new MetadataService.RemoteSiteSetting();
            remoteSiteSettings.fullName = name;
            remoteSiteSettings.url = url;
            remoteSiteSettings.description=description;
            remoteSiteSettings.isActive=true;
            remoteSiteSettings.disableProtocolSecurity=false;
            MetadataService.SaveResult[]  results = service.createMetadata(new List<MetadataService.Metadata> { remoteSiteSettings });
        }
        catch(Exception ex)
        {
            system.debug(ex);
        }
    }
    
    public static void addSiteToCors(string name,String urlPattern)
    {   
    
       try {
            MetadataService.MetadataPort service = createService();
            MetadataService.CorsWhitelistOrigin corsSetting= new MetadataService.CorsWhitelistOrigin ();
            corsSetting.fullName = name;
            corsSetting.urlPattern= urlPattern;
            MetadataService.SaveResult[]  results = service.createMetadata(new List<MetadataService.Metadata> { corsSetting});            
        }
        catch(Exception ex)
        {
            system.debug(ex);
        }
    }

    public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
}