$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        downloadUrlTemplate = $("#no-show-and-cancellations .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate,
        reportsNoShowAndCancellationsTable = $(),
        table = '#reports-no-show-and-cancellations-table';
    $("#no-show-and-cancellations .report-download-button").attr("href", downloadUrl);

    // init exception summary table
    $('a[href="#no-show-and-cancellations"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsNoShowAndCancellationsTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/no_show_and_cancellations",
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
                    {data: "direction"},
                    {data: "manifested"},
                    {data: "no_shows"}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Init picker
    $('#no-show-and-cancellations-picker').daterangepicker({
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
            $("#no-show-and-cancellations .report-download-button").attr("href", downloadUrl);
            reportsNoShowAndCancellationsTable.draw();
        }
    );

    $("#no-show-and-cancellations .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});