$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        downloadUrlTemplate = $("#trip-logs .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate,
        reportsTripLogsTable = $(),
        table = '#reports-trip-logs-table';
    $("#trip-logs .report-download-button").attr("href", downloadUrl);

    $('a[href="#trip-logs"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsTripLogsTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/trip_logs",
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
                // dom: "t<'row'<'col-sm-12' p>>",
                columns: [
                    {data: "date", orderable: false},
                    {data: "trip_id"},
                    {data: "driver"},
                    {data: "operator"},
                    {data: "plate_number"},
                    {data: "shift_time", orderable: false},
                    {data: "direction", orderable: false},
                    {data: "actual_time", orderable: false},
                    {data: "trip_created", orderable: false},
                    {data: "trip_assigned", orderable: false},
                    {data: "trip_accepted"},
                    {data: "trip_started"},
                    {data: "number_of_riders", orderable: false},
                    {data: "distance"},
                    {data: "duration"},
                    {data: "status", orderable: false},
                    {data: "exception_detail"},
                    {data: "vehicle_capacity"},
                    {data: "delta_time", orderable: false}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });


    // Init picker
    $('#trip-logs-picker').daterangepicker({
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
            $("#trip-logs .report-download-button").attr("href", downloadUrl);
            reportsTripLogsTable.draw();
        }
    );

    $("#trip-logs .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});
