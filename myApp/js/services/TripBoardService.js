
angular.module('app').factory('TripboardService',['$resource','BASE_URL_8002','BASE_URL',
 function($resource,BASE_URL_8002,BASE_URL) {
    return $resource(BASE_URL_8002+'tripBoardList',{},{
        get: { method: "POST"},
        getAllSiteList:{
          url: BASE_URL + 'getAllSiteList',
          method: "POST"
        }
    });
}]);
