import { LightningElement ,api } from 'lwc';

export default class demoeng_account_data extends LightningElement {
    @api defaultemail = 'demoeng@vlocity.com';
    @api ccimage = '';
    @api showcomponent=false;

    connectedCallback() {

    }

    disconnectedCallback() {
        
    }

}