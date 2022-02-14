import { FlexCardMixin } from "vlocity_cmt/flexCardMixin";
    import {interpolateWithRegex, interpolateKeyValue, fetchCustomLabels, loadCssFromStaticResource } from "vlocity_cmt/flexCardUtility";
    
          import { LightningElement, api, track } from "lwc";
          
          import pubsub from "vlocity_cmt/pubsub";
          
          import data from "./definition";
          
          import styleDef from "./styleDefinition";
              
          export default class cfCpqManualPriceAdjustmentsActions extends FlexCardMixin(LightningElement){
              @api debug;
              @api recordId;
              @api objectApiName;
              
              @track record;
              @track _sessionApiVars = {};

              _regexPattern = /\{([a-zA-Z.0-9_]+)\}/g; //for {} fields by default
              @track Label={CPQDuration:"Duration",
      CPQPolicy:"Policy",
      CPQSelectPolicy:"Select Policy",
      CPQMessageWhenValueMissing:"This field is required",
      CPQSelectDuration:"Select Duration",
      CPQLimitAdjustmentTime:"Limit Adjustment Time",
      Add:"Add",
      CPQAdjustBy:"Adjust By"
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

        pubsub.register(`AdjustmentMode`,this.pubsubEvent[0]);

        this.pubsubEvent[1] = {
          baseinputvaluechange: this.handleEventAction.bind(this, data.events[1],1)
        };

        pubsub.register(`ChildAdjustmentValue`,this.pubsubEvent[1]);

        this.pubsubEvent[2] = {
          baseinputvaluechange: this.handleEventAction.bind(this, data.events[2],2)
        };

        pubsub.register(`ChildAdjustmentCode`,this.pubsubEvent[2]);

        this.pubsubEvent[3] = {
          cpq_chargetype: this.handleEventAction.bind(this, data.events[3],3)
        };

        pubsub.register(`cpq`,this.pubsubEvent[3]);

        this.pubsubEvent[4] = {
          valuechange: this.handleEventAction.bind(this, data.events[4],4)
        };

        pubsub.register(`ChargeSignType`,this.pubsubEvent[4]);

        this.pubsubEvent[5] = {
          baseinputvaluechange: this.handleEventAction.bind(this, data.events[5],5)
        };

        pubsub.register(`LimitAdjustmentTime`,this.pubsubEvent[5]);

        this.pubsubEvent[6] = {
          baseinputvaluechange: this.handleEventAction.bind(this, data.events[6],6)
        };

        pubsub.register(`AdjustmentPlan`,this.pubsubEvent[6]);

        this.pubsubEvent[7] = {
          baseinputvaluechange: this.handleEventAction.bind(this, data.events[7],7)
        };

        pubsub.register(`AdjustmentPolicy`,this.pubsubEvent[7]);

        this.pubsubEvent[8] = {
          cpq_adjustment_apply_child: this.handleEventAction.bind(this, data.events[8],8)
        };

        pubsub.register(`cpq_${this.recordId}`,this.pubsubEvent[8]);

              }

              unregisterEvents(){
                pubsub.unregister(`AdjustmentMode`,this.pubsubEvent[0]);
pubsub.unregister(`ChildAdjustmentValue`,this.pubsubEvent[1]);
pubsub.unregister(`ChildAdjustmentCode`,this.pubsubEvent[2]);
pubsub.unregister(`cpq`,this.pubsubEvent[3]);
pubsub.unregister(`ChargeSignType`,this.pubsubEvent[4]);
pubsub.unregister(`LimitAdjustmentTime`,this.pubsubEvent[5]);
pubsub.unregister(`AdjustmentPlan`,this.pubsubEvent[6]);
pubsub.unregister(`AdjustmentPolicy`,this.pubsubEvent[7]);
pubsub.unregister(`cpq_${this.recordId}`,this.pubsubEvent[8]);

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