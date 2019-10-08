
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
        return $resource(BASE_URL_8002 + 'generateRoutes', {}, {
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
        return $resource(BASE_URL_8002 + 'allocateVehicles', {}, {
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
        route_response: {
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
                        "guard": {
                            "guardId": 12311,
                            "guardName": "Dhruv Rathi",
                            "gender": "M"
                        },
                        "vehicle": {
                            "vehicleId": 12312,
                            "vehicleNumber": "MH47L5609",
                            "driverName": "Rushikesh Indulkar",
                            "driverID": 232423,
                            "vehicleType": "HB"
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
                                "empId": 12313,
                                "empName": "Vaibhavi Rawale",
                                "lat": "123123123.23",
                                "long": "23423423423.234",
                                "gender": "F",
                                "special": "Yes"
                            },
                            {
                                "rank": 2,
                                "empId": 12312,
                                "empName": "Madhuri Dikshit",
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
                                "empName": "Mansi Sawant",
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
                                "empName": "Umar Sayyed",
                                "lat": "123123123.23",
                                "long": "23423423423.234",
                                "gender": "M",
                                "special": "Yes"
                            },
                            {
                                "rank": 2,
                                "empId": 12312,
                                "empName": "Ekta Shinde",
                                "lat": "123123123.23",
                                "long": "23423423423.234",
                                "gender": "F",
                                "special": "Yes"
                            },
                            {
                                "rank": 3,
                                "empId": 12312,
                                "empName": "Pranjali Deshmukh Deshmukh Deshmukh ",
                                "lat": "123123123.23",
                                "long": "23423423423.234",
                                "gender": "M",
                                "special": "Yes"
                            },
                            {
                                "rank": 4,
                                "empId": 12312,
                                "empName": "Praveen Samariya",
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
    }


});