$(function () {
    'use strict';

    var $activeTripTable = $('#reports-active-trip-table');

    // init active trips table
    var reportsActiveTripTable = $activeTripTable.DataTable({
        serverSide: true,
        ajax: "/reports/active",
        searching: false,
        lengthChange: false,
        pagingType: "simple_numbers",
        paging: false,
        info: false,
        autoWidth: false,
        ordering: false,
        columns: [
            {
                className: 'details-control text-center',
                data: null,
                width: '20px',
                defaultContent: '<i class="fa fa-chevron-right"></i>'
            },
            {data: "trip_roster"},
            {data: "driver"},
            {data: "phone"},
            {
                data: "trip_status",
                width: '10%'
            }
        ]
    });

    // show child rows
    $activeTripTable.on('click', 'td.details-control', function () {
        var tr = $(this).closest('tr');
        var row = reportsActiveTripTable.row(tr);

        if (row.child.isShown()) {
            // This row is already open - close it
            row.child.hide();
            tr.removeClass('selected');
        }
        else {
            // Open this row
            row.child(format(row.data())).show();
            tr.addClass('selected');
        }
    });
});

/**
 * Format Data function for DataTable
 * @param d
 * @returns {string}
 */
function format(d) {
    var employees = '';

    // get employees data
    d.employees.forEach(function (elem, i) {
        employees +=
            '<tr>' +
            '<td>' + elem.name + '</td>' +
            '<td>' + elem.status + '</td>' +
            '<td>' + elem.eta + '</td>' +
            '<td>' + elem.actual_time + '</td>' +
            '</tr>';
    });

    return '<table class="table table-bordered child-table">' +
        '<thead><tr>' +
        '<th>Employee</th>' +
        '<th>Status</th>' +
        '<th>ETA</th>' +
        '<th>Actual Time</th>' +
        '</tr></thead>' +
        '<tbody>' + employees + '</tbody></table>';
}