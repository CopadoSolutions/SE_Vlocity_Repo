@isTest
private class XMLHelperFunctionsTest
{
	static String bookstoreXML = '<?xml version="1.0" encoding="UTF-8"?><bookstore><book category="COOKING"><title lang="en">Everyday Italian</title><author>Giada De Laurentiis</author><year>2005</year><price>30.00</price></book><book category="CHILDREN"><title lang="en">Harry Potter</title><author>J K. Rowling</author><year>2005</year><price>29.99</price></book><book category="WEB"><title lang="en">XQuery Kick Start</title><author>James McGovern</author><author>Per Bothner</author><author>Kurt Cagle</author><author>James Linn</author><author>Vaidyanathan Nagarajan</author><year>2003</year><price>49.99</price></book><book category="WEB"><title lang="en">Learning XML</title><author>Erik T. Ray</author><year>2003</year><price>39.95</price></book></bookstore>';
	
	//static String matrixxSubmitOrderXML ='<?xml version="1.0" encoding="UTF-8"?><RequestDataSubmitCustomerOrder xmlns:dvm="http://www.oracle.com/XSL/Transform/java/oracle.tip.dvm.LookupValue" xmlns:tns="urn:v0.ordermanagement.cpcm.services.bgc" xmlns="urn:v0.ordermanagement.cpcm.services.bgc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:v0.ordermanagement.cpcm.services.bgc CPCM-SVC-OrderManagement-0.1.xsd"><tns:customerOrder><req1:requestedDate xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc" xmlns="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"></req1:requestedDate><req1:dueDate xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc" xmlns="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc">2016-07-6T00:00:00
 //       </req1:dueDate><req1:fulfillmentMode xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc" xmlns="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"></req1:fulfillmentMode><req1:version xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc" xmlns="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"></req1:version><req1:type xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc" xmlns="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><codeSystem></codeSystem><codeSystemVersion></codeSystemVersion><codeDescription></codeDescription><value></value><context></context></req1:type><req1:status xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc" xmlns="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><codeSystem></codeSystem><codeSystemVersion></codeSystemVersion><codeDescription></codeDescription><value></value><context></context></req1:status><req1:interactionDuration xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc" xmlns="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><startTimeStamp>2016-07-18T13:41:14</startTimeStamp><endTimeStamp>2016-07-18T13:41:14</endTimeStamp></req1:interactionDuration><req1:comment xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc" xmlns="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><comment></comment></req1:comment><req1:relationship xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc" xmlns="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"></req1:relationship><req1:item xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc" xmlns="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><req1:quantity>1</req1:quantity><req1:identifier><req1:id>01u36000002VJFMAA4</req1:id></req1:identifier><req1:comment><req1:comment>null</req1:comment></req1:comment><req1:status><req1:value>New</req1:value></req1:status><req1:assignedProduct><req1:charVal><req1:name>PRX_AT_1050</req1:name><req1:value>24 M</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1200</req1:name><req1:value>ADSL</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1240</req1:name><req1:value>6</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1220</req1:name><req1:value>CBD</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1310</req1:name><req1:value>123</req1:value></req1:charVal><req1:identifier><req1:id>80236000000rWPdAAM</req1:id></req1:identifier><req1:billingAccountIdentifier><req1:id>0013600000Nm55YAAR</req1:id></req1:billingAccountIdentifier><req1:customerIdentifier><req1:id>0013600000Nm55YAAR</req1:id></req1:customerIdentifier><req1:relationship><req1:isForAssignedProductIdentifier><req1:id>01t36000001kSIFAA2</req1:id></req1:isForAssignedProductIdentifier><req1:type><req1:value>SPO_AP_ID</req1:value></req1:type></req1:relationship><req1:offerIdentifier><req1:id>80236000000rWPcAAM</req1:id></req1:offerIdentifier><req1:requestedAction>Add</req1:requestedAction><req1:serviceIdentifier><req1:id></req1:id></req1:serviceIdentifier><req1:name><req1:defaultName>PS IPWAN Connectivity Bundle &lt;Product Spec&gt;</req1:defaultName></req1:name><req1:productIdentifier><req1:productSpecificationIdentifier><req1:id>01t36000001kSIFAA2</req1:id></req1:productSpecificationIdentifier></req1:productIdentifier><req1:installationPoint><req1:id>0013600000Nm55YAAR</req1:id></req1:installationPoint><req1:Type>Device</req1:Type></req1:assignedProduct><req1:assignedProduct><req1:charVal><req1:name>PRX_AT_1060</req1:name><req1:value>Standard</req1:value></req1:charVal><req1:identifier><req1:id>80236000000rWPfAAM</req1:id></req1:identifier><req1:billingAccountIdentifier><req1:id>0013600000Nm55YAAR</req1:id></req1:billingAccountIdentifier><req1:customerIdentifier><req1:id>0013600000Nm55YAAR</req1:id></req1:customerIdentifier><req1:relationship><req1:isForAssignedProductIdentifier><req1:id>01t36000001kUAIAA2</req1:id></req1:isForAssignedProductIdentifier><req1:type><req1:value>SPO_AP_ID</req1:value></req1:type></req1:relationship><req1:relationship><req1:isForAssignedProductIdentifier><req1:id>80236000000rWPdAAM</req1:id></req1:isForAssignedProductIdentifier><req1:type><req1:value>PARENT_OFFER_AP_ID</req1:value></req1:type></req1:relationship><req1:offerIdentifier><req1:id>80236000000rWPeAAM</req1:id></req1:offerIdentifier><req1:requestedAction>Add</req1:requestedAction><req1:serviceIdentifier><req1:id></req1:id></req1:serviceIdentifier><req1:name><req1:defaultName>PS IPWAN Connectivity Bundle Management &lt;Product Spec&gt;</req1:defaultName></req1:name><req1:productIdentifier><req1:productSpecificationIdentifier><req1:id>01t36000001kUAIAA2</req1:id></req1:productSpecificationIdentifier></req1:productIdentifier><req1:installationPoint><req1:id>0013600000Nm55YAAR</req1:id></req1:installationPoint><req1:Type>Device</req1:Type></req1:assignedProduct><req1:assignedProduct><req1:charVal><req1:name>PRX_AT_1060</req1:name><req1:value>Standard</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1070</req1:name><req1:value>null</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1080</req1:name><req1:value>Single Uplink</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1090</req1:name><req1:value>STD-Rmt-Bus Plus</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1200</req1:name><req1:value>Ethernet</req1:value></req1:charVal><req1:identifier><req1:id>80236000000rWPhAAM</req1:id></req1:identifier><req1:billingAccountIdentifier><req1:id>0013600000Nm55YAAR</req1:id></req1:billingAccountIdentifier><req1:customerIdentifier><req1:id>0013600000Nm55YAAR</req1:id></req1:customerIdentifier><req1:relationship><req1:isForAssignedProductIdentifier><req1:id>01t36000001kU0RAAU</req1:id></req1:isForAssignedProductIdentifier><req1:type><req1:value>SPO_AP_ID</req1:value></req1:type></req1:relationship><req1:relationship><req1:isForAssignedProductIdentifier><req1:id>80236000000rWPdAAM</req1:id></req1:isForAssignedProductIdentifier><req1:type><req1:value>PARENT_OFFER_AP_ID</req1:value></req1:type></req1:relationship><req1:offerIdentifier><req1:id>80236000000rWPgAAM</req1:id></req1:offerIdentifier><req1:requestedAction>Add</req1:requestedAction><req1:serviceIdentifier><req1:id></req1:id></req1:serviceIdentifier><req1:name><req1:defaultName>PS IPWAN Port &lt;Product Spec&gt;</req1:defaultName></req1:name><req1:productIdentifier><req1:productSpecificationIdentifier><req1:id>01t36000001kU0RAAU</req1:id></req1:productSpecificationIdentifier></req1:productIdentifier><req1:installationPoint><req1:id>0013600000Nm55YAAR</req1:id></req1:installationPoint><req1:Type>Device</req1:Type></req1:assignedProduct><req1:assignedProduct><req1:charVal><req1:name>PRX_AT_1220</req1:name><req1:value>CBD</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1240</req1:name><req1:value>6</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1080</req1:name><req1:value>Single Uplink</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1250</req1:name><req1:value>Standard</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1200</req1:name><req1:value>Ethernet</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1230</req1:name><req1:value>null</req1:value></req1:charVal><req1:identifier><req1:id>80236000000rWPjAAM</req1:id></req1:identifier><req1:billingAccountIdentifier><req1:id>0013600000Nm55YAAR</req1:id></req1:billingAccountIdentifier><req1:customerIdentifier><req1:id>0013600000Nm55YAAR</req1:id></req1:customerIdentifier><req1:relationship><req1:isForAssignedProductIdentifier><req1:id>01t36000001kTvWAAU</req1:id></req1:isForAssignedProductIdentifier><req1:type><req1:value>SPO_AP_ID</req1:value></req1:type></req1:relationship><req1:relationship><req1:isForAssignedProductIdentifier><req1:id>80236000000rWPdAAM</req1:id></req1:isForAssignedProductIdentifier><req1:type><req1:value>PARENT_OFFER_AP_ID</req1:value></req1:type></req1:relationship><req1:offerIdentifier><req1:id>80236000000rWPiAAM</req1:id></req1:offerIdentifier><req1:requestedAction>Add</req1:requestedAction><req1:serviceIdentifier><req1:id></req1:id></req1:serviceIdentifier><req1:name><req1:defaultName>PS IPWAN Access &lt;Product Spec&gt;</req1:defaultName></req1:name><req1:productIdentifier><req1:productSpecificationIdentifier><req1:id>01t36000001kTvWAAU</req1:id></req1:productSpecificationIdentifier></req1:productIdentifier><req1:installationPoint><req1:id>0013600000Nm55YAAR</req1:id></req1:installationPoint><req1:Type>Device</req1:Type></req1:assignedProduct><req1:assignedProduct><req1:charVal><req1:name>PRX_AT_1260</req1:name><req1:value>Upfront</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1270</req1:name><req1:value>Cisco</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1280</req1:name><req1:value>Cisco</req1:value></req1:charVal><req1:identifier><req1:id>80236000000rWPlAAM</req1:id></req1:identifier><req1:billingAccountIdentifier><req1:id>0013600000Nm55YAAR</req1:id></req1:billingAccountIdentifier><req1:customerIdentifier><req1:id>0013600000Nm55YAAR</req1:id></req1:customerIdentifier><req1:relationship><req1:isForAssignedProductIdentifier><req1:id>01t36000001kTofAAE</req1:id></req1:isForAssignedProductIdentifier><req1:type><req1:value>SPO_AP_ID</req1:value></req1:type></req1:relationship><req1:relationship><req1:isForAssignedProductIdentifier><req1:id>80236000000rWPdAAM</req1:id></req1:isForAssignedProductIdentifier><req1:type><req1:value>PARENT_OFFER_AP_ID</req1:value></req1:type></req1:relationship><req1:offerIdentifier><req1:id>80236000000rWPkAAM</req1:id></req1:offerIdentifier><req1:requestedAction>Add</req1:requestedAction><req1:serviceIdentifier><req1:id></req1:id></req1:serviceIdentifier><req1:name><req1:defaultName>PS IPWAN Connectivity Bundle Router &lt;Product Spec&gt;</req1:defaultName></req1:name><req1:productIdentifier><req1:productSpecificationIdentifier><req1:id>01t36000001kTofAAE</req1:id></req1:productSpecificationIdentifier></req1:productIdentifier><req1:installationPoint><req1:id>0013600000Nm55YAAR</req1:id></req1:installationPoint><req1:Type>Device</req1:Type></req1:assignedProduct><req1:assignedProduct><req1:charVal><req1:name>PRX_AT_1090</req1:name><req1:value>STD-Rmt-Bus Plus</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1290</req1:name><req1:value>Activated</req1:value></req1:charVal><req1:identifier><req1:id>80236000000rWPnAAM</req1:id></req1:identifier><req1:billingAccountIdentifier><req1:id>0013600000Nm55YAAR</req1:id></req1:billingAccountIdentifier><req1:customerIdentifier><req1:id>0013600000Nm55YAAR</req1:id></req1:customerIdentifier><req1:relationship><req1:isForAssignedProductIdentifier><req1:id>01t36000001kTmAAAU</req1:id></req1:isForAssignedProductIdentifier><req1:type><req1:value>SPO_AP_ID</req1:value></req1:type></req1:relationship><req1:relationship><req1:isForAssignedProductIdentifier><req1:id>80236000000rWPdAAM</req1:id></req1:isForAssignedProductIdentifier><req1:type><req1:value>PARENT_OFFER_AP_ID</req1:value></req1:type></req1:relationship><req1:offerIdentifier><req1:id>80236000000rWPmAAM</req1:id></req1:offerIdentifier><req1:requestedAction>Add</req1:requestedAction><req1:serviceIdentifier><req1:id></req1:id></req1:serviceIdentifier><req1:name><req1:defaultName>PS IPWAN Connectivity Bundle Service Assurance &lt;Product Spec&gt;</req1:defaultName></req1:name><req1:productIdentifier><req1:productSpecificationIdentifier><req1:id>01t36000001kTmAAAU</req1:id></req1:productSpecificationIdentifier></req1:productIdentifier><req1:installationPoint><req1:id>0013600000Nm55YAAR</req1:id></req1:installationPoint><req1:Type>Device</req1:Type></req1:assignedProduct><req1:assignedProduct><req1:charVal><req1:name>PRX_AT_1240</req1:name><req1:value>6</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1220</req1:name><req1:value>CBD</req1:value></req1:charVal><req1:charVal><req1:name>PRX_AT_1300</req1:name><req1:value>6</req1:value></req1:charVal><req1:identifier><req1:id>80236000000rWPpAAM</req1:id></req1:identifier><req1:billingAccountIdentifier><req1:id>0013600000Nm55YAAR</req1:id></req1:billingAccountIdentifier><req1:customerIdentifier><req1:id>0013600000Nm55YAAR</req1:id></req1:customerIdentifier><req1:relationship><req1:isForAssignedProductIdentifier><req1:id>01t36000001kTjLAAU</req1:id></req1:isForAssignedProductIdentifier><req1:type><req1:value>SPO_AP_ID</req1:value></req1:type></req1:relationship><req1:relationship><req1:isForAssignedProductIdentifier><req1:id>80236000000rWPdAAM</req1:id></req1:isForAssignedProductIdentifier><req1:type><req1:value>PARENT_OFFER_AP_ID</req1:value></req1:type></req1:relationship><req1:offerIdentifier><req1:id>80236000000rWPoAAM</req1:id></req1:offerIdentifier><req1:requestedAction>Add</req1:requestedAction><req1:serviceIdentifier><req1:id></req1:id></req1:serviceIdentifier><req1:name><req1:defaultName>PS IPWAN Multicast &lt;Product Spec&gt;</req1:defaultName></req1:name><req1:productIdentifier><req1:productSpecificationIdentifier><req1:id>01t36000001kTjLAAU</req1:id></req1:productSpecificationIdentifier></req1:productIdentifier><req1:installationPoint><req1:id>0013600000Nm55YAAR</req1:id></req1:installationPoint><req1:Type>Device</req1:Type></req1:assignedProduct><req1:charVal><req1:name>null</req1:name><req1:value></req1:value></req1:charVal></req1:item><req1:identifier xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc" xmlns="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><req1:id>80136000000AV5wAAG</req1:id></req1:identifier><req1:charVal xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc" xmlns="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><req1:name></req1:name><req1:value></req1:value></req1:charVal><req1:operationalContext xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc" xmlns="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><req1:orderContext><req1:value></req1:value></req1:orderContext></req1:operationalContext></tns:customerOrder><tns:submitReferenceObjectRequest><customer><req1:isAntiMarketing xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc">true
 //           </req1:isAntiMarketing><req1:party xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><req1:organisation><req1:foundationDate>1976-07-10T00:00:00Z</req1:foundationDate><req1:identifier><req1:id></req1:id></req1:identifier><req1:name><req1:printName>Org1</req1:printName></req1:name><req1:legalLanguage><req1:alpha2Code>NL</req1:alpha2Code></req1:legalLanguage></req1:organisation></req1:party><req1:classification xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><req1:classification xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><req1:codeSystem>MarketSubSegment</req1:codeSystem><req1:value>22</req1:value></req1:classification></req1:classification><req1:classification xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><req1:classification xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><req1:codeSystem>PartyType</req1:codeSystem><req1:value>E</req1:value></req1:classification></req1:classification><req1:classification xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><req1:classification xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><req1:codeSystem>SLALevelCode</req1:codeSystem><req1:value>1</req1:value></req1:classification></req1:classification><req1:identifier xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><req1:id>619213560</req1:id><req1:idContext><req1:value>CDBF</req1:value></req1:idContext></req1:identifier></customer><salesChannel><req1:identifier xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><req1:id>Call Center</req1:id></req1:identifier></salesChannel><req1:urbanAddress xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"></req1:urbanAddress><req1:delivery xmlns:req1="urn:v0.requestsubmitcustomerorder.cpcm.objects.bgc"><req1:reference></req1:reference><req1:date></req1:date><req1:requestedDate></req1:requestedDate><req1:address></req1:address><req1:method></req1:method><req1:requestedTime></req1:requestedTime><req1:carrier></req1:carrier><req1:comment></req1:comment><req1:point></req1:point></req1:delivery></tns:submitReferenceObjectRequest></RequestDataSubmitCustomerOrder>'

