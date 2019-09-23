angular.module('app').config(["$stateProvider","$urlRouterProvider",function (
    $stateProvider,
    $urlRouterProvider
) {
    $stateProvider
        .state("routing", {
            url: "/route",
            controller: "routeCtrl"
        })
        .state('Login', { 
            url : '/login', 
            controller : "routeCtrl"
        }) 
}]);