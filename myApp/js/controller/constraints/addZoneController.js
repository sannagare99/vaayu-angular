'use strict';

// Register `phoneList` component, along with its associated controller and template
angular.
  module('app').
  component('addZone', {
    templateUrl: './views/add_zone.html',
    controller: function AddZoneController($scope, $http, toaster) {
      this.$onInit = () => {
        console.log('onInit called addZone');
        this.fetchSiteList();
      }

      this.siteNames = [];
      this.siteID = "";
      this.zoneName = null;
      this.latitude = null;
      this.longitude = null;
      this.zipcode = null;

      this.fetchSiteList = () => {
        // $http({
        //     method: 'POST',
        //     url: 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com:8001/api/v1/getAllSiteList',
        //     headers: {
        //         'Content-Type': 'application/json',
        //         'uid': 'deekshithmech@gmail.com',
        //         'access_token': 'h-Hen_PE9YDkOTa-HLjMVw',
        //         'client': 'A50BtzCIieAvpcTk2450ew'
        //     },
        //     data: { test: 'test' }
        // }).then(res => {
        //         if (res.data['success']) {
        //             this.siteNames = res.data.data.list;
        //             console.log(JSON.stringify(this.siteNames))
        //         } else {
        //             alert(res.data['message']);
        //         }
        //     }).catch(err => {
        //         console.log(err)
        //     });
      };

      $scope.$on("onSiteListReceived", (evt, list) => {
        this.siteNames = list;
      });

      $scope.hasError = function (field, validation) {
        if (validation) {
          return ($scope.form[field].$dirty && $scope.form[field].$error[validation]) || ($scope.submitted && $scope.form[field].$error[validation]);
        }
        return ($scope.form[field].$dirty && $scope.form[field].$invalid) || ($scope.submitted && $scope.form[field].$invalid);
      };


      $scope.submitZone = function (isValid) {
        console.log($scope.$parent.siteID)
        $scope.submitted = true;
      //   toaster.pop({
      //     type: 'error',
      //     title: 'Title text',
      //     body: 'Body text',
      //     timeout: 100000
      // });

        // check to make sure the form is completely valid
        if (isValid) {
          
        }

      };

    }
  });
