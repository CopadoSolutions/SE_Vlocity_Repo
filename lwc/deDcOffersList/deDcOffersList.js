import { LightningElement } from 'lwc';
import dcOffersList            from "vlocity_cmt/dcOffersList";
import template      from "./deDcOffersList.html";

export default class deDcOffersList extends dcOffersList
{
    // connectedCallback() {super.connectedCallback();    }


    render() 
    {
        return template;
    }
}