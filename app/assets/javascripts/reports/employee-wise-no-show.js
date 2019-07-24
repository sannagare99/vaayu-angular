$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        downloadUrlTemplate = $("#employee-wise-no-show .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate,
        reportsEmployeeWiseNoShowTable = $(),
        table = '#reports-employee-wise-no-show-table';
    $("#employee-wise-no-show .report-download-button").attr("href", downloadUrl);

    $('a[href="#employee-wise-no-show"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsEmployeeWiseNoShowTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/employee_wise_no_show",
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
                    {data: "employee_id"},
                    {data: "employee_name"},
                    {data: "total_rides", orderable: false},
                    {data: "no_shows", orderable: false}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Init picker
    $('#employee-wise-no-show-picker').daterangepicker({
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
            $("#employee-wise-no-show .report-download-button").attr("href", downloadUrl);
            reportsEmployeeWiseNoShowTable.draw();
        }
    );

    $("#employee-wise-no-show .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});