	static String deeperBookstoreXML = '<?xml version="1.0" encoding="utf-8"?><bookstore><book category="COOKING"><title lang="en">Everyday Italian</title><author><name>Giada De Laurentiis</name><dob>14-02-78</dob><languages><language>English</language><language>German</language></languages></author><year>2005</year><price>30.00</price></book><book category="CHILDREN"><title lang="en">Harry Potter</title><author><name>J K. Rowling</name><dob>11-05-1970</dob><languages><language>English</language><language>Pig Latin</language></languages></author><year>2005</year><price>29.99</price></book><book category="WEB"><title lang="en">XQuery Kick Start</title><author><name>James McGovern</name><dob>09-11-1980</dob><languages><language>English</language><language>Pig Latin</language></languages></author><author><name>Per Bothner</name><dob>01-08-1963</dob><languages><language>English</language></languages></author><author><name>Kurt Cagle</name><dob>11-05-1970</dob><languages><language>English</language></languages></author><author><name>James Linn</name><dob>11-05-1970</dob><languages><language>English</language></languages></author><author><name>Vaidyanathan Nagarajan</name><dob>11-05-1970</dob><languages><language>English</language></languages></author><year>2003</year><price>49.99</price><language>Engrish</language></book><book category="WEB"><title lang="en">Learning XML</title><author>Erik T. Ray</author><year>2003</year><price>39.95</price></book></bookstore>';

