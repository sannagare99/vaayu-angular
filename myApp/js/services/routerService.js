
angular.module('app').factory('VehicleService', ['$resource', 'BASE_URL_8002', 'SessionService',
  function ($resource, BASE_URL_8002, SessionService) {
    return $resource(BASE_URL_8002 + 'getVehicleData', {}, {
      query: { method: "GET", isArray: true },
      create: { method: "POST" },
      get: {
        method: "GET"
      },
      remove: { method: "DELETE" },
      update: { method: "PUT" }
    });
  }]);

angular.module('app').factory('GuardsService', ['$resource', 'BASE_URL_8002', 'SessionService',
  function ($resource, BASE_URL_8002, SessionService) {
    return $resource(BASE_URL_8002 + 'getAllGuards', {}, {
      query: {
        method: "GET"
      },
      create: { method: "POST" },
      get: {
        method: "GET"
      },
      remove: { method: "DELETE" },
      update: { method: "PUT" }
    });
  }]);

angular.module('app').factory('RouteService', ['$resource', 'BASE_URL_8002', 'SessionService',
  function ($resource, BASE_URL_8002, SessionService) {
    return $resource('http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com:8002/api/v1/' + 'generateRoutes', {}, {
      query: { method: "GET", isArray: true },
      create: { method: "POST" },
      getRoutes: {
        method: "POST"
      },
      remove: { method: "DELETE" },
      update: { method: "PUT" }
    });
  }]);

angular.module('app').factory('RouteUpdateService', ['$resource', 'BASE_URL_8002', 'SessionService',
  function ($resource, BASE_URL_8002, SessionService) {
    return $resource(BASE_URL_8002 + 'updateEmployeeRoutes', {}, {
      query: { method: "POST" },
      create: { method: "POST" },
      getRoutes: {
        method: "POST"
      },
      remove: { method: "DELETE" },
      update: { method: "PUT" }
    });
  }]);

angular.module('app').factory('AutoAllocationService', ['$resource', 'BASE_URL_8002', 'SessionService',
  function ($resource, BASE_URL_8002, SessionService) {
    return $resource('https://2c6da523.ngrok.io/' + 'allocateVehicles', {}, {
      query: { method: "POST" },
      create: { method: "POST" },
      getRoutes: {
        method: "POST"
      },
      remove: { method: "DELETE" },
      update: { method: "PUT" }
    });
  }]);


angular.module('app').factory('VehicleAssignService', ['$resource', 'BASE_URL_8002', 'SessionService',
  function ($resource, BASE_URL_8002, SessionService) {
    return $resource(BASE_URL_8002 + 'assignVehicleToTrip', {}, {
      query: { method: "PATCH" },
      create: { method: "POST" },
      getRoutes: {
        method: "POST"
      },
      remove: { method: "DELETE" },
      update: { method: "PUT" }
    });
  }]);

angular.module('app').factory('GuardAssignService', ['$resource', 'BASE_URL_8002', 'SessionService',
  function ($resource, BASE_URL_8002, SessionService) {
    return $resource(BASE_URL_8002 + 'addGuardInTrip', {}, {
      query: { method: "PATCH" },
      create: { method: "POST" },
      getRoutes: {
        method: "POST"
      },
      remove: { method: "DELETE" },
      update: { method: "PUT" }
    });
  }]);

angular.module('app').factory('FinalizeService', ['$resource', 'BASE_URL_8002', 'SessionService',
  function ($resource, BASE_URL_8002, SessionService) {
    return $resource(BASE_URL_8002 + 'routesFinalize', {}, {
      query: { method: "POST" },
      create: { method: "POST" },
      getRoutes: {
        method: "POST"
      },
      remove: { method: "DELETE" },
      update: { method: "PUT" }
    });
  }]);







