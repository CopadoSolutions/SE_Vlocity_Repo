/**
 * Lightning Web Component used to view assets in various ways when spread accross multiple Service Accounts:
 *   -A searchable, hierarchical view of assets by Service Account
 *   -A Geographical Map-based view of Service Accounts and assets at each location
 *   -Supports OmniScript actions Change-to-Quote, Change-to-Order, and Move
 *
 * Dependencies
 * ------------
 * -DataRaptor CommsB2BGetAssetsAndServiceDetails
 * 
 * Limitations
 * -----------
 * -The Salesforce Lightning Map will only geo-code up to 10 addresses.
 *   -if you use specific lat/long instead of addresses there are no limitations, but they recommend not going beyond 100 locations
 *   -enhancements to the LWC will be required to support the use of lat/long
 * -Only OmniScript Actions are supported on the Card
 * 
 * 
 * @author Joe McMaster (joe.mcmaster@salesforce.com)
 * @version 1.0
 * 
 * History
 * -------
 * v1.0 - Sep 2, 2020 - Initial version built for ByTel PoC
 * 
 */
import { LightningElement } from 'lwc';
import { BaseState } from "vlocity_cmt/baseState";
import template from "./commsB2B_AssetManagerCard.html";
//import { get } from "vlocity_cmt/lodash";

export default class CommsB2B_AssetManagerCard extends BaseState(LightningElement) {

    static ACTION_VIEW_ACCOUNT = "View Account";
    static ACTION_VIEW_ASSET   = "View Asset";

    static debug = false;  // enable to see plenty of debug information
    rendered = false;

    // Asset Table (all Service Accounts)
    assetKey      = "Id";
    assetColumns  = [];
    assetData     = [];
    assetExpanded = [];

    // Map Pins
    locations;

    // Asset Map Table (selected Service Account on map)
    assetMapColumns  = [];
    assetMapData     = [];
    assetMapExpanded = [];

    /**
     * Renders this LWC Card.  This will get called multiple times as LWC parameters are
     * set (i.e. state, obj, etc.)
     * 
     * @return {Object} The HTML Template
     */
    render() {
        
        // Do it all inside a try block or you'll never see any errors!
        try {
            
            // Render once both the state and obj data is set (and only do this once!)
            if (this.state && this.obj && !this.rendered) {
            
                // Debug
                if (CommsB2B_AssetManagerCard.debug) {
                    console.log('----------------- DEBUG -----------------------');
                    console.log("Card Session -> " + JSON.stringify(this.session));
                    console.log("Card State   -> " + JSON.stringify(this.state));
                    console.log("Card Obj     -> " + JSON.stringify(this.obj));
                }

                // Set the Asset Table Columns
                this.setTableColumns(this.state);
                this.setTableData(this.obj, "");

                // Add Locations to the Map
                this.locations = CommsB2B_AssetManagerCard.getLocations(this.obj);

                this.rendered = true;
            }

            return template;
        }
        catch (err) {
            console.error('Exception occured during CommsB2B_AssetManagerCard render() -> ' + err);
        }        
    }

    /**
     * Dynamically builds the table columns to show on the map table
     * 
     * @param {Array} state - The Card State
     */
    setTableColumns(state) {

        let columns = [];        

        // Go through the field definitions on the card and map those to the lightning-tree-grid column definitions
        for (let field of state.fields) {

            let column = {
                type: field.type,
                fieldName: field.name,
                label: field.label
            };

            columns.push(column);
        }

        // If we have any actions, add the extra column
        if (state.definedActions.actions.length) {
            
            let column = {
                type: "action",
                //label: "Actions",
                iconName: "utility:threedots_vertical",
                typeAttributes: {
                    rowActions: this.getAssetActions
                }
            };

            columns.push(column);
        }
        
        this.assetColumns = columns;
    }

