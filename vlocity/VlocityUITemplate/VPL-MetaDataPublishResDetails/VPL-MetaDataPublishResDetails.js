vlocity.cardframework.registerModule.controller('MetaDataPublishResDetails', ['$scope', function($scope,$timeout) {
    $scope.isSuccess = true;
    $scope.notFoundFields = '';
    $scope.notFoundObjects = '';
    $scope.notSyncFields = '';
    $scope.successFieldCount = '';
    $scope.noDataToPublish = false;
    $scope.$watchCollection('bpTree.response.CCIPublishResponse', function(newVal, oldVal) {
        if($scope.bpTree.response.CCIPublishResponse != null ){
            $scope.fileId = $scope.bpTree.response.CCIPublishResponse.createFileObject.FileId;
            if($scope.bpTree.response.CCIPublishResponse.notFoundFields instanceof Array)
                $scope.notFoundFields = $scope.bpTree.response.CCIPublishResponse.notFoundFields.join(',');
            if($scope.bpTree.response.CCIPublishResponse.notFoundObjects instanceof Array)
                $scope.notFoundObjects = $scope.bpTree.response.CCIPublishResponse.notFoundObjects.join(',');
            if($scope.bpTree.response.CCIPublishResponse.syncFailureFields instanceof Array)
                $scope.notSyncFields = $scope.bpTree.response.CCIPublishResponse.syncFailureFields.join(',');
            if($scope.bpTree.response.CCIPublishResponse.syncSuccessFields instanceof Array)
                $scope.successFieldCount = $scope.bpTree.response.CCIPublishResponse.syncSuccessFields.length;
            if(!$scope.bpTree.response.CCIPublishResponse.isFieldsPresentToPublish && 
                ($scope.notFoundFields == null || $scope.notFoundFields == '') && 
                ($scope.notFoundObjects == null || $scope.notFoundObjects == '')){
                    $scope.noDataToPublish = true;
            }
        }
    });

    $scope.$watchCollection('bpTree.response.success', function(newVal, oldVal) {
        if(newVal != undefined && !newVal ){
            $scope.isSuccess = false;
        }
    });

}]);