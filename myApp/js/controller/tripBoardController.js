angular.module('app').controller('tripboardCtrl', function ($scope, TripboardService, SiteService, $http) {


  $scope.init = function () {
    $scope.today();
    // date picket
    $scope.toggleMin();
    $scope.markerArray = [];


    $scope.dateOptions = {
      formatYear: 'yy',
      startingDay: 1
    };

    $scope.formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'dd.MM.yyyy', 'shortDate'];
    $scope.format = $scope.formats[0];

    // date function

    TripboardService.getAllSiteList(function (data) {
      console.log(data);
      $scope.siteList = data.data.list;
      if($scope.siteList) $scope.selectedSiteID = $scope.siteList[0].id;
    }
      , function (error) {
        console.error(error);
      });
  };
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

  $scope.getAllTrips = function () {

    $scope.fullRoster = $scope.tempResponse.tripsdetails;
    $scope.rosters = $scope.fullRoster;
    $scope.stats = $scope.tempResponse.stats;

    // let postData = {
    //   "site_id": $scope.selectedSiteID,
    //   "to_date": moment($scope.filterDate).format('YYYY-MM-DD')
    // }
    // console.log(postData)
    // TripboardService.get(postData, function (data) {
    //   // $scope.rosters = data.data.tripsdetails;
    //   $scope.fullRoster = $scope.tempResponse.tripsdetails;
    //   $scope.rosters = $scope.fullRoster;
    //   $scope.stats = $scope.tempResponse.stats;
    //   console.log($scope.rosters);
    // }, function (error) {
    //   console.error(error);
    // });

  }
  //date picker function
  $scope.popup = function (modelData) {
    $scope.modelData = modelData;

    // var mapProp = {
    //   center: new google.maps.LatLng(51.508742, -0.120850),
    //   zoom: 5,
    // };
    // var map = new google.maps.Map(document.getElementById("googleMap"), mapProp);
    var directionsService = new google.maps.DirectionsService();
        var directionsRenderer = new google.maps.DirectionsRenderer();
    var map = new google.maps.Map(document.getElementById('googleMap'), {
      zoom: 13,
      center: { lat: 19.2578, lng: 72.8731 },
      mapTypeId: 'terrain'
    });

    directionsRenderer.setMap(map);
    var stepDisplay = new google.maps.InfoWindow;
    var waypts =[
      {
        location: 'Kandivali Station (W), Parekh Nagar, Kandivali, Mumbai, Maharashtra',
        stopover: true
      },
      {
        location: 'Thane Station Road, Jambli Naka, Thane West, Thane, Maharashtra',
        stopover: true
      }

    ];

    // calculateAndDisplayRoute(directionsRenderer, directionsService, $scope.markerArray, waypts, stepDisplay, map);    // Define a symbol using SVG path notation, with an opacity of 1.
    calculateAndDisplayRoute( directionsService, directionsRenderer, waypts)
    var lineSymbol = {
      path: 'M 0,-1 0,1',
      strokeOpacity: 1,
      scale: 2
    };


    // Create the polyline, passing the symbol in the 'icons' property.
    // Give the line an opacity of 0.
    // Repeat the symbol at intervals of 20 pixels to create the dashed effect.
    var line = new google.maps.Polyline({
      path: [{ lat: 32.291, lng: 157.027 }, { lat: 22.291, lng: 153.027 }, { lat: 28.291, lng: 158.027 }, { lat: 18.291, lng: 153.027 }],
      strokeOpacity: 0,
      icons: [{
        icon: lineSymbol,
        offset: '0',
        repeat: '5px'
      }],
      map: map
    });


    var modal = document.getElementById("myModal");
    modal.style.display = "block";

    // Get the button that opens the modal
    // var btn = document.getElementById("myBtn");

    // // Get the <span> element that closes the modal
    var closepop = document.getElementsByClassName("closepop")[0];


    // When the user clicks the button, open the modal 
    // btn.onclick = function() {

    // }

    // When the user clicks on <span> (x), close the modal
    closepop.onclick = function () {
      modal.style.display = "none";
    }


    // When the user clicks anywhere outside of the modal, close it
    window.onclick = function (event) {
      if (event.target == modal) {
        modal.style.display = "none";
      }
    }

  }
    // Helper function to display route with Waypointers  no Steps

  function calculateAndDisplayRoute(directionsService, directionsRenderer,waypts) {
    directionsService.route({
      origin: 'Veer Savarkar Flyover, Malad, Liliya Nagar, Malad West, Mumbai, Maharashtra 400064',
      destination: 'Panvel, Navi Mumbai, Maharashtra',
      waypoints: waypts,
      optimizeWaypoints: true,
      travelMode: 'DRIVING'
    }, function(response, status) {
      if (status === 'OK') {
        directionsRenderer.setDirections(response);
        var route = response.routes[0];
        var summaryPanel = document.getElementById('directions-panel');
        summaryPanel.innerHTML = '';
        // For each route, display summary information.
        for (var i = 0; i < route.legs.length; i++) {
          var routeSegment = i + 1;
          summaryPanel.innerHTML += '<b>Route Segment: ' + routeSegment +
              '</b><br>';
          summaryPanel.innerHTML += route.legs[i].start_address + ' to ';
          summaryPanel.innerHTML += route.legs[i].end_address + '<br>';
          summaryPanel.innerHTML += route.legs[i].distance.text + '<br><br>';
        }
      } else {
        window.alert('Directions request failed due to ' + status);
      }
    });
  }
  // Helper function to display route with Steps and not Waypointers 
//   function calculateAndDisplayRoute(directionsRenderer, directionsService,markerArray, waypts, stepDisplay, map) {
//   // First, remove any existing markers from the map.
//   for (var i = 0; i < markerArray.length; i++) {
//     markerArray[i].setMap(null);
//   }

//   // Retrieve the start and end locations and create a DirectionsRequest using
//   // WALKING directions.
//   directionsService.route({
//     origin: 'Veer Savarkar Flyover, Malad, Liliya Nagar, Malad West, Mumbai, Maharashtra 400064',
//     destination: 'Panvel, Navi Mumbai, Maharashtra',
//     // waypoints: waypts,
//     // optimizeWaypoints: true,
//     travelMode: 'DRIVING'
//   }, function(response, status) {
//     // Route the directions and pass the response to a function to create
//     // markers for each step.
//     if (status === 'OK') {
//       document.getElementById('warnings-panel').innerHTML =
//           '<b>' + response.routes[0].warnings + '</b>';
//       directionsRenderer.setDirections(response);
//       // showSteps(response, $scope.markerArray, stepDisplay, map);
//     } else {
//       window.alert('Directions request failed due to ' + status);
//     }
//   });
// }

function showSteps(directionResult, markerArray, stepDisplay, map) {
  // For each step, place a marker, and add the text to the marker's infowindow.
  // Also attach the marker to an array so we can keep track of it and remove it
  // when calculating new routes.
  var myRoute = directionResult.routes[0].legs[0];
  for (var i = 0; i < myRoute.steps.length; i++) {
    var marker = markerArray[i] = markerArray[i] || new google.maps.Marker;
    marker.setMap(map);
    marker.setPosition(myRoute.steps[i].start_location);
    attachInstructionText(
        stepDisplay, marker, myRoute.steps[i].instructions, map);
  }
}

function attachInstructionText(stepDisplay, marker, text, map) {
  google.maps.event.addListener(marker, 'click', function() {
    // Open an info window when the marker is clicked on, containing the text
    // of the step.
    stepDisplay.setContent(text);
    stepDisplay.open(map, marker);
  });
}
// Helping Functions End

  $scope.filterTrips = function (status) {
    $scope.rosters = $scope.fullRoster.filter(item => item.current_status === status)
  }

  $scope.tempResponse = {
    "stats": {
      "all_trips": 4,
      "ongoing_trips": 9,
      "delayed_trips": 0,
      "accepted_trips": 4,
      "pending_acceptance_trips": 0,
      "cancelled": 0
    },
    "tripsdetails": [{
      "trip_id": 138,
      "trip_type": "checkin",
      "shift_time": "09:00 AM",
      "vehicle_type": 'SUV',
      "vehicle_model": 'CRETA',
      "vehicle_number": "MH43K7867",
      "driver_name": 'Ram Kumar',
      "no_of_employees": 4,
      "current_status": "cancelled",
      "tripInfo": [{

        "routeId": 23423232342344,
        "total_time": 90,
        "total_distance": 40,
        "tripStartTime": "09:00",
        "tripEndTime": "10:00",
        "vehicle_type": "SUV",
        "total_seats": 5,
        "empty_seats": 2,
        "guard_required": "Y",
        "vehicle_allocated": "N",
        "trip_cost": 100,
        "driver_id": "",
        "driver_profile_image": "",
      }],
      "employees_nodes_addresses": [{
        "rank": 1,
        "empId": 12312,
        "empName": "Deekshith M",
        "lat": "123123123.23",
        "long": "23423423423.234",
        "gender": "M",
        "special": "Yes"
      },
      {
        "rank": 2,
        "empId": 12312,
        "empName": "Umar Sayyed",
        "lat": "123123123.23",
        "long": "23423423423.234",
        "gender": "M",
        "special": "Yes"
      },
      {
        "rank": 3,
        "empId": 12312,
        "empName": "Ajay Sharma",
        "lat": "123123123.23",
        "long": "23423423423.234",
        "gender": "M",
        "special": "Yes"
      },
      {
        "rank": 4,
        "empId": 12312,
        "empName": "Vaibhavi Rawale",
        "lat": "123123123.23",
        "long": "23423423423.234",
        "gender": "M",
        "special": "Yes"
      }
      ]
    },
    {
      "trip_id": 138,
      "trip_type": "checkin",
      "shift_time": "09:00 AM",
      "vehicle_type": 'SUV',
      "vehicle_model": 'CRETA',
      "vehicle_number": "MH43K7867",
      "driver_name": 'Ram Kumar',
      "no_of_employees": 4,
      "current_status": "cancelled",
      "tripInfo": [{

        "routeId": 23423232342344,
        "total_time": 90,
        "total_distance": 40,
        "tripStartTime": "09:00",
        "tripEndTime": "10:00",
        "vehicle_type": "SUV",
        "total_seats": 5,
        "empty_seats": 2,
        "guard_required": "Y",
        "vehicle_allocated": "N",
        "trip_cost": 100,
        "driver_id": "",
        "driver_profile_image": "",
      }],
      "employees_nodes_addresses": [{
        "rank": 1,
        "empId": 12312,
        "empName": "Rushikesh Indulkar",
        "lat": "123123123.23",
        "long": "23423423423.234",
        "gender": "M",
        "special": "Yes"
      },
      {
        "rank": 2,
        "empId": 12312,
        "empName": "Mansi Sawant",
        "lat": "123123123.23",
        "long": "23423423423.234",
        "gender": "M",
        "special": "Yes"
      },
      {
        "rank": 3,
        "empId": 12312,
        "empName": "Dhruv Sharma",
        "lat": "123123123.23",
        "long": "23423423423.234",
        "gender": "M",
        "special": "Yes"
      },
      {
        "rank": 4,
        "empId": 12312,
        "empName": "Sohel Khan",
        "lat": "123123123.23",
        "long": "23423423423.234",
        "gender": "M",
        "special": "Yes"
      }
      ]
    },
    {
      "trip_id": 138,
      "trip_type": "checkin",
      "shift_time": "09:00 AM",
      "vehicle_type": 'SUV',
      "vehicle_model": 'CRETA',
      "vehicle_number": "MH43K7867",
      "driver_name": 'Ram Kumar',
      "no_of_employees": 4,
      "current_status": "cancelled",
      "tripInfo": [{

        "routeId": 23423232342344,
        "total_time": 90,
        "total_distance": 40,
        "tripStartTime": "09:00",
        "tripEndTime": "10:00",
        "vehicle_type": "SUV",
        "total_seats": 5,
        "empty_seats": 2,
        "guard_required": "Y",
        "vehicle_allocated": "N",
        "trip_cost": 100,
        "driver_id": "",
        "driver_profile_image": "",
      }],
      "employees_nodes_addresses": [{
        "rank": 1,
        "empId": 12312,
        "empName": "Veer Singh",
        "lat": "123123123.23",
        "long": "23423423423.234",
        "gender": "M",
        "special": "Yes"
      },
      {
        "rank": 2,
        "empId": 12312,
        "empName": "Praveen Singh",
        "lat": "123123123.23",
        "long": "23423423423.234",
        "gender": "M",
        "special": "Yes"
      },
      {
        "rank": 3,
        "empId": 12312,
        "empName": "Pushp S",
        "lat": "123123123.23",
        "long": "23423423423.234",
        "gender": "M",
        "special": "Yes"
      },
      {
        "rank": 4,
        "empId": 12312,
        "empName": "Kirti Sharma",
        "lat": "123123123.23",
        "long": "23423423423.234",
        "gender": "M",
        "special": "Yes"
      }
      ]
    }
    ]

  }

});