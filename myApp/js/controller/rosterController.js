angular.module('app').controller('rosterCtrl', function ($scope, RosterService, RouteService, ToasterService, SiteService, $http) {


  $scope.init = function () {
    $scope.isAddMenuOpen = false;
    $scope.today();

    $scope.defaultVehiclesList = {
      HATCHBACK: 0,
      SUV: 0,
      TT: 0,
      SEDAN: 0,
      BUS: 0,
      'MINI VAN': 0,
      TRUCK: 0,
    };

    $scope.defaultVehiclesCapacityList = {
      SEDAN: 8,
      SUV: 8,
      BUS: 10,
      'MINI VAN': 8,
      HATCHBACK: 5,
      TRUCK: 8,
      TT: 10
    }
    // date picket
    $scope.toggleMin();
    $scope.isDoneDisabled = true;

    $scope.dateOptions = {
      formatYear: 'yy',
      startingDay: 1
    };

    $scope.formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'dd.MM.yyyy', 'shortDate'];
    $scope.format = $scope.formats[0];

    // date function





    RosterService.getAllSiteList(function (data) {
      $scope.siteList = data.data.list;
      $scope.selectedSite = $scope.siteList[0];
      let postData = {
        "site_id": $scope.siteList[0].id,
        "to_date": moment($scope.filterDate).format('YYYY-MM-DD')
      }

      RosterService.get(postData, function (data) {
        if (data.data) {
          $scope.rosters = data.data.shiftdetails;
          $scope.stats = data.data.stats;
        }
      }
        , function (error) {
          console.error(error);
        });
    }
      , function (error) {
        console.error(error);
      });;

  }

  $scope.updateFilters = function () {

    let postData = {
      "site_id": $scope.selectedSite.id,
      "to_date": moment($scope.filterDate).format('YYYY-MM-DD')
    }

    if ($scope.shift_type) {
      postData.shift_type = $scope.shift_type;
    }
    console.log(postData)
    RosterService.get(postData, function (data) {
      $scope.rosters = data.data.shiftdetails;
      $scope.stats = data.data.stats;
    }
      , function (error) {
        console.error(error);
      });;


  }


  // datepicker function
  $scope.today = function () {
    $scope.filterDate = new Date();
  };

  $scope.clear = function () {
    $scope.filterDate = null;
  };

  // Disable weekend selection
  $scope.disabled = function (date, mode) {
    // return (mode === 'day' && (date.getDay() === 0 || date.getDay() === 6));
    return false;
  };

  $scope.toggleMin = function () {
    $scope.minDate = $scope.minDate ? null : new Date();
  };

  $scope.open = function ($event) {
    $event.preventDefault();
    $event.stopPropagation();

    $scope.opened = true;
  };

  //date picker function

  $scope.generateRoutes = function(roster) {
    console.log(roster);
    console.log($scope.selectedSite);
    console.log($scope.filterDate)

    let shift_type = 0;
    if (roster.shift_type.toLowerCase() === 'check out') {
      shift_type = 1;
    }

    let postData = {
      "site_id":parseInt($scope.selectedSite.id),
      "shift_id":parseInt(roster.id),
      "to_date":moment($scope.filterDate).format('YYYY-MM-DD'),
      "shift_type": shift_type // 0 -checkin 1-checout
    }

    RouteService.getRoutes(postData,
      (res) => {
        console.log(res);
        if (res['success']) {
          ToasterService.showSuccess('Success', 'Route generated successfully.');
        }

    }, (error) => {
      ToasterService.showError('Error', 'Something went wrong, Try again later.');
      console.error(error);
    });
  } 

  $scope.addVehicleToRoster = function (roster) {
    $scope.currentRoster = roster;
    console.log($scope.currentRoster.vehicle);
    console.log(angular.equals($scope.currentRoster.vehicle, {}));
    if (angular.equals($scope.currentRoster.vehicle, {})) {
      $scope.currentRoster.vehicle = $scope.defaultVehiclesList;
      $scope.currentRoster.vehicle_capacity = $scope.defaultVehiclesCapacityList;
      $scope.currentRoster.total_seats = 0;
      $scope.currentRoster.total_vehicles = 0;

    } else if (!$scope.currentRoster.vehicle) {
      $scope.currentRoster.vehicle = $scope.defaultVehiclesList;
      $scope.currentRoster.vehicle_capacity = $scope.defaultVehiclesCapacityList;
      $scope.currentRoster.total_seats = 0;
      $scope.currentRoster.total_vehicles = 0;
    }
    $scope.disableDone(roster);

    // Open Side View
    $scope.isAddMenuOpen = true;
    console.log($scope.currentRoster);
  }

  $scope.hideAddMenu = function () {
    $scope.isAddMenuOpen = false;
    $scope.defaultVehiclesList = {
      HATCHBACK: 0,
      SUV: 0,
      TT: 0,
      SEDAN: 0,
      BUS: 0,
      'MINI VAN': 0,
      TRUCK: 0,
    };



  }

  $scope.plusVehicle = function (key) {
    $scope.currentRoster.vehicle[key] = parseInt($scope.currentRoster.vehicle[key]) + 1;
    $scope.currentRoster.total_vehicles = $scope.currentRoster.total_vehicles + 1;
    if ($scope.currentRoster.vehicle_capacity[key]) {
      $scope.currentRoster.total_seats = $scope.currentRoster.total_seats + $scope.currentRoster.vehicle_capacity[key];
    }
    $scope.disableDone($scope.currentRoster);

  }

  $scope.minusVehicle = function (key) {
    if(parseInt($scope.currentRoster.vehicle[key]) > 0){
      $scope.currentRoster.vehicle[key] = parseInt($scope.currentRoster.vehicle[key]) - 1
      $scope.currentRoster.total_vehicles = $scope.currentRoster.total_vehicles - 1;
      if ($scope.currentRoster.vehicle_capacity[key]) {
        $scope.currentRoster.total_seats = $scope.currentRoster.total_seats - $scope.currentRoster.vehicle_capacity[key];
      }

      $scope.disableDone($scope.currentRoster);
    }
  }

  $scope.submitAddVehicle = function () {

        let postData = {
          id: $scope.currentRoster.id,
          no_of_emp: $scope.currentRoster.no_of_emp,
          vehicle: $scope.currentRoster.vehicle,
          total_seats: $scope.currentRoster.total_seats,
          vehicle_capacity: $scope.currentRoster.vehicle_capacity,
          to_date:moment($scope.filterDate).format('YYYY-MM-DD'),
          total_vehicles: $scope.currentRoster.total_vehicles,
          trip_type: $scope.currentRoster.trip_type,

    }
    RosterService.addVehicle(postData, function (result) {
      $scope.isAddMenuOpen = false;
      $scope.updateFilters();
      $scope.defaultVehiclesList = {
        HATCHBACK: 0,
        SUV: 0,
        TT: 0,
        SEDAN: 0,
        BUS: 0,
        'MINI VAN': 0,
        TRUCK: 0,
      };


    });

  }

  $scope.disableDone = roster => {

    if (!roster.total_seats) {
      $scope.isDoneDisabled = true;
    }
    else if (roster.total_seats < roster.no_of_emp) {
      $scope.isDoneDisabled = true;
    } else {
      $scope.isDoneDisabled = false;
    }
  }

});
