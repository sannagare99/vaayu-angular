var app = angular.module('app', ['ui.router','dndLists','rzSlider']);

app.service('Map', function($q) {
    
    this.init = function() {
        var options = {
            center: new google.maps.LatLng(40.7127837, -74.00594130000002),
            zoom: 13,
            disableDefaultUI: true    
        }
        this.map = new google.maps.Map(
            document.getElementById("map"), options
        );
        this.places = new google.maps.places.PlacesService(this.map);
    }
    
    this.search = function(str) {
        var d = $q.defer();
        this.places.textSearch({query: str}, function(results, status) {
            if (status == 'OK') {
                d.resolve(results[0]);
            }
            else d.reject(status);
        });
        return d.promise;
    }
    
    this.addMarker = function(res) {
        if(this.marker) this.marker.setMap(null);
        this.marker = new google.maps.Marker({
            map: this.map,
            position: res.geometry.location,
            animation: google.maps.Animation.DROP
        });
        this.map.setCenter(res.geometry.location);
    }
    
});

app.controller('rosterCtrl', function($scope){
    $scope.rosters=[
        {
            shift:"shift1",
            type:1,
            shift_time:"09:00 AM",
            shift_type:"Check In",
            no_of_employee:"236",
            vehicle_required:"4 SUV | 2 TT | 3HB : 22VEHICLE",
            vehicle_avialble:"23",
            result:'GOOD TO GO'
        },
        {
            shift:"shift1",
            type:2,
            shift_time:"09:00 AM",
            shift_type:"Check In",
            no_of_employee:"236",
            vehicle_required:"4 SUV | 2 TT | 3HB : 22VEHICLE",
            vehicle_avialble:"23",
            result:'GOOD TO GO'
        },
        {
            shift:"shift1",
            type:1,
            shift_time:"09:00 AM",
            shift_type:"Check Out",
            no_of_employee:"236",
            vehicle_required:"4 SUV | 2 TT | 3HB : 22VEHICLE",
            vehicle_avialble:"2",
            result:'REQUIRED MORE VEHICLE'
        }
    ]
});