	static String MatrixxWallet = '' 
	+'<MtxResponseWallet>'
	+'    <BalanceArray>'
	+'        <MtxBalanceInfoSimple>'
	+'            <ThresholdArray>'
	+'                <MtxThresholdInfo>'
	+'                    <ThresholdId>15</ThresholdId>'
	+'                    <Name>familyAdminThreshold</Name>'
	+'                    <Amount>0.0000</Amount>'
	+'                    <IsPct>false</IsPct>'
	+'                    <IsRecurring>false</IsRecurring>'
	+'                    <IsCreditLimit>true</IsCreditLimit>'
	+'                    <IsCustom>false</IsCustom>'
	+'                    <NotificationState>true</NotificationState>'
	+'                    <Type>Notify_Gross,Notify_BalIncr,Notify_IncrEq</Type>'
	+'                    <GroupNotificationPreference>Use_Group_Setting</GroupNotificationPreference>'
	+'                </MtxThresholdInfo>'
	+'                <MtxThresholdInfo>'
	+'                    <ThresholdId>90</ThresholdId>'
	+'                    <Name>subscriberPersonalizedThreshold</Name>'
	+'                    <Amount>0.0000</Amount>'
	+'                    <IsPct>false</IsPct>'
	+'                    <IsRecurring>false</IsRecurring>'
	+'                    <IsCreditLimit>false</IsCreditLimit>'
	+'                    <IsCustom>false</IsCustom>'
	+'                    <NotificationState>true</NotificationState>'
	+'                    <Type>Notify_Gross,Notify_BalIncr,Notify_IncrEq</Type>'
	+'                    <GroupNotificationPreference>Use_Group_Setting</GroupNotificationPreference>'
	+'                </MtxThresholdInfo>'
	+'            </ThresholdArray>'
	+'            <SimpleBalanceGrantCreditFloorAdjust>grant_amount_plus_balance_amount</SimpleBalanceGrantCreditFloorAdjust>'
	+'            <IsMainBalance>false</IsMainBalance>'
	+'            <ResourceId>2</ResourceId>'
	+'            <Amount>-1000.0000</Amount>'
	+'            <ReservedAmount>0.0000</ReservedAmount>'
	+'            <CreditLimit>0.0000</CreditLimit>'
	+'            <ThresholdLimit>1000.0000</ThresholdLimit>'
	+'            <AvailableAmount>1000.0000</AvailableAmount>'
	+'            <TemplateId>21011</TemplateId>'
	+'            <Name>D1000PO-Domestic-Balance</Name>'
	+'            <ClassId>20008</ClassId>'
	+'            <ClassName>Data</ClassName>'
	+'            <Category>2</Category>'
	+'            <IsPrepaid>true</IsPrepaid>'
	+'            <IsPeriodic>false</IsPeriodic>'
	+'            <IsAggregate>false</IsAggregate>'
	+'            <IsVirtual>false</IsVirtual>'
	+'            <StartTime>2016-09-13T19:39:03.000000Z</StartTime>'
	+'            <EndTime>2016-10-13T19:39:03.000000Z</EndTime>'
	+'            <QuantityUnit>megabytes</QuantityUnit>'
	+'        </MtxBalanceInfoSimple>'
	+'        <MtxBalanceInfoSimple>'
	+'            <ThresholdArray>'
	+'                <MtxThresholdInfo>'
	+'                    <ThresholdId>95</ThresholdId>'
	+'                    <Name>postpaidFamilySpendLimit</Name>'
	+'                    <Amount>1000.0000</Amount>'
	+'                    <IsPct>false</IsPct>'
	+'                    <IsRecurring>false</IsRecurring>'
	+'                    <IsCreditLimit>true</IsCreditLimit>'
	+'                    <IsCustom>false</IsCustom>'
	+'                    <NotificationState>true</NotificationState>'
	+'                    <Type>Notify_Gross,Notify_BalIncr</Type>'
	+'                    <GroupNotificationPreference>Use_Group_Setting</GroupNotificationPreference>'
	+'                </MtxThresholdInfo>'
	+'            </ThresholdArray>'
	+'            <SimpleBalanceGrantCreditFloorAdjust>grant_amount_plus_balance_amount</SimpleBalanceGrantCreditFloorAdjust>'
	+'            <IsMainBalance>false</IsMainBalance>'
	+'            <ResourceId>1</ResourceId>'
	+'            <Amount>42.9800</Amount>'
	+'            <ReservedAmount>0.0000</ReservedAmount>'
	+'            <CreditLimit>1000.0000</CreditLimit>'
	+'            <ThresholdLimit>1000.0000</ThresholdLimit>'
	+'            <AvailableAmount>957.0200</AvailableAmount>'
	+'            <TemplateId>21007</TemplateId>'
	+'            <Name>Postpaid Euro</Name>'
	+'            <ClassId>978</ClassId>'
	+'            <ClassName>Euro</ClassName>'
	+'            <Category>1</Category>'
	+'            <IsPrepaid>false</IsPrepaid>'
	+'            <IsPeriodic>false</IsPeriodic>'
	+'            <IsAggregate>true</IsAggregate>'
	+'            <IsVirtual>false</IsVirtual>'
	+'            <QuantityUnit>none</QuantityUnit>'
	+'        </MtxBalanceInfoSimple>'
	+'        <MtxBalanceInfoSimple>'
	+'            <ThresholdArray>'
	+'                <MtxThresholdInfo>'
	+'                    <ThresholdId>11</ThresholdId>'
	+'                    <Name>familyAdminThreshold</Name>'
	+'                    <Amount>0.0000</Amount>'
	+'                    <IsPct>false</IsPct>'
	+'                    <IsRecurring>false</IsRecurring>'
	+'                    <IsCreditLimit>true</IsCreditLimit>'
	+'                    <IsCustom>false</IsCustom>'
	+'                    <NotificationState>true</NotificationState>'
	+'                    <Type>Notify_Gross,Notify_BalIncr,Notify_BalDecr,Notify_IncrEq,Notify_DecrEq</Type>'
	+'                    <GroupNotificationPreference>Use_Group_Setting</GroupNotificationPreference>'
	+'                </MtxThresholdInfo>'
	+'                <MtxThresholdInfo>'
	+'                    <ThresholdId>80</ThresholdId>'
	+'                    <Name>subscriberPersonalizedThreshold</Name>'
	+'                    <Amount>0.0000</Amount>'
	+'                    <IsPct>false</IsPct>'
	+'                    <IsRecurring>false</IsRecurring>'
	+'                    <IsCreditLimit>false</IsCreditLimit>'
	+'                    <IsCustom>false</IsCustom>'
	+'                    <NotificationState>true</NotificationState>'
	+'                    <Type>Notify_Gross,Notify_BalIncr,Notify_BalDecr,Notify_IncrEq,Notify_DecrEq</Type>'
	+'                    <GroupNotificationPreference>Use_Group_Setting</GroupNotificationPreference>'
	+'                </MtxThresholdInfo>'
	+'            </ThresholdArray>'
	+'            <SimpleBalanceGrantCreditFloorAdjust>grant_amount_plus_balance_amount</SimpleBalanceGrantCreditFloorAdjust>'
	+'            <IsMainBalance>false</IsMainBalance>'
	+'            <ResourceId>3</ResourceId>'
	+'            <Amount>-500.0000</Amount>'
	+'            <ReservedAmount>0.0000</ReservedAmount>'
	+'            <CreditLimit>0.0000</CreditLimit>'
	+'            <ThresholdLimit>500.0000</ThresholdLimit>'
	+'            <AvailableAmount>500.0000</AvailableAmount>'
	+'            <TemplateId>21008</TemplateId>'
	+'            <Name>V500PO-MTX-Balance</Name>'
	+'            <ClassId>20006</ClassId>'
	+'            <ClassName>Voice</ClassName>'
	+'            <Category>2</Category>'
	+'            <IsPrepaid>true</IsPrepaid>'
	+'            <IsPeriodic>false</IsPeriodic>'
	+'            <IsAggregate>false</IsAggregate>'
	+'            <IsVirtual>false</IsVirtual>'
	+'            <StartTime>2016-09-13T19:39:03.000000Z</StartTime>'
	+'            <EndTime>2016-10-13T19:39:03.000000Z</EndTime>'
	+'            <QuantityUnit>minutes</QuantityUnit>'
	+'        </MtxBalanceInfoSimple>'
	+'        <MtxBalanceInfoPeriodic>'
	+'            <Period>4</Period>'
	+'            <IntervalCount>3</IntervalCount>'
	+'            <IsOnDemand>false</IsOnDemand>'
	+'            <IsRenewable>false</IsRenewable>'
	+'            <BalancePeriodArray>'
	+'                <MtxBalancePeriodInfo>'
	+'                    <Amount>-4915.2000</Amount>'
	+'                    <StartTime>2016-09-13T00:00:00.000000Z</StartTime>'
	+'                    <EndTime>2016-10-13T00:00:00.000000Z</EndTime>'
	+'                    <ThresholdLimit>4915.2000</ThresholdLimit>'
	+'                    <ReservedAmount>0.0000</ReservedAmount>'
	+'                    <IntervalId>1</IntervalId>'
	+'                </MtxBalancePeriodInfo>'
	+'                <MtxBalancePeriodInfo>'
	+'                    <Amount>0.0000</Amount>'
	+'                    <StartTime>2016-10-13T00:00:00.000000Z</StartTime>'
	+'                    <EndTime>2016-11-13T00:00:00.000000Z</EndTime>'
	+'                    <ThresholdLimit>0.0000</ThresholdLimit>'
	+'                    <ReservedAmount>0.0000</ReservedAmount>'
	+'                    <IntervalId>2</IntervalId>'
	+'                </MtxBalancePeriodInfo>'
	+'                <MtxBalancePeriodInfo>'
	+'                    <Amount>0.0000</Amount>'
	+'                    <StartTime>2016-11-13T00:00:00.000000Z</StartTime>'
	+'                    <EndTime>2016-12-13T00:00:00.000000Z</EndTime>'
	+'                    <ThresholdLimit>0.0000</ThresholdLimit>'
	+'                    <ReservedAmount>0.0000</ReservedAmount>'
	+'                    <IntervalId>3</IntervalId>'
	+'                </MtxBalancePeriodInfo>'
	+'            </BalancePeriodArray>'
	+'            <ThresholdArray>'
	+'                <MtxThresholdInfo>'
	+'                    <ThresholdId>161</ThresholdId>'
	+'                    <Name>subscriberPersonalizedThreshold</Name>'
	+'                    <Amount>-500.0000</Amount>'
	+'                    <IsPct>false</IsPct>'
	+'                    <IsRecurring>false</IsRecurring>'
	+'                    <IsCreditLimit>false</IsCreditLimit>'
	+'                    <IsCustom>false</IsCustom>'
	+'                    <NotificationState>true</NotificationState>'
	+'                    <Type>Notify_Gross,Notify_BalIncr,Notify_IncrEq</Type>'
	+'                    <GroupNotificationPreference>Use_Group_Setting</GroupNotificationPreference>'
	+'                </MtxThresholdInfo>'
	+'                <MtxThresholdInfo>'
	+'                    <ThresholdId>1030</ThresholdId>'
	+'                    <Name>bal</Name>'
	+'                    <Amount>0.0000</Amount>'
	+'                    <IsPct>false</IsPct>'
	+'                    <IsRecurring>false</IsRecurring>'
	+'                    <IsCreditLimit>true</IsCreditLimit>'
	+'                    <IsCustom>false</IsCustom>'
	+'                    <NotificationState>true</NotificationState>'
	+'                    <Type></Type>'
	+'                    <GroupNotificationPreference>Use_Group_Setting</GroupNotificationPreference>'
	+'                </MtxThresholdInfo>'
	+'            </ThresholdArray>'
	+'            <PeriodInterval>1</PeriodInterval>'
	+'            <IsBillingCyclePeriodic>false</IsBillingCyclePeriodic>'
	+'            <CycleGrantAmount>1843.2000</CycleGrantAmount>'
	+'            <PeriodicBalanceGrantCreditFloorAdjust>actual_grant_amount</PeriodicBalanceGrantCreditFloorAdjust>'
	+'            <PeriodicBalanceForfeitureCreditFloorAdjust>grant_amount</PeriodicBalanceForfeitureCreditFloorAdjust>'
	+'            <ResourceId>4</ResourceId>'
	+'            <Amount>-4915.2000</Amount>'
	+'            <ReservedAmount>0.0000</ReservedAmount>'
	+'            <CreditLimit>0.0000</CreditLimit>'
	+'            <ThresholdLimit>4915.2000</ThresholdLimit>'
	+'            <AvailableAmount>4915.2000</AvailableAmount>'
	+'            <TemplateId>21055</TemplateId>'
	+'            <Name>Data</Name>'
	+'            <ClassId>20008</ClassId>'
	+'            <ClassName>Data</ClassName>'
	+'            <Category>2</Category>'
	+'            <IsPrepaid>true</IsPrepaid>'
	+'            <IsPeriodic>true</IsPeriodic>'
	+'            <IsAggregate>false</IsAggregate>'
	+'            <IsVirtual>false</IsVirtual>'
	+'            <StartTime>2016-09-13T00:00:00.000000Z</StartTime>'
	+'            <EndTime>2016-10-13T00:00:00.000000Z</EndTime>'
	+'            <QuantityUnit>megabytes</QuantityUnit>'
	+'        </MtxBalanceInfoPeriodic>'
	+'        <MtxBalanceInfoPeriodic>'
	+'            <Period>4</Period>'
	+'            <IntervalCount>3</IntervalCount>'
	+'            <IsOnDemand>false</IsOnDemand>'
	+'            <IsRenewable>false</IsRenewable>'
	+'            <BalancePeriodArray>'
	+'                <MtxBalancePeriodInfo>'
	+'                    <Amount>-5120.0000</Amount>'
	+'                    <StartTime>2016-09-13T00:00:00.000000Z</StartTime>'
	+'                    <EndTime>2016-10-13T00:00:00.000000Z</EndTime>'
	+'                    <ThresholdLimit>5120.0000</ThresholdLimit>'
	+'                    <ReservedAmount>0.0000</ReservedAmount>'
	+'                    <IntervalId>1</IntervalId>'
	+'                </MtxBalancePeriodInfo>'
	+'                <MtxBalancePeriodInfo>'
	+'                    <Amount>0.0000</Amount>'
	+'                    <StartTime>2016-10-13T00:00:00.000000Z</StartTime>'
	+'                    <EndTime>2016-11-13T00:00:00.000000Z</EndTime>'
	+'                    <ThresholdLimit>0.0000</ThresholdLimit>'
	+'                    <ReservedAmount>0.0000</ReservedAmount>'
	+'                    <IntervalId>2</IntervalId>'
	+'                </MtxBalancePeriodInfo>'
	+'                <MtxBalancePeriodInfo>'
	+'                    <Amount>0.0000</Amount>'
	+'                    <StartTime>2016-11-13T00:00:00.000000Z</StartTime>'
	+'                    <EndTime>2016-12-13T00:00:00.000000Z</EndTime>'
	+'                    <ThresholdLimit>0.0000</ThresholdLimit>'
	+'                    <ReservedAmount>0.0000</ReservedAmount>'
	+'                    <IntervalId>3</IntervalId>'
	+'                </MtxBalancePeriodInfo>'
	+'            </BalancePeriodArray>'
	+'            <ThresholdArray>'
	+'                <MtxThresholdInfo>'
	+'                    <ThresholdId>161</ThresholdId>'
	+'                    <Name>subscriberPersonalizedThreshold</Name>'
	+'                    <Amount>-500.0000</Amount>'
	+'                    <IsPct>false</IsPct>'
	+'                    <IsRecurring>false</IsRecurring>'
	+'                    <IsCreditLimit>false</IsCreditLimit>'
	+'                    <IsCustom>false</IsCustom>'
	+'                    <NotificationState>true</NotificationState>'
	+'                    <Type>Notify_Gross,Notify_BalIncr,Notify_IncrEq</Type>'
	+'                    <GroupNotificationPreference>Use_Group_Setting</GroupNotificationPreference>'
	+'                </MtxThresholdInfo>'
	+'                <MtxThresholdInfo>'
	+'                    <ThresholdId>1030</ThresholdId>'
	+'                    <Name>bal</Name>'
	+'                    <Amount>0.0000</Amount>'
	+'                    <IsPct>false</IsPct>'
	+'                    <IsRecurring>false</IsRecurring>'
	+'                    <IsCreditLimit>true</IsCreditLimit>'
	+'                    <IsCustom>false</IsCustom>'
	+'                    <NotificationState>true</NotificationState>'
	+'                    <Type></Type>'
	+'                    <GroupNotificationPreference>Use_Group_Setting</GroupNotificationPreference>'
	+'                </MtxThresholdInfo>'
	+'            </ThresholdArray>'
	+'            <PeriodInterval>1</PeriodInterval>'
	+'            <IsBillingCyclePeriodic>false</IsBillingCyclePeriodic>'
	+'            <CycleGrantAmount>5120.0000</CycleGrantAmount>'
	+'            <PeriodicBalanceGrantCreditFloorAdjust>actual_grant_amount</PeriodicBalanceGrantCreditFloorAdjust>'
	+'            <PeriodicBalanceForfeitureCreditFloorAdjust>grant_amount</PeriodicBalanceForfeitureCreditFloorAdjust>'
	+'            <ResourceId>5</ResourceId>'
	+'            <Amount>-5120.0000</Amount>'
	+'            <ReservedAmount>0.0000</ReservedAmount>'
	+'            <CreditLimit>0.0000</CreditLimit>'
	+'            <ThresholdLimit>5120.0000</ThresholdLimit>'
	+'            <AvailableAmount>5120.0000</AvailableAmount>'
	+'            <TemplateId>21055</TemplateId>'
	+'            <Name>Data</Name>'
	+'            <ClassId>20008</ClassId>'
	+'            <ClassName>Data</ClassName>'
	+'            <Category>2</Category>'
	+'            <IsPrepaid>true</IsPrepaid>'
	+'            <IsPeriodic>true</IsPeriodic>'
	+'            <IsAggregate>false</IsAggregate>'
	+'            <IsVirtual>false</IsVirtual>'
	+'            <StartTime>2016-09-13T00:00:00.000000Z</StartTime>'
	+'            <EndTime>2016-10-13T00:00:00.000000Z</EndTime>'
	+'            <QuantityUnit>megabytes</QuantityUnit>'
	+'        </MtxBalanceInfoPeriodic>'
	+'        <MtxBalanceInfoPeriodic>'
	+'            <Period>4</Period>'
	+'            <IntervalCount>3</IntervalCount>'
	+'            <IsOnDemand>false</IsOnDemand>'
	+'            <IsRenewable>false</IsRenewable>'
	+'            <BalancePeriodArray>'
	+'                <MtxBalancePeriodInfo>'
	+'                    <Amount>-1000.0000</Amount>'
	+'                    <StartTime>2016-09-13T00:00:00.000000Z</StartTime>'
	+'                    <EndTime>2016-10-13T00:00:00.000000Z</EndTime>'
	+'                    <ThresholdLimit>1000.0000</ThresholdLimit>'
	+'                    <ReservedAmount>0.0000</ReservedAmount>'
	+'                    <IntervalId>1</IntervalId>'
	+'                </MtxBalancePeriodInfo>'
	+'                <MtxBalancePeriodInfo>'
	+'                    <Amount>0.0000</Amount>'
	+'                    <StartTime>2016-10-13T00:00:00.000000Z</StartTime>'
	+'                    <EndTime>2016-11-13T00:00:00.000000Z</EndTime>'
	+'                    <ThresholdLimit>0.0000</ThresholdLimit>'
	+'                    <ReservedAmount>0.0000</ReservedAmount>'
	+'                    <IntervalId>2</IntervalId>'
	+'                </MtxBalancePeriodInfo>'
	+'                <MtxBalancePeriodInfo>'
	+'                    <Amount>0.0000</Amount>'
	+'                    <StartTime>2016-11-13T00:00:00.000000Z</StartTime>'
	+'                    <EndTime>2016-12-13T00:00:00.000000Z</EndTime>'
	+'                    <ThresholdLimit>0.0000</ThresholdLimit>'
	+'                    <ReservedAmount>0.0000</ReservedAmount>'
	+'                    <IntervalId>3</IntervalId>'
	+'                </MtxBalancePeriodInfo>'
	+'            </BalancePeriodArray>'
	+'            <ThresholdArray>'
	+'                <MtxThresholdInfo>'
	+'                    <ThresholdId>1003</ThresholdId>'
	+'                    <Name>bal</Name>'
	+'                    <Amount>0.0000</Amount>'
	+'                    <IsPct>false</IsPct>'
	+'                    <IsRecurring>false</IsRecurring>'
	+'                    <IsCreditLimit>true</IsCreditLimit>'
	+'                    <IsCustom>false</IsCustom>'
	+'                    <NotificationState>true</NotificationState>'
	+'                    <Type></Type>'
	+'                    <GroupNotificationPreference>Use_Group_Setting</GroupNotificationPreference>'
	+'                </MtxThresholdInfo>'
	+'            </ThresholdArray>'
	+'            <PeriodInterval>1</PeriodInterval>'
	+'            <IsBillingCyclePeriodic>false</IsBillingCyclePeriodic>'
	+'            <CycleGrantAmount>1000.0000</CycleGrantAmount>'
	+'            <PeriodicBalanceGrantCreditFloorAdjust>actual_grant_amount</PeriodicBalanceGrantCreditFloorAdjust>'
	+'            <PeriodicBalanceForfeitureCreditFloorAdjust>grant_amount</PeriodicBalanceForfeitureCreditFloorAdjust>'
	+'            <ResourceId>6</ResourceId>'
	+'            <Amount>-1000.0000</Amount>'
	+'            <ReservedAmount>0.0000</ReservedAmount>'
	+'            <CreditLimit>0.0000</CreditLimit>'
	+'            <ThresholdLimit>1000.0000</ThresholdLimit>'
	+'            <AvailableAmount>1000.0000</AvailableAmount>'
	+'            <TemplateId>21056</TemplateId>'
	+'            <Name>Voice</Name>'
	+'            <ClassId>20006</ClassId>'
	+'            <ClassName>Voice</ClassName>'
	+'            <Category>2</Category>'
	+'            <IsPrepaid>true</IsPrepaid>'
	+'            <IsPeriodic>true</IsPeriodic>'
	+'            <IsAggregate>false</IsAggregate>'
	+'            <IsVirtual>false</IsVirtual>'
	+'            <StartTime>2016-09-13T00:00:00.000000Z</StartTime>'
	+'            <EndTime>2016-10-13T00:00:00.000000Z</EndTime>'
	+'            <QuantityUnit>minutes</QuantityUnit>'
	+'        </MtxBalanceInfoPeriodic>'
	+'        <MtxBalanceInfoPeriodic>'
	+'            <Period>4</Period>'
	+'            <IntervalCount>3</IntervalCount>'
	+'            <IsOnDemand>false</IsOnDemand>'
	+'            <IsRenewable>false</IsRenewable>'
	+'            <BalancePeriodArray>'
	+'                <MtxBalancePeriodInfo>'
	+'                    <Amount>-999999999.0000</Amount>'
	+'                    <StartTime>2016-09-13T00:00:00.000000Z</StartTime>'
	+'                    <EndTime>2016-10-13T00:00:00.000000Z</EndTime>'
	+'                    <ThresholdLimit>999999999.0000</ThresholdLimit>'
	+'                    <ReservedAmount>0.0000</ReservedAmount>'
	+'                    <IntervalId>1</IntervalId>'
	+'                </MtxBalancePeriodInfo>'
	+'                <MtxBalancePeriodInfo>'
	+'                    <Amount>0.0000</Amount>'
	+'                    <StartTime>2016-10-13T00:00:00.000000Z</StartTime>'
	+'                    <EndTime>2016-11-13T00:00:00.000000Z</EndTime>'
	+'                    <ThresholdLimit>0.0000</ThresholdLimit>'
	+'                    <ReservedAmount>0.0000</ReservedAmount>'
	+'                    <IntervalId>2</IntervalId>'
	+'                </MtxBalancePeriodInfo>'
	+'                <MtxBalancePeriodInfo>'
	+'                    <Amount>0.0000</Amount>'
	+'                    <StartTime>2016-11-13T00:00:00.000000Z</StartTime>'
	+'                    <EndTime>2016-12-13T00:00:00.000000Z</EndTime>'
	+'                    <ThresholdLimit>0.0000</ThresholdLimit>'
	+'                    <ReservedAmount>0.0000</ReservedAmount>'
	+'                    <IntervalId>3</IntervalId>'
	+'                </MtxBalancePeriodInfo>'
	+'            </BalancePeriodArray>'
	+'            <ThresholdArray>'
	+'                <MtxThresholdInfo>'
	+'                    <ThresholdId>1013</ThresholdId>'
	+'                    <Name>bal</Name>'
	+'                    <Amount>0.0000</Amount>'
	+'                    <IsPct>false</IsPct>'
	+'                    <IsRecurring>false</IsRecurring>'
	+'                    <IsCreditLimit>true</IsCreditLimit>'
	+'                    <IsCustom>false</IsCustom>'
	+'                    <NotificationState>true</NotificationState>'
	+'                    <Type></Type>'
	+'                    <GroupNotificationPreference>Use_Group_Setting</GroupNotificationPreference>'
	+'                </MtxThresholdInfo>'
	+'            </ThresholdArray>'
	+'            <PeriodInterval>1</PeriodInterval>'
	+'            <IsBillingCyclePeriodic>false</IsBillingCyclePeriodic>'
	+'            <CycleGrantAmount>999999999.0000</CycleGrantAmount>'
	+'            <PeriodicBalanceGrantCreditFloorAdjust>actual_grant_amount</PeriodicBalanceGrantCreditFloorAdjust>'
	+'            <PeriodicBalanceForfeitureCreditFloorAdjust>grant_amount</PeriodicBalanceForfeitureCreditFloorAdjust>'
	+'            <ResourceId>7</ResourceId>'
	+'            <Amount>-999999999.0000</Amount>'
	+'            <ReservedAmount>0.0000</ReservedAmount>'
	+'            <CreditLimit>0.0000</CreditLimit>'
	+'            <ThresholdLimit>999999999.0000</ThresholdLimit>'
	+'            <AvailableAmount>999999999.0000</AvailableAmount>'
	+'            <TemplateId>21057</TemplateId>'
	+'            <Name>Text</Name>'
	+'            <ClassId>20007</ClassId>'
	+'            <ClassName>Messaging</ClassName>'
	+'            <Category>2</Category>'
	+'            <IsPrepaid>true</IsPrepaid>'
	+'            <IsPeriodic>true</IsPeriodic>'
	+'            <IsAggregate>false</IsAggregate>'
	+'            <IsVirtual>false</IsVirtual>'
	+'            <StartTime>2016-09-13T00:00:00.000000Z</StartTime>'
	+'            <EndTime>2016-10-13T00:00:00.000000Z</EndTime>'
	+'            <QuantityUnit>none</QuantityUnit>'
	+'        </MtxBalanceInfoPeriodic>'
	+'    </BalanceArray>'
	+'    <BillingCycle>'
	+'        <MtxBillingCycleInfo>'
	+'            <BillingCycleId>300</BillingCycleId>'
	+'            <Period>4</Period>'
	+'            <PeriodInterval>1</PeriodInterval>'
	+'            <DatePolicy>2</DatePolicy>'
	+'            <CurrentPeriodStartTime>2016-09-01T00:00:00.000000Z</CurrentPeriodStartTime>'
	+'            <CurrentPeriodEndTime>2016-10-01T00:00:00.000000Z</CurrentPeriodEndTime>'
	+'            <CurrentPeriodDuration>30</CurrentPeriodDuration>'
	+'            <CurrentPeriodOffset>25</CurrentPeriodOffset>'
	+'        </MtxBillingCycleInfo>'
	+'    </BillingCycle>'
	+'    <Result>0</Result>'
	+'    <ResultText>OK</ResultText>'
	+'</MtxResponseWallet>';


