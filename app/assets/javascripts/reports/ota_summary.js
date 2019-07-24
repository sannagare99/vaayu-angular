$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        downloadUrlTemplate = $("#on-time-arrivals .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate,
        reportsOnTimeArrivalsTable = $(),
        table = '#reports-on-time-arrivals-table';
    $("#on-time-arrivals .report-download-button").attr("href", downloadUrl);

    // init exception summary table
    $('a[href="#on-time-arrivals"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsOnTimeArrivalsTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/ota_summary",
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
                    {data: "total_logins"},
                    {data: "logins_catered_to"},
                    {data: "logins_canceled"},
                    {data: "logins_delayed"},
                    {data: "avg_delay_to_login"}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Init picker
    $('#on-time-arrivals-picker').daterangepicker({
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
            $("#on-time-arrivals .report-download-button").attr("href", downloadUrl);
            reportsOnTimeArrivalsTable.draw();
        }
    );

    $("#on-time-arrivals .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});