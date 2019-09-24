'use strict';

// Register `phoneList` component, along with its associated controller and template
angular.
  module('app').
  component('phoneList', {
    templateUrl: './phone-list.template.html',
    controller: function PhoneListController() {
      this.phones = [
        {
          name: 'Nexus S',
          snippet: 'Fast just got faster with Nexus S.'
        }, {
          name: 'Motorola XOOM™ with Wi-Fi',
          snippet: 'The Next, Next Generation tablet.'
        }, {
          name: 'MOTOROLA XOOM™',
          snippet: 'The Next, Next Generation tablet.'
        }
      ];
    }
  });


  // angular.
  // module('app').controller, function PhoneListController() {
  //     this.phones = [
  //       {
  //         name: 'Nexus S',
  //         snippet: 'Fast just got faster with Nexus S.'
  //       }, {
  //         name: 'Motorola XOOM™ with Wi-Fi',
  //         snippet: 'The Next, Next Generation tablet.'
  //       }, {
  //         name: 'MOTOROLA XOOM™',
  //         snippet: 'The Next, Next Generation tablet.'
  //       }
  //     ];
  //   };