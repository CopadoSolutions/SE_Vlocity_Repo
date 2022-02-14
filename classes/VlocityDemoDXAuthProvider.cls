global class VlocityDemoDXAuthProvider extends Auth.AuthProviderPluginClass {
               
               public String redirectUrl; // use this URL for the endpoint that the authentication provider calls back to for configuration
               private String key;
               private String secret;
               private String authUrl;    // application redirection to the Concur website for authentication and authorization
               private String accessTokenUrl; // uri to get the new access token from concur  using the GET verb
               private String customMetadataTypeApiName; // api name for the custom metadata type created for this auth provider
               private String userAPIUrl; // api url to access the user in concur
               private String userAPIVersionUrl; // version of the user api url to access data from concur
               
       
               global String getCustomMetadataType() {
                   return 'VlocityDemoDX_Authentication__mdt';
               }
       
               global PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate) {
                   authUrl = authProviderConfiguration.get('Auth_Url__c');
                   key = authProviderConfiguration.get('Key__c');
                   //Here the developer can build up a request of some sort
                   //Ultimately they’ll return a URL where we will redirect the user
                   String url = authUrl + '?client_id='+ key +'&scope=USER,EXPRPT,LIST&redirect_uri='+ redirectUrl + '&state=' + stateToPropagate;
                   return new PageReference(url);
                }
        
               global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) {
                   //Here, the developer will get the callback with actual protocol.  
                   //Their responsibility is to return a new object called AuthProviderToken
                   //This will contain an optional accessToken and refreshToken
                   
                   
                   key = authProviderConfiguration.get('Client_Id__c');
                   secret = authProviderConfiguration.get('Secret__c');
                   accessTokenUrl = authProviderConfiguration.get('Token_Endpoint__c');
                   
                   Map<String,String> queryParams = state.queryParameters;
                   String code = queryParams.get('code');
                   String sfdcState = queryParams.get('state');
                   
                   HttpRequest req = new HttpRequest();
                   String url = accessTokenUrl+'?grant_type=client_credentials&client_id=' + key + '&client_secret=' + secret;
                   req.setEndpoint(url);
                   req.setHeader('Content-Type','application/xml');
                   req.setHeader('Accept', 'application/vnd.stellar-v1+json');
                   req.setMethod('POST');
                   
                   Http http = new Http();
                   HTTPResponse res = http.send(req);
                   Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                   
                   return new Auth.AuthProviderTokenResponse('Loyalty', (String)result.get('access_token'), 'refreshToken', sfdcState);
                }
    
    
                 global Auth.UserData  getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) { 
                     //Here the developer is responsible for constructing an Auth.UserData object 
                     
                     //UserData(identifier, firstName, lastName, fullName, email, link, userName, locale, provider, siteLoginUrl, attributeMap)
                     //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_Auth_UserData.htm                  
                     Map<String,String> claims = new Map<String,String>();                    
                     return new Auth.UserData('8675309', 'Mary', 'Sanchez', 'Mary Sanchez', 'msanchez-vdo@vlocity-de-codo.com',
                          'what', null, null, 'VlocityDemoDX', null, claims);
                }
                
                private String getTokenValueFromResponse(String response, String token, String ns) {
                    Dom.Document docx = new Dom.Document();
                    docx.load(response);
                    String ret = null;

                    dom.XmlNode xroot = docx.getrootelement() ;
                    if(xroot != null){
                       ret = xroot.getChildElement(token, ns).getText();
                    }
                    return ret;
                }  
    
}