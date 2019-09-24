var app = angular.module('app', ['ui.router','dndLists','rzSlider','ngResource']);


// Define all the routes below
app.config(function (
    $stateProvider,
    $urlRouterProvider
) {
    $stateProvider
        .state("routing", {
            url: "/route",
            templateUrl: "./views/route.html",
            controller: "routeCtrl"
        })
        .state('roster', { 
            url : '/roster', 
            templateUrl : "./views/roster.html", 
            controller : "rosterCtrl"
        }) 
        .state('tripboard', { 
            url : '/tripboard', 
            templateUrl : "./views/trip_board.html", 
            controller : "tripboardCtrl"
        }) 
        .state('constraint', { 
            url : '/constraint', 
            templateUrl : "./views/constraint.html", 
            controller : "constraintController"
        }) 
        .state('contract', { 
            url : '/contract', 
            templateUrl : "./views/contract.html", 
            controller : "tripboardCtrl"
        }) 

    $urlRouterProvider.otherwise("/tripboard");
});