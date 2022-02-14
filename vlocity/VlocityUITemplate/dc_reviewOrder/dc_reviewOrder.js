vlocity.cardframework.registerModule.controller('dcReviewOrderController', ['$scope', function($scope) {
    digitalCommerceSDK = null
    $scope.orderSubmitted = false;
    $scope.submittingOrder = false;

    $scope.initialiseSDK = function() {
        digitalCommerceSDK = this.getSDKInstance();
    }
    $scope.showSpinner = function() {
        return $scope.submittingOrder;
    }
    $scope.submitOrder = function(){
        $scope.submittingOrder = true;
        const input = Object.assign(
            digitalCommerceSDK.createSubmitOrderInput(),
            {
                email: this.bpTree.response.Authenticate.email,
                catalogCode: this.bpTree.response.catalogCode,
                cartContextKey: this.bpTree.response.cartContextKey
            }
        );
        if (this.bpTree.response.orderId) {
            input.orderId = this.bpTree.response.orderId;
        }

        // SDK call
        digitalCommerceSDK.submitOrder(input)
            .then(response => {
                $scope.submittingOrder = false;
                $scope.orderSubmitted = true;
                this.bpTree.response.orderId = response.orderId;
                this.autoAdvance("next");
            })
            .catch(error => {
                $scope.submittingOrder = false;
                $scope.$apply(function () {
                    $scope.submittingOrder = false;
                });
                console.log('Submit order failed');
            });    
    }

    // load the SDK
    $scope.initialiseSDK();
}]);