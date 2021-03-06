/**
 * Advances to the next step in the OmniScript (if there is one) 
 * 
 * @param scp  The HTML element / Angular Scope
 */ 
function nextStep(scp) {

    // Get the index for the current step we are on and the index to the next step
    let curIndex  = scp.bpTree.children[scp.bpTree.asIndex].indexInParent;
    let nextIndex = scp.bpTree.children[scp.bpTree.asIndex].nextIndex;        

    // Get the next step (if there is one!)
    if (nextIndex && scp.bpTree.children[nextIndex]) {
        console.log("Moving to Step " + scp.bpTree.children[nextIndex].name);
        scp.nextRepeater(nextIndex, curIndex);
    }
};

/**
 * Attempts to extract the Catalog Code from a Digital Commerce offer.
 * 
 * @param offer  An offer object originating from the Digital Commerce GetOffersByCatalog API
 * 
 * @return The Catalog Code, undefined otherwise
 */
function getCatalog(offer) {

    // Likely need to make this more robust but for now ....
    // Get the URL such as v3/catalogs/WATCHES/basket, and then extract the Catalog Code (WATCHES)
    var link = offer.addtocart.rest.link;
    
    if (link) return link.replace(/.*catalogs\//g, '').replace(/\/.*/g, '');
};

/**
 * This is a utility method that generates the Basket Request URL
 * 
 * @param offer  An offer object originating from the Digital Commerce GetOffersByCatalog API
 * @param scp    The HTML element / Angular Scope
 * 
 * @return The Digital Commerce Request URL
 */
function getRequestURL(offer, scp) {

    var url = '/' + offer.addtocart.rest.link;

    // Add the Basket Id (if we have one)
    if (scp.bpTree.response.basketId) url += '/' + scp.bpTree.response.basketId;

    return url;
};

/**
 * Creates the API Request for the Digital Commerce API
 * 
 * @param offer    A selected offer object originating from the Digital Commerce GetOffersByCatalog API
 * @param control  The OmniScript component definition (i.e. Selectable Items)
 * @param scp      The HTML element / Angular Scope
 * @param txKey    The transaction key (see Multi-Transaction Service documentation)
 * 
 * @return The API request (Remote Action)
 */
function createAPIRequest(offer, control, scp, txKey) {

    // Set default remote properties and override with any set explicitly on the OmniScript Component (Remote Properties)
    var className  = '%vlocity_namespace%.CpqAppHandler';
    var methodName = offer.addtocart.rest.params.basketAction;  // AddWithNoConfig
    var timeout    = 15000;
    var opt        = {};

    if (control) {
        if (control.propSetMap.remoteClass)   className  = control.propSetMap.remoteClass;
        if (control.propSetMap.remoteMethod)  methodName = control.propSetMap.remoteMethod;
        if (control.propSetMap.remoteTimeout) timeout    = control.propSetMap.remoteTimeout;
    }

    if (control && control.propSetMap && control.propSetMap.elementValueMap) {
        if (control.propSetMap.elementValueMap.remoteClass)   className  = control.propSetMap.elementValueMap.remoteClass;
        if (control.propSetMap.elementValueMap.remoteMethod)  methodName = control.propSetMap.elementValueMap.remoteMethod;
        if (control.propSetMap.elementValueMap.remoteTimeout) timeout    = control.propSetMap.elementValueMap.remoteTimeout;
    }


    // Build API Input
    let inputParam = {
            'apiName'     : 'basketOperations',
            'catalogCode' : getCatalog(offer),                                                   // i.e. WATCHES
            'requestURL'  : getRequestURL(offer, scp),                                           // i.e. /v3/catalogs/WATCHES/basket/<basketId>
            'offer'       : offer.addtocart.rest.params.offer,                                   // i.e. VLO-MOB-0153
            'methodName'  : methodName.substring(0, 1).toLowerCase() + methodName.substring(1)   // i.e. addWithNoConfig
        };

    // if we have context (i.e. logged in user) add it to the request
    if (offer.addtocart.rest.params.context) {
        inputParam.isloggedin = true;
        inputParam.context = offer.addtocart.rest.params.context;
    }

    // Add the Basket Id (if we have one)
    if (scp.bpTree.response.basketId) inputParam.cartContextKey = scp.bpTree.response.basketId;

    // Add the MTS transaction key if we have one
    if (txKey) inputParam.multiTransactionKey = txKey;

    // Setup the Remote Action Request
    var configObj = {
            sClassName  : className,
            sMethodName : methodName,
            input       : angular.toJson(inputParam),
            options     : angular.toJson(opt),
            iTimeout    : timeout,
            label       : {label:control && control.name}
        };

    // Debugging
    //console.log('class      -> ' + className);
    //console.log('methodName -> ' + methodName);
    //console.log('timeout    -> ' + timeout);
    //console.log('options    -> ' + JSON.stringify(opt));
    //console.log('propSet    -> ' + JSON.stringify(control.propSetMap));
    //console.log('input      -> ' + JSON.stringify(inputParam));
    console.log('config     -> ' + JSON.stringify(configObj));

    return configObj;
};

/**
 * Checks for any errors in the API Response
 * 
 * @param resp     The API Response
 * @param control  The OmniScript component definition (i.e. Selectable Items)
 * @param scp      The HTML element / Angular Scope
 * 
 */
function hasErrors(resp, control, scp) {

	if (resp.error && resp.error !== "OK") {

		console.error('Digital Commerce API Error -> ' + resp.error);
		scp.handleRemoteCallError(control, resp.error, true, false);
		return true;
	}

    // No detectable errors
    return false;
};

/**
 * Saves the response details to OmniScript data
 * 
 * @param resp  The API Response
 * @param scp   The HTML element / Angular Scope
 */
function saveResponse(resp, scp) {

    // Save the Basket Id (you'll get a new Id each time)
    if (resp.cartContextKey) {
        //console.log('Basket Id = ' + resp.cartContextKey);
        scp.bpTree.response.basketId = resp.cartContextKey;
    }

    // Save the response
    scp.bpTree.response.basket = resp.result;
};

/**
 * Adds a selected offer to the Digital Commerce Basket
 * 
 * @param offer        A selected offer object originating from the Digital Commerce GetOffersByCatalog API
 * @param control      The OmniScript component definition (i.e. Selectable Items)
 * @param scp          The HTML element / Angular Scope
 * @param autoAdvance  An indication that upon adding an Offer to the basket, we should attempt to auto-advance the OmniScript to the next step
 */
baseCtrl.prototype.addOfferToBasket = function(offer, control, scp, autoAdvance) {

    // Debugging
    console.log(offer);

    if (!offer.addtocart) return;

    // Create the request
    var apiRequest = createAPIRequest(offer, control, scp);

    scp.$root.loading = true;
    scp.bpService.OmniRemoteInvoke(apiRequest).then(
        
        // Success (Maybe)
        function (result) {

            // Debugging
            console.log('Response -> ');
            console.log(result);

            // Check for Errors
            var resp = angular.fromJson(result);
            if (hasErrors(resp, control, scp)) return;            

            // See if we have the response contains information from MTS (Multi-Transaction Service)
            // MTS breaks the API request up so that we can avoid exceeding governor limits.  The implication
            // is that we need to make the API request again and include the MTS key to get the complete API response
            if (resp.nexttransaction && resp.nexttransaction.rest && resp.nexttransaction.rest.params && resp.nexttransaction.rest.params.multiTransactionKey) {

                console.warn("Multi-Transaction Service (MTS) was triggered, requesting update!");

                // Re-encode the API Request with the MTS Key
                apiRequest = createAPIRequest(offer, control, scp, resp.nexttransaction.rest.params.multiTransactionKey);

                // Re-send the API Request
                scp.bpService.OmniRemoteInvoke(apiRequest).then(

                    function (result) {

                        console.log('Response -> ');
                        console.log(result);

                        // Check for Errors
                        var resp = angular.fromJson(result);
                        if (hasErrors(resp, control, scp)) return;

                        // Save the response details to OmniScript data
                        saveResponse(resp, scp);

                        // Stop the spinning dots
                        scp.$root.loading = false;

                        // Auto-Advance if necessary
                        if (autoAdvance) nextStep(scp);
                    },
                    function (error) {

                        scp.$root.loading = false;
                        console.error('API Error -> ' + JSON.stringify(error));
                        scp.handleRemoteCallError(control, resp.error, true, false);
                    }
                );
             }
             else {

                // Save the response details to OmniScript data
                saveResponse(resp, scp);

                // Stop the spinning dots
                scp.$root.loading = false;

                // Auto-Advance if necessary
                if (autoAdvance) nextStep(scp);
            }
        },
        function (error) {

            scp.$root.loading = false;
            console.error('API Error -> ' + JSON.stringify(error));
            scp.handleRemoteCallError(control, resp.error, true, false);
        }
    );
};

baseCtrl.prototype.addOfferToBasketV2 = function(offer, control, scp, autoAdvance) {

    // Debugging
    console.log(offer.addtocart.rest.params.offer);

    scp.bpTree.response.offerCode    = offer.addtocart.rest.params.offer;
    scp.bpTree.response.basketAction = offer.addtocart.rest.params.basketAction;
    // Auto-Advance if necessary
    if (autoAdvance) nextStep(scp);
    return;

    if (!offer.addtocart) return;
};