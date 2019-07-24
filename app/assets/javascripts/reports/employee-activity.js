$(function () {
    'use strict';

    var reportsVehicleDeploymentTable = $(),
        table = '#reports-employee-activity-table';

    $('a[href="#employee-activity"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {
            var reportsVehicleDeploymentTable = $(table).DataTable({
                serverSide: true,
                ajax: "/reports/employee_activity",
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
                { data: "employee_id" },
                { data: "phone", orderable: false },
                { data: "email", orderable: false },
                { data: "site", orderable: false },
                { data: "sign_in_count", orderable: false  },
                { data: "current_sign_at", orderable: false },
                { data: "last_sign_in_at", orderable: false },
                { data: "last_active_time", orderable: false },
                { data: "last_active", orderable: false },
                { data: "status", orderable: false }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    $("#employee-activity .send-report-button").on("click", function(e){
        send_report('', '', $(this).closest(".reportDownloadModal"));
        e.preventDefault();
    });
});
