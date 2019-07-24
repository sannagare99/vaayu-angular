$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        downloadUrlTemplate = $("#vehicle-deployment .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate,
        reportsVehicleDeploymentTable = $(),
        table = '#reports-vehicle-deployment-table';
    $("#vehicle-deployment .report-download-button").attr("href", downloadUrl);

    $('a[href="#vehicle-deployment"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsVehicleDeploymentTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/vehicle_deployment",
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
                    {data: "ba_name"},
                    {data: "shift_time"},
                    {data: "trip_type"},
                    {data: "vehicle_deployed"}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Init picker
    $('#vehicle-deployment-picker').daterangepicker({
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
            $("#vehicle-deployment .report-download-button").attr("href", downloadUrl);
            reportsVehicleDeploymentTable.draw();
        }
    );

    $("#vehicle-deployment .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});
