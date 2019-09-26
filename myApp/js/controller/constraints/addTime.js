'use strict';

// Register `phoneList` component, along with its associated controller and template
angular.
  module('app').
  component('addTime', {
    templateUrl: './views/add_time.html',
    controller: function GuardController($http, $scope, SessionService, ToasterService) {

      this.siteID = "";


      this.$onInit = () => {
        console.log('onInit called addTime');
      }

      // $scope.$on("onSiteListReceived", (evt, list) => {
      //   this.siteNames = list;
      // });

      $scope.submitForm = function (isValid) {
        console.log($scope.$parent.siteID)
        console.log($scope.distance)

        $scope.submitted = true;
        if ($scope.$parent.siteID == null) {
          ToasterService.showError('Error', 'Select Site Name');
          return true;
        }
        if (isValid) {
          $scope.addTime();
        }

      };

      $scope.hasError = function (field, validation) {
        // console.log($scope.form)
        if (validation) {
          return ($scope.form[field].$dirty && $scope.form[field].$error[validation]) || ($scope.submitted && $scope.form[field].$error[validation]);
        }
        return ($scope.form[field].$dirty && $scope.form[field].$invalid) || ($scope.submitted && $scope.form[field].$invalid);
      };

      $scope.addTime = () => {
        $http({
          method: 'POST',
          url: 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com/' + 'constraint/insert',
          headers: {
            'Content-Type': 'application/json',
            'uid': SessionService.uid,
            'access_token': SessionService.access_token, //'8HP_3YQagGCUoWCXiCR_cg'
            'client': SessionService.client//'DDCqul04WXTRkxBHTH3udA',
          },
          data: { 
            siteId: parseInt($scope.$parent.siteID),
            type: 'time',
            clause: 'total_time',
            operator: 'less_than',
            value: parseInt($scope.distance)
          }
        })
          .then(function (res) {
            console.log(JSON.stringify(res));
            if (res.data['success']) {
              ToasterService.showSuccess('Success', 'Constraint added successfully');
              $scope.$parent.fetchConstraintList($scope.$parent.siteID);
            } else {
              ToasterService.showError('Error', res.data['message']);
            }
          }).catch(err => {
            console.log(err);
            ToasterService.showError('Error', 'Something went wrong, Try again later.');
          });
      }
      
    }
  });
