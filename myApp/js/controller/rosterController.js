angular.module('app').controller('rosterCtrl', function($scope,ShiftService){

    ShiftService.get(function(data) {
        console.log(data);
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
});