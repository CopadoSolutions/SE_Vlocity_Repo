/**
 * This Controller is used to manage a list of Site Configurations.
 * 
 */
vlocity.cardframework.registerModule.controller('SiteConfigurationController', ['$rootScope', '$scope', '$filter', function($rootScope, $scope, $filter, $route) {

    /**
     * This function ensures that the data is a list that can be iterated over.  This is useful in OmniScripts as
     * often times a single object is not represented as a list (even though you expect it to be a list).
     * For example, Edit Blocks within an OmniScript do not present a single entry as a list object until you add a second entry.
     * We want to be sure we always get a list even if it contains only 1 entry.
     * 
     * @param data  The data to examine
     * 
     * @return If the data is already a list it will be returned, if the data is an object it will be added to a single-entry list
     *         if the data is undefined/null, this function will return that value.
     */
    function asList(data) {
        
        if (data !== undefined && data !== null) {
            
            // If this is already a list, return it immediately.  Otherwise, create a list with a single entry
            if (Array.isArray(data)) return data;
            else return [ data ];
        }
        
        return data;
    };

    /**
     * Initializes a Site Configuration
     */
    $scope.initSite = function(index, entry) {

        if (! $scope.control.response) $scope.control.response = [];

        $scope.control.response[index] = entry;

        // Billing Accounts
        $scope.control.response[index].billingAccountOptions   = asList($scope.bpTree.response.BillingAccounts);
        $scope.control.response[index].billingAccountSelection = null;

        // Lookup the Service Qualification Details in the OmniScript JSON
        qualEntries = $scope.bpTree.response.QualificationMicroServiceResponse;
        for (let i=0; i<qualEntries.length; i++) {

            if (qualEntries[i][0] === entry.serviceAccountName) {

                // Physical Connection
                $scope.control.response[index].physcon = qualEntries[i][1];

                // Physical Connection - Max Speed
                $scope.control.response[index].physmax = qualEntries[i][2];

                // Bandwidth Type (Fixed vs. Dynamic), defaults to Fixed
                $scope.control.response[index].contype = "Fixed Rate";

                // Managed CPE
                $scope.control.response[index].managedCpe = "Yes";

                // Possible Committed Bandwidth Rates
                bwSplit = qualEntries[i][3].split(',');
                for (let i=0; i<bwSplit.length; i++) bwSplit[i] = bwSplit[i].trim();
                $scope.control.response[index].bwOptions = bwSplit;

                // Selected Bandwidth (defaults to last entry = highest bandwidth)
                $scope.control.response[index].bwSelection = bwSplit[bwSplit.length - 1];
            }
        }

        // Lookup the Product Name
        if ($scope.bpTree.response.SelectLineItemsStep.SelectOppyLineItem) $scope.control.response[index].product = $scope.bpTree.response.SelectLineItemsStep.SelectOppyLineItem[0];
    };

    /**
     * This watch is executed any time the model 'control.response' changes and updates the OmniScript JSON
     * 
     */
    $scope.$watch('control.response', function() { 
        
        setData($scope, $scope.control.response); 
        
    }, true);

}]);

/**
 * Sets the OmniScript JSON data for the given OmniScript component
 * 
 * @param scp  The AngularJS Scope associated with the current OmniScript Component
 * @param data The data to set in the OmniScript
 */
function setData(scp, data) {
	
    if (data) {
        
        // Navigate/Build the node tree where we need to stick the updated data
        let currentNode = scp.bpTree.response;
        
        let namePath = scp.control.JSONPath.split(":");
        for (let i=0; i < namePath.length; i++) {

            // Add this branch if it doesn't yet exist
            if (! namePath[i] in currentNode) currentNode[namePath[i]] = {};

            // If we are at the final branch, assign the value
            if (i === namePath.length - 1) currentNode[namePath[i]] = data;
            else {

                // Continue traversing/creating the node tree (be sure to convert any null values a map!)
                if (currentNode[namePath[i]] == null) currentNode[namePath[i]] = {};
                
                currentNode = currentNode[namePath[i]];
            }
        }     
    }
};