
// Services 
angular.module('app').constant('BASE_URL', 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com:8001/api/v1/');
angular.module('app').constant('BASE_URL_8002', 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com/');
angular.module('app').constant('BASE_URL_RUBY', 'http://alb-uat10-1592161168.ap-south-1.elb.amazonaws.com/api/v2/');

angular.module('app').factory('SessionService', function() {
    // var _data ={
    //     uid:'deekshithmech@gmail.com',
    //     access_token:'h-Hen_PE9YDkOTa-HLjMVw',
    //     client:'A50BtzCIieAvpcTk2450ew'
    // }

    var _data2 ={
        custId : 1,
        uid:'deekshithmech@gmail.com',
        access_token:'LD0GDI5yEEG7oYIXJFfa1A',
        client:'R5qaZj5Za6wry2CPBkUvSQ'
    }
    
    return _data2;
});