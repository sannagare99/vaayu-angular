app.controller('constraintController', function ($scope, $http, $state) {


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
});