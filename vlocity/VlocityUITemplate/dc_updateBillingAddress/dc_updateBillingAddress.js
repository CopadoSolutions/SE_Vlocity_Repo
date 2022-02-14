vlocity.cardframework.registerModule.controller('dcBillingAddressController', ['$scope', function($scope) {
    digitalCommerceSDK = null;
    $scope.savingAddress = false;

    $scope.initialiseSDK = function() {
        digitalCommerceSDK = this.getSDKInstance();
        if(this.bpTree.response.orderId) {
            this.bpTree.response.Authenticate = {};
            this.bpTree.response.Authenticate.email = this.bpTree.response.email;
            this.bpTree.response.Authenticate.name = this.bpTree.response.name;
        }
    }

    $scope.showSpinner = function() {
        return $scope.savingAddress;
    }

    $scope.updateBillingAddress = function() {
        $scope.savingAddress = true;
        this.bpTree.response.billingAddress = "yes";
        let input = $scope.saveBillingDetailsGetInput();
        digitalCommerceSDK.updateBillingDetails(input)
        .then(response => {
            this.bpTree.response.billingAddress = "yes";
            $scope.savingAddress = false;
            this.autoAdvance("next");
        })
        .catch(error => {
            $scope.savingAddress = false;
            console.error('Error in updating address ',error);
        });
    }
    $scope.saveBillingDetailsGetInput = function() {
        return Object.assign(
            digitalCommerceSDK.createUpdateBillingDetailsInput(),
            {
                email: this.bpTree.response.Authenticate.email,
                billingCity: this.bpTree.response.UpdateBillingAddress.Billing.BillingCity,
                billingState: this.bpTree.response.UpdateBillingAddress.Billing.BillingState,
                billingAddress: this.bpTree.response.UpdateBillingAddress.Billing.BillingAddress,
                billingZipCode: this.bpTree.response.UpdateBillingAddress.Billing.BillingZIPCode,
                shippingCity: this.bpTree.response.UpdateBillingAddress.Shipping.ShippingCity,
                shippingState: this.bpTree.response.UpdateBillingAddress.Shipping.ShippingState,
                shippingAddress: this.bpTree.response.UpdateBillingAddress.Shipping.ShippingAddress,
                shippingZipCode: this.bpTree.response.UpdateBillingAddress.Shipping.ShippingZIPCode,
            }
        );
    }
    $scope.initialiseSDK();
}]);