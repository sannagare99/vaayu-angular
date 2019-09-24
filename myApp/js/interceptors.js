
angular.module('app').factory('sessionInjector', ['SessionService', function(SessionService) {  
    var sessionInjector = {
        request: function(config) {
            if (!SessionService.isAnonymus) {
                // config.headers['Content-Type']='application/json';
                config.headers['uid'] = SessionService.uid;
                config.headers['access_token'] = SessionService.access_token;
                config.headers['client'] = SessionService.client;
                config.headers['Content-Type'] = 'application/json'
            }

            console.log(config.headers);
            return config;
        }
    };
    return sessionInjector;
}]);

angular.module('app').config(['$httpProvider', function($httpProvider) {  
    $httpProvider.interceptors.push('sessionInjector');
}]);