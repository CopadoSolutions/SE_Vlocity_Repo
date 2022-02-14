import { LightningElement } from 'lwc';
import dcChildCatalogs            from "vlocity_cmt/dcChildCatalogs";
import catalogTemplate      from "./deCommsChildCatalog.html";
//import myResource from '@salesforce/resourceUrl/dc_assets';

export default class deCommsChildCatalog extends dcChildCatalogs
{
    // connectedCallback() {super.connectedCallback();    }

     fetchCatalogsPreHook(catalogs) 
     {
          const myCatalogDetails = {
           name: "Demo-Eng",
           catalogCode: "de-eng-cat",         
           img1: "/resource/dc_assets/images/mobile.svg",
           img2: "/resource/dc_assets/images/mobile.svg",

           childCatalogs: {
             totalSize: 3,
             records: [
               { name: "Apple",     catalogCode: "de-ApplePhones"  }, 
               { name: "LG",     catalogCode: "de-LGPhones"  },
               { name: "Samsung",   catalogCode: "de-SamsungPhones"   }
             ]
           }
          }
          //catalogs.push(myCatalogDetails); // append to original catalogs list
          catalogs.unshift(myCatalogDetails); 
          // catalogs.reverse();
          return Promise.resolve(catalogs);
      }

    render() 
    {
        return catalogTemplate;
    }
}