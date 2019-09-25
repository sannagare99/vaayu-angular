app.controller('routeCtrl', function ($scope, $http, $state,Map,VehicleService,SiteService,GuardsService) {

    $scope.place = {};
    Map.init();
  
   

    $scope.init = function(){
       
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
