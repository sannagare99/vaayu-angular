angular.module('app').controller('tripboardCtrl', function($scope,TripboardService, SiteService, $http){
    
  
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

    TripboardService.getAllSiteList( function(data) {
      $scope.siteList=data.data.list;
      $scope.selectedSite = $scope.siteList[0].name;
      let postData = {
        "site_id":$scope.siteList[0].id,
        "to_date":  moment($scope.filterDate).format('YYYY-MM-DD')
    }
      
    //   TripboardService.get(postData, function(data) {
    //     if(data.data){
    //       $scope.rosters=data.data.shiftdetails;
    //       $scope.stats = data.data.stats;
    //     }
    // }
    // , function (error) {
    //     console.error(error);
    // });
  } 
  , function (error) {
      console.error(error);
  });;
  };
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
 
  $scope.FilterTripBoard = function(){
    let selectedSiteId = 0;
    for(i = 0; i < $scope.siteList.length; i++){
      if($scope.siteList[i].name == $scope.selectedSite) {
        selectedSiteId = $scope.siteList[i].id;
      }
    }
    let postData = {
      "site_id": selectedSiteId,
      "to_date":  moment($scope.filterDate).format('YYYY-MM-DD')
  }
  TripboardService.get(postData, function(data) {
      $scope.rosters=data.data.shiftdetails;
  }
  , function (error) {
      console.error(error);
  });;
  
  
}
  //date picker function
    $scope.popup=function() {
        var mapProp= {
            center:new google.maps.LatLng(51.508742,-0.120850),
            zoom:5,
          };
          var map = new google.maps.Map(document.getElementById("googleMap"),mapProp);
        
        var modal = document.getElementById("myModal");
    
        // Get the button that opens the modal
        var btn = document.getElementById("myBtn");
        
        // Get the <span> element that closes the modal
        var closepop = document.getElementsByClassName("closepop")[0];
        
        
        // When the user clicks the button, open the modal 
        btn.onclick = function() {
          modal.style.display = "block";
        }
        
        // When the user clicks on <span> (x), close the modal
        closepop.onclick = function() {
          modal.style.display = "none";
        }
        
        
        // When the user clicks anywhere outside of the modal, close it
        window.onclick = function(event) {
          if (event.target == modal) {
            modal.style.display = "none";
          }
        }
    
     }

    $scope.rosters=[
        {
            type:"1",
            shift_time:"09:00 AM",
            shift_type:"Check In",
            no_of_employee:"236",
            vehicle_type:"SUV",
            driver_name:'Rajpal Yadav',
            vehicle_rc_no:"MH04DH4565",
            live_tracking_in_eta:'08:45 AM',
            current_status:'ON GOING'
        },
        {
            type:"2",
            shift_time:"09:00 AM",
            shift_type:"Check In",
            no_of_employee:"236",
            vehicle_type:"SUV",
            driver_name:'Rajpal Yadav',
            vehicle_rc_no:"MH04DH4565",
            live_tracking_in_eta:'08:45 AM',
            current_status:'PENDING'
        },
        {
            type:"3",
            shift_time:"09:00 AM",
            shift_type:"Check In",
            no_of_employee:"236",
            vehicle_type:"SUV",
            driver_name:'Rajpal Yadav',
            vehicle_rc_no:"MH04DH4565",
            live_tracking_in_eta:'08:45 AM',
            current_status:'CANCELLED'
        },
        {
            type:"4",
            shift_time:"09:00 AM",
            shift_type:"Check In",
            no_of_employee:"236",
            vehicle_type:"SUV",
            driver_name:'Rajpal Yadav',
            vehicle_rc_no:"MH04DH4565",
            live_tracking_in_eta:'08:45 AM',
            current_status:'CANCELLED'
        }
    ]
});