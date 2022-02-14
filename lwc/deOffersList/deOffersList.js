import { LightningElement }     from 'lwc';
import dcOffersList             from "vlocity_cmt/dcOffersList";
import template                 from "./deOffersList.html";

export default class deOffersList extends dcOffersList
{
    // connectedCallback() {super.connectedCallback();    }


    render() 
    {
        return template;
    }
}