var employeesTableEditor;

$(function () {
    'use strict';

    /**
     * Employees Users Table
     */
    var table = '#employees-table';
    var emploeesTable = $();
    var focusOutTimer;
    var checked = false;

    employeesTableEditor = new $.fn.dataTable.Editor({
        table: table,
        ajax: {
            edit: {
                type: 'PUT',
                url: '/employees/_id_'
            },
            remove: {
                type: 'DELETE',
                url: '/employees/_id_'
            }
        },
        fields: [
            {
                label: 'First name',
                className: "col-md-4",
                name: "f_name"
            }, {
                label: 'Middle name',
                className: "col-md-4",
                name: "m_name"
            }, {
                label: 'Last name',
                className: "col-md-4",
                name: "l_name"
            }, {
                label: 'Email',
                className: "col-md-offset-4 col-md-4",
                name: "email"
            }, {
                label: "Employee Attributes:",
                className: "col-md-4 clear",
                name: "employee_info",
                type: "title"
            }, {
                label: 'Phone',
                className: "col-md-4",
                name: "phone"
            }, {
                label: 'Employee ID',
                className: "col-md-4",
                name: "entity_attributes.employee_id"
            }, {
                label: "Avatar:",
                name: "avatar",
                type: "upload",
                className: "col-md-4",
                display: function (file_id) {
                    return '<img src="' + file_id + '"/>';
                },
                clearText: "Clear",
                noImageText: 'No image'
            },
            {
                label: 'Gender',
                className: "col-md-4 selectboxit-wrap",
                name: "entity_attributes.gender",
                type: "select",
                options: [
                    {label: "Male", value: "male"},
                    {label: "Female", value: "female"}
                ]
            }, {
                label: 'Site',
                className: "col-md-4 selectboxit-wrap",
                name: "entity_attributes.site_id",
                type: "select"
            }, {
                label: 'Billing Zone',
                className: "col-md-4 selectboxit-wrap",
                name: "entity_attributes.billing_zone",
            }, {
                label: 'Zone',
                type: "select",
                className: "col-md-4 col-md-offset-4 selectboxit-wrap",
                name: "entity_attributes.zone_id"
            }, {
                label: 'Home Address',
                className: "col-md-4 col-md-offset-4",
                name: "entity_attributes.home_address"
            }, {
                label: 'Nodal Name',
                className: "col-md-4 col-md-offset-4",
                name: "entity_attributes.nodal_name"
            }, {
                label: 'Nodal Address',
                className: "col-md-4 col-md-offset-4",
                name: "entity_attributes.nodal_address"
            }, {
                label: 'Landmark',
                className: "col-md-4",
                name: "entity_attributes.landmark"
            }, {
                label: 'Bus Travel',
                className: "col-md-8",
                name: "entity_attributes.bus_travel",
                type: "select"
            }, {
                label: 'Bus Trip Route',
                className: "col-md-4 selectboxit-wrap",
                name: "entity_attributes.bus_trip_route_id",
                type: "select"
            }, {
                label: 'Date of Birth',
                className: "col-md-4 col-md-offset-4",
                type: 'datetime',
                format: 'MM-DD-YYYY',
                name: "entity_attributes.date_of_birth"
            }]

    });

    // Edit record
    $(table).on('click', 'a.editor_edit', function (e) {
        e.preventDefault();

        employeesTableEditor
            .title('Edit employee')
            .buttons([
                {
                    label: "Close",
                    className: 'btn btn-sm btn-default',
                    fn: function () {
                        this.close()
                    }
                }, {
                    label: "Save changes",
                    className: 'btn btn-sm btn-primary btn-fixed-width',
                    fn: function () {
                        this.submit()
                    }
                }])
            .edit($(this).closest('tr'))
    });

    // set selectboxes
    employeesTableEditor.on('preOpen', function (e, mode, action) {
        window.setTimeout(function () {
            initModalSelectBox();
        }, 100);
    });

    // Delete record
    $(table).on('click', 'a.editor_remove', function (e) {
        e.preventDefault();

        employeesTableEditor
            .title('Delete employee')
            .message("Are you sure you wish to delete this employee?")
            .buttons([
                {
                    label: "Close",
                    className: 'btn btn-sm btn-default',
                    fn: function () {
                        this.close()
                    }
                }, {
                    label: "Delete",
                    className: 'btn btn-sm btn-primary',
                    fn: function () {
                        this.submit()
                    }
                }])
            .remove($(this).closest('tr'));
    });

    // Re invite action
    $(table).on('click', 'a.invite-count', function (e) {
        $.getJSON( $(this).attr("data-url"))
          .done(function() {
            emploeesTable.draw(false);
          });
        e.preventDefault();
    });

    $('a[href="#employees"]').on('shown.bs.tab', function (e) {
        // Show Ingest Button
        $('.provisioning .action-buttons .ingest').removeClass('hide', 200);

        if (loadedTabs['employees']) return;

        // set loaded state
        loadedTabs['employees'] = true;

        if (!loadedDatatables[table]) {

            emploeesTable = $(table).DataTable({
                serverSide: true,
                ajax: "/employees",
                ajax: {
                    url: "/employees",
                    data: function ( d ) {
                        d.search_input = $("#employees-table-search-input").val();
                        d.search_by = $("#employees-table-field-name").val();
                    }
                },
                lengthChange: false,
                searching: false,
                order: [[0, 'desc']],
                pagingType: "simple_numbers",
                processing: true,
                info: false,
                language: {
                    emptyTable: "No result"
                },

                columns: [
                    {data: "entity_attributes.employee_id"},
                    {
                        data: null,
                        orderable: false,
                        render: function (data) {
                            return '<a href="/employees/' + data.id + '/edit" data-remote="true" class="edit employer_edit">' + data.name + '</a>';
                        }
                    },
                    {
                        data: null,
                        orderable: false,
                        render: function (data) {
                            return '<a href="/employees/' + data.id + '/schedule_trip" data-remote="true" class="setup_schedule">Setup Schedule</a>';
                        }
                    },
                    {
                        data: "phone",
                        orderable: false
                    },
                    {
                        data: "entity_attributes.gender",
                        orderable: false
                    },
                    {
                        data: "entity_attributes.home_address",
                        orderable: false
                    },
                    {
                        data: "status",
                        orderable: false
                    },
                    {
                        data: null,
                        orderable: false,
                        render: function (data) {
                            var txt = data.status === "Invited" ? '<a href="#" data-url="/employees/'+ data.id +'/invite" class="invite-count"><span>Re-Invite</span></a> <a href="#" class="editor_remove text-danger">Delete</a>' : '<a href="#" class="editor_remove text-danger">Delete</a>'
                            return txt;
                        }
                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                    var info = this.api().page.info();
                    if(info.recordsTotal == 0) {
                        $("#badge-employee-count").addClass('hidden');
                    } else {
                        $("#badge-employee-count").text(info.recordsTotal);
                        $("#badge-employee-count").removeClass('hidden');
                    }
                }
            });

        }

        // redraw table on edit action
        $(document).on('hidden.bs.modal', '#m-employees-edit',function (e) {
            emploeesTable.draw(false);
        })

        // Reload table
        $("#employees.tab-pane").on('click', 'a.reload-button', function (e) {
            emploeesTable.draw(false);
            e.preventDefault();
        });
    });

    $('a[href="#employees"]').on('hide.bs.tab', function(e) {
        // Hide Ingest Button
        $('.provisioning .action-buttons .ingest').addClass('hide', 200);
    });

    $('#employees-table_search').on('click', function(e) {
        emploeesTable.draw();
        e.preventDefault();
    });

    $("#employees-table-search-input").keypress(function(e) {
      if(e.which == 13) {
        $('#employees-table_search').click();
      }
    });

    // Form Validation
    $("#employees").on("focusout", ".live-validation input.required, select.required", function(e){
        var _this = this;
        focusOutTimer = setTimeout(function () {
            var fields = ['user[email]', 'user[phone]', 'user[entity_attributes][home_address]', 'user[entity_attributes][nodal_address]'];
            $.validate($(_this), _this.name, fields, "/employees/validate", $("#form-employees"))
        }, 200)
    });

    $(".nav-actions").on("click", ".edit-buttons .submit-btn.form-employees", function(e) {        
        console.log($(".bus_travel").attr("value"))
        if($(".bus_travel").attr("checked") == "checked" || checked){
            var selectedStop = $("#user_entity_attributes_bus_trip_route_id option:selected").val();
            if(selectedStop == '' || selectedStop == undefined || selectedStop == null){
                $(".user_entity_bus_trip_route label:first").addClass("text-danger")
                $("#user_entity_attributes_bus_trip_route_id").css("border-color", "#DA4F49")
                e.preventDefault()
                return
            }
            else{
                $(".user_entity_bus_trip_route label:first").removeClass("text-danger")
                $("#user_entity_attributes_bus_trip_route_id").css("border-color", "#E0E4E8")
            }

        }
        clearTimeout(focusOutTimer);
        $.call("/employees/validate", $("#form-employees"), "", "", true);
        $("select.required").focusout();
        e.preventDefault();
    })

    // Match Employees
    var typingTimer, matchTemplate, listItem;
    var doneTypingInterval = 600;

    $("#employees").on("keyup", ".search-match input", function(e){
        if (![9, 17, 18, 91].includes(e.keyCode)) {
            var _this = this;
            var searchBy;
            clearTimeout(typingTimer);
            if ($(_this).val()) {
                typingTimer = setTimeout(function(){
                    if ($(_this).val().length >= 3) {
                        $(_this).closest("div").find(".match-result").remove();
                        $.get("/employees", {search_input: $(_this).val(), search_by: $(_this).data("match-user"), format: "json", highlight: false, paginate: false}).done(function(data){
                            if ($(_this).is(":focus") && data.iTotalRecords > 0) {
                                matchTemplate = $(".match-result").clone();
                                $.each(data.aaData, function(i, emp) {
                                    listItem = '<li><a href="/employees/' + emp.id + '/edit" data-remote="true" class="edit employer_edit"><div class="clearfix"><div class="col-md-8"><p>' + emp.name + '</p><p>'+ emp.email +'</p></div><div class="col-md-4"><p class="phone-no">'+ emp.phone +'</p></div></div></a></li>';
                                    matchTemplate.append(listItem);
                                });
                                $(_this).closest("div").append(matchTemplate.show());
                            }
                        });
                    }
                }, doneTypingInterval);
            }
        }
    });

    $("#employees").on("focusin", ".live-validation input, select", function(){
        $(".form-group .match-result").remove();
    });

    $("#employees").on("click", ".geo_code", function(e) {
        if($("#user_entity_attributes_home_address").val() !== "") {
            $.showLoader();
            $.get($(this).attr("href"), { home_address: $("#user_entity_attributes_home_address").val() }).done(function(data){
                if(!$.isEmptyObject(data)) {
                    $("#user_entity_attributes_home_address_latitude").val(data["lat"]);
                    $("#user_entity_attributes_home_address_longitude").val(data["lng"]);
                }
                $.hideLoader();
            });
        }
        e.preventDefault();
    });

    $("#employees").on("click", ".nodal_geo_code", function(e) {
        if($("#user_entity_attributes_nodal_address").val() !== "") {
            $.showLoader();
            $.get($(this).attr("href"), { nodal_address: $("#user_entity_attributes_nodal_address").val() }).done(function(data){
                if(!$.isEmptyObject(data)) {
                    $("#user_entity_attributes_nodal_address_latitude").val(data["lat"]);
                    $("#user_entity_attributes_nodal_address_longitude").val(data["lng"]);
                }
                $.hideLoader();
            });
        }
        e.preventDefault();
    });

    $("#employees").on("click", ".bus_travel", function(e) {
        checked = !checked;        
    })

    $("#employees").on("change", "#user_entity_attributes_bus_trip_route_id", function(e) {
        $(".user_entity_bus_trip_route label:first").removeClass("text-danger")
        $("#user_entity_attributes_bus_trip_route_id").css("border-color", "#E0E4E8")
    });


  $('#modal-ingest-job-stats').on('hidden.bs.modal', function() {
    if (emploeesTable) {
      emploeesTable.draw();
    }
  });
});

