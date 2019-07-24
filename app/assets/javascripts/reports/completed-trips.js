$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A');

    // init completed trips table
    var completedTripsTable = $('#reports-completed-trips-table').DataTable({
        serverSide: true,
        ajax: {
            url: "/reports/completed",
            data: function (d) {
                d.startDate = startDate;
                d.endDate = endDate;
            }            
        },
        searching: false,
        lengthChange: false,
        pagingType: "simple_numbers",
        info: false,
        autoWidth: false,
        ordering: false,
        columns: [
            {data: "trip_roster"},
            {data: "driver"},
            {data: "check_in_time"},
            {data: "actual_check_in_time"},
            {data: "average_rating"},
            {data: "duration"},
            {data: "distance"}
        ]
    });

    // Init picker
    $('#completed-trips-picker').daterangepicker({
            timePicker: true,
            applyClass: 'btn-primary',
            timePickerIncrement: 30,
            startDate: moment(),
            endDate: moment().add(1, 'day'),
            locale: {
                format: 'DD/MM/YYYY h:mm A'
            }
        },

        function (start, end) {
            startDate = start.format('DD/MM/YYYY h:mm A');
            endDate = end.format('DD/MM/YYYY h:mm A');
            completedTripsTable.draw();
        });
});