    /**
     * Organizes the Asset Table Data for display
     * 
     * @param {Array}  data       - The object passed into the card
     * @param {Array}  data.Asset - The list of assets
     * @param {string} filter     - The name filter (contains) to apply to the asset name
     */
    setTableData(data, filter) {

        let assets = [];
        let autoExpand = [];

        // Get a list of assets for each service account
        for (let sa of CommsB2B_AssetManagerCard.getLocations(data)) {
            
            let assetsFound = this.getAssets(sa.value);

            // If a filter has been provided, prune the list of assets as needed
            if (filter && filter.trim() != "") {

                // Apply the filter to each asset
                let filteredAssets = [];
                for (let asset of assetsFound) {
                    
                    let fa = CommsB2B_AssetManagerCard.filterAsset(asset, filter, autoExpand);
                    if (fa) filteredAssets.push(fa);
                }

                assetsFound = filteredAssets;
            }

            // Set Table Data for this service account "if" there are assets to display
            if (assetsFound.length > 0) {
                
                assets.push({
                    Id: sa.value,
                    Name: sa.title,
                    actions: [
                        {
                            id: "viewRecord",
                            displayName: CommsB2B_AssetManagerCard.ACTION_VIEW_ACCOUNT,
                            type: "internal"
                        }
                    ],
                    _children: assetsFound
                });

                // If we are filtering, expand the service account
                if (filter && filter.trim().length > 0) autoExpand.push(sa.value);
            }
        }

        this.assetData = assets;

        this.assetExpanded = autoExpand;
    }

    /**
     * Applys a filter to the asset data.  This is somewhat complicated due to the fact
     * that the list is hierarchical so even though an asset name may not match, it may have
     * a child asset that does so we can't omit the parent asset.
     * 
     * @param {Object} asset           - A hierarchical list of assets
     * @param {string} asset.Name      - The asset name
     * @param {Array}  asset._children - any child assets
     * @param {string} filter          - The filter to apply
     * @param {Array}  autoExpand      - An array used to track automatic asset expansion
     * 
     * @returns {Object} the filtered asset or undefined if the asset doesn't match the filter or has children that match the filter
     */
    static filterAsset(asset, filter, autoExpand) {

        // If an asset matches the filter it is returned (along with all children regardless if they match or not)
        if (asset.Name.toLowerCase().includes(filter.toLowerCase())) return asset;

        // If an asset doesn't match, check the children to determine if is to be filtered out
        else if ("_children" in asset) {

            let filteredChildren = [];
            for (let childAsset of asset._children) {

                // If an asset doesn't match, but has children that match it is returned along with any matching children (unmatched children are filtered out)                
                // If an asset doesn't match and has no children that match it is not returned
                let filteredAsset = CommsB2B_AssetManagerCard.filterAsset(childAsset, filter, autoExpand);
                if (filteredAsset) filteredChildren.push(filteredAsset);
            }

            // If we have children after the filter, return this asset (with filtered children) and auto-expand it
            if (filteredChildren.length > 0) {

                asset._children = filteredChildren;
                autoExpand.push(asset.Id);  // Auto-Expand this asset if it has children matching the filter

                return asset;
            }
        }
    }

    /**
     * Extracts all of the unique service account locations from the data
     * produced by the CommsB2BGetAssetsAndServiceDetails DataRaptor
     * 
     * @param {Object} data       - The object passed into the card
     * @param {Array}  data.Asset - The list of assets
     * 
     * @returns {Array} List of unique Map Locations
     */
    static getLocations(data) {

        let locs = {};

        if ("Asset" in data) {

        	// Force into a list
        	let assets = [].concat(data.Asset || []);
        	
            for (let item of assets) {

                // Make sure we are tracking unique locations (no duplicates)
                let id = item.ServiceAccountId;

                if (!(id in locs)) {

                    // Create the Map Location
                    let location = {
                        value: item.ServiceAccountId,
                        title: item.ServiceAccountName,
                        location: {
                            Street: item.ShippingAddress.StreetAddress,
                            City: item.ShippingAddress.City,
                            PostalCode: item.ShippingAddress.PostalCode,
                            Country: item.ShippingAddress.Country
                        }
                    };

                    locs[id] = location;
                }
            }
        }

        return Object.values(locs);
    }

