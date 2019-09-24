
angular.module('app').factory('TripService', function($resource,BASE_URL) {
    return $resource(BASE_URL+'getAllSiteList');
});
