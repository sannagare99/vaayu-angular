$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        downloadUrlTemplate = $("#employee-logs .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate,
        reportsEmployeeLogsTable = $(),
        table = "#reports-employee-logs-table";
    $("#employee-logs .report-download-button").attr("href", downloadUrl);

    // var reportsEmployeeLogsTable = $('#reports-employee-logs-table').DataTable({
    $('a[href="#employee-logs"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsEmployeeLogsTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/employee_logs",
                    data: function (d) {
                        d.startDate = startDate;
                        d.endDate = endDate;
                    }
                },
                searching: false,
                lengthChange: false,
                pagingType: "simple_numbers",
                processing: true,
                info: false,
                autoWidth: false,
                columns: [
                    {data: "date"},
                    {data: "trip_id"},
                    {data: "status", orderable: false},
                    {data: "shift_time"},
                    {data: "direction"},
                    {data: "employee_id"},
                    {data: "rider_name", orderable: false},
                    {data: "driver_name", orderable: false},
                    {data: "operator", orderable: false},
                    {data: "vehicle_number", orderable: false},
                    {data: "planned_eta", orderable: false},
                    {data: "notified_eta", orderable: false},
                    {data: "i_am_here", orderable: false},
                    {data: "pick_up_time", orderable: false},
                    {data: "wait_time", orderable: false},
                    {data: "drop_off_time", orderable: false},
                    {data: "employee_status", orderable: false},
                    {data: "exception_detail", orderable: false}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Init picker
    $('#employee-logs-picker').daterangepicker({
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
            downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate;
            $("#employee-logs .report-download-button").attr("href", downloadUrl);
            reportsEmployeeLogsTable.draw();
        }
    );

    $("#employee-logs .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});