'use strict';

// Register `phoneList` component, along with its associated controller and template
angular.
  module('app').
  component('addDistance', {
    templateUrl: './views/add_distance.html',
    controller: function GuardController($scope) {

      this.siteID = "";

      this.$onInit = () => {
        console.log('onInit called addDistance');
      }

      $scope.$on("onSiteListReceived", (evt, list) => {
        this.siteNames = list;
      });
    }
  });
