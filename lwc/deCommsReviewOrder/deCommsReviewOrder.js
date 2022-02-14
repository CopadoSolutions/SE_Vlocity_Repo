import { LightningElement } from 'lwc';

import dcReviewOrder          from "vlocity_cmt/dcReviewOrder";
import template               from "./deCommsReviewOrder.html";


export default class deCommsReviewOrder extends dcReviewOrder
{
    // connectedCallback() {super.connectedCallback();    }
    render() 
    {
        return template;
    }
}