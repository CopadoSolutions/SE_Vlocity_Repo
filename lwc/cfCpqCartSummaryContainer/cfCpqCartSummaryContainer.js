import { FlexCardMixin } from "vlocity_cmt/flexCardMixin";
    import {interpolateWithRegex, interpolateKeyValue, fetchCustomLabels, loadCssFromStaticResource } from "vlocity_cmt/flexCardUtility";
    
          import { LightningElement, api, track } from "lwc";
          
          import pubsub from "vlocity_cmt/pubsub";
          
          import data from "./definition";
          
          import styleDef from "./styleDefinition";
              
          export default class cfCpqCartSummaryContainer extends FlexCardMixin(LightningElement){
              @api debug;
              @api recordId;
              @api objectApiName;
              
              @track record;
              @track _sessionApiVars = {};

              _regexPattern = /\{([a-zA-Z.0-9_]+)\}/g; //for {} fields by default
              @track Label={CPQAddToCart:"Add to Cart",
      CPQConfigure:"Configure",
      Cart:"Cart",
      CPQLoadMore:"Load More",
      CPQNoCartItemsFound:"No Cart Items Found",
      CPQAddProducts:"Add Products",
      close:"Close",
      CPQCatalogPreview:"Catalog Preview"
      };
              pubsubEvent = [];
              customEvent = [];
              
              connectedCallback() {
                super.connectedCallback();
                this.registerEvents();
                this.setStyleDefinition(styleDef);
                data.Session = {} //reinitialize on reload
                
                
                this.customLabels = this.Label;
                      
                        fetchCustomLabels(Object.keys(this.Label)).then(labels => {
                          this.Label = labels;
                          let card = {...this.card};
                          card.Label = labels;
                          this.card = card;
                          this.customLabels = this.Label;
                      });
                this.setDefinition(data);
                
                
              }
              
              disconnectedCallback(){
                super.disconnectedCallback();
                    
                    

                  this.unregisterEvents();
              }
                  
              executeAction(event) {
                let dataset = event.currentTarget.dataset;
                if (dataset && dataset.onchange === 'setValue' ) {
                  this.setValueOnToggle(event);
                }
                if(dataset && typeof dataset.actionIndex !== 'undefined') {
                  let actionIndex = dataset.actionIndex;
                  this.elementIndex = event.currentTarget && event.currentTarget.closest(".cf-vlocity-state") ? event.currentTarget.closest(".cf-vlocity-state").dataset.rindex : null;
                  if (this.records) {
                    this.record = this.records[this.elementIndex];
                  }
                  this.action = {};
                  this.action[actionIndex] = true;
                  this.template.querySelector('.execute-action').executeAction(event, this.card);
                }
                event.stopPropagation();
              }

              registerEvents() {
                
        this.pubsubEvent[0] = {
          cpq_catalog_item_select_cart: this.handleEventAction.bind(this, data.events[0],0),
cpq_close_preview_catalog: this.handleEventAction.bind(this, data.events[1],1),
cpq_open_preview_catalog: this.handleEventAction.bind(this, data.events[2],2),
cpqselect: this.handleEventAction.bind(this, data.events[5],5),
cpqshowfilters: this.handleEventAction.bind(this, data.events[6],6),
cpq_qualified: this.handleEventAction.bind(this, data.events[7],7),
apply_filter: this.handleEventAction.bind(this, data.events[8],8),
cpq_cart_updated: this.handleEventAction.bind(this, data.events[9],9),
cpq_spinner: this.handleEventAction.bind(this, data.events[10],10),
cpq_select_multiple_products_cart: this.handleEventAction.bind(this, data.events[11],11),
cpq_remove_multiselect_cart: this.handleEventAction.bind(this, data.events[12],12)
        };

        pubsub.register(`cpq_${this.recordId}`,this.pubsubEvent[0]);

        this.pubsubEvent[1] = {
          cpq: this.handleEventAction.bind(this, data.events[3],3)
        };

        pubsub.register(`cpqCloneItem_${this.recordId}`,this.pubsubEvent[1]);

        this.pubsubEvent[2] = {
          cpq_update_cart_summary: this.handleEventAction.bind(this, data.events[4],4)
        };

        pubsub.register(`cpq_ui_event_${this.recordId}`,this.pubsubEvent[2]);

              }

              unregisterEvents(){
                pubsub.unregister(`cpq_${this.recordId}`,this.pubsubEvent[0]);
pubsub.unregister(`cpqCloneItem_${this.recordId}`,this.pubsubEvent[1]);
pubsub.unregister(`cpq_ui_event_${this.recordId}`,this.pubsubEvent[2]);

              }
            
              renderedCallback() {
                super.renderedCallback();
                
              }

              handleEventAction(eventObj, eventIndex, event) {
                eventObj.actionList = eventObj.actionList || (eventObj.actionData ? [eventObj.actionData] : []);
                let stateIndex = 0;
                if (eventObj.eventtype === 'event' && event?.target){
                  if(this.elementIndex && event?.target?.classList.contains("execute-action")) {
                    stateIndex = this.elementIndex;
                  } else {
                    const stateElement = event.target.closest(".cf-vlocity-state")
                     ? event.target.closest(".cf-vlocity-state")
                     : null;
                    if (stateElement?.dataset.rindex) {
                    stateIndex = parseInt(stateElement.dataset.rindex, 10);
                    }
                  }
                }
                if(eventObj.actionList && eventObj.actionList.length > 0){
                  this.fireMultipleActionRecursively(eventObj, 0, null, eventIndex, event, stateIndex, data);
                }
              }
          }