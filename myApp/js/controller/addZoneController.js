'use strict';

// Register `phoneList` component, along with its associated controller and template
angular.
  module('app').
  component('addZone', {
    templateUrl: './views/add_zone.html',
    controller: function AddZoneController($http) {
        this.$onInit = () => {
            console.log('onInit called');
            this.fetchSiteList();
        }

        this.siteNames = [];
        this.siteID = null;
        this.siteName = null;
        this.siteLat = null;
        this.siteLong = null;
        this.zipcode = null;

        this.fetchSiteList = () => {
       
            $http({
                method: 'POST',
                url: 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com:8001/api/v1/getAllSiteList',
                headers: {
                  'Content-Type': 'application/json',
                  'uid': 'deekshithmech@gmail.com',
                  'access_token': 'h-Hen_PE9YDkOTa-HLjMVw',
                  'client': 'A50BtzCIieAvpcTk2450ew'
                },
                data: { test: 'test' }
               })
            .then(res =>  { 
                if (res.data['success']) {
                    this.siteNames = res.data.data.list;
                    console.log(JSON.stringify(this.siteNames))
                } else {
                    alert(res.data['message']);
                }
             });
        };
    
    
        this.submitForm = () => {
            // console.log($scope.zipcode);
            // console.log($scope.siteName);
            // console.log($scope.siteID);
            // console.log($scope.siteLat);
            // console.log($scope.siteLong);
        }
    
    }
  });
