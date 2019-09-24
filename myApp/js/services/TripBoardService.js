
angular.module('app').factory('TripboardService', function($resource,BASE_URL) {
    return $resource(BASE_URL+'api/entries');
});