	@isTest
	static void bookstoreTest() {
		String path2 = '/bookstore/book[1]/title';
		//String path2 = '/bookstore/book/title';

		Dom.Document doc = new Dom.Document();
		doc.load(deeperBookstoreXML);
		Map<String, Dom.XmlNode> foundNodes = XMLHelperFunctions.getXPath(path2, doc);

		System.assertEquals(1, foundNodes.keySet().size());			
	}


	/*
	 * Not sure if this is desired behavior or not of XPath.
	 * TODO: Investigate
	 */
	//static void bookstoreTest() {
	//	String path2 = '/bookstore/book/title';

	//	Dom.Document doc = new Dom.Document();
	//	doc.load(deeperBookstoreXML);
	//	Map<String, Dom.XmlNode> foundNodes = XMLHelperFunctions.getXPath(path2, doc);

	//	System.assertEquals(4, foundNodes.keySet().size());			
	//}


	@isTest
	static void testAbsolutePathNoIndexes() {
		String path = '/bookstore/book/title';

		Map<String, Dom.XmlNode> smashedNodes = XMLHelperFunctions.smashXML(deeperBookstoreXML, path);
		
		//Map<String, Dom.XmlNode> foundNodes = XMLHelperFunctions.getAllNodes(smashedNodes, path, false);
		//System.assertEquals(4, foundNodes.keySet().size());		

	}

