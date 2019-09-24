
// Services 
angular.module('app').constant('BASE_URL', 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com/');

angular.module('app').factory('SessionService', function($resource,BASE_URL) {
    return $resource(BASE_URL+'api/entries');
});