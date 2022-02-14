vlocity.cardframework.registerModule.controller('dcPaymentController', ['$scope','$sce', function($scope,$sce) {

    $scope.paymentUrl = function(){
      var url = "https://vlocity-dc-braintree-checkout.herokuapp.com/";
      if(this.bpTree && this.bpTree.response.total){
        url += "?amount=" + this.bpTree.response.total;
      }
      return $sce.trustAsResourceUrl(url);
    }

    $scope.initPaymentCallback = function(){
      this.bpTree.response.paymentDone = "yes";
      window.addEventListener(
      "message",
      e => {
        if (e.data && e.data.success) {
          this.bpTree.response.paymentDone = "yes";
          let _transactionDetails = e.data.transaction.creditCard;
          this.bpTree.response.Payment = Object.assign(
            {},
            {
              paymentReceived: true,
              transactionId: e.data.transaction.networkTransactionId,
              cardType: _transactionDetails.cardType,
              expirationDate: _transactionDetails.expirationDate,
              cardNumber: _transactionDetails.maskedNumber
            }
          );
          setTimeout(()=>{
            this.autoAdvance("next");
          },350);
        }
      },
      false
    );
  }
   $scope.initPaymentCallback();
}]);