    /**
     * Triggered when the user selects a marker on the map
     * 
     * @param {Object} event                            - The event object
     * @param {Object} event.detail                     - The event details
     * @param {string} event.detail.selectedMarkerValue - The selected marker value
     */
    handleMarkerSelect(event) {

        try {            

            let selectedLocation = event.detail.selectedMarkerValue;

            // Set the Map Table Data
            this.assetMapData = [{
                Id: selectedLocation,
                Name: this.getServiceAccount(selectedLocation).title,
                actions: [
                    {
                        id: "viewRecord",
                        displayName: CommsB2B_AssetManagerCard.ACTION_VIEW_ACCOUNT,
                        type: "internal"
                    }
                ],
                _children: this.getAssets(selectedLocation, "")
            }];

            this.assetMapExpanded = [selectedLocation];
        }
        catch (err) {
            console.error('Exception occured during handleMarkerSelect() event -> ' + err);
        }
    }

    /**
     * Returns details for the given service account
     * 
     * @param {string} serviceAccountId - service Account Id of interest
     * 
     * @returns {Object} The serivce account if found, undefined otherwise
     */
    getServiceAccount(serviceAccountId) {

        for (let sa of CommsB2B_AssetManagerCard.getLocations(this.obj)) {
            
            if (sa.value == serviceAccountId) return sa;
        }
    }

    /**
     * Builds a hierarchical data model of assets for given Service Account
     * 
     * @param {string} serviceAccountId - service Account Id for which to find assets     
     * 
     * @returns {Array} The asset data model for the service account
     */
    getAssets(serviceAccountId) {
        
        let assets = [];
        
        // Force into list
        let allAssets = [].concat(this.obj.Asset || []);
        
        for (let asset of allAssets) {
            if (asset.ServiceAccountId == serviceAccountId) CommsB2B_AssetManagerCard.addAssetToHierarchy(assets, asset, this.state.definedActions.actions);
        }

        return assets;
    }

    /**
     * Adds an asset to the asset hierarchy
     * 
     * @param {Array}  assets  - The current asset hierarchy 
     * @param {Object} asset   - A new asset to insert into the hierarchy
     * @param {Object} actions - A list of actions to add to the asset
     */
    static addAssetToHierarchy(assets, asset, actions) {

        // Clone the asset data (so we can make changes to it!)
        let assetData = JSON.parse(JSON.stringify(asset));

        // Always add the "View Asset" action
        assetData.actions = [{
            id: "viewRecord",
            displayName: CommsB2B_AssetManagerCard.ACTION_VIEW_ASSET,
            type: "internal"
        }];

        // Determine where to add this asset in the hierarchy
        let parentAsset = CommsB2B_AssetManagerCard.findAsset(assets, assetData.ParentId);

        // If we found a parent asset, we know this is a child asset
        if (parentAsset) {
                                   
            if (!("_children" in parentAsset)) parentAsset._children = [];            
            parentAsset._children.push(assetData);
        }
        else {            

            // Add configured Actions (only to root level assets)
            if (actions) assetData.actions = assetData.actions.concat(JSON.parse(JSON.stringify(actions)));

            assets.push(assetData);  // Root level asset
        }
    }

    /**
     * Looks into the asset hierarchy to find a particular asset by Id
     * 
     * @param {Array} assets - The current asset hierarchy
     * @param {string} id    - The Id of the asset to find
     * 
     * @returns {Object} The Asset in the hierarchy if found, undefined otherwise
     */
    static findAsset(assets, id) {

        if (id) {

            for (let item of assets) {

                // If this is the asset return it immediately, otherwise look deeper (children)
                if (item.Id == id) return item;
                else if ("_children" in item) {
                    let asset = CommsB2B_AssetManagerCard.findAsset(item._children, id);
                    if (asset) return asset;
                }
            }
        }
    }

