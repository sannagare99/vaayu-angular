$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        downloadUrlTemplate = $("#trip-wise-driver-exception .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate,
        reportsTripWiseDriverExceptionTable = $(),
        table = '#reports-trip-wise-driver-exception-table';
    $("#trip-wise-driver-exception .report-download-button").attr("href", downloadUrl);

    $('a[href="#trip-wise-driver-exception"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsTripWiseDriverExceptionTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/trip_wise_driver_exception",
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
                    {data: "shift_time"},
                    {data: "direction"},
                    {data: "driver_name"},
                    {data: "plate_number"},
                    {data: "out_of_geofence_driver_arrived", orderable: false},
                    {data: "out_of_geofence_pick_up", orderable: false},
                    {data: "out_of_geofence_drop_off", orderable: false},
                    {data: "panic_alert", orderable: false},
                    {data: "car_broke_down", orderable: false}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Init picker
    $('#trip-wise-driver-exception-picker').daterangepicker({
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
            $("#trip-wise-driver-exception .report-download-button").attr("href", downloadUrl);
            reportsTripWiseDriverExceptionTable.draw();
        }
    );

    $("#trip-wise-driver-exception .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});
