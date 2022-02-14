$.getScript('/resource/commsBase_DemoUtils/js/os-utils.js');
$.getScript('/resource/commsBase_DemoUtils/js/os-cpq-javascript.js');

// global variables
var scp = null;
var lib = null;
var stepData = null;
var cpqClient = null;
var progress = 0;
var progressIncrement = null;
var debug = false;

/**
 * Updates the progress bar status.  You should update this function to point to the step & elements you are using
 * to monitor the progress.  By default we are assuming:
 * 
 * Step "CPQProgress"
 *   TextArea "progress"   
 *
 * @param value   The progress value (0-100) to set
 * @param status  A text description of the current progress to display (optional)
 * 
 */
function setProgress(value, status) {

	progress = value;

	if (debug) console.log("Progress " + progress + "%");
	
	lib.setElementData("CPQProgress:progress", progress);
	if (status)	lib.setElementData("CPQProgress:progressStatus", status);
}

/**
 * increments the progress bar
 *
 * @param status  A description of the next action (optional)
 */
function bumpProgress(status) {

	let val = Math.ceil(progress + progressIncrement);
  
	if (val >= 100) setProgress(100, "Complete");
	else setProgress(val, status);
}

/**
 * Initializes the Progress Monitoring configuration
 * This function determines the progress increment to use based on all the API calls we will be making.
 * You should update this function by determining all of the API calls you will be making.
 * 
 * @param initialStatus  The initial status to display on the Progress Bar
 */
function initProgress(initialStatus) {

  // Determine number of CPQ API calls we'll need to make
  // +1 call for cart query
  var steps = 1;

  // Add a single offer for each selected Service Account (+1 call/account)
  let serviceAccounts = getStepDataAsList("configuredSites", stepData, lib);
  steps += serviceAccounts.length;
  
  // Configure Attributes on each offer (+1 call/account)
  steps += serviceAccounts.length;
  
  // Calculate progress increment value
  progressIncrement = 100/steps;
  
  if (debug) console.log("Progress Initialization (Total Steps = " + steps + ")");
  
  setProgress(0, initialStatus);
};

/**
 * Generates an order based on the data captured within the OmniScript.  Due to the asynchronous nature
 * of calling the CPQ APIs, this function uses a series of callback functions to perform work once each API response
 * is received.  Think of this as chains of functions that will be called.
 * 
 * The CPQClient enforces serialization of API requests so only 1 request will ever be sent at a time.
 * 
 * @param $scope    Provides access to the underlying OmniScript infrastructure and data
 * @param path      An array with incremental steps leading from $scope to the set values element that triggered the function
 * @param library   An object with a collection of functions that might be useful to your code (os-sv-javascript)
 * @param valueMap  A JavaScript dictionary with the key:value pairs in the set values statement
 */
function configureQuote($scope, path, library, valueMap) {

	//console.log(valueMap);	
	
	// set the global variables
	scp       = $scope;
	lib       = library;
	stepData  = valueMap;
	debug     = getStepData("debug", stepData, lib);
    cartId    = getStepData("cartId", stepData, lib);
	cpqClient = new CPQClient(scp, { "useApex": true, "debug": debug });
	
	// Initialize Progress
	initProgress("Configuring Multi-Site Order");

	// Reference for the Cart
	cpqCart = new Cart({"details": {"records": [{"Id": cartId}]}});
	
	// Configure the sites
	configureSites();
};

/**
 * Configures the selected offer for each configured service account
 * 
 */
function configureSites() {
	
	// Order Queried, add offers for each Configured Site
	let sites = getStepDataAsList("configuredSites", stepData, lib);	

	// Update Status
	bumpProgress("Configuring " + sites.length + " Sites");
	
	for (let i=0; i<sites.length; i++) {
		
		fields2update = { "%vlocity_namespace%__ServiceAccountId__c": sites[i].serviceAccountId};
		if (sites[i].billingAccountSelection) {
			fields2update["%vlocity_namespace%__BillingAccountId__c"] = sites[i].billingAccountSelection.billingAccountId;
		}

		// No need to query the product again, pull the Id from the site data
		let product = new Product({"Id": sites[i].product.PricebookEntryId});
		
		// Add the line item
		cpqClient.addLineItem(cpqCart, product, null, fields2update, function(lineItems) {
			
			for (let x=0; x<lineItems.length; x++) configureLineItem(lineItems[x], sites[i]);
		});
	}
};

/**
 * Configures the Line Item
 * 
 * @param lineItem  The line item added to the cart
 * @param site      The site configuration in OmniScript for the line item
 */
function configureLineItem(lineItem, site) {
	
	// Line Item Added
	bumpProgress("Configuring Site : " + site.serviceAccountName);

	// Configure Attributes
	lineItem.setAttribute("ATTR-PLAN-001", site.contype);       // Usage Type - Fixed Rate vs. Dynamic Rate
	lineItem.setAttribute("ATTRIBUTE-153", site.physmax);       // Access Speed
	lineItem.setAttribute("ATT-ATTR-BW-003", site.bwSelection); // Committed Bandwidth
	
	// Access Type
	if (site.physcon.includes("T1") || site.physcon.includes("T3")) lineItem.setAttribute("ATTRIBUTE-152", "Private Line");
	else lineItem.setAttribute("ATTRIBUTE-152", "Ethernet");
	
	// Customer Owned CPE Router
	if (site.managedCpe === "Yes") lineItem.setAttribute("B2B-ATTR-CUSTOMER-CPE-ROUTER", "No");
	else lineItem.setAttribute("B2B-ATTR-CUSTOMER-CPE-ROUTER", "Yes");
	
		
	// Update the line item in the cart
	cpqClient.updateLineItem(cpqCart, lineItem, function() {
		
		// attribute configuration is complete
		bumpProgress();
	});
};