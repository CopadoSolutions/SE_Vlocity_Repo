global class VDOLoyaltyAuthProvider extends Auth.AuthProviderPluginClass {
               
               public String redirectUrl; // use this URL for the endpoint that the authentication provider calls back to for configuration
               private String key;
               private String secret;
               private String authUrl;    // application redirection to the Concur website for authentication and authorization
               private String accessTokenUrl; // uri to get the new access token from concur  using the GET verb
               private String customMetadataTypeApiName; // api name for the custom metadata type created for this auth provider
               private String userAPIUrl; // api url to access the user in concur
               private String userAPIVersionUrl; // version of the user api url to access data from concur
               
       
               global String getCustomMetadataType() {
                   return 'Vlocity_Loyalty_Authentication__mdt';
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
                   key = authProviderConfiguration.get('Consumer_Key__c');
                   secret = authProviderConfiguration.get('Consumer_Secret__c');
                   accessTokenUrl = authProviderConfiguration.get('Access_Token_Url__c');
                   
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
                     Map<String,String> provMap = new Map<String,String>();                    
                     return new Auth.UserData('0000', 'Admin', 'User', 'Admin User', 'adminuser@loyalty.auth',
                          'what', null, null, 'Concur', null, provMap);
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