vlocity.cardframework.registerModule.controller('MainCtrl', ['$scope','$rootScope', function($scope, $rootScope) {
// group child assets with parent (bundle = parent, all product/s = child)
let ungroupedAssets = $scope.records.Asset
  $scope.assets = []
  ungroupedAssets.forEach(p => {
          p.child = ungroupedAssets.filter(c => {
              let lastIndex = c.LineNumber.lastIndexOf('.');
              let level = lastIndex > 0 ? c.LineNumber.substring(0, lastIndex) : '';
              if (c.ServiceAccountId == p.ServiceAccountId) {
                return p.LineNumber == level;
              }
          });
      })

$scope.assets = ungroupedAssets.filter(a => a.LineNumber.lastIndexOf('.') < 0);


// sort based on child length 
$scope.assets.sort(function (a, b) {
    return a.child.length - b.child.length;
});

// console.log('assets', $scope.assets)


// start with product name column sorted, a to z
$scope.orderByField = 'Name';
$scope.reverseSort = false;

// checkbox and toggle all
$scope.all_checked = [];
$scope.toggleSelection = function toggleSelection(item) {
    $scope.allSelected = false
    let idx = $scope.all_checked.indexOf(item);
      // is currently selected
    if (idx > -1) {
      $scope.all_checked.splice(idx, 1);
      item.assetChecked = false
      }
        // is newly selected
    else {
      $scope.all_checked.push(item);
      item.assetChecked = true
            }
    if($scope.all_checked.length == $scope.assets.length) {
      $scope.allSelected = true
    }
    console.log('checked items include', $scope.all_checked)
    // console.log('all selected', $scope.allSelected)
}    

  $scope.toggleAll = function toggleAll() {
    if ($scope.all_checked.length && !$scope.allSelected){
      $scope.all_checked = []
      $scope.allSelected = false
      $scope.assets.forEach(i => {
        i.assetChecked = false     
      })
    }
    else {
      $scope.allSelected = true
      $scope.all_checked = [];
      $scope.assets.forEach(i => {
        $scope.all_checked.push(i);
        i.assetChecked = true        
      })
    }
    // console.log('all selected', $scope.allSelected)
    console.log('checked items include', $scope.all_checked)
  }    

// expand to show asset details
$scope.expandSelected=function(asset){
  $scope.assets.forEach(function(val){
    val.expanded=false;
  })
 asset.expanded=true;
 }

 $scope.showAttributes=function(asset){
 asset.showAttributes=true;
 }

// package data for OS
$scope.requestMap = {}

let createRequestMap = function(itemList){
  // console.log('items requested to map', itemList)
  itemList.forEach(function(item, index, array){
    // console.log(item, index, index-1)
        var irm = JSON.stringify($scope.requestMap).indexOf(item.ServiceAccountId);
        var sai = item.ServiceAccountId
      var iid = item.Id
          
    if (irm > -1 ) {
      $scope.requestMap[sai]["assetsList"].push(iid)
      $scope.requestMap[sai]["assets"].push(item)
      // var assetObj = {};
      // assetObj[iid] = item
      // $scope.requestMap[sai]["assetsList"].push(({ [iid]: item }))
            
      // $scope.requestMap[sai]["assetsList"][iid] = item
    }
    else {
       $scope.requestMap[sai] = {
         "serviceAccountId": sai,
         "Location": (item.ServiceAccountName ? item.ServiceAccountName : "No Location Name"),
"Address": (item.ShippingAddress ? item.ShippingAddress.StreetAddress : "No Address"),
"City": (item.ShippingAddress ? item.ShippingAddress.City : "No Address"),
"State": (item.ShippingAddress ? item.ShippingAddress.State : "No Address"),
"ZipCode": (item.ShippingAddress ? item.ShippingAddress.PostalCode : "No Address"),
      "assetsList": [],
      "assets":[item]
       }
       $scope.requestMap[sai]["assetsList"].push(iid)
       
    console.log($scope.requestMap)
    }
})
  //  console.log('final requestMap', $scope.requestMap)
   }

// send data to session storage and launch OS
$scope.saveDataLaunchOS = function (action){
  // sessionStorage.setItem("selectedAssets", JSON.stringify($scope.all_checked))
  // console.log('selectedAssets', $scope.all_checked)
  createRequestMap($scope.all_checked)
  sessionStorage.setItem("requestMap", JSON.stringify($scope.requestMap))
  console.log('final Request Map', $scope.requestMap)
  $scope.performAction(action)
}
  
}]);