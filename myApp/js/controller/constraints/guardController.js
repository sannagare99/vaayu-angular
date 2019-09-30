'use strict';

// Register `phoneList` component, along with its associated controller and template
app.controller('createGuard', function ($scope, $http, SessionService, ToasterService) {

      $scope.when = ''
      $scope.event = ''

      this.$onInit = () => {
        console.log('onInit called createGuard');
      }


      // $scope.$on("onSiteListReceived", (evt, list) => {
      //   this.siteNames = list;
      // });

      $scope.hasError = function (field, validation) {
        // console.log($scope.form)
        if (validation) {
          return ($scope.form[field].$dirty && $scope.form[field].$error[validation]) || ($scope.submitted && $scope.form[field].$error[validation]);
        }
        return ($scope.form[field].$dirty && $scope.form[field].$invalid) || ($scope.submitted && $scope.form[field].$invalid);
      };

      $scope.submitForm = function (isValid) {
        console.log($scope.$parent.siteID)
        console.log($scope.for)
        console.log($scope.when)
        console.log($scope.event)
        console.log($scope.from_time)
        console.log($scope.to_time)

        console.log(moment($scope.to_time))

        $scope.submitted = true;
        if ($scope.$parent.siteID == null) {
          ToasterService.showError('Error', 'Select Site Name');
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
            'Content-Type': 'application/json',
            'uid': SessionService.uid,
            'access_token': SessionService.access_token, //'8HP_3YQagGCUoWCXiCR_cg'
            'client': SessionService.client//'DDCqul04WXTRkxBHTH3udA',
          },
          data: { 
            siteId: parseInt($scope.$parent.siteID),
            type: 'guard',
            for : $scope.for, //male
            event: $scope.event, // pick drop
            when: $scope.when, // first last
            fromTime: $scope.from_time,
            toTime: $scope.to_time,
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
            console.log(err)
            ToasterService.showError('Error', 'Something went wrong, Try again later.');
          });
      }
      
  });
