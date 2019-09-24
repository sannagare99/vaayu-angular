'use strict';

// Register `phoneList` component, along with its associated controller and template
angular.
  module('app').
  component('createGuard', {
    templateUrl: './views/add_guard.html',
    controller: function GuardController($scope, $http) {

      this.siteID = "";

      this.$onInit = () => {
        console.log('onInit called createGuard');
      }


      $scope.$on("onSiteListReceived", (evt, list) => {
        this.siteNames = list;
      });
    }


  });
