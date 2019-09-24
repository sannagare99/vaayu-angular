angular.module('app').controller('tripboardCtrl', function($scope,TripboardService){
    
    var entry = TripboardService.get(function(data) {
        console.log("Here is APi Response");
        console.log(entry);
        $scope.trips=data;
    });

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