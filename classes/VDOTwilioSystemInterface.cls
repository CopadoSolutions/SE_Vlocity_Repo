global virtual class VDOTwilioSystemInterface implements vlocity_cmt.XOMOrchestrationInterfaces.ISystemInterface

{

   private Http http=null;

   global class DefaultInterfaceUnrecoverableException extends Exception {}

   // Based on https://en.wikipedia.org/wiki/List_of_HTTP_status_codes

   private static Set<Integer> successStatusCode=new Set<Integer>

   {

      200, 201, 202, 203, 204, 205, 206, 302, 304

   };

   private static Set<Integer> recoverableErrorStatusCodes=new Set<Integer>

   {

      408, 426 /* Upgrade is required */, 500, 502, 503, 504, 440, 444, 520, 522, 523, 524, 525

   };

   global VDOTwilioSystemInterface()

   {

      // Do nothing

   }

   /**

   * This method is a part of ISystemInterface. It is invoked at the start of the batch

   * @param url base URL the batch is started for

   * @param path path this batch is started for

   */

   global virtual void startBatch(String url, String path)

   {

      // Do nothing

   }

   /**

   * Executes a Callout OrchestrationItem

   * @param url base URL to send the request to

   * @param path path to send the request to

   * @param item OrchestrationItem that needs to be executed

   */

   global virtual void executeItem (String url, String path, vlocity_cmt__OrchestrationItem__c item)

   {
      HttpRequest req = new HttpRequest();   
      List<vlocity_cmt__OrchestrationItem__c> itemReference = [SELECT vlocity_cmt__OrderItemId__r.Order.Account.Phone, vlocity_cmt__OrderItemId__r.Order.ShipToContact.FirstName, vlocity_cmt__OrderItemId__r.Order.ShipToContact.MobilePhone, vlocity_cmt__OrderItemId__r.Order.ShipToContact.Phone, vlocity_cmt__OrderItemId__r.Order.ShipToContactId, vlocity_cmt__OrderItemId__r.Order.AccountId, vlocity_cmt__OrchestrationItemDefinitionId__r.vlocity_cmt__SystemInterfaceId__r.Name, vlocity_cmt__OrchestrationItemDefinitionId__r.Message_Content__c FROM vlocity_cmt__OrchestrationItem__c WHERE Id = :item.Id];
      
      if(itemReference.size() > 0){
      
              Contact c;
              if(itemReference[0].vlocity_cmt__OrderItemId__r.Order.ShipToContactId == null){
                  c = [SELECT id, Phone, FirstName, LastName, MobilePhone, HomePhone FROM Contact WHERE Vlocity_Demo_Key__c = 'democontact1' LIMIT 1];
              }else{
                  c = itemReference[0].vlocity_cmt__OrderItemId__r.Order.ShipToContact;
              }
      
              String outboundMessage = itemReference[0].vlocity_cmt__OrchestrationItemDefinitionId__r.Message_Content__c;
              Map<String,String> params = new Map<String, String>();
              //params.put('From', '+15107579361');
              params.put('From', '+19293951502');
              if(itemReference[0].vlocity_cmt__OrchestrationItemDefinitionId__r.vlocity_cmt__SystemInterfaceId__r.Name == 'SMS Message'){
                  outboundMessage = outboundMessage.replace('{Company}', UserInfo.getOrganizationName() );
                  outboundMessage = outboundMessage.replace('{Name}', c.FirstName);                  
                  params.put('To', c.MobilePhone);
                  params.put('Body', outboundMessage);
              }
              else if(itemReference[0].vlocity_cmt__OrchestrationItemDefinitionId__r.vlocity_cmt__SystemInterfaceId__r.Name == 'Phone Call'){
                  params.put('To', c.Phone);
                  Domain siteDomain = [SELECT id,Domain FROM Domain LIMIT 1];
                  String siteURL = siteDomain.Domain.replace('cmt', 'cmt-site');
                  siteURL = siteURL.replace('.force', '.secure.force');
                  params.put('Url', 'http://' + siteURL + outboundMessage + '?id=' + c.Id);

              }
        
              req.setMethod('POST');
              req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
              req.setHeader('authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('ACab2436287debb6ae36dbb2a83af238a3:70581e8d4be8660f9e35d6f39586be5b')));
              
              //OLD
              //req.setHeader('authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('AC49f864280c3674fbed5fd7ccbe0a48b0:83c41d4fb94757674963d128d657a2a2')));
              req.setEndPoint(url+path);
              req.setBody(buildEntityBody(params)); 
         
      

          if (item.vlocity_cmt__timeoutMs__c != null && item.vlocity_cmt__timeoutMs__c >0)
    
          {
    
             req.setTimeout ( item.vlocity_cmt__timeoutMs__c.intValue() );
    
          }
    
          try
    
          {
    
             Http h=new Http();
    
             HttpResponse resp=h.send(req);
             Integer statusCode=resp.getStatusCode();
             System.debug('*** ' + resp.getBody());
    
             if (!successStatusCode.contains(statusCode))
    
             {
    
                if (recoverableErrorStatusCodes.contains(statusCode))
    
                {
    
                   //throw new vlocity_cmt.XOMOrchestrationInterfaces.SystemInterfaceRecoverableException ('Recoverable status code '+statusCode+' in response '+resp+' as a request to '+req);
    
                }
    
                else
    
                {
    
                   //throw new DefaultInterfaceUnrecoverableException ('Unrecoverable status code '+statusCode+' in response '+resp+' as a request to '+req);
    
                }
    
             }
    
             // The call is successful, let's give subclasses a chance to process response
    
              if(itemReference[0].vlocity_cmt__OrchestrationItemDefinitionId__r.vlocity_cmt__SystemInterfaceId__r.Name == 'SMS Message'){
                 Task t = new Task(Subject = 'SMS Order Notification', Description = outboundMessage, WhatId = itemReference[0].vlocity_cmt__OrderItemId__r.Order.AccountId, Status = 'Completed', Type ='SMS', ActivityDate = System.Today(), WhoId = c.Id);
                 insert t;
              }
              else if(itemReference[0].vlocity_cmt__OrchestrationItemDefinitionId__r.vlocity_cmt__SystemInterfaceId__r.Name == 'Phone Call'){
                 Task t = new Task(Subject = 'Call Order Notification', Description = 'Automated call about the customer\'s order.', WhatId = itemReference[0].vlocity_cmt__OrderItemId__r.Order.AccountId, Status = 'Completed', Type ='SMS', ActivityDate = System.Today(), WhoId = c.Id);
                 insert t;
              }     
                        
             processResponse(url, path, resp);
    
          }
    
          catch (CalloutException e)
    
          {
    
             //throw new vlocity_cmt.XOMOrchestrationInterfaces.SystemInterfaceRecoverableException ('Callout exception '+e+': trying to retry');
    
          }
      }

   }

  
   /**

   * This method is called from executeItem to create process response

   *

   * Subclasses are free to override this method to implement response processing.

   * Out-of-the-box implementation of the method does nothing

   * @param url base URL for the batch

   * @param path path for the batch

   * @param res HttpResponse to process

   */

   global virtual void processResponse(String url, String path, HttpResponse res)

   {

      // Do nothing by default

   }

   /**

   * This method is called at the end of the batch

   * @param url base URL for the batch

   * @param path path for the batch

   */

   global virtual void endBatch(String url, String path)

   {

      // Do nothing

   }
   
 
    private String buildEntityBody(Map<String,String> params) {
        String entityBody='';
        if (params != null) {
            for (String key : params.keySet()) {
                try {
                    entityBody += (entityBody=='' ? '' : '&')
                                    + key + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8');
                } catch (Exception e) {
                    System.debug('ERROR: ' + e);
                }
            }
        }
        return entityBody;
    }
 

}