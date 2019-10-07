app.controller('constraintController', function ($scope, $http, $state, SessionService, ToasterService) {

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
    console.log(SessionService.uid);
    console.log(SessionService.access_token);
    console.log(SessionService.client);
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
    }).then(function (res) {
        console.log(JSON.stringify(res))
        if (res.data['success']) {
          $scope.constraintList = res.data.data;
          for (i = 0; i < $scope.constraintList; i++) {
            if (constraintList[i].type === 'time') {
              $scope.time_data = constraintList[i];
            } else if (constraintList[i].type === 'distance') {
              $scope.distance_data = constraintList[i];
            }
            
          }
          console.log($scope.constraintList);
        } else {
          alert(res.data['message']);
        }
      }).catch(err => {
        console.log(err)
        // ToasterService.showError('Error', 'Something went wrong, Try again later.');
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
          ToasterService.showError('Error', res.data['message']);
        }

      }).catch(err => {
        console.log(err)
        ToasterService.showError('Error', 'Something went wrong, Try again later.');
      });
  };


  $scope.getFormattedTime = (time) => {
    console.log(moment(time));
    moment(time)
  };


});