    /**
     * Filters the asset list based on the search criteria provided by the user.
     * The filter is checked against the asset name
     * 
     * @param {Object} event              - The change event
     * @param {Object} event.detail       - The event details
     * @param {string} event.detail.value - The user-provided search filter
     */
    filterAssetTable(event) {

        try {

            if (CommsB2B_AssetManagerCard.debug) console.log('Filtering Asset List -> ' + JSON.stringify(event.detail));
            
            this.setTableData(this.obj, event.detail.value);
        }
        catch (err) {
            console.error('Exception occured during CommsB2B_AssetManagerCard.filterAssets() event -> ' + err);
        }
    }

    /**
     * Triggered when the user selects the action drop-down in the grid-table.  It builds the list
     * of possible actions that can be taken against the asset.
     * 
     * @param {Object} row     - The row that was selected
     * @param {*} doneCallback - A callback function which will be triggered at the end of this function
     */
    getAssetActions(row, doneCallback) {
        
        const actions = [];

        try {
        
            if ("actions" in row) {

                for (let action of row.actions) {

                    actions.push({
                        name: action.id,
                        label: action.displayName
                    });
                }
            }
        }
        catch (err) {
            console.error("Exception occured during CommsB2B_AssetManagerCard.getAssetActions() event -> " + err);
        }

        // Trigger the callback
        doneCallback(actions);
    }

    /**
     * Triggered when the user selects an action on an asset (or Service Account) in the tables
     * 
     * @param {Object} event  - The action that was selected
     */
    handleAction(event) {

        try {

            if (CommsB2B_AssetManagerCard.debug) console.log('Asset Action Triggered -> ' + JSON.stringify(event));

            // Find the Action
            let actionId = event.detail.action.name;

            for (let action of event.detail.row.actions) {
            
                if (action.id === actionId) {

                    // Found the action, run it!
                    if (action.type === "OmniScript") {

                        // Build the Context for the OmniScript
                        // Unfortunately, this can be dependent on the OmniScript we are calling
                        let contextId = event.detail.row.Id;
                        if (action.omniType.Type === "MACD" && action.omniType.SubType === "ChangeToQuote") {

                            // This OmniScript expects a ContextId in the form <accountId>:all:<assetId>
                            contextId = event.detail.row.ServiceAccountId + ":all:" + contextId;
                        }
                        
                        // Build the OmniScript URL
                        let url = "/apex/" + encodeURIComponent(action.vForcewithNsPrefix) + "?"
                                  + "id=" + encodeURIComponent(contextId)
                                  + "&layout=" + encodeURIComponent(action.layoutType) + "#"
                                  + "/OmniScriptType/" + encodeURIComponent(action.omniType.Type)
                                  + "/OmniScriptSubType/" + encodeURIComponent(action.omniType.SubType)
                                  + "/OmniScriptLang/" + encodeURIComponent(action.omniType.Language)
                                  + "/ContextId/" + encodeURIComponent(contextId)
                                  + "/PrefillDataRaptorBundle//true";

                        if (CommsB2B_AssetManagerCard.debug) console.log("Launching OmniScript -> " + url);

                        window.open(url, action.openUrlIn);
                    }
                    else if (action.type === "internal") {

                        if (action.id === "viewRecord") {

                            // Navigate to the Record
                            let url = "/" + encodeURIComponent(event.detail.row.Id);

                            if (CommsB2B_AssetManagerCard.debug) console.log("Navigating to -> " + url);

                            window.open(url, "_self");
                        }
                        else console.error("Unsupported 'internal' Action Id '" + action.id + "'");
                    }
                    else console.error("Unsupported Action Type '" + action.type + "'");
                }
            }
        }
        catch (err) {
            console.error("Exception occured during CommsB2B_AssetManagerCard.handleRowAction() event -> " + err);
        }
    }
}