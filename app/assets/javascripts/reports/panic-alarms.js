$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        reportsPanicAlarmsTable = $(),
        table = '#reports-panic-alarms-table',
        downloadUrlTemplate = $("#panic-alarms .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate;
    $("#panic-alarms .report-download-button").attr("href", downloadUrl);

    // init exception summary table
    $('a[href="#panic-alarms"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsPanicAlarmsTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/panic_alarms",
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
                    {data: "manifest_id"},
                    {data: "driver"},
                    {data: "vehicle"},
                    {data: "employee_id"},
                    {data: "alarm_time"},
                    {data: "location"},
                    {data: "resolution_time"},
                    {data: "resolved_by"}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Init picker
    $('#panic-alarms-picker').daterangepicker({
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
        reportsPanicAlarmsTable.draw();
    });

    $("#panic-alarms .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });

});