angular.module('app').controller('rosterCtrl', function($scope,RosterService, SiteService, $http){


    $scope.init = function(){
       
          $scope.today();
        
          $scope.toggleMin();
        
          
          $scope.dateOptions = {
            formatYear: 'yy',
            startingDay: 1
          };
        
          $scope.formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'dd.MM.yyyy', 'shortDate'];
          $scope.format = $scope.formats[0];

        let postData = {
            "site_id":30,
            "to_date":  moment($scope.filterDate).format('YYYY-MM-DD')
        }
       
        RosterService.get(postData, function(data) {
            $scope.rosters=data.data.shiftdetails;
            console.log($scope.rosters)
        }
        , function (error) {
            console.error(error);
        });;
        // $scope.fetchRoasterList(postData);
        // SiteService.get(function(data) {
        //     $scope.shifts=data.data.list;
        // });

        // $scope.rosters=[
        //     {
        //         shift:"shift1",
        //         type:1,
        //         shift_time:"09:00 AM",
        //         shift_type:"Check In",
        //         no_of_employee:"236",
        //         vehicle_required:"4 SUV | 2 TT | 3HB : 22VEHICLE",
        //         vehicle_avialble:"23",
        //         result:'GOOD TO GO'
        //     },
        //     {
        //         shift:"shift1",
        //         type:2,
        //         shift_time:"09:00 AM",
        //         shift_type:"Check In",
        //         no_of_employee:"236",
        //         vehicle_required:"4 SUV | 2 TT | 3HB : 22VEHICLE",
        //         vehicle_avialble:"23",
        //         result:'GOOD TO GO'
        //     },
        //     {
        //         shift:"shift1",
        //         type:1,
        //         shift_time:"09:00 AM",
        //         shift_type:"Check Out",
        //         no_of_employee:"236",
        //         vehicle_required:"4 SUV | 2 TT | 3HB : 22VEHICLE",
        //         vehicle_avialble:"2",
        //         result:'REQUIRED MORE VEHICLE'
        //     }
        // ]
    }

    $scope.updateDirectionData = function(directionData){
      console.log(directionData);
    }

    $scope.updateFilters = function(){
      let postData = {
        "site_id":30,
        "to_date":  moment($scope.filterDate).format('YYYY-MM-DD')
    }

    if($scope.directionData){
      postData.shift_type = $scope.directionData;
    }
   
    RosterService.get(postData, function(data) {
        $scope.rosters=data.data.shiftdetails;
        console.log($scope.rosters)
    }
    , function (error) {
        console.error(error);
    });;
    }
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
    
      
      $scope.addVehicleToRoster = function(roster){
        $scope.currentRoster = roster;
        // Open Side View
      }

    
});
