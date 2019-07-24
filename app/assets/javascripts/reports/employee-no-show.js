$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        downloadUrlTemplate = $("#employee-no-show .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate,
        reportsEmployeeNoShowTable = $(),
        table = '#reports-employee-no-show-table';
    $("#employee-no-show .report-download-button").attr("href", downloadUrl);

    $('a[href="#employee-no-show"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsEmployeeNoShowTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/employee_no_show",
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
                order: [[1, 'desc']],
                columns: [
                    {data: "date"},
                    {data: "trip_id"},
                    {data: "status"},
                    {data: "direction"},
                    {data: "shift_time"},
                    {data: "driver_name"},
                    {data: "vehicle"},
                    {data: "employee_id"},
                    {data: "employee_name"},
                    {data: "gender"},
                    {data: "employee_pick_up_location", orderable: false},
                    {data: "no_show_triggered_location", orderable: false},
                    {data: "no_show_trigger_time", orderable: false}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Init picker
    $('#employee-no-show-picker').daterangepicker({
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
            $("#employee-no-show .report-download-button").attr("href", downloadUrl);
            reportsEmployeeNoShowTable.draw();
        }
    );

    $("#employee-no-show .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});
