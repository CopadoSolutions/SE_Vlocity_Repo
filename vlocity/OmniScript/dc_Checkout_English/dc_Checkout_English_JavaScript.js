let digitalCommerceSDK = null;
baseCtrl.prototype.$scope.getSDKInstance = function() {
    if(digitalCommerceSDK){ 
      return digitalCommerceSDK;
    }
    let digitalCommerceConfig = window.VlocitySDK.digitalcommerce.createConfigForAnonymousUser();
    digitalCommerceSDK = window.VlocitySDK.digitalcommerce.getInstance(digitalCommerceConfig);
     digitalCommerceSDK.checkoutSDKNodeServerUrl = "https://dc-checkout-sdk.herokuapp.com";
    return digitalCommerceSDK;
}