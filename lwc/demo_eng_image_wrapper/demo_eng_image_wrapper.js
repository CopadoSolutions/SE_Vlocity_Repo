/* eslint-disable no-console */
import { LightningElement, api, track, wire } from 'lwc';
import findDocument from '@salesforce/apex/DemoEngineeringLWCController.getDocumentImage';

export default class demo_eng_image_wrapper extends LightningElement {

    @api defaultdocname='VLOCITY';
    @api width='';
    @api height='';
    @api defaultAltText='';
    @track resolvedimagepath;
    @track document;
    @track error;

        @wire(findDocument,{documentName: '$defaultdocname'})
    wiredDocument({ error, data }) {
        if (data) {
            this.document = data;
            this.resolvedimagepath = "/servlet/servlet.FileDownload?file="+data.Id;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.defaultAltText = error;
            this.document = undefined;
        }
    }    

    connectedCallback() {
    }

    disconnectedCallback() {
        
    }
}