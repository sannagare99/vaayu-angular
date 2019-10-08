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
        
        if (res.data['success']) {
          $scope.constraintList = res.data.data;
          for (i = 0; i < $scope.constraintList.length; i++) {
            if ( $scope.constraintList[i].type === 'time') {
              $scope.max_trip_time = $scope.constraintList[i].value;
            } else if ( $scope.constraintList[i].type === 'distance') {
              $scope.distance =  $scope.constraintList[i].value;
            }
            
          }
          console.log($scope.constraintList);
          arr = $scope.constraintList.sort((a, b) => a.id > b.id ? -1 : 1);
          
        } else {
          alert(res.data['message']);
        }
      }).catch(err => {
        console.log(err)
        // ToasterService.showError('Error', 'Something went wrong, Try again later.');
      });
  }


  $scope.sortByKey = (array, key) => {
    return array.sort(function(a, b) {
        var x = a[key];
        var y = b[key];

        if (typeof x == "string")
        {
            x = (""+x).toLowerCase(); 
        }
        if (typeof y == "string")
        {
            y = (""+y).toLowerCase();
        }

        return ((x > y) ? -1 : ((x < y) ? 1 : 0));
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