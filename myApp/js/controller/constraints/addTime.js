'use strict';

// Register `phoneList` component, along with its associated controller and template
angular.
  module('app').
  component('addTime', {
    templateUrl: './views/add_time.html',
    controller: function GuardController() {
        this.$onInit = () => {
            console.log('onInit called addTime');
        }
    }
  });
