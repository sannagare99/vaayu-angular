$(function () {
    'use strict';

    var startDate = moment().format('DD/MM/YYYY h:mm A'),
        endDate = moment().add(1, 'day').format('DD/MM/YYYY h:mm A'),
        downloadUrlTemplate = $("#vendor-trip-distribution .report-download-button").attr("href"),
        downloadUrl = downloadUrlTemplate + "&startDate=" + startDate + "&endDate=" + endDate,
        reportsVendorTripDistributionTable = $(),
        table = '#reports-vendor-trip-distribution-table';
    $("#vendor-trip-distribution .report-download-button").attr("href", downloadUrl);

    $('a[href="#vendor-trip-distribution"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsVendorTripDistributionTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/reports/vendor_trip_distribution",
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
                    {data: "shift"},
                    {data: "direction"},
                    {data: "vendor"},
                    {data: "no_of_trips", orderable: false},
                    {data: "planned_mileage", orderable: false},
                    {data: "actual_mileage", orderable: false}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Init picker
    $('#vendor-trip-distribution-picker').daterangepicker({
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
            $("#vendor-trip-distribution .report-download-button").attr("href", downloadUrl);
            reportsVendorTripDistributionTable.draw();
        }
    );

    $("#vendor-trip-distribution .send-report-button").on("click", function(e){
        send_report(startDate, endDate, $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});
