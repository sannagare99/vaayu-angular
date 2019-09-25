
angular.module('app').factory('RosterService', ['$resource','BASE_URL_8002','BASE_URL',
function ($resource,BASE_URL_8002,BASE_URL) {
    return $resource(BASE_URL_8002+'roasterlist', {}, {
        // query: { method: "GET", isArray: true },
        // create: { method: "POST"},
        get: { method: "POST"},
        // remove: { method: "DELETE"},
        // update: { method: "PUT"}
        addVehicle:{
          url: BASE_URL_8002 + 'addvehicle',
          method: "POST"
        },
        getAllSiteList:{
          url: BASE_URL + 'getAllSiteList',
          method: "POST"
        }
    });

}]);