	@isTest
	static void singleElementTest() {
		String path = '/bookstore/book[0]/title';

		Map<String, Dom.XmlNode> els = XMLHelperFunctions.getXPath(path, bookstoreXML);
		System.debug(els);
		System.Assert(els.get(path).getText().equals('Everyday Italian'));
	}

	@isTest
	static void getAllAuthorLanguages() {
		String langSearch = '//languages/language';

		Map<String, Dom.XmlNode> els = XMLhelperFunctions.getXPath(langSearch, deeperBookstoreXML);
		for (String k : els.keySet()){
			System.assert(k.contains(langSearch.removeStart('//')));
		}

	}

	@isTest
	static void getLanguageUnderBook() {
		String path = '/bookstore/book/*/languages';
		Map<String, Dom.XmlNode> els = XMLHelperFunctions.getXPath(path, deeperBookstoreXML);
	
		System.debug('els is: ' + els);
		System.assertNotEquals(0, els.keySet().size(), 'Returned map must contain something.');
		for (String k : els.keySet()) {
			System.assert(k.contains('/bookstore/book') && k.contains('language'));
			System.debug(k);
		}
	}

	// FAILING 
	@isTest
	static void testAbsurdPaths() {
		// So this should return all language nodes that have book as an ancestor?
		String absurdPath1 = '//book//language'; 
		
		// This should get all the languages found anywhere.
		String absurdPath2 = '/bookstore/*//language';

		Map<String, Dom.XmlNode> els = XMLHelperFunctions.getXPath(absurdPath1, deeperBookstoreXML);
		//System.assert(els.keySet().size() == 10, 'Wrong number of languages returned');

		Map<String, Dom.XmlNode> els2 = XMLHelperFunctions.getXPath(absurdPath2, deeperBookstoreXML); 
		//System.assert(els2.keySet().size() == 10, 'Wrong number of languages returned');		
	}

