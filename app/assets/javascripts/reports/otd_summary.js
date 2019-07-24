$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        downloadUrlTemplate = $("#otd-summary .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate,
        reportsOnTimeDeparturesTable = $(),
        table = '#reports-otd-summary-table';
    $("#otd-summary .report-download-button").attr("href", downloadUrl);

    // init exception summary table
    $('a[href="#otd-summary"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsOnTimeDeparturesTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/otd_summary",
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
                    {data: "shift_time"},
                    {data: "total_logouts"},
                    {data: "logouts_catered_to"},
                    {data: "logouts_canceled"},
                    {data: "logouts_delayed"},
                    {data: "avg_delay_to_logout"}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Init picker
    $('#otd-summary-picker').daterangepicker({
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
            $("#otd-summary .report-download-button").attr("href", downloadUrl);
            reportsOnTimeDeparturesTable.draw();
        }
    );

    $("#otd-summary .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});