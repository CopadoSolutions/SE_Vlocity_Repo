vlocity.cardframework.registerModule.controller('serviceAccountController', ['$rootScope', '$scope', '$filter', function($rootScope, $scope, $filter, $route) {

   /**
     * Selects a Service Account
     * 
     * @param account  A selected service account
     * @param index    The index of the selected account
     * @param control  The OmniScript component definition (i.e. Selectable Items)
     * @param scp      The HTML element / Angular Scope
     */
    $scope.selectAccount = function(account, index, control, scp) {

    	console.log(account);

        // Add Selected accout to the OmniScript
        scp.onSelectItem(control, account, index, scp, true);
    }

}]);