var app = angular.module('app', ['ui.router','dndLists','rzSlider','ngResource']);


// Define all the routes below
app.config(function (
    $stateProvider,
    $urlRouterProvider
) {
    $stateProvider
        .state("routing", {
            url: "/route",
            templateUrl: "route.html",
            controller: "routeCtrl"
        })
        .state('roster', { 
            url : '/roster', 
            templateUrl : "roster.html", 
            controller : "rosterCtrl"
        }) 
        .state('tripboard', { 
            url : '/tripboard', 
            templateUrl : "trip_board.html", 
            controller : "tripboardCtrl"
        }) 
        .state('constraints', { 
            url : '/constraint', 
            templateUrl : "Constraint.html", 
            controller : "tripboardCtrl"
        }) 
        .state('contract', { 
            url : '/contract', 
            templateUrl : "contract.html", 
            controller : "tripboardCtrl"
        }) 

    $urlRouterProvider.otherwise("/tripboard");
});