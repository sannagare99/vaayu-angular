'use strict';

// Register `phoneList` component, along with its associated controller and template
angular.
  module('app').
  component('createGuard', {
    templateUrl: './views/add_guard.html',
    controller: function GuardController() {
        this.$onInit = () => {
            console.log('onInit called createGuard');
        }
    }
  });