	// FAILING NOT IMPLEMENTED
	@isTest
	static void testSearchInternalText() {
		// This should return all titles with text=Everday Italian. 
		String path = '/boostore/book/title[Everyday Italian]';
		Map<String, Dom.XmlNode> els = XMLHelperFunctions.getXPath(path, deeperBookstoreXML);
		//System.assert(els.keySet().size() == 1, 'Should have found one node');
	}

	// FAILING NOT IMPLEMENTED
	@isTest
	static void testSearchAttrib() {
		// This should return all books for category WEB.
		String path = '/bookstore/book[@category="WEB"]/';
	
		Map<String, Dom.XmlNode> els = XMLHelperFunctions.getXPath(path, deeperBookstoreXML);
		//System.assert(els.keySet().size() == 2, 'Should have found two nodes');	
	}

	// FAILING NOT IMPLEMENTED
	@isTest
	static void testSearchCondition() {
		// This should return any titles that are in books where the child element price > 35.
		String path = '/bookstore/book[price>35.00]/title';

		Map<String, Dom.XmlNode> els = XMLHelperFunctions.getXPath(path, deeperBookstoreXML);
		//System.assert(els.keySet().size() == 1, 'Should have found one node');	
	}

	@isTest
	static void testMatrixxWallet() {
		String path = '/MtxResponseWallet/BalanceArray/MtxBalanceInfoSimple[0]';
		Map<String, Dom.XmlNode> els = XMLHelperFunctions.getXPath(path, MatrixxWallet);

		//Map<String, Dom.XmlNode> smashed = XMLHelperFunctions.smashXML(path, els.get(path));

		//for (String p : smashed.keySet()) {
		//	System.debug(p + ' : ' + smashed.get(p).getText().remove('\n')); // Remove newlines since this is a pretty xml string.
		//}
		//System.debug(els);
	}

