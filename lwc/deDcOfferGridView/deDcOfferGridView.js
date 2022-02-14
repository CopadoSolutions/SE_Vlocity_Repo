import { LightningElement } from 'lwc';
import dcOfferGridView from "vlocity_cmt/dcOfferGridView";
import template from "./deDcOfferGridView.html";

export default class DeDcOfferGridView extends dcOfferGridView {
    // connectedCallback() { super.connectedCallback(); }


    render() {
        return template;
    }
}