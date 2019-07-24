$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        downloadUrlTemplate = $("#shift-fleet-utilisation-summary .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate,
        reportsShiftFleetUtilisationSummaryTable = $(),
        table = '#reports-shift-fleet-utilisation-summary-table';
    $("#shift-fleet-utilisation-summary .report-download-button").attr("href", downloadUrl);

    $('a[href="#shift-fleet-utilisation-summary"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsShiftFleetUtilisationSummaryTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/shift_fleet_utilisation_summary",
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
                    {data: "shift_time"},
                    {data: "direction"},
                    {data: "vehicle_deployed", orderable: false},
                    {data: "total_capacity", orderable: false},
                    {data: "planned_capacity", orderable: false},
                    {data: "actual_capacity", orderable: false},
                    {data: "load_factor", orderable: false}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Init picker
    $('#shift-fleet-utilisation-summary-picker').daterangepicker({
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
            $("#shift-fleet-utilisation-summary .report-download-button").attr("href", downloadUrl);
            reportsShiftFleetUtilisationSummaryTable.draw();
        }
    );

    $("#shift-fleet-utilisation-summary .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});
