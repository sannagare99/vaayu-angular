'use strict';

// Register `phoneList` component, along with its associated controller and template
angular.
  module('app').controller('addZone', function ($scope, $http, $state, SessionService, ToasterService) {
      this.$onInit = () => {
        console.log('onInit called addZone');
        $scope.fetchSiteList();
        
      }

      $scope.site_list = [];
      $scope.siteID = "";
      $scope.zoneName = null;
      $scope.latitude = null;
      $scope.longitude = null;
      $scope.zipcode = null;

      $scope.fetchSiteList = () => {
        $http({
            method: 'POST',
            url: 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com:8001/api/v1/getAllSiteList',
            headers: {
                'Content-Type': 'application/json',
                'uid': SessionService.uid,
                'access_token': SessionService.access_token,
                'client': SessionService.client
            },
            data: { test: 'test' }
        }).then(res => {
                if (res.data['success']) {
                    $scope.site_list = res.data.data.list;
                    console.log('addzone sites = '+JSON.stringify($scope.site_list))
                } else {
                    alert(res.data['message']);
                }
            }).catch(err => {
                console.log(err)
            });
      };

      // $scope.$on("onSiteListReceived", (evt, list) => {
      //   this.siteNames = list;
      // });

      $scope.hasError = function (field, validation) {
        if (validation) {
          return ($scope.form[field].$dirty && $scope.form[field].$error[validation]) || ($scope.submitted && $scope.form[field].$error[validation]);
        }
        return ($scope.form[field].$dirty && $scope.form[field].$invalid) || ($scope.submitted && $scope.form[field].$invalid);
      };


      $scope.submitZone =  (isValid) =>  {
        console.log($scope.site_list);
        console.log(SessionService.uid)
        $scope.submitted = true;
      
        if ($scope.siteID == null) {
          // alert('Select Site Name');
          ToasterService.showError('Error', 'Select Site Name');
        } else if (isValid) {
          $scope.addZone();
        }
       
      };

      $scope.addZone = () => {

        let data  = {
            site_id: parseInt($scope.siteID),
            name: $scope.zoneName,
            latitude: $scope.latitude+'',
            longitude: $scope.longitude+'',
            zipcode: $scope.zipcode+''

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
          .then( (res) => {
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

  });
