$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        downloadUrlTemplate = $("#employee-satisfaction .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate,
        reportsEmployeeSatisfactionTable = $(),
        table = '#reports-employee-satisfaction-table';
    $("#employee-satisfaction .report-download-button").attr("href", downloadUrl);

    $('a[href="#employee-satisfaction"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsEmployeeSatisfactionTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/employee_satisfaction",
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
                    {data: "shift_type"},
                    {data: "shift_time"},
                    {data: "vehicle_no"},
                    {data: "employee_id"},
                    {data: "employee_name"},
                    {data: "rating"},
                    {data: "rating_feedback", orderable: false}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Init picker
    $('#employee-satisfaction-picker').daterangepicker({
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
            $("#employee-satisfaction .report-download-button").attr("href", downloadUrl);
            reportsEmployeeSatisfactionTable.draw();
        }
    );

    $("#employee-satisfaction .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});
