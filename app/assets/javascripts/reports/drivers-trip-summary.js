$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        downloadUrlTemplate = $("#drivers-trip-summary .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate,
        reportsDriversTripSummaryTable = $(),
        table = '#reports-drivers-trip-summary-table';
    $("#drivers-trip-summary .report-download-button").attr("href", downloadUrl);

    $('a[href="#drivers-trip-summary"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsDriversTripSummaryTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/drivers_trip_summary",
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
                    {data: "driver_name"},
                    {data: "vehicle"},
                    {data: "total_trips", orderable: false},
                    {data: "mileage", orderable: false},
                    {data: "mileage_per_trip", orderable: false}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Init picker
    $('#drivers-trip-summary-picker').daterangepicker({
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
            $("#drivers-trip-summary .report-download-button").attr("href", downloadUrl);
            reportsDriversTripSummaryTable.draw();
        }
    );

    $("#drivers-trip-summary .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});
