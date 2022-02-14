public class NENeedleCastController {

      public String oid { get; set; }
      public String retURL { get; set; }
      public String sunetworkid { get; set; }
      public String sunetworkuserid { get; set; }
      public String target { get; set; }
     
      public NENeedleCastController() {
      
      oid = ApexPages.currentPage().getParameters().get('oid');
      retURL = ApexPages.currentPage().getParameters().get('retURL');
      sunetworkid = ApexPages.currentPage().getParameters().get('sunetworkid');
      sunetworkuserid = ApexPages.currentPage().getParameters().get('sunetworkuserid');
      
            
        }
        
             public PageReference go() {
             
             target = Url.getSalesforceBaseURL().toExternalForm()+'/servlet/servlet.su?oid=';
             target += oid;
             target += '&retURL=%2F';
             target += retURL;
             target +='&sunetworkid=';
             target += sunetworkid;
             target += '&sunetworkuserid=';
             target += sunetworkuserid;

            PageReference newFloodOnlyUrl = new PageReference(target);
            newFloodOnlyUrl.setRedirect(true);
            return newFloodOnlyUrl;
    
          
        }
        
    }