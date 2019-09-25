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


      // $scope.$on("onSiteListReceived", (evt, list) => {
      //   this.siteNames = list;
      // });

      $scope.hasError = function (field, validation) {
        if (validation) {
          return ($scope.form[field].$dirty && $scope.form[field].$error[validation]) || ($scope.submitted && $scope.form[field].$error[validation]);
        }
        return ($scope.form[field].$dirty && $scope.form[field].$invalid) || ($scope.submitted && $scope.form[field].$invalid);
      };

      $scope.submitGuard = function (isValid) {
        console.log($scope.$parent.siteID)
        $scope.submitted = true;
        if ($scope.$parent.siteID == null) {
          alert('Select Site Name');
          return true;
        }
        if (isValid) {
          $scope.addGuard();
        }

      };

      $scope.addGuard = () => {
        $http({
          method: 'POST',
          url: 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com/' + 'constraint/insert',
          headers: {
            // 'Content-Type': 'application/json',
            'uid': 'deekshithmech@gmail.com',
            'access_token': '8HP_3YQagGCUoWCXiCR_cg',
            'client': 'DDCqul04WXTRkxBHTH3udA',
          },
          data: { 
            siteId: $scope.$parent.siteID,
            type: 'guard',
            for : $scope.for,
            event: $scope.event,
            when: $scope.when,
            fromTime: $scope.fromTime,
            toTime: $scope.toTime,
          }
        })
          .then(function (res) {
            if (res.data['success']) {
              
              console.log(JSON.stringify(res.data))
            } else {
              alert(res.data['message']);
            }
          }).catch(err => {
            console.log(err)
          });
      }
      
    }
  });
