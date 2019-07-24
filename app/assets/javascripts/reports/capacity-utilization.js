$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A');

    // init capacity utilization table
    var capacityUtilizationTable = $('#reports-capacity-utilization-table').DataTable({
        serverSide: true,
        ajax: {
            url: "/reports/utilization",
            data: function (d) {
                d.startDate = startDate;
                d.endDate = endDate;
            }
        },
        lengthChange: false,
        searching: false,
        pagingType: "simple_numbers",
        paging: false,
        info: false,
        autoWidth: false,
        ordering: false,
        columns: [
            {data: "date"},
            {data: "vehicles_deployed"},
            {data: "total_available_capacity"},
            {data: "total_employees_transported"},
            {data: "utilization"}
        ]
    });

    // Init picker
    $('#capacity-utilization-picker').daterangepicker({
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
            capacityUtilizationTable.draw();
        });
});