vlocity.cardframework.registerModule.controller('selectSite', ['$scope', function($scope) {
    $scope.siteOptions = [];
    $scope.$watchCollection('bpTree.response.site', function(newVal, oldVal) {
        if(newVal && newVal !== null && Array.isArray(newVal)){
            $scope.siteOptions = $scope.bpTree.response.site;
        }
    });
}]);