
// angular.module('app').factory('RosterService', function($resource,BASE_URL) {
//     return $resource(BASE_URL+'getAllSiteList');
// });



angular.module('app').factory('RosterService',['$resource', 'BASE_URL', 'BASE_URL_8002',
  function($resource,BASE_URL, BASE_URL_8002) {
    return $resource('allocation', {},{
    post:{
        url: BASE_URL_8002 + 'roasterlist' ,
        method: 'POST',
        isArray: false
    },
  });
  },
]);
