import { FlexCardMixin } from "vlocity_cmt/flexCardMixin";
    import {interpolateWithRegex, interpolateKeyValue, fetchCustomLabels, loadCssFromStaticResource } from "vlocity_cmt/flexCardUtility";
    
          import { LightningElement, api, track } from "lwc";
          
          import pubsub from "vlocity_cmt/pubsub";
          
          import data from "./definition";
          
          import styleDef from "./styleDefinition";
              
          export default class cfCpqBrowsePhaseContainer extends FlexCardMixin(LightningElement){
              @api debug;
              @api recordId;
              @api objectApiName;
              
              @track record;
              @track _sessionApiVars = {};

              _regexPattern = /\{([a-zA-Z.0-9_]+)\}/g; //for {} fields by default
              @track Label={CPQCartPreview:"Cart Preview",
      Close:"Close",
      CPQLoadMore:"Load More"
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
          cpqchangeviewtotile: this.handleEventAction.bind(this, data.events[0],0),
cpqchangeviewtolist: this.handleEventAction.bind(this, data.events[1],1),
cpq_catalog_item_select_browse: this.handleEventAction.bind(this, data.events[2],2),
cpqselect: this.handleEventAction.bind(this, data.events[3],3),
apply_filter: this.handleEventAction.bind(this, data.events[4],4),
cpqshowfilters: this.handleEventAction.bind(this, data.events[5],5),
cpq_qualified: this.handleEventAction.bind(this, data.events[6],6),
cpq_summarycart_details: this.handleEventAction.bind(this, data.events[7],7),
cpq_preview_cart: this.handleEventAction.bind(this, data.events[8],8),
cpq_close_preview_cart: this.handleEventAction.bind(this, data.events[9],9),
cpq_spinner: this.handleEventAction.bind(this, data.events[11],11)
        };

        pubsub.register(`cpq_${this.recordId}`,this.pubsubEvent[0]);

        this.pubsubEvent[1] = {
          cpq_update_cart_persistentcartview: this.handleEventAction.bind(this, data.events[10],10)
        };

        pubsub.register(`cpq_ui_event_${this.recordId}`,this.pubsubEvent[1]);

              }

              unregisterEvents(){
                pubsub.unregister(`cpq_${this.recordId}`,this.pubsubEvent[0]);
pubsub.unregister(`cpq_ui_event_${this.recordId}`,this.pubsubEvent[1]);

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