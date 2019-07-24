$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A');

    // init exception summary table
    var reportsExceptionSummaryTable = $('#reports-exception-summary-table').DataTable({
        serverSide: true,
        ajax: {
            url: "/reports/exceptions_summary",
            data: function (d) {
                d.startDate = startDate;
                d.endDate = endDate;
            }
        },
        searching: false,
        lengthChange: false,
        pagingType: "simple_numbers",
        paging: false,
        info: false,
        autoWidth: false,
        ordering: false,
        columns: [
            {data: "date"},
            {data: "total_rosters_submitted"},
            {data: "total_rosters_fulfilled"},
            {data: "late_check_ins"},
            {data: "late_departures"},
            {data: "employees_as_no_show"},
            {data: "pick_up_no_show"},
            {data: "drop_off_no_show"}
        ]
    });

    // Init picker
    $('#exception-summary-picker').daterangepicker({
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
            reportsExceptionSummaryTable.draw();
        });
});