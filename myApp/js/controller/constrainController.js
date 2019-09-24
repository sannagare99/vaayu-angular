app.controller('constraintController', function ($scope, $http, $state) {

    this.$onInit = () => {
        $scope.fetchSiteList();
    }
    

    $scope.reset =function() {
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
        .then(function(response){ 
            console.log(JSON.stringify(response))
         });
    };

   
});