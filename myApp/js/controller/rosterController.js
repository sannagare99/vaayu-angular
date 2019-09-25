angular.module('app').controller('rosterCtrl', function($scope,RosterService, SiteService, $http){


    $scope.init = function(){
       
          $scope.today();
          // date picket
          $scope.toggleMin();
        
          
          $scope.dateOptions = {
            formatYear: 'yy',
            startingDay: 1
          };
        
          $scope.formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'dd.MM.yyyy', 'shortDate'];
          $scope.format = $scope.formats[0];

          // date function

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
        // Open Side View
      }

    
});
