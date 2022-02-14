global virtual class VDODefaultSystemInterface implements vlocity_cmt.XOMOrchestrationInterfaces.ISystemInterface

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

   global VDODefaultSystemInterface()

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

      Id orderId=null;

      vlocity_cmt__OrchestrationItem__c theitem = [SELECT id, vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.Id, vlocity_cmt__SystemInterfaceId__r.vlocity_cmt__SystemId__r.online__c FROM vlocity_cmt__OrchestrationItem__c WHERE id = :item.id];

      vlocity_cmt.XOMOrderDomainObject orderObj=null;

      if (item.vlocity_cmt__orderItemId__c!=null) {

         orderId=item.vlocity_cmt__orderItemId__r.orderId;

         orderObj= ((vlocity_cmt.XOMOrderService)vlocity_cmt.XOMObjectFactory.getService(Order.SobjectType)).getObject(orderId, true);

      } else {

         orderId = theitem.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.Id;

         orderObj = ((vlocity_cmt.XOMOrderService)vlocity_cmt.XOMObjectFactory.getService(Order.SobjectType)).getObject(orderId, true);

         //orderObj= ((vlocity_cmt.XOMOrderService)vlocity_cmt.XOMObjectFactory.getService(Order.SobjectType)).getFulfilmentRequest(orderId, true);

      }

      String requestPayload = generatePayload(item, orderObj);

      System.debug ('Request payload: '+requestPayload);

      HttpRequest req = createHttpRequest(url, path, requestPayload);
      
      

      if (item.vlocity_cmt__timeoutMs__c != null && item.vlocity_cmt__timeoutMs__c >0)

      {

         req.setTimeout ( item.vlocity_cmt__timeoutMs__c.intValue() );

      }

      try

      {

         Http h=new Http();

         HttpResponse resp=h.send(req);

         // TODO: Set returned ID as external ID
         
         

         Integer statusCode=resp.getStatusCode();
         
         theitem.request__c = req.getBody();
         theitem.response__c = resp.getBody();
         update theitem;

         if(theItem.vlocity_cmt__SystemInterfaceId__r.vlocity_cmt__SystemId__r.online__c == false){
            statusCode = 408;
         }

         if (!successStatusCode.contains(statusCode))

         {

            if (recoverableErrorStatusCodes.contains(statusCode))

            {

               throw new vlocity_cmt.XOMOrchestrationInterfaces.SystemInterfaceRecoverableException ('Recoverable status code '+statusCode+' in response '+resp+' as a request to '+req);

            }

            else

            {

               throw new DefaultInterfaceUnrecoverableException ('Unrecoverable status code '+statusCode+' in response '+resp+' as a request to '+req);

            }

         }

         // The call is successful, let's give subclasses a chance to process response

         processResponse(url, path, resp);

      }

      catch (CalloutException e)

      {

         throw new vlocity_cmt.XOMOrchestrationInterfaces.SystemInterfaceRecoverableException ('Callout exception '+e+': trying to retry');

      }

   }

   /**

   * This method is called from executeItem to generate payload to be sent

   *

   * Sub-classes are free to override this method to change the way payload is generated

   *

   * @param item OrchestrationItem to generate payload for

   * @param orderObj loaded DomainObject for the Order

   * @return generated payload

   */

   global virtual String generatePayload(vlocity_cmt__OrchestrationItem__c item, vlocity_cmt.XOMOrderDomainObject orderObj)

   {

      String drBundleName = item.vlocity_cmt__vlocityDataRaptorBundleId__r.name;

      // If DR Bundle is specified, use DR Bundle to generate JSON

      if (drBundleName != null) {

         /*Map<String, Object> drParams = new Map<String, Object>{ 'orderId' => orderObj.getId() };

         System.debug ('DefaultSystemInterface>> running drBundle '+drBundleName+' against '+drParams);

         DRProcessResult result = DRProcessor.processNow(drParams, drBundleName, null);

         System.debug ('DefaultSystemInterface>>DR result: '+result);

         return JSON.serialize(result.toJson());*/
         
         return generateJSON (orderObj);

      } else {

         return generateJson (orderObj);

      }

   }

   /**

   * This method is called from executeItem to create HttpRequest

   *

   * Subclasses are free to override this method to change HTTP method, Content-Type or any of HTTP headers

   * Please note that it is not possible to change timeout settings in this method as timeout is always

   * sourced from the Orchestration Item

   * @param url base URL for the batch

   * @param path path for the batch

   * @param requestPayload payload to be send

   * @return HttpRequest to be sent

   */

   global virtual HttpRequest createHttpRequest (String url, String path, String requestPayload)

   {

      HttpRequest req = new HttpRequest();

      req.setMethod('POST');

      req.setHeader('Content-Type', 'application/json');

      req.setEndPoint(url+path);

      req.setBody(requestPayload);

      return req;

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

   private String generateJson (vlocity_cmt.XOMOrderDomainObject order)

   {

      System.debug ('Generate JSON for '+order);

      JSONGenerator gen=JSON.createGenerator(true);

      gen.writeStartObject();

      gen.writeIdField('order_id', order.getId());

      gen.writeIdField('account_id', order.getAccountId());

      gen.writeFieldName('order_items');

      gen.writeStartArray();

      if (order.getChildren() != null)

      {

         for (vlocity_cmt.XOMOrderItemDomainObject oi: order.getChildren())

         {

            writeOrderItem(gen, oi);

         }

      }

      gen.writeEndArray();

      gen.writeEndObject();

      return gen.getAsString();

   }

   private void writeOrderItem(JSONGenerator gen, vlocity_cmt.XOMOrderItemDomainObject obj)

   {

      gen.writeStartObject();

      gen.writeIdField('order_item_id', obj.getId());

      gen.writeStringField('action', obj.getAction());

      gen.writeFieldName('specified_by');

      gen.writeStartObject();

      vlocity_cmt.XOMSpecificationDomainObject spec=obj.getSpecification();

      gen.writeStringField('specification_id', spec.getId());

      gen.writeStringField('specification_name', spec.getName());

      gen.writeEndObject();

      gen.writeFieldName('described_by');

      gen.writeStartArray();

      /*Map<String, vlocity_cmt.XOMAttributeValueRT> attributeValueMap = obj.getAttributeValueMap();

      if (attributeValueMap != null)

      {

         for (String attrCode: attributeValueMap.keySet())

         {

            XOMAttributeValueRT av = attributeValueMap.get(attrCode);

            gen.writeStartObject();

            gen.writeStringField('characteristic', av.getAttribute().getName());

            gen.writeStringField('value', av.getValue());

            gen.writeEndObject();

         }

      }*/

      gen.writeEndArray();

      if (obj.getChildren() != null && obj.getChildren().size() > 0)

      {

         gen.writeFieldName('order_items');

         gen.writeStartArray();

         for (vlocity_cmt.XOMOrderItemDomainObject c: obj.getChildren())

         {

            writeOrderItem(gen, c);

         }

         gen.writeEndArray();

      }

      gen.writeEndObject();

   }

}