angular.module('app').factory('RouteStaticResponse', function () {

  return {

    emptyResponse: {
      "success": true,
      "data": {
        "tats": [
          {
            "site_id": 0,
            "shift_id": 0,
            "no_of_routes": 0,
            "male_count": 0,
            "female_count": 0,
            "special": 0,
            "on_duty_vehicle": 0,
            "kilometres": 0
          }
        ],
        "routes": [],
      }
    },

    route_response: {
      "success": true,
      "data": {
        "shiftId": 93,
        "shiftType": "checkin",
        "tripEnd": "tripEnd",
        "siteId": 8,
        "routes": [
          // {
          //     "routeId": 234234,
          //     "total_time": 90,
          //     "total_distance": 40,
          //     "tripStartTime": "09:00",
          //     "tripEndTime": "10:00",
          //     "vehicle_type": "SUV",
          //     "total_seats": 5,
          //     "empty_seats": 2,
          //     "guard_required": "N",
          //     "vehicle_allocated": "Y",
          //     "trip_cost": 100,
          //     "guard": null,
          //     "vehicle": null,
          //     "route_final_path": [
          //         {
          //             "lat": 12.935227, "long": 77.624433, "rank": "1", "time": "09:30"
          //         }
          //     ],
          //     "employees_nodes_addresses": [

          //         {
          //             "empId": 3949,
          //             "empName": "rawale-vaibhavi-mahindra-com",
          //             "gender": "M",
          //             "long": "77.624433",
          //             "rank": "1",
          //             "lat": "12.935227",
          //             "special": "No"
          //         }

          //     ]
          // },
          // {
          //     "routeId": 234234,
          //     "total_time": 90,
          //     "total_distance": 100,
          //     "tripStartTime": "09:00",
          //     "tripEndTime": "10:00",
          //     "vehicle_type": "SUV",

          //     "empty_seats": 1, 
          //     "total_seats": 5,
          //     "trip_cost": 100,

          //     "vehicle_allocated": "Y",
          //     "guard_required": "Y",
          //     "guard": null, 
          //     "vehicle": null,
          //     "route_final_path": [
          //         {
          //             "lat": 12.935227, "long": 77.624433, "rank": "1", "time": "09:30"
          //         }
          //     ], 
          //     "employees_nodes_addresses": [
          //         {
          //             "empId": 3949,
          //             "empName": "rawale-vaibhavi-mahindra-com",
          //             "gender": "M",
          //             "long": "77.624433",
          //             "rank": "1",
          //             "lat": "12.935227",
          //             "special": "No"
          //         }
          //     ],

          // },
          {
            "total_time": "1:00:00",
            "route_final_path": [
              {
                "lat": 12.935227, "long": 77.624433, "rank": "1", "time": "09:30"
              }
            ],
            "guard_required": "Y",
            "empty_seats": 1,
            "total_distance": 100,
            "employees_nodes_addresses": [
              {
                "empId": 3949,
                "empName": "rawale-vaibhavi-mahindra-com",
                "gender": "M",
                "long": "77.624433",
                "rank": "1",
                "lat": "12.935227",
                "special": "No"
              }
            ],
            "routeId": "23423232342344",
            "tripEndTime": "2019-10-10 09:04:21.737282",
            "trip_cost": 100,
            "vehicle_type": "BUS",
            "tripStartTime": "2019-10-10 09:04:21.737258",
            "total_seats": 57,
            "vehicle_allocated": "N",
            "guard": null, "vehicle": null
          }
        ],
        "tripStart": "tripStart",
        "siteLong": 77.735542,
        "customerID": 8,
        "siteLat": 12.985924,
        "tats": [
          {
            "site_id": 8,
            "shift_id": 8,
            "to_date": "2019-10-08",

            "shift_type": 0,
            "no_of_routes": 2,
            "male_count": 2,
            "female_count": 2,
            "special": 1,
            "on_duty_vehicle": 3,
            "kilometres": 60
          }
        ]
      }, "errors": {}, "message": "routes listed successfully"
    },

    // route_response: {
    //     "success": true,
    //     "data": {
    //         "tats": [
    //             {
    //                 "site_id": 30,
    //                 "shift_id": 138,
    //                 "to_date": "2019-09-24",
    //                 "shift_type": "1",
    //                 "no_of_routes": 2,
    //                 "male_count": 2,
    //                 "female_count": 2,
    //                 "special": 1,
    //                 "on_duty_vehicle": 3,
    //                 "kilometres": 60
    //             }
    //         ],
    //         "routes": [
    //             {
    //                 "routeId": 234234,
    //                 "total_time": 90,
    //                 "total_distance": 40,
    //                 "tripStartTime": "09:00",
    //                 "tripEndTime": "10:00",
    //                 "vehicle_type": "SUV",
    //                 "total_seats": 5,
    //                 "empty_seats": 2,
    //                 "guard_required": "N",
    //                 "vehicle_allocated": "Y",
    //                 "trip_cost": 100,
    //                 "guard": {
    //                     "guardId": 12311,
    //                     "guardName": "Dhruv Rathi",
    //                     "gender": "M"
    //                 },
    //                 "vehicle": {
    //                     "vehicleId": 12312,
    //                     "vehicleNumber": "MH47L5609",
    //                     "driverName": "Rushikesh Indulkar",
    //                     "driverID": 232423,
    //                     "vehicleType": "HB"
    //                 },
    //                 "route_final_path": [
    //                     {
    //                         "lat": "123131231.23",
    //                         "long": "123131231.23",
    //                         "time": "09:00"
    //                     },
    //                     {
    //                         "lat": "123131231.23",
    //                         "long": "123131231.23",
    //                         "time": "09:00"
    //                     },
    //                     {
    //                         "lat": "123131231.23",
    //                         "long": "123131231.23",
    //                         "time": "09:00"
    //                     },
    //                     {
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "time": "09:00"
    //                     }
    //                 ],
    //                 "employees_nodes_addresses": [
    //                     {
    //                         "rank": 1,
    //                         "empId": 12313,
    //                         "empName": "Vaibhavi Rawale",
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "gender": "F",
    //                         "special": "Yes"
    //                     },
    //                     {
    //                         "rank": 2,
    //                         "empId": 12314,
    //                         "empName": "Madhuri Dikshit",
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "gender": "M",
    //                         "special": "Yes"
    //                     },
    //                     {
    //                         "rank": 3,
    //                         "empId": 12315,
    //                         "empName": "Ajay Sharma",
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "gender": "M",
    //                         "special": "Yes"
    //                     },
    //                     {
    //                         "rank": 4,
    //                         "empId": 12316,
    //                         "empName": "Mansi Sawant",
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "gender": "F",
    //                         "special": "Yes"
    //                     }
    //                 ]
    //             },
    //             {
    //                 "routeId": 234278,
    //                 "total_time": 90,
    //                 "total_distance": 40,
    //                 "tripStartTime": "09:00",
    //                 "tripEndTime": "10:00",
    //                 "vehicle_type": "SUV",
    //                 "total_seats": 5,
    //                 "empty_seats": 2,
    //                 "guard_required": "N",
    //                 "vehicle_allocated": "Y",
    //                 "trip_cost": 100,
    //                 "guard": {
    //                     "guardId": 12411,
    //                     "guardName": "Bambam Singh",
    //                     "gender": "M"
    //                 },
    //                 "vehicle": {
    //                     "vehicleId": 12412,
    //                     "vehicleNumber": "MH04L9608",
    //                     "driverName": "Sumit P",
    //                     "driverID": 232523,
    //                     "vehicleType": "HB"
    //                 },
    //                 "route_final_path": [
    //                     {
    //                         "lat": "123131231.23",
    //                         "long": "123131231.23",
    //                         "time": "09:00"
    //                     },
    //                     {
    //                         "lat": "123131231.23",
    //                         "long": "123131231.23",
    //                         "time": "09:00"
    //                     },
    //                     {
    //                         "lat": "123131231.23",
    //                         "long": "123131231.23",
    //                         "time": "09:00"
    //                     },
    //                     {
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "time": "09:00"
    //                     }
    //                 ],
    //                 "employees_nodes_addresses": [
    //                     {
    //                         "rank": 1,
    //                         "empId": 12413,
    //                         "empName": "Pushp C",
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "gender": "F",
    //                         "special": "Yes"
    //                     },
    //                     {
    //                         "rank": 2,
    //                         "empId": 12414,
    //                         "empName": "Rajeev S",
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "gender": "M",
    //                         "special": "Yes"
    //                     },
    //                     {
    //                         "rank": 3,
    //                         "empId": 12415,
    //                         "empName": "Dipak P",
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "gender": "M",
    //                         "special": "Yes"
    //                     },
    //                     {
    //                         "rank": 4,
    //                         "empId": 12416,
    //                         "empName": "Atul J",
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "gender": "F",
    //                         "special": "Yes"
    //                     }
    //                 ]
    //             },


    //             {
    //                 "routeId": 23423232342344,
    //                 "total_time": 90,
    //                 "total_distance": 40,
    //                 "tripStartTime": "09:00",
    //                 "tripEndTime": "10:00",
    //                 "vehicle_type": "SUV",
    //                 "total_seats": 5,
    //                 "empty_seats": 2,
    //                 "guard_required": "Y",
    //                 "vehicle_allocated": "N",
    //                 "trip_cost": 100,
    //                 "route_final_path": [
    //                     {
    //                         "lat": "123131231.23",
    //                         "long": "123131231.23",
    //                         "time": "09:00"
    //                     },
    //                     {
    //                         "lat": "123131231.23",
    //                         "long": "123131231.23",
    //                         "time": "09:00"
    //                     },
    //                     {
    //                         "lat": "123131231.23",
    //                         "long": "123131231.23",
    //                         "time": "09:00"
    //                     },
    //                     {
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "time": "09:00"
    //                     }
    //                 ],
    //                 "employees_nodes_addresses": [
    //                     {
    //                         "rank": 1,
    //                         "empId": 12321,
    //                         "empName": "Umar Sayyed",
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "gender": "M",
    //                         "special": "Yes"
    //                     },
    //                     {
    //                         "rank": 2,
    //                         "empId": 12322,
    //                         "empName": "Ekta Shinde",
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "gender": "F",
    //                         "special": "Yes"
    //                     },
    //                     {
    //                         "rank": 3,
    //                         "empId": 12323,
    //                         "empName": "Pranjali Deshmukh Deshmukh Deshmukh ",
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "gender": "M",
    //                         "special": "Yes"
    //                     },
    //                     {
    //                         "rank": 4,
    //                         "empId": 12324,
    //                         "empName": "Praveen Samariya",
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "gender": "F",
    //                         "special": "Yes"
    //                     }
    //                 ]
    //             },
    //             {
    //                 "routeId": 23423232342389,
    //                 "total_time": 90,
    //                 "total_distance": 40,
    //                 "tripStartTime": "09:00",
    //                 "tripEndTime": "10:00",
    //                 "vehicle_type": "SUV",
    //                 "total_seats": 5,
    //                 "empty_seats": 2,
    //                 "guard_required": "Y",
    //                 "vehicle_allocated": "N",
    //                 "trip_cost": 100,
    //                 "route_final_path": [
    //                     {
    //                         "lat": "123131231.23",
    //                         "long": "123131231.23",
    //                         "time": "09:00"
    //                     },
    //                     {
    //                         "lat": "123131231.23",
    //                         "long": "123131231.23",
    //                         "time": "09:00"
    //                     },
    //                     {
    //                         "lat": "123131231.23",
    //                         "long": "123131231.23",
    //                         "time": "09:00"
    //                     },
    //                     {
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "time": "09:00"
    //                     }
    //                 ],
    //                 "employees_nodes_addresses": [
    //                     {
    //                         "rank": 1,
    //                         "empId": 12521,
    //                         "empName": "Rushikesh I",
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "gender": "M",
    //                         "special": "Yes"
    //                     },
    //                     {
    //                         "rank": 2,
    //                         "empId": 12522,
    //                         "empName": "Sachin P",
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "gender": "F",
    //                         "special": "Yes"
    //                     },
    //                     {
    //                         "rank": 3,
    //                         "empId": 12523,
    //                         "empName": "Nitin M",
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "gender": "M",
    //                         "special": "Yes"
    //                     },
    //                     {
    //                         "rank": 4,
    //                         "empId": 12524,
    //                         "empName": "Dhruv R",
    //                         "lat": "123123123.23",
    //                         "long": "23423423423.234",
    //                         "gender": "F",
    //                         "special": "Yes"
    //                     }
    //                 ]
    //             }
    //         ]
    //     },
    //     "errors": {},
    //     "message": "routes listed successfully"
    // },

    all_guards_response: [
      {
        "guardId": 12911,
        "guardName": "Bambam Singh",
        "gender": "M"
      },
      {
        "guardId": 12912,
        "guardName": "Bambam Singh",
        "gender": "M"
      },
      {
        "guardId": 12913,
        "guardName": "Bambam Singh",
        "gender": "M"
      },
      {
        "guardId": 12914,
        "guardName": "Bambam Singh",
        "gender": "M"
      },

    ],

    all_vehicle_response: [
      {
        "vehicleId": 12915,
        "vehicleNumber": "MH04L8971",
        "driverName": "Rajeev P",
        "driverID": 232524,
        "vehicleType": "SUV"
      },
      {
        "vehicleId": 12916,
        "vehicleNumber": "MH04L8972",
        "driverName": "Akshay P",
        "driverID": 232525,
        "vehicleType": "HB"
      },
      {
        "vehicleId": 12917,
        "vehicleNumber": "MH04L8973",
        "driverName": "Robin P",
        "driverID": 232526,
        "vehicleType": "SUV"
      },
      {
        "vehicleId": 12918,
        "vehicleNumber": "MH04L8974",
        "driverName": "Chulbul P",
        "driverID": 232527,
        "vehicleType": "HB"
      },
    ]

  }


});