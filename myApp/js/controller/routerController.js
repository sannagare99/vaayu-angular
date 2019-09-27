
angular.module('app').directive('setHeight', function($window){
  return{
    link: function(scope, element, attrs){
        element.css('height', $window.innerHeight/2 + 'px');
    }
  }
})

angular.module('app')
  .filter('range', function(){
    return function(items, property, min, max) {
      return items.filter(function(item){
        return item[property] >= min && item[property] <= max;
      });
    };
  });

angular.module('app').controller('routeCtrl', function ($scope, $http, $state,Map,VehicleService,SiteService,GuardsService,RosterService,RouteService) {

    $scope.place = {};
    // Map.init();

    $scope.initMap = function() {
      $scope.mymap = new google.maps.Map(document.getElementById('map'), {
        zoom: 13,
        center: {lat: 0, lng: -180},
        mapTypeId: 'terrain'
      });

      // $scope.drawMapPath([
      //   {lat: 37.772, lng: -122.214},
      //   {lat: 21.291, lng: -157.821},
      //   {lat: -18.142, lng: 178.431},
      //   {lat: -27.467, lng: 153.027}
      // ])

      // var flightPlanCoordinates = [
        // {lat: 37.772, lng: -122.214},
        // {lat: 21.291, lng: -157.821},
        // {lat: -18.142, lng: 178.431},
        // {lat: -27.467, lng: 153.027}
      // ];
    
    }

    $scope.drawMapPath = (coordinates) => {
      var pt = new google.maps.LatLng(coordinates[0].lat, coordinates[0].lng);
      // var pt = new google.maps.LatLng(19.184925, 72.8398173);
      
      $scope.mymap.setCenter(pt);
      $scope.mymap.setZoom(13);
      
      let flightPath = new google.maps.Polyline({
        path: coordinates,
        geodesic: true,
        strokeColor: '#FF0000',
        strokeOpacity: 1.0,
        strokeWeight: 2
      });

      flightPath.setMap($scope.mymap);
    }


    $scope.selectRoute = (container) => {
      var coords = [];
      angular.forEach(container.employees,function(emp,idx,empArray){
        try {
          coords.push({lat: parseFloat(emp.lat), lng: parseFloat(emp.long)})
        } catch (er) { console.log(er) }
      });

      $scope.drawMapPath(coords)
    }

     
    $scope.init = function(){

      $scope.initMap();
       
      SiteService.get().$promise.then(function(res) {
        $scope.sites=res.data.list;
      });

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

      
      RosterService.getAllSiteList( function(data) {
        $scope.siteList=data.data.list;
        $scope.siteId = $scope.siteList[0].id;

        let postData = {
          "site_id":$scope.siteList[0].id,
          "to_date":  moment($scope.filterDate).format('YYYY-MM-DD')
        }
        
        RosterService.get(postData, function(data) {
          if(data.data){
            $scope.shifts=data.data.shiftdetails;
            $scope.stats = data.data.stats;
          }
      }, function (error) {
          console.error(error);
      });
    } , function (error) {
        console.error(error);
    });

     
    GuardsService.get({ "siteId":"8","shiftId":"105"}, function(res){
        $scope.guardList=res.data;

        angular.forEach($scope.guardList,function(item){
          item.type="guard";
      })

        $scope.guards = [
          {
              label: "Guard",
              allowedTypes: ['guard'],
              guard:$scope.guardList
          }
      ];
    }, function (error) {
      console.error(error);
    });

    VehicleService.get({ "siteId":"8","shiftId":"130"}, function(res){
        $scope.vehicleList=res.data;
       angular.forEach($scope.vehicleList,function(item){
          item.type="vehical";
       })
      $scope.vehicals = [
        {
            label: "Vehical",
            allowedTypes: ['vehical'],
            max: 4,
            vehical:$scope.vehicleList
        }
      ];
    }, function (error) {
      console.error(error);
    });

   
 
  }

  $scope.updateFilters = function(){
    let postData = {
      "site_id": $scope.siteId,
      "to_date":  moment($scope.filterDate).format('YYYY-MM-DD')
    }

    if($scope.shiftType){
      postData.shift_type = $scope.shiftType;
    }
    RosterService.get(postData, function(data) {
        $scope.shifts=data.data.shiftdetails;
        $scope.stats = data.data.stats;
    }
    , function (error) {
        console.error(error);
    });;
  }

  $scope.genrateRoute = function() {
    

    let postData = {
      "site_id": $scope.siteId,
      "to_date":  moment($scope.filterDate).format('YYYY-MM-DD')
    }

    if($scope.shiftType){
      postData.shift_type = $scope.shiftType;
    }
    RouteService.getRoutes(function(data) {
      console.log(data)
    }
    , function (error) {
        console.error(error);
    });
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

  $scope.slider_occupied = {
      minValue: 1,
      maxValue: 8,
      options: {
        floor: 0,
        ceil: 10,
        showTicksValues: true
      }
    };

    $scope.slider_empty = {
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

    $scope.search='';

    $scope.setTab = function (tabId) {
      if (tabId == 2) {// non allocated 
        $scope.search = "Y";
      }else if (tabId == 3) {// non allocated 
        $scope.search = "N";
      }else {
        $scope.search='';
      }

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
    $scope.routes = { 
      "statusCode":200,
      "responseBody": {
          "customerID": 234234,
          "siteId":1234,
          "shiftId":4563,
          "shiftType":"checkout",
          "tripStart" :"site",
          "siteLat":"123131231.23",
          "siteLong":"123123342342.345",
          "tripEnd" : "",
          "routes":[
                  {
                    "routeId": 234234,
                    "total_time":90,      //90mins
                    "total_distabce":40,  //40 km
                    "tripStartTime":"",   
                    "tripEndTime" :"",  
                    "vehicle_type":"SUV",
                    "total_seats": 5,
                    "empty_seats": 2,
                    "guard_required": "Y / N",
                    "vehicle_allocated": "Y",
                    "trip_cost": 100,
                    "route_final_path": [
                         {"lat":"123131231.23","long":"123131231.23","time":""},
                         {"lat":"123131231.23","long":"123131231.23","time":""},
                         {"lat":"123131231.23","long":"123131231.23","time":""},        
                         {"lat":"123123123.23","long":"23423423423.234","time":""}
                    ],
                    "guard":{
                      "guardId":12312,
                      "guardName" : "Rushikesh Indulkar",
                      "gender":"M"
                    },
                    "vehicle":{
                        "vehicleId":12312,
                        "vehicleNumber":"MH47L5609",
                        "driverName" : "Rushikesh Indulkar",
                        "driverID":232423,
                        "vehicleType":"HB"
                    },
                    "employees_nodes_addresses":[
                            {
                              "rank": 1,
                              "empId":12312,
                              "empName" : "Rushikesh Indulkar",
                              "lat": "123123123.23",
                              "long": "23423423423.234",
                              "gender":"M",
                              "special" : "Yes"   //Yes/NO
                            },
                            {
                              "rank": 2,
                              "empId":12312,
                              "empName" : "Rushikesh Indulkar",
                              "lat": "123123123.23",
                              "long": "23423423423.234",
                              "gender":"M",
                              "special" : "Yes"   //Yes/NO
                            },
                            {
                              "rank": 3,
                              "empId":12312,
                              "empName" : "Rushikesh Indulkar",
                              "lat": "123123123.23",
                              "long": "23423423423.234",
                              "gender":"M",
                              "special" : "Yes"   //Yes/NO
                            },
                            {
                              "rank": 4,
                              "empId":12312,
                              "empName" : "Rushikesh Indulkar",
                              "lat": "123123123.23",
                              "long": "23423423423.234",
                              "gender":"M",
                              "special" : "Yes"   //Yes/NO
                            }
                    ]
                  },
                  {
                    "routeId": 23423232342344,
                    "total_time":90,      //90mins
                    "total_distabce":40,  //40 km
                    "tripStartTime":"",   
                    "tripEndTime" :"",  
                    "vehicle_type":"SUV",
                    "total_seats": 5,
                    "empty_seats": 2,
                    "guard_required": "Y / N",
                    "vehicle_allocated": "N",
                    "trip_cost": 100,
                    "route_final_path": [
                        {"lat":"123131231.23","long":"123131231.23","time":""},
                        {"lat":"123131231.23","long":"123131231.23","time":""},
                        {"lat":"123131231.23","long":"123131231.23","time":""},        
                        {"lat":"123123123.23","long":"23423423423.234","time":""}
                    ],
                    "employees_nodes_addresses":[
                            {
                              "rank": 1,
                              "empId":12312,
                              "empName" : "Rushikesh Indulkar",
                              "lat": "123123123.23",
                              "long": "23423423423.234",
                              "gender":"M",
                              "special" : "Yes"   //Yes/NO
                            },
                            {
                              "rank": 2,
                              "empId":12312,
                              "empName" : "Rushikesh Indulkar",
                              "lat": "123123123.23",
                              "long": "23423423423.234",
                              "gender":"M",
                              "special" : "Yes"   //Yes/NO
                            },
                            {
                              "rank": 3,
                              "empId":12312,
                              "empName" : "Rushikesh Indulkar",
                              "lat": "123123123.23",
                              "long": "23423423423.234",
                              "gender":"M",
                              "special" : "Yes"   //Yes/NO
                            },
                            {
                              "rank": 4,
                              "empId":12312,
                              "empName" : "Rushikesh Indulkar",
                              "lat": "123123123.23",
                              "long": "23423423423.234",
                              "gender":"M",
                              "special" : "Yes"   //Yes/NO
                            }
                    ]
                  }
                ] 
      },
      "msg":"success",
      "errors":[]
   };
   
   $scope.filterModel=function(){

   }
   angular.forEach($scope.routes.responseBody.routes, function(route,index, routeArray){
      route.allowed="all";
      if(route.guard){
        let guard = route.guard;
        guard.type = 'guard';
        route.guard = [guard]
      }else{
        route.guard =[];
      }
      if(route.vehicle){
        let vehical = route.vehicle;
        vehical.type = 'vehical';
        route.vehicle = [vehical]
      }else{
        route.vehicle =[];
      }
     
      angular.forEach(route.employees_nodes_addresses, function(employee,idx,emmplyeeArray){
        employee.type="employee";
        employee.effectAllowed="all";
      })

      route.employees = route.employees_nodes_addresses;
   })

    $scope.routes.responseBody.routes.push(
      {
        "vehicle_allocated":'',
        "employees" :[],
        "vehicle":[],
        "guard":[],
        "allowed":"all"
      }
    )

  
   
   
    console.log($scope.routes);

    $scope.fullModel =[$scope.routes.responseBody.routes];
    $scope.model2 = $scope.fullModel;

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


    $scope.$watch('model2', function(model) {
        $scope.modelAsJson = angular.toJson(model, true);
    }, true);


    

    // Model to JSON for demo purpose
    $scope.$watch('guards', function(guards) {
        $scope.modelAsJson = angular.toJson(guards, true);
    }, true);
    



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
