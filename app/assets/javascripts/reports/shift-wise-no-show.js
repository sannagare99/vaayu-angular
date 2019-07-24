$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        downloadUrlTemplate = $("#shift-wise-no-show .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate,
        reportsShiftWiseNoShowTable = $(),
        table = '#reports-shift-wise-no-show-table';
    $("#shift-wise-no-show .report-download-button").attr("href", downloadUrl);

    $('a[href="#shift-wise-no-show"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsShiftWiseNoShowTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/shift_wise_no_show",
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
                    {data: "total_employees", orderable: false},
                    {data: "no_shows", orderable: false}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Init picker
    $('#shift-wise-no-show-picker').daterangepicker({
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
            $("#shift-wise-no-show .report-download-button").attr("href", downloadUrl);
            reportsShiftWiseNoShowTable.draw();
        }
    );

    $("#shift-wise-no-show .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});
