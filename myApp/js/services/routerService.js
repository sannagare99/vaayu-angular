
angular.module('app').factory('VehicleService', ['$resource','BASE_URL','SessionService',
    function ($resource,BASE_URL,SessionService) {
        return $resource(BASE_URL+'vehicles', {}, {
            query: { method: "GET", isArray: true },
            create: { method: "POST"},
            get: { 
                method: "GET",
                headers: { 
                    'Content-Type':'application/json',
                    'uid': SessionService.uid,
                    'access_token': SessionService.access_token,
                    'client':SessionService.client
                }
            },
            remove: { method: "DELETE"},
            update: { method: "PUT"}
        });
}]);