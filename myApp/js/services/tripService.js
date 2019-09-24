
angular.module('app').factory('SiteService', ['$resource','BASE_URL','SessionService',
    function ($resource,BASE_URL,SessionService) {
        return $resource(BASE_URL+'getAllSiteList', {}, {
            query: { method: "GET", isArray: true },
            create: { method: "POST"},
            get: { 
                method: "POST",
                headers: { 
                    'uid': SessionService.uid,
                    'access_token': SessionService.access_token,
                    'client':SessionService.client
                }
            },
            remove: { method: "DELETE"},
            update: { method: "PUT"}
        });
}]);

angular.module('app').factory('GuardService', ['$resource','BASE_URL',
    function ($resource,BASE_URL) {
        return $resource(BASE_URL+'guard', {}, {
            query: { method: "GET", isArray: true },
            create: { method: "POST"},
            get: { method: "POST"},
            remove: { method: "DELETE"},
            update: { method: "PUT"}
        });
}]);


angular.module('app').factory('DriverService', ['$resource','BASE_URL_RUBY',
    function ($resource,BASE_URL_RUBY) {
        return $resource(BASE_URL_RUBY+'drivers', {}, {
            query: { method: "GET"},
            create: { method: "POST"},
            get:  { method: "GET"},
            remove: { method: "DELETE"},
            update: { method: "PUT"}
        });
}]);

