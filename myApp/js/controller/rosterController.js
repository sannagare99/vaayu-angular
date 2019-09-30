angular.module('app').controller('rosterCtrl', function($scope,RosterService, SiteService, $http){


    $scope.init = function(){
          $scope.isAddMenuOpen = false;
          $scope.today();

          $scope.defaultVehiclesList = {
            HATCHBACK: 0,
            SUV: 0,
            TT: 0,
            SEDAN:0,
            BUS: 0,
            'MINI VAN': 0,
            TRUCK: 0,
          };

          $scope.defaultVehiclesCapacityList = {
            HATCHBACK: 8,
            SUV: 8,
            TT: 10,
            SEDAN:5,
            BUS: 40,
            'MINI VAN': 6,
            TRUCK: 20,
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

        
       
        

        RosterService.getAllSiteList( function(data) {
          $scope.siteList=data.data.list;
          $scope.selectedSite = $scope.siteList[0];
          let postData = {
            "site_id":$scope.siteList[0].id,
            "to_date":  moment($scope.filterDate).format('YYYY-MM-DD')
        }
          
          RosterService.get(postData, function(data) {
            if(data.data){
              $scope.rosters=data.data.shiftdetails;
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

    $scope.updateDirectionData = function(directionData){
    }

    $scope.updateFilters = function(){
     
      let postData = {
        "site_id": $scope.selectedSite.id,
        "to_date":  moment($scope.filterDate).format('YYYY-MM-DD')
    }

    if($scope.directionData){
      postData.shift_type = $scope.directionData;
    }
    RosterService.get(postData, function(data) {
        $scope.rosters=data.data.shiftdetails;
        $scope.stats = data.data.stats;
    }
    , function (error) {
        console.error(error);
    });;
    
    
  }
    

    // datepicker function
    $scope.today = function() {
        $scope.filterDate = new Date();
      };
    
      $scope.clear = function () {
        $scope.filterDate = null;
      };
    
      // Disable weekend selection
      $scope.disabled = function(date, mode) {
        return ( mode === 'day' && ( date.getDay() === 0 || date.getDay() === 6 ) );
      };
    
      $scope.toggleMin = function() {
        $scope.minDate = $scope.minDate ? null : new Date();
      };

      $scope.open = function($event) {
        $event.preventDefault();
        $event.stopPropagation();
    
        $scope.opened = true;
      };
    
      //date picker function

      $scope.addVehicleToRoster = function(roster){
        $scope.currentRoster = roster;
        console.log($scope.currentRoster.vehicle);
        console.log(angular.equals($scope.currentRoster.vehicle, {}));
        if(angular.equals($scope.currentRoster.vehicle, {})){
          $scope.currentRoster.vehicle = $scope.defaultVehiclesList;
          $scope.currentRoster.vehicle_capacity = $scope.defaultVehiclesCapacityList;
          $scope.currentRoster.total_seats = 0;
          $scope.currentRoster.total_vehicles = 0;

        }else if(!$scope.currentRoster.vehicle){
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

      $scope.hideAddMenu = function(){
        $scope.isAddMenuOpen = false;

      }

      $scope.plusVehicle = function(key){
        $scope.currentRoster.vehicle[key] = parseInt($scope.currentRoster.vehicle[key]) + 1;
        $scope.currentRoster.total_vehicles =  $scope.currentRoster.total_vehicles + 1;
        if( $scope.currentRoster.vehicle_capacity[key]){
          $scope.currentRoster.total_seats = $scope.currentRoster.total_seats + $scope.currentRoster.vehicle_capacity[key];
        }
        $scope.disableDone($scope.currentRoster);

      }

      $scope.minusVehicle = function(key){
        $scope.currentRoster.vehicle[key] = parseInt($scope.currentRoster.vehicle[key]) - 1
        $scope.currentRoster.total_vehicles =  $scope.currentRoster.total_vehicles -1;
        if( $scope.currentRoster.vehicle_capacity[key]){
          $scope.currentRoster.total_seats = $scope.currentRoster.total_seats - $scope.currentRoster.vehicle_capacity[key];
        }

        $scope.disableDone($scope.currentRoster);
      }

      $scope.submitAddVehicle = function(){

        let postData = {
          id: $scope.currentRoster.id,
          no_of_emp: $scope.currentRoster.no_of_emp,
          vehicle: $scope.currentRoster.vehicle,
          total_seats: $scope.currentRoster.total_seats,
          vehicle_capacity: $scope.currentRoster.vehicle_capacity,
          to_date:moment($scope.filterDate).format('YYYY-MM-DD'),
          total_vehicles: $scope.currentRoster.total_vehicles

        }
        RosterService.addVehicle(postData, function(result){
          $scope.isAddMenuOpen = false;
          $scope.updateFilters();
          $scope.defaultVehiclesList = {
            HATCHBACK: 0,
            SUV: 0,
            TT: 0,
            SEDAN:0,
            BUS: 0,
            'MINI VAN': 0,
            TRUCK: 0,
          };

          
        });

      }

      $scope.disableDone = roster =>{
        
        if(!roster.total_seats){
            $scope.isDoneDisabled =true;
        }
        else if(roster.total_seats < roster.no_of_emp){
          $scope.isDoneDisabled =true;
        }else{
           $scope.isDoneDisabled =false;
        }
      }
    
});
