$(function () {
    'use strict';

    var reportsDriverActivityTable = $(),
        table = '#reports-driver-activity-table';

    $('a[href="#driver-activity"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            reportsDriverActivityTable = $(table).DataTable({
                serverSide: true,
                ajax: "/reports/driver_activity",
                searching: false,
                lengthChange: false,
                pagingType: "simple_numbers",
                processing: true,
                info: false,
                autoWidth: false,
                order: [[1, 'desc']],
                columns: [
                { data: "first_name", orderable: false  },
                { data: "last_name", orderable: false  },
                { data: "phone", orderable: false },
                { data: "licence_number", orderable: false },
                { data: "last_used_vehicle", orderable: false },
                { data: "site", orderable: false },
                { data: "vendor_id", orderable: false },
                { data: "sign_in_count", orderable: false  },
                { data: "current_sign_at", orderable: false },
                { data: "last_sign_in_at", orderable: false },
                { data: "last_active_time", orderable: false },
                { data: "last_active", orderable: false }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    $("#driver-activity .send-report-button").on("click", function(e){
        send_report('', '', $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});
