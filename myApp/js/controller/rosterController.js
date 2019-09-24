angular.module('app').controller('rosterCtrl', function($scope,RosterService, ShiftService, $http){

    $scope.init = function(){
        console.log('init called');
        let postData = {
            "site_id":8,
            "to_date":"2019-09-23"
        }
        RosterService.post(postData, function(data) {
            $scope.rosters=data;
            console.log($scope.rosters)
        });
        // $scope.fetchRoasterList(postData);
        ShiftService.get(function(data) {
            $scope.shifts=data.data.list;
        });

        $scope.rosters=[
            {
                shift:"shift1",
                type:1,
                shift_time:"09:00 AM",
                shift_type:"Check In",
                no_of_employee:"236",
                vehicle_required:"4 SUV | 2 TT | 3HB : 22VEHICLE",
                vehicle_avialble:"23",
                result:'GOOD TO GO'
            },
            {
                shift:"shift1",
                type:2,
                shift_time:"09:00 AM",
                shift_type:"Check In",
                no_of_employee:"236",
                vehicle_required:"4 SUV | 2 TT | 3HB : 22VEHICLE",
                vehicle_avialble:"23",
                result:'GOOD TO GO'
            },
            {
                shift:"shift1",
                type:1,
                shift_time:"09:00 AM",
                shift_type:"Check Out",
                no_of_employee:"236",
                vehicle_required:"4 SUV | 2 TT | 3HB : 22VEHICLE",
                vehicle_avialble:"2",
                result:'REQUIRED MORE VEHICLE'
            }
        ]
    }

    $scope.fetchRoasterList = (data) => {
       
        $http({
            method: 'POST',
            url: 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com:8002/api/v1/roasterlist',
            headers: {
              'Content-Type': 'application/json',
              'uid': 'deekshithmech@gmail.com',
              'access_token': 'h-Hen_PE9YDkOTa-HLjMVw',
              'client': 'A50BtzCIieAvpcTk2450ew'
            },
            data: data
           })
        .then(res =>  { 
            if (res.data['success']) {
                this.siteNames = res.data.data.list;
                console.log(JSON.stringify(this.siteNames))
            } else {
                alert(res.data['message']);
            }
         });
    };

    
});
