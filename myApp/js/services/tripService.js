
angular.module('app').factory('ShiftService', ['$resource','BASE_URL',
    function ($resource,BASE_URL) {
        return $resource(BASE_URL+'getAllSiteList', {}, {
            query: { method: "GET", isArray: true },
            create: { method: "POST"},
            get: { method: "POST"},
            remove: { method: "DELETE"},
            update: { method: "PUT"}
        });
 
}]);