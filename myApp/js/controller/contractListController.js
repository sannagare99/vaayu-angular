app.controller('contractListCtrl', function ($scope, $http, $state) {$scope.selectedSiteId;
  this.$onInit = function () {
    $scope.fetchSiteList();

    console.log('onit');
  };
  $scope.getContracts = () => {
    $scope.site=JSON.parse($scope.selectedSiteId);
    console.log( $scope.site)
    $scope.siteName=$scope.site.name;
    $http({
      method: 'GET',
      url: 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com/getContractListByCustId?custId=1&custType='+$scope.tab+'&siteId=' + $scope.site.id,
      headers: {
        'Content-Type': 'application/json',
        'uid': 'deekshithmech@gmail.com',
        'access_token': 'jC4xE4k46tSzQNVZwqOAuA',
        'client': 'czgRN-x624Fsp05tmKE0dg'
      },
      data: { test: 'test' }
    })
      .then(function (res) {
        if (res.data['success']) {
          $scope.contractList = res.data;
          // $scope.$broadcast('onSiteListReceived',res.data.data.list);
          console.log(JSON.stringify($scope.contractList))
        } else {
          alert(res.data['message']);
        }

      }).catch(err => {
        console.log(err)
      });
  }
  $scope.fetchSiteList = () => {

    $http({
      method: 'POST',
      url: 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com:8001/api/v1/getAllSiteList',
      headers: {
        'Content-Type': 'application/json',
        'uid': 'deekshithmech@gmail.com',
        'access_token': 'h-Hen_PE9YDkOTa-HLjMVw',
        'client': 'A50BtzCIieAvpcTk2450ew'
      },
      data: { test: 'test' }
    })
      .then(function (res) {
        if (res.data['success']) {
          $scope.siteList = res.data.data.list;
          // $scope.$broadcast('onSiteListReceived',res.data.data.list);
          console.log(JSON.stringify($scope.siteList))
        } else {
          alert(res.data['message']);
        }

      }).catch(err => {
        console.log(err)
      });


  };
  $scope.contracts = [{
    cust_id: "23412355-2",
    site: "Adam Denisov",
    file_name: "File Name.csv",
  },
  {
    cust_id: "23412355-2",
    site: "Adam Denisov",
    file_name: "File Name.csv",
  },
  {
    cust_id: "23412355-2",
    site: "Adam Denisov",
    file_name: "File Name.csv",
  },
  {
    cust_id: "23412355-2",
    site: "Adam Denisov",
    file_name: "File Name.csv",
  },
  {
    cust_id: "23412355-2",
    site: "Adam Denisov",
    file_name: "File Name.csv",
  },
  {
    cust_id: "23412355-2",
    site: "Adam Denisov",
    file_name: "File Name.csv",
  },

  ]
  
  $scope.reset = function () {
    $state.reload(true);
  }

  $scope.tab = 'CUSTOMER';

  $scope.setTab = function (tabId) {
    console.log('set tabbed');
    $scope.tab = tabId;
    $scope.getContracts();

  };

  $scope.isSet = function (tabId) {
    return $scope.tab === tabId;
  };
});