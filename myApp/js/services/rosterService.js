
// angular.module('app').factory('RosterService', function($resource,BASE_URL) {
//     return $resource(BASE_URL+'getAllSiteList');
// });


angular.module('app').factory('RosterService',['$resource', 'BASE_URL',
  function($resource,BASE_URL) {
    return $resource('allocation', {
        //subDivisionId: '@_id'
      },{
    post:{
        url: BASE_URL+'allocation/autoallocate' ,
        method: 'POST'
    },
  });
  },
]);
