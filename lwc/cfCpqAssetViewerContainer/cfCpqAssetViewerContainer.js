import { FlexCardMixin } from "vlocity_cmt/flexCardMixin";
    import {interpolateWithRegex, interpolateKeyValue, fetchCustomLabels, loadCssFromStaticResource } from "vlocity_cmt/flexCardUtility";
    
          import { LightningElement, api, track } from "lwc";
          
          import pubsub from "vlocity_cmt/pubsub";
          
          import data from "./definition";
          
          import styleDef from "./styleDefinition";
              
          export default class cfCpqAssetViewerContainer extends FlexCardMixin(LightningElement){
              @api debug;
              @api recordId;
              @api objectApiName;
              
              @track record;
              @track _sessionApiVars = {};

              _regexPattern = /\{([a-zA-Z.0-9_]+)\}/g; //for {} fields by default
              @track Label={Quantity2:"Quantity",
      CPQSearch:"Search",
      CPQProduct:"Product",
      CPQLoadMore:"Load More",
      CPQOneTimeChargeColumn:"CPQOneTimeChargeColumn",
      EffectiveCPQRecurringTotal:"EffectiveCPQRecurringTotal",
      CPQCreateQuote:"CPQCreateQuote",
      CPQCreateOrder:"Create Order",
      CPQSelectAnAction:"CPQSelectAnAction",
      OneTimeTotal:"OneTimeTotal",
      CPQOneTimeCharge:"CPQOneTimeCharge",
      CPQRecurringCharge:"CPQRecurringCharge",
      CPQServiceAccount:"CPQServiceAccount",
      CPQName:"CPQName",
      CPQNone:"CPQNone",
      CPQGroupBy:"CPQGroupBy"
      };
              pubsubEvent = [];
              customEvent = [];
              
              connectedCallback() {
                super.connectedCallback();
                this.registerEvents();
                this.setStyleDefinition(styleDef);
                data.Session = {} //reinitialize on reload
                
                
                this.customLabels = this.Label;
                      
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
          valuechange: this.handleEventAction.bind(this, data.events[0],0),
open_advanced_search: this.handleEventAction.bind(this, data.events[9],9),
click_search: this.handleEventAction.bind(this, data.events[10],10)
        };

        pubsub.register(`customsearch_${this.recordId}`,this.pubsubEvent[0]);

        this.pubsubEvent[1] = {
          bulkloadmoreresponse: this.handleEventAction.bind(this, data.events[1],1),
selectallassets: this.handleEventAction.bind(this, data.events[2],2),
select_record: this.handleEventAction.bind(this, data.events[4],4),
apply_advanced_search: this.handleEventAction.bind(this, data.events[8],8),
group_by_asset_viewer_event: this.handleEventAction.bind(this, data.events[11],11),
get_asset_viewer_lineitems: this.handleEventAction.bind(this, data.events[12],12)
        };

        pubsub.register(`cpq_${this.recordId}`,this.pubsubEvent[1]);

        this.pubsubEvent[2] = {
          select_record: this.handleEventAction.bind(this, data.events[3],3)
        };

        pubsub.register(`BulkSearchAndSelectAssets_${this.recordId}`,this.pubsubEvent[2]);

        this.pubsubEvent[3] = {
          baseinputvaluechange: this.handleEventAction.bind(this, data.events[5],5)
        };

        pubsub.register(`dateInput_${this.recordId}`,this.pubsubEvent[3]);

        this.pubsubEvent[4] = {
          baseinputvaluechange: this.handleEventAction.bind(this, data.events[6],6)
        };

        pubsub.register(`groupByInput_${this.recordId}`,this.pubsubEvent[4]);

        this.pubsubEvent[5] = {
          clear_all: this.handleEventAction.bind(this, data.events[7],7)
        };

        pubsub.register(`cpqAssetViewerAdvancedSearch_${this.recordId}`,this.pubsubEvent[5]);

              }

              unregisterEvents(){
                pubsub.unregister(`customsearch_${this.recordId}`,this.pubsubEvent[0]);
pubsub.unregister(`cpq_${this.recordId}`,this.pubsubEvent[1]);
pubsub.unregister(`BulkSearchAndSelectAssets_${this.recordId}`,this.pubsubEvent[2]);
pubsub.unregister(`dateInput_${this.recordId}`,this.pubsubEvent[3]);
pubsub.unregister(`groupByInput_${this.recordId}`,this.pubsubEvent[4]);
pubsub.unregister(`cpqAssetViewerAdvancedSearch_${this.recordId}`,this.pubsubEvent[5]);

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