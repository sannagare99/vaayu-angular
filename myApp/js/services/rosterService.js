
angular.module('app').factory('RosterService', ['$resource','BASE_URL_8002',
function ($resource,BASE_URL_8002) {
    return $resource(BASE_URL_8002+'roasterlist', {}, {
        query: { method: "GET", isArray: true },
        create: { method: "POST"},
        get: { method: "POST"},
        remove: { method: "DELETE"},
        update: { method: "PUT"}
    });

}]);



