'use strict';

// Register `phoneList` component, along with its associated controller and template
angular.
  module('app').
  component('addZone', {
    templateUrl: './views/add_zone.html',
    controller: function AddZoneController($scope, $http, toaster, SessionService, ToasterService) {
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
        console.log(SessionService.uid)
        $scope.submitted = true;
      
        if ($scope.$parent.siteID == null) {
          // alert('Select Site Name');
          ToasterService.showError('Error', 'Select Site Name');
        } else if (isValid) {
          $scope.addZone();
        }
       
      };

      $scope.addZone = () => {

        let data  = {
            site_id: parseInt($scope.$parent.siteID),
            name: this.zoneName,
            latitude: this.latitude+'',
            longitude: this.longitude+'',
            zipcode: this.zipcode+''

            // "name":"Dombivali",
            // "site_id":10,
            // "latitude":"19.2094",
            // "longitude":"73.0939",
            // "zipcode":"421202"
        }
        console.log('body'+JSON.stringify(data))
        $http({
          method: 'POST',
          url: 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com/' + 'createZones',
          headers: {
            'Content-Type': 'application/json',
            'uid': SessionService.uid,
            'access_token': SessionService.access_token, //'8HP_3YQagGCUoWCXiCR_cg'
            'client': SessionService.client//'DDCqul04WXTRkxBHTH3udA',
          },
          data: data
        })
          .then(function (res) {
            console.log(JSON.stringify(res));
            if (res.data['success']) {
              ToasterService.showSuccess('Success', 'Zone added successfully.');
              console.log(JSON.stringify(res.data))
            } else {
              ToasterService.showError('Error', res.data['message']);
            }
          }).catch(err => {
            console.log(err)
            ToasterService.showError('Error', 'Something went wrong, Try again later.');
          });
      }

    }
  });
