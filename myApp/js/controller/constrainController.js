app.controller('constraintController', function ($scope, $http, $state, SessionService) {

  $scope.siteNames = [];
  $scope.siteID = null;
  $scope.siteName = null;
  $scope.siteLat = null;
  $scope.siteLong = null;
  $scope.zipcode = null;


  this.$onInit = () => {
    $scope.fetchSiteList();
  }


  $scope.reset = function () {
    $state.reload(true);
  }

  $scope.tab = 1;

  $scope.setTab = function (tabId) {
    console.log('set tabbed');
    $scope.tab = tabId;
  };

  $scope.isSet = function (tabId) {

    return $scope.tab === tabId;
  };

  $scope.fetchConstraintList = (id) => {
    $http({
      method: 'GET',
      url: 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com/' + 'constraint/getall/site/'+id,
      headers: {
        // 'Content-Type': 'application/json',
        'uid': SessionService.uid,
        'access_token': SessionService.access_token, //'8HP_3YQagGCUoWCXiCR_cg'
        'client': SessionService.client//'DDCqul04WXTRkxBHTH3udA',
      },
      data: { test: 'test' }
    })
      .then(function (res) {
        if (res.data['success']) {
          $scope.constraintList = res.data.data;
          console.log(JSON.stringify(res.data))
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
        'uid': SessionService.uid,
            'access_token': SessionService.access_token, //'8HP_3YQagGCUoWCXiCR_cg'
            'client': SessionService.client//'DDCqul04WXTRkxBHTH3udA',
      },
      data: { test: 'test' }
    })
      .then(function (res) {
        if (res.data['success']) {
          $scope.siteNames = res.data.data.list;
          $scope.$broadcast('onSiteListReceived', res.data.data.list);
          console.log(JSON.stringify($scope.siteNames))
        } else {
          alert(res.data['message']);
        }

      }).catch(err => {
        console.log(err)
      });
  };


  $scope.getFormattedTime = (time) => {
    console.log(moment(time));
    moment(time)
  };


});