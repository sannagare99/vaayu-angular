'use strict';

// Register `phoneList` component, along with its associated controller and template
angular.
  module('app').
  component('createGuard', {
    template: `
      <form name="form" ng-submit="submitForm(form.$valid)" novalidate>
    <div class="tab-content-area ">
        <div class="row mb-2 ">
            <div class="col-md-3 d-flex;">
                <label class="radio-inline mb-0 mr-2" >
                    <input type="radio" name="radioWhen"  class="mr-2"
                    ng-model="when" checked value='first'
                     required >First
                </label>
                <label class="radio-inline  mb-0 mr-2" >
                    <input type="radio" name="radioWhen" class="mr-2" " 
                    ng-model="when" value='last' required>Last
                </label>
                <span ng-show="hasError('radioWhen', 'required')" class="help-block">
                        Field is required.</span>
            </div>

            <div class="col-md-3 ">
                <label class="radio-inline mb-0 mr-2" >
                    <input type="radio"
                    ng-model="event" name="radioEvent" class="mr-2" value='pick' checked " required>Pick
                </label>
                <label class="radio-inline mb-0 mr-2" >
                    <input type="radio" 
                    ng-model="event" name="radioEvent" class="mr-2"  value='drop' " required>Drop
                </label>
                <span ng-show="hasError('radioEvent', 'required')" class="help-block">
                        Field is required.</span>
            </div>
            <!-- <div class="col-md-5">
                <div class="col">
                    <div class="input-group mb-3">
                        <label class="text-label" for="basic-url">Site Name</label>
                        <select class="custom-select" ng-model="$ctrl.siteID">
                            <option value="">Select here</option>
                            <option ng-repeat="site in $ctrl.siteNames" value="{{$ctrl.site.id}}">
                                {{site.name.toUpperCase()}}</option>
                        </select>
                    </div>
                </div>
            </div> -->
            <div class="col-md-4 ">
                <select class="custom-select" name='gender' ng-model="for" required>
                    <option value="">Select Gender</option>
                    <option value="F">Female</option>
                    <option value="M">Male</option>
                    <option value="F_M">Both</option>
                </select>
                <span ng-show="hasError('gender', 'required')" class="help-block">Gender is
                    required.</span>
            </div>

        </div>
        <div class=" guard">
            <div class="row padding-20 bg">
                <div class="col-md-4">
                    <div class="input-group mb-3">
                        <label class="text-label" for="basic-url">Time</label>
                        <div class="input-group-append">
                            <span class="input-group-text">FROM</span>
                        </div>
                        <input type="number" id="appt" min="0" max="23" ng-model="from_time" name='from_time'
                            required>
                        <span ng-show="hasError('from_time', 'required')" class="help-block">From Time is
                            required.</span>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="input-group mb-3">
                        <div class="input-group-append">
                            <span class="input-group-text">TO</span>
                        </div>
                        <input type="number" id="appt" min="0" max="23"  ng-model="to_time" name='to_time' required>
                        <span ng-show="hasError('to_time', 'required')" class="help-block">To Time is
                            required.</span>
                    </div>
                </div>
            </div>
            <div class="col-md-12">
            <button type="button" class="btn btn-primary main-submit-btn"
                ng-click="submitForm(form.$valid)">Submit</button>

</div>


        </div>

    </div>
</form>


<!-- <div class="tab-content-area ">
    <div class="row margin-b-20 ">
        <div class="col-md-6 ">
            <div class="col">
                <div class="input-group mb-3">
                    <label class="text-label" for="basic-url">Site Name</label>
                    <select class="custom-select" ng-model="$ctrl.siteID">
                        <option value="">Select here</option>
                        <option ng-repeat="site in $ctrl.siteNames" value="{{$ctrl.site.id}}">{{site.name.toUpperCase()}}</option>
                    </select>
                </div>
            </div>
        </div>
        <div class="col-md-2">
            <div class="custom-control custom-checkbox">
                <input type="checkbox" class="custom-control-input" id="defaultUnchecked">
                <label class="custom-control-label" for="defaultUnchecked">Last Drop</label>
            </div>
        </div>
        <div class="col-md-2">
            <div class="custom-control custom-checkbox">
                <input type="checkbox" class="custom-control-input" id="pick">
                <label class="custom-control-label" for="pick">First Pick</label>
            </div>
        </div>
        <div class="col-md-2 ">
            <select class="custom-select">
                <option value="1">Female</option>
                <option value="2">Male-Female</option>
            </select>
        </div>
       
    </div>
    <div class=" guard">
        <div class="row padding-20 bg">
            <div class="col-md-4">
                <div class="input-group mb-3">
                    <label class="text-label" for="basic-url">Time</label>
                    <div class="input-group-append">
                        <span class="input-group-text">FROM</span>
                    </div>
                    <input type="time" id="appt" name="appt" min="00:00" max="11:59" required>
                </div>
            </div>
            <div class="col-md-4">
                <div class="input-group mb-3">
                    <div class="input-group-append">
                        <span class="input-group-text">TO</span>
                    </div>
                    <input type="time" id="appt" name="appt" min="00:00" max="11:59" required>
                </div>
            </div>
        </div>
        <div class="row bg">
            <div class="col-md-4">
                <div class="input-group mb-3">
                    <label class="text-label" for="basic-url">Time</label>
                    <div class="input-group-append">
                        <span class="input-group-text">FROM</span>
                    </div>
                    <input type="time" id="appt" name="appt" min="00:00" max="11:59" required>
                </div>
            </div>
            <div class="col-md-4">
                <div class="input-group mb-3">
                    <div class="input-group-append">
                        <span class="input-group-text">TO</span>
                    </div>
                    <input type="time" id="appt" name="appt" min="00:00" max="11:59" required>
                </div>
            </div>
        </div>
        <button type="button" class="btn btn-primary main-submit-btn">Submit</button>




    </div>
</div> -->
    `,
    controller: function GuardController($scope, $http, SessionService, ToasterService) {

      this.siteID = "";
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
      
    }
  });