	@isTest
	static void testFirstNodeWithoutIndex() {
		// This should be the all MtxThresholdInfo under The first MatxBalanceInfoPeriodic/ThresholdArray
		String path1 = '/MtxResponseWallet/BalanceArray/MtxBalanceInfoPeriodic[0]/ThresholdArray/MtxThresholdInfo';
		// This should be all elements that match this path wile ignoring the index. 
		String path2 = '/MtxResponseWallet/BalanceArray/MtxBalanceInfoPeriodic/ThresholdArray/MtxThresholdInfo';
		// This should be the first entry in the above examples. 
		String path3 = '/MtxResponseWallet/BalanceArray/MtxBalanceInfoPeriodic[0]/ThresholdArray/MtxThresholdInfo[0]';

		Map<String, Dom.XmlNode> els1 = XMLHelperFunctions.getXPath(path1, MatrixxWallet);
		Map<String, Dom.XmlNode> els2 = XMLHelperFunctions.getXPath(path2, MatrixxWallet);
		Map<String, Dom.XmlNode> els3 = XMLHelperFunctions.getXPath(path3, MatrixxWallet);

		System.debug('Printing els1: \n ========================================================================');
		printNodePath(els1);

		System.debug('Printing els2: \n ========================================================================');
		printNodePath(els2);

		System.debug('Printing els3: \n ========================================================================');
		printNodePath(els3);
		System.debug('Printing els3 keySet: ' + els3.keySet());


		//System.AssertEquals(els3.get(path3), els1.get(path3));
		//System.AssertEquals(els3.get(path3), els2.get(path3));

	}

	static void printNodePath(Map<String, Dom.XmlNode> els) {
		for (String s : els.keySet()) {
			System.debug(s + ' : ' + getLineage(els.get(s)));
		}
	}

	static string getLineage(Dom.XmlNode node) {
		if (node == Null) return '';
		return getLineage(node.getParent()) + '/' + node.getName(); 
	}

	//@isTest
	//static void testReleativeLookupByNode() {


	//}

	// Tests to add:
	//   /bookstore/book/title
	//   //book/author[3]

	// Need to add a much more complex xml to work with for further corner case testing.

}