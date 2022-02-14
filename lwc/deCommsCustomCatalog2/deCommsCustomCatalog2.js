import { LightningElement } from 'lwc';
import dcCatalog            from "vlocity_cmt/dcCatalog";
import catalogTemplate      from "./deCommsCustomCatalog2.html";
//import myResource from '@salesforce/resourceUrl/dc_assets';

export default class DeCommsCustomCatalog2 extends dcCatalog
{
   
     fetchCatalogsPreHook(catalogs) 
     {
        const dcAssets = "/resource/vlocity_cmt__dc_assets"
        const myCatalogDetails = {
           name: "Demo-Eng",
           catalogCode: "de-eng-cat",  
           
           img1: dcAssets + "/images/mobile.svg",
           img2: dcAssets + "/images/mobile_white.svg",

           childCatalogs: {
             totalSize: 3,
             records: [
               { name: "Apple",     catalogCode: "de-ApplePhones"  }, 
               { name: "LG",     catalogCode: "de-LGPhones"  }, 
               { name: "Samsung",   catalogCode: "de-SamsungPhones"   }
             ]
           }
          }
          //append to original catalogs list - shows to the right when displayed
          //catalogs.push(myCatalogDetails);

          //pre-pend to the new catalog to the start (left) of the list.
          catalogs.unshift(myCatalogDetails); 

          // catalogs.reverse();
          return Promise.resolve(catalogs);
      }

    render() 
    { 
      return catalogTemplate;
    }
}