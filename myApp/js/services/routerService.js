
angular.module('app').factory('VehicleService', ['$resource','BASE_URL_8002','SessionService',
    function ($resource,BASE_URL_8002,SessionService) {
        return $resource(BASE_URL_8002+'getVehicleData', {}, {
            query: { method: "GET", isArray: true },
            create: { method: "POST"},
            get: { 
                method: "GET"
            },
            remove: { method: "DELETE"},
            update: { method: "PUT"}
        });
}]);

angular.module('app').factory('GuardsService', ['$resource','BASE_URL_8002','SessionService',
    function ($resource,BASE_URL_8002,SessionService) {
        return $resource(BASE_URL_8002+'getAllGuards', {}, {
            query: { 
                method: "GET"
            },
            create: { method: "POST"},
            get: { 
                method: "GET"
            },
            remove: { method: "DELETE"},
            update: { method: "PUT"}
        });
}]);

angular.module('app').factory('RouteService', ['$resource','BASE_URL_8002','SessionService',
    function ($resource,BASE_URL_8002,SessionService) {
        return $resource(BASE_URL_8002+'generateRoutes', {}, {
            query: { method: "GET", isArray: true },
            create: { method: "POST"},
            getRoutes: { 
                method: "POST"
            },
            remove: { method: "DELETE"},
            update: { method: "PUT"}
        });
}]);

angular.module('app').factory('RouteUpdateService', ['$resource','BASE_URL_8002','SessionService',
    function ($resource,BASE_URL_8002,SessionService) {
        return $resource(BASE_URL_8002+'updateEmployeeRoutes', {}, {
            query: { method: "POST"},
            create: { method: "POST"},
            getRoutes: { 
                method: "POST"
            },
            remove: { method: "DELETE"},
            update: { method: "PUT"}
        });
}]);

angular.module('app').factory('AutoAllocationService', ['$resource','BASE_URL_8002','SessionService',
    function ($resource,BASE_URL_8002,SessionService) {
        return $resource(BASE_URL_8002+'allocateVehicles', {}, {
            query: { method: "POST"},
            create: { method: "POST"},
            getRoutes: { 
                method: "POST"
            },
            remove: { method: "DELETE"},
            update: { method: "PUT"}
        });
}]);


angular.module('app').factory('VehicleAssignService', ['$resource','BASE_URL_8002','SessionService',
    function ($resource,BASE_URL_8002,SessionService) {
        return $resource(BASE_URL_8002+'assignVehicleToTrip', {}, {
            query: { method: "PATCH"},
            create: { method: "POST"},
            getRoutes: { 
                method: "POST"
            },
            remove: { method: "DELETE"},
            update: { method: "PUT"}
        });
}]);

angular.module('app').factory('GuardAssignService', ['$resource','BASE_URL_8002','SessionService',
    function ($resource,BASE_URL_8002,SessionService) {
        return $resource(BASE_URL_8002+'addGuardInTrip', {}, {
            query: { method: "PATCH"},
            create: { method: "POST"},
            getRoutes: { 
                method: "POST"
            },
            remove: { method: "DELETE"},
            update: { method: "PUT"}
        });
}]);