app.controller('tripboardCtrl', function($scope){
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

app.controller('routeCtrl', function ($scope, $http, $state,Map) {

    $scope.place = {};
    Map.init();

    
    $scope.slider = {
        minValue: 1,
        maxValue: 8,
        options: {
          floor: 0,
          ceil: 10,
          showTicksValues: true
        }
      };

    $scope.reset =function() {
        $state.reload(true);
    }

    $scope.tab = 1;

    $scope.setTab = function (tabId) {
        $scope.tab = tabId;
    };

    $scope.isSet = function (tabId) {
        return $scope.tab === tabId;
    };

    $scope.dragoverCallback = function(index, external, type, callback) {
        $scope.logListEvent('dragged over', index, external, type);
        // Invoke callback to origin for container types.
        if (type == 'container' && !external) {
            console.log('Container being dragged contains ' + callback() + ' items');
        }
        return index < 10; // Disallow dropping in the third row.
    };

    $scope.dropCallback = function(index, item, external, type) {
        $scope.logListEvent('dropped at', index, external, type);
        // Return false here to cancel drop. Return true if you insert the item yourself.
        return item;
    };

    $scope.logEvent = function(message) {
        console.log(message);
    };

    $scope.logListEvent = function(action, index, external, type) {
        var message = external ? 'External ' : '';
        message += type + ' element was ' + action + ' position ' + index;
        console.log(message);
    };

    $scope.allowedVehicalTypes=['vehical'];
    $scope.allowedGuardTypes=['guard'];

    // // Initialize model
    $scope.model = [
        [
          {
            "vehical":[
                // {
                // "model": "SUV",
                // "number": "MH 15 FB-1292",
                // "type": "vehical"
                // }
            ],
            "guard":[
                {
                    "model": "SUV",
                    "number": "MH 15 FB-1292",
                    "type": "guard"
                }
            ],
            "items": [
              {
                "label": "all 10",
                "effectAllowed": "all",
                "gender":'male',
                "type": "employee"
              },
              {
                "label": "all 12",
                "effectAllowed": "all",
                "gender":'female',
                "type": "employee"
              },
              {
                "label": "all 14",
                "effectAllowed": "all",
                "gender":'male',
                "type": "employee"
              },
              {
                "label": "all 15",
                "effectAllowed": "all",
                "gender":'female',
                "type": "employee"
              }
            ],
            "allowed": "all"
          },
          {
            "vehical":[
                {
                "model": "SUV",
                "number": "MH 15 FB-1292",
                "type": "vehical"
                }
            ],
   
            "guard":[
                    // {
                    //     "model": "SUV",
                    //     "number": "MH 15 FB-1292",
                    //     "type": "guard"
                    // }
            ],
            "items": [
              {
                "label": "copy 24",
                "effectAllowed": "all",
                "gender":'male',
                "type": "employee"
              },
              {
                "label": "copy 26",
                "effectAllowed": "all",
                "gender":'male',
                "type": "employee"
              },
              {
                "label": "copy 27",
                "effectAllowed": "all",
                "gender":'female',
                "type": "employee"
              },
              {
                "label": "copy 29",
                "effectAllowed": "all",
                "gender":'male',
                "type": "employee"
              },
              {
                "label": "copy 30",
                "effectAllowed": "all",
                "gender":'female',
                "type": "employee"
              }
            ],
            "allowed": "all"
          },
          {
            "vehical":[
                // {
                // "model": "SUV",
                // "number": "MH 15 FB-1292",
                // "type": "vehical"
                // }
            ],
            "guard":[
                {
                    "model": "SUV",
                    "number": "MH 15 FB-1292",
                    "type": "guard"
                }
            ],
            "items": [
              {
                "label": "all 10",
                "effectAllowed": "all",
                "gender":'male',
                "type": "employee"
              },
              {
                "label": "all 12",
                "effectAllowed": "all",
                "gender":'female',
                "type": "employee"
              },
              {
                "label": "all 14",
                "effectAllowed": "all",
                "gender":'male',
                "type": "employee"
              },
              {
                "label": "all 15",
                "effectAllowed": "all",
                "gender":'female',
                "type": "employee"
              }
            ],
            "allowed": "all"
          },
          {
              "items":[],
              "vehical":[],
              "guard":[],
              "allowed":"all"
          }
        ]
       
      ]


    $scope.$watch('model', function(model) {
        $scope.modelAsJson = angular.toJson(model, true);
    }, true);



    
    $scope.guards = [
        {
            label: "Guard",
            allowedTypes: ['guard'],
            max: 4,
            guard: [
                {name: "Bob", type: "guard"},
                {name: "Charlie", type: "guard"},
                {name: "Dave", type: "guard"}
            ]
        }
    ];

    // Model to JSON for demo purpose
    $scope.$watch('guards', function(guards) {
        $scope.modelAsJson = angular.toJson(guards, true);
    }, true);

    $scope.vehicals = [
        {
            label: "Vehical",
            allowedTypes: ['vehical'],
            max: 4,
            vehical: [
                {name: "Bob", type: "vehical"},
                {name: "Charlie", type: "vehical"},
                {name: "Dave", type: "vehical"}
            ]
        }
    ];

    // Model to JSON for demo purpose
    $scope.$watch('vehicals', function(vehicals) {
        $scope.modelAsJson = angular.toJson(vehicals, true);
    }, true);

    
    $scope.resetSidebar =function() {
        $scope.isVehicalSidebarView=false;
        $scope.isGuardSidebarView=false;
        $scope.isFilterSidebarView=false;
    }

    $scope.resetSidebar();

    $scope.hideVehicalSidebar =function(){
        $scope.isVehicalSidebarView=false;
    }

    $scope.showVehicalSidebar =function(){
        $scope.resetSidebar();
        $scope.isVehicalSidebarView=true;
    }

    $scope.hideGuardSidebar =function(){
        $scope.resetSidebar();
    }

    $scope.showGuardSidebar =function(){
        $scope.resetSidebar();
        $scope.isGuardSidebarView=true;
    }

    $scope.hideFilterSidebar =function(){
        $scope.resetSidebar();
    }

    $scope.showFilterSidebar =function(){
        $scope.resetSidebar();
        $scope.isFilterSidebarView=true;
    }

});

// Define all the routes below
app.config(function (
    $stateProvider,
    $urlRouterProvider
) {
    $stateProvider
        .state("routing", {
            url: "/route",
            templateUrl: "route.html",
            controller: "routeCtrl"
        })
        .state('roster', { 
            url : '/roster', 
            templateUrl : "roster.html", 
            controller : "rosterCtrl"
        }) 
        .state('tripboard', { 
            url : '/tripboard', 
            templateUrl : "trip_board.html", 
            controller : "tripboardCtrl"
        }) 

    $urlRouterProvider.otherwise("/tripboard");
});