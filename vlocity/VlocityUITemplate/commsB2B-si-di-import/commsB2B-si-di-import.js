vlocity.cardframework.registerModule.controller('siController_jw1zr', ['$rootScope', '$scope', '$filter', function($rootScope, $scope, $filter, $route) {

            // Wraps functions in an error catcher to return a default value
            // Errors happen a lot when the selectable item does not yet have data
            function trier(x, defvalue) {
                return function () {
                    try {
                        return x();
                    } catch (e) {
                        // console.log(e);
                    }
                    return defvalue;
                }
            }

            $scope.showList = trier(function() {
                try {
                    if ($scope.control.vlcSI[$scope.control.itemsKey].length >= 0) {
                        return true;
                    }
                } catch (e) {
                    // Nothing
                }
                return false;
            },false);

            $scope.pageSize = 10;
            $scope.pageStart = 0;
            $scope.availablePaginations = [10, 20, 30, 50, 100];

            $scope.numItems = trier(function () {
                return $scope.control.vlcSI[$scope.control.itemsKey].length;
            },1);
            $scope.numPages = trier(function () {
                return 1 + Math.floor(Math.max(0,($scope.control.vlcSI[$scope.control.itemsKey].length-1) / $scope.pageSize));
            },1);

            $scope.currentStart = trier(function () {
                if ($scope.pageStart >= $scope.control.vlcSI[$scope.control.itemsKey].length) {
                    $scope.pageStart = 0;
                }
                return 1 + $scope.pageStart / $scope.pageSize;    // Users aren't origin zero
            },1);

            $scope.canNextPage = trier(function() {
                return ( ($scope.pageStart+$scope.pageSize) < $scope.control.vlcSI[$scope.control.itemsKey].length)
            }, false);

            $scope.listNextPage = function() {
                $scope.pageStart += $scope.pageSize;
                // alert($scope.pageStart);
            };

            $scope.canPrevPage = trier(function() {
                return $scope.pageStart != 0;
            }, false);

            $scope.listPrevPage = function() {
                $scope.pageStart = Math.max(0,$scope.pageStart - $scope.pageSize);
                //alert($scope.pageStart);
            };


}]);

baseCtrl.prototype.$scope.doSelectAll = function(ctrl,ths) {
  for (let i=0;i<ctrl.vlcSI.recSet.length;i++) {
    ctrl.vlcSI.recSet[i]['vlcSelected'] = false;
    baseCtrl.prototype.$scope.onSelectItem(ctrl, ctrl.vlcSI.recSet[i], i, ths, true);
  }
}

baseCtrl.prototype.$scope.doDeselectAll = function(ctrl,ths) {
  for (let i=0;i<ctrl.vlcSI.recSet.length;i++) {
    ctrl.vlcSI.recSet[i]['vlcSelected'] = true;
    baseCtrl.prototype.$scope.onSelectItem(ctrl, ctrl.vlcSI.recSet[i], i, ths, true);
  }
}