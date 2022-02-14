// import { LightningElement } from 'lwc';
import { LightningElement, api, track }     from "lwc";
import dcOfferConfig                        from "vlocity_cmt/dcOfferConfig";

export default class deOfferConfig extends dcOfferConfig {
  configureOfferPreHook(input) {
    const offerIndex = this.digitalCommerceSDK.offersInConfiguration.findIndex(
      (offerConfiguration) => {
        return offerConfiguration.offerCode === input.offerCode;
      }
    );

    delete this.digitalCommerceSDK.offersInConfiguration[offerIndex].contextKey;
    console.log(
      "@@@",
      this.digitalCommerceSDK.offersInConfiguration[offerIndex]
    );

    return Promise.resolve(input);
  }
}