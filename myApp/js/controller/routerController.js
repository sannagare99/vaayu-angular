
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

angular.module('app').controller('routeCtrl', function ($scope, $http, $state,Map,VehicleService,SiteService,GuardsService,RosterService,RouteService,RouteUpdateService,AutoAllocationService,VehicleAssignService,GuardAssignService,FinalizeService) {

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

    $scope.finalizeArray=[];

    $scope.selectRoute = (container) => {
      $scope.finalizeArray.push(container);

      var coords = [];
      angular.forEach(container.employees,function(emp,idx,empArray){
        try {
          coords.push({lat: parseFloat(emp.lat), lng: parseFloat(emp.long)})
        } catch (er) { console.log(er) }
      });

      $scope.drawMapPath(coords)
    }

     
    $scope.init = function(){

      $scope.stats= {
        "no_of_routes": 0,
        "male_count": 0,
        "female_count": 0,
        "special": 0,
        "on_duty_vehicle": 0,
        "kilometres": 0
      }

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
            if($scope.shifts && $scope.shifts.length){
              $scope.shiftId=$scope.shifts[0].id;
              $scope.resetRoute();
              // $scope.genrateRoute($scope.siteId,$scope.shifts[0].id,moment().format('YYYY-MM-DD'),1);
            }else{
              $scope.shiftId=0;
              $scope.resetRoute();
            }
          }
      }, function (error) {
          console.error(error);
      });
    } , function (error) {
        console.error(error);
    });   
 
  }

  $scope.getVehicleAndGuardList =function(siteId,shiftId){

      GuardsService.get({ "siteId":siteId,"shiftId":shiftId}, function(res){
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
    
    VehicleService.get({ "siteId":siteId,"shiftId":shiftId}, function(res){
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

  
    RosterService.get(postData, function(data) {
        $scope.shifts=data.data.shiftdetails;
    }
    , function (error) {
        console.error(error);
    });;
  }

  $scope.shuffleEvent = function(item) {
    console.log(message);
  };

  $scope.isDisabled=true;

  $scope.finalizeRoutes = function() {
    FinalizeService.query($scope.finalizeArray,function(){
       $scope.resetRoute();
    });
  }

  $scope.saveRoutes =function(){

    var changedRoutes = [];
   
    angular.forEach($scope.routes.data.routes, function(route){
      angular.forEach($scope.routeChangedIds, function(routeId){
        if (route.routeId === routeId){
          changedRoutes.push(route);
        }
      })
    })

   
    var finalChangedRoutes=[];
    angular.forEach(changedRoutes, function(route){
      var employee_nodes=[];
      angular.forEach(route.employees, function(emp){
        employee_nodes.push(emp.empId);
      })
      var data = {
        "route_id":route.routeId,
        "vehicle_category": route.vehicle_type,
        "employee_nodes":employee_nodes
      }
      finalChangedRoutes.push(data);
    })

    var original_routes =[];

    
    var originalChangedRoutes = [];
   
    angular.forEach($scope.originalRoutes, function(route){
      angular.forEach($scope.routeChangedIds, function(routeId){
        if (route.routeId === routeId){
          originalChangedRoutes.push(route);
        }
      })
    })

    angular.forEach(originalChangedRoutes, function(originalRoute){
      var employee_nodes=[];
      angular.forEach(originalRoute.employees_nodes_addresses, function(orgEmp){
        employee_nodes.push(orgEmp.empId);
      })
      var data = {
        "route_id":originalRoute.routeId,
        "vehicle_category": originalRoute.vehicle_type,
        "employee_nodes":employee_nodes
      }
      original_routes.push(data);
    })

    if(finalChangedRoutes.length){
      var shift_type='';

      angular.forEach($scope.shifts,function(shift,idx,shiftArray){
          if(shift.id == $scope.shiftId){
            shift_type=shift.shift_type;
          }
      });
  
      let postData = {
        "site_id":parseInt($scope.siteId),
        "shift_id":parseInt($scope.shiftId),
        "to_date":moment($scope.filterDate).format('YYYY-MM-DD'),
        "shift_type":shift_type,
        "updated_routes":finalChangedRoutes,
        "original_route":original_routes
      }
    
      $scope.isDisabled=true;
      
      RouteUpdateService.query(postData,function(res){
        $scope.resetRoute();
      })
    }
  }

  $scope.resetRoute =function(){
    $scope.finalizeArray=[];
    $scope.routeChangedIds =[];
    var shift_type='';

    angular.forEach($scope.shifts,function(shift,idx,shiftArray){
        if(shift.id == $scope.shiftId){
          shift_type=shift.shift_type;
        }
    });

    $scope.genrateRoute($scope.siteId,$scope.shiftId,$scope.filterDate,shift_type);
  }

  $scope.genrateRoute = function(siteId,shiftId,filterDate,shiftType) {
  
    $scope.getVehicleAndGuardList(siteId,shiftId);

    var shift_type='';

    angular.forEach($scope.shifts,function(shift,idx,shiftArray){
        if(shift.id == shiftId){
          shift_type=shift.shift_type;
        }
    });

    let postData = {
      "site_id":parseInt(siteId),
      "shift_id":parseInt(shiftId),
      "to_date":moment(filterDate).format('YYYY-MM-DD'),
      "shift_type":shift_type // 0 -checkin 1-checout
    }

    RouteService.getRoutes(postData,function(data) {

      // $scope.routes =data;
     

      $scope.routes ={
        "success": true,
        "data": {
            "tats": [
                {
                    "site_id": 30,
                    "shift_id": 138,
                    "to_date": "2019-09-24",
                    "shift_type": "1",
                    "no_of_routes": 2,
                    "male_count": 2,
                    "female_count": 2,
                    "special": 1,
                    "on_duty_vehicle": 3,
                    "kilometres": 60
                }
            ],
            "routes": [
               
              {
                "routeId": 234234,
                "total_time": 90,
                "total_distabce": 40,
                "tripStartTime": "09:00",
                "tripEndTime": "10:00",
                "vehicle_type": "SUV",
                "total_seats": 5,
                "empty_seats": 2,
                "guard_required": "N",
                "vehicle_allocated": "Y",
                "trip_cost": 100,
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
                "route_final_path": [
                    {
                        "lat": "123131231.23",
                        "long": "123131231.23",
                        "time": "09:00"
                    },
                    {
                        "lat": "123131231.23",
                        "long": "123131231.23",
                        "time": "09:00"
                    },
                    {
                        "lat": "123131231.23",
                        "long": "123131231.23",
                        "time": "09:00"
                    },
                    {
                        "lat": "123123123.23",
                        "long": "23423423423.234",
                        "time": "09:00"
                    }
                ],
                "employees_nodes_addresses": [
                    {
                        "rank": 1,
                        "empId": 12312,
                        "empName": "XYZ Indulkar",
                        "lat": "123123123.23",
                        "long": "23423423423.234",
                        "gender": "F",
                        "special": "Yes"
                    },
                    {
                        "rank": 2,
                        "empId": 12312,
                        "empName": "Rushikesh Indulkar",
                        "lat": "123123123.23",
                        "long": "23423423423.234",
                        "gender": "M",
                        "special": "Yes"
                    },
                    {
                        "rank": 3,
                        "empId": 12312,
                        "empName": "Rushikesh Indulkar",
                        "lat": "123123123.23",
                        "long": "23423423423.234",
                        "gender": "M",
                        "special": "Yes"
                    },
                    {
                        "rank": 4,
                        "empId": 12312,
                        "empName": "ABC Indulkar",
                        "lat": "123123123.23",
                        "long": "23423423423.234",
                        "gender": "F",
                        "special": "Yes"
                    }
                ]
            },
                {
                    "routeId": 23423232342344,
                    "total_time": 90,
                    "total_distabce": 40,
                    "tripStartTime": "09:00",
                    "tripEndTime": "10:00",
                    "vehicle_type": "SUV",
                    "total_seats": 5,
                    "empty_seats": 2,
                    "guard_required": "Y",
                    "vehicle_allocated": "N",
                    "trip_cost": 100,
                    "route_final_path": [
                        {
                            "lat": "123131231.23",
                            "long": "123131231.23",
                            "time": "09:00"
                        },
                        {
                            "lat": "123131231.23",
                            "long": "123131231.23",
                            "time": "09:00"
                        },
                        {
                            "lat": "123131231.23",
                            "long": "123131231.23",
                            "time": "09:00"
                        },
                        {
                            "lat": "123123123.23",
                            "long": "23423423423.234",
                            "time": "09:00"
                        }
                    ],
                    "employees_nodes_addresses": [
                        {
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
                            "empName": "PQR Indulkar",
                            "lat": "123123123.23",
                            "long": "23423423423.234",
                            "gender": "F",
                            "special": "Yes"
                        },
                        {
                            "rank": 3,
                            "empId": 12312,
                            "empName": "Rushikesh Indulkar",
                            "lat": "123123123.23",
                            "long": "23423423423.234",
                            "gender": "M",
                            "special": "Yes"
                        },
                        {
                            "rank": 4,
                            "empId": 12312,
                            "empName": "PRS Indulkar",
                            "lat": "123123123.23",
                            "long": "23423423423.234",
                            "gender": "F",
                            "special": "Yes"
                        }
                    ]
                }
            ]
        },
        "errors": {},
        "message": "routes listed successfully"
      }

      $scope.originalRoutes = angular.copy($scope.routes.data.routes);

      $scope.stats = $scope.routes.data.tats[0];

      angular.forEach($scope.routes.data.routes, function(route,index, routeArray){
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
  
      $scope.routes.data.routes.push(
        {
          "vehicle_allocated":'',
          "employees" :[],
          "vehicle":[],
          "guard":[],
          "allowed":"all"
        }
      )
  
      $scope.fullModel =[$scope.routes.data.routes];
      $scope.model2 = $scope.fullModel;
    
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

    $scope.routeChangedIds =[];

    $scope.dragoverCallback = function(container,index, external, type, callback) {
      if ($scope.routeChangedIds.indexOf(container.routeId) === -1){
        $scope.routeChangedIds.push(container.routeId)
        console.log( $scope.routeChangedIds);
        $scope.isDisabled=false;
      }
     
        if (type == 'container' && !external) {
            console.log('Container being dragged contains ' + callback() + ' items');
        }
        return index < 10; // Disallow dropping in the third row.
    };

    

    $scope.dropCallback = function(container,index, item, external, type) {
      if ($scope.routeChangedIds.indexOf(container.routeId) === -1){
        $scope.routeChangedIds.push(container.routeId)
        console.log( $scope.routeChangedIds);
        $scope.isDisabled=false;
      }
      return item;
    };

    $scope.dropVehicleCallback =function(container,index, item, external, type) {

      var isAssign =true;
      if(isAssign){
        var postData ={
          "vehicleId":item.vehicleId,
          "routeId":container.routeId
        };
  
        VehicleAssignService.query(postData, function(data){
          console.log("Guard Assign");
          isAssign=false;
        })
        return container;
      }
     
    };

    $scope.dropGuardCallback =function(container,index, item, external, type) {
      
      var isAssign =true;
      if(isAssign){
        var postData ={
          "guardId":item.id,
          "routeId":container.routeId
        };
  
        GuardAssignService.query(postData, function(data){
          console.log("Guard Assign");
          $scope.resetRoute();
        })

        return container;
      }
    };

    $scope.logEvent = function(message) {
        // console.log(message);
    };

    $scope.logListEvent = function(action, index, external, type) {
        var message = external ? 'External ' : '';
        message += type + ' element was ' + action + ' position ' + index;
        // console.log(message);
    };

    $scope.allowedVehicalTypes=['vehical'];
    $scope.allowedGuardTypes=['guard'];

    // // Initialize model

    $scope.autoAllocate =function() {
      var postData ={
        "site_id":$scope.siteId,
        "shift_id_id":$scope.shiftId,
      }
      AutoAllocationService.query(function(data){
         $scope.routes=data;
         $scope.resetRoute();
      })
    }
   
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
