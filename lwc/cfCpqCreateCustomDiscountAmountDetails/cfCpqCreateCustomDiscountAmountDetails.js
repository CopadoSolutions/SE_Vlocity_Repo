import { FlexCardMixin } from "vlocity_cmt/flexCardMixin";
    import {interpolateWithRegex, interpolateKeyValue, fetchCustomLabels, loadCssFromStaticResource } from "vlocity_cmt/flexCardUtility";
    
          import { LightningElement, api, track } from "lwc";
          
          import pubsub from "vlocity_cmt/pubsub";
          
          import data from "./definition";
          
          import styleDef from "./styleDefinition";
              
          export default class cfCpqCreateCustomDiscountAmountDetails extends FlexCardMixin(LightningElement){
              @api debug;
              @api recordId;
              @api objectApiName;
              
              @track record;
              @track _sessionApiVars = {};

              _regexPattern = /\{([a-zA-Z.0-9_]+)\}/g; //for {} fields by default
              @track Label={OneTime:"One Time",
      Recurring:"Recurring",
      PCValue:"Value",
      CPQAdjustBy:"Adjust By",
      CPQSetAmountToBeApplied:"Set the amount of discount to be applied.",
      CPQAmount:"Amount"
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
          baseinputvaluechange: this.handleEventAction.bind(this, data.events[0],0)
        };

        pubsub.register(`customDiscoutField`,this.pubsubEvent[0]);

              }

              unregisterEvents(){
                pubsub.unregister(`customDiscoutField`,this.pubsubEvent[0]);

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