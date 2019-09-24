'use strict';

// Register `phoneList` component, along with its associated controller and template
angular.
  module('app').
  component('addDistance', {
    templateUrl: './views/add_distance.html',
    controller: function GuardController() {
        this.$onInit = () => {
            console.log('onInit called addDistance' );
        }
    }
  });
