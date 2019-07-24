var lineManagersTableEditor;

$(function () {
    'use strict';

    /**
     * Employers Users Table
     */
    var table = '#devices-table';;
    var deviceTable = $();
    var focusOutTimer;

    $('a[href="#devices"]').on('shown.bs.tab', function () {
        if (loadedTabs['devices']) return;

        // set loaded state
        loadedTabs['devices'] = true;

        if (!loadedDatatables[table]) {

            deviceTable = $(table).DataTable({
                serverSide: true,
                ajax: "/devices",
                lengthChange: false,
                searching: false,
                pagingType: "simple_numbers",
                ordering: false,
                processing: true,
                info: false,

                columns: [
                    {
                        data: null,
                        render: function (data) {
                            return '<a href="/devices/'+ data.id +'/edit" class="edit" data-remote=true>' + data.device_id + '</a>';
                        }
                    },
                    {data: "make"},
                    {data: "model"},
                    {data: "os"},
                    {data: "os_version"},
                    {data: "status"}
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Form Validation
    $("#devices").on("focusout", ".live-validation input.required, select.required", function(e){
        console.log("Came here");
        var _this = this;
        focusOutTimer = setTimeout(function () {
            var fields = [];
            $.validate($(_this), _this.name, fields, "/devices/validate", $("#form-devices"))
        }, 200)
    });
    $(".nav-actions").on("click", ".edit-buttons .submit-btn.form-devices", function(e) {
        clearTimeout(focusOutTimer);
        $.call("/devices/validate", $("#form-devices"), "", "", true);
        $("select.required").focusout();
        e.preventDefault();
    })

    // Reload table
    $("#devices.tab-pane").on('click', 'a.reload-button', function (e) {
        deviceTable.draw(false);
        e.preventDefault();
    });
});
