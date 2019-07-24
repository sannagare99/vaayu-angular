$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        downloadUrlTemplate = $("#operations-summary .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate,
        reportsOperationsSummaryTable = $(),
        table = '#reports-operations-summary-table';
    $("#operations-summary .report-download-button").attr("href", downloadUrl);

    // init exception summary table
    $('a[href="#operations-summary"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsOperationsSummaryTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/operations_summary",
                    data: function (d) {
                        d.startDate = startDate;
                        d.endDate = endDate;
                    }
                },
                searching: false,
                lengthChange: false,
                pagingType: "simple_numbers",
                paging: false,
                info: false,
                autoWidth: false,
                ordering: false,
                columns: [
                    {data: "date"},
                    {data: "total_trips", orderable: false},
                    {data: "trips_catered_to", orderable: false},
                    {data: "trips_canceled", orderable: false},
                    {data: "drivers", orderable: false},
                    {data: "total_distance", orderable: false},
                    {data: "distance_per_trip", orderable: false},
                    {data: "duration_per_trip", orderable: false}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Init picker
    $('#operations-summary-picker').daterangepicker({
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
            $("#operations-summary .report-download-button").attr("href", downloadUrl);
            reportsOperationsSummaryTable.draw();
        }
    );

    $("#operations-summary .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});