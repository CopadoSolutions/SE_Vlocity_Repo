import { LightningElement, api } from 'lwc';

export default class demo_eng_simple_banner_text extends LightningElement {

    @api bannerstyle = '';
    @api bannertext='';
    @api showcomponent=false;

    connectedCallback() {

    }

    disconnectedCallback() {
        
    }

}