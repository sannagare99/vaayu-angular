$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        downloadUrlTemplate = $("#ota .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate,
        reportsOtaTable = $(),
        table = '#reports-ota-table';
    $("#ota .report-download-button").attr("href", downloadUrl);

    $('a[href="#ota"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsOtaTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/ota",
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
                    {data: "driver"},
                    {data: "vehicle"},
                    {data: "ba"},
                    {data: "shift_time", orderable: false},
                    {data: "scheduled_end_time", orderable: false},
                    {data: "actual_end_time"},
                    {data: "delta_in_arrival_at_site", orderable: false},
                    {data: "planned_first_pickup_time"},
                    {data: "actual_arrival_time_for_first_pickup", orderable: false},
                    {data: "actual_first_pickup_time", orderable: false}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Init picker
    $('#ota-picker').daterangepicker({
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
            $("#ota .report-download-button").attr("href", downloadUrl);
            reportsOtaTable.draw();
        }
    );

    $("#ota .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});
