
// Services 
angular.module('app').constant('BASE_URL', 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com:8001/api/v1/');
angular.module('app').constant('BASE_URL_8002', 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com:8002/api/v1/');

angular.module('app').factory('SessionService', function() {
    var _data ={
        uid:'deekshithmech@gmail.com',
        access_token:'h-Hen_PE9YDkOTa-HLjMVw',
        client:'A50BtzCIieAvpcTk2450ew'
    }
    
    return _data;
});