$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        downloadUrlTemplate = $("#otd .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate,
        reportsOtdTable = $(),
        table = '#reports-otd-table';
    $("#otd .report-download-button").attr("href", downloadUrl);

    $('a[href="#otd"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsOtdTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/otd",
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
                    {data: "driver_name"},
                    {data: "vehicle"},
                    {data: "vendor_name"},
                    {data: "shift_time", orderable: false},
                    {data: "driver_arrival_at_site", orderable: false},
                    {data: "scheduled_depature_time", orderable: false},
                    {data: "actual_depature_time", orderable: false}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Init picker
    $('#otd-picker').daterangepicker({
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
            $("#otd .report-download-button").attr("href", downloadUrl);
            reportsOtdTable.draw();
        }
    );

    $("#otd .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});
