var guardsTableEditor;

$(function () {
    'use strict';

    /**
     * Employers Users Table
     */
    var table = '#guards-table';;
    var guardTable = $();

    guardsTableEditor = new $.fn.dataTable.Editor({
        table: table,
        ajax: {
            edit: {
                type: 'PATCH',
                url: '/employees/_id_'
            },
            remove: {
                type: 'DELETE',
                url: '/employees/_id_'
            }
        },
        fields: [{
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
            className: "col-md-4 col-md-offset-4 clear",
            name: "email"
        }, {
            label: 'Phone',
            className: "col-md-4",
            name: "phone"
        }, {
            label: "Guard Attributes:",
            className: "col-md-4 clear",
            name: "customer_info",
            type: "title"
        }, {
            label: 'Company',
            className: "col-md-4 selectboxit-wrap",
            name: "entity_attributes.employee_company_id",
            type: "select"
        }, {
            label: 'Site',
            className: "col-md-4 selectboxit-wrap",
            name: "entity_attributes.site_id",
            type: "select"
        }]
    });

    $('a[href="#guards"]').on('shown.bs.tab', function () {
        if (loadedTabs['guards']) return;

        // set loaded state
        loadedTabs['guards'] = true;

        if (!loadedDatatables[table]) {

            guardTable = $(table).DataTable({
                serverSide: true,
                ajax: "/employees/guards",
                lengthChange: false,
                searching: false,
                pagingType: "simple_numbers",
                ordering: false,
                processing: true,
                info: false,

                columns: [
                    {data: "entity_attributes.id"},
                    {
                        data: null,
                        orderable: false,
                        render: function (data) {
                            return '<a href="/employees/' + data.id + '/edit?is_guard=true" data-remote="true" class="edit employer_edit">' + data.f_name + ' ' + data.m_name + ' ' + data.l_name + '</a>';
                        }
                    },
                    {data: "entity_attributes.company"},
                    {data: "phone"},
                    {data: "entity_attributes.site"},
                    {
                        data: null,
                        render: function (data) {
                            return '<a href="#" class="editor_remove guard_remove text-danger">Delete</a>';
                        }
                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Edit record
    $(table).on('click', 'a.editor_edit.guard_edit', function (e) {
        e.preventDefault();

        guardsTableEditor
            .title('Edit Guard')
            .buttons([
                {
                    label: "Close",
                    className: 'btn btn-sm btn-default',
                    fn: function () {
                        this.close()
                    }
                }, {
                    label: "Save changes",
                    className: 'btn btn-sm btn-primary',
                    fn: function () {
                        this.submit()
                    }
                }])
            .edit($(this).closest('tr'));
    });

    // Delete record
    $(table).on('click', 'a.editor_remove.guard_remove', function (e) {
        e.preventDefault();

        guardsTableEditor
            .title('Delete Guard')
            .message("Are you sure you wish to delete this Guard?")
            .buttons([
                {
                    label: "Close",
                    className: 'btn btn-sm btn-default',
                    fn: function () {
                        this.close()
                    }
                }, {
                    label: "Delete",
                    className: 'btn btn-sm btn-primary btn-fixed-width',
                    fn: function () {
                        this.submit()
                    }
                }])
            .remove($(this).closest('tr'));
    });

    $("#guards").on("click", ".geo_code", function(e) {
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

    $("#guards").on("click", ".nodal_geo_code", function(e) {
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

    // Reload table
    $("#guards.tab-pane").on('click', 'a.reload-button', function (e) {
        guardTable.draw(false);
        e.preventDefault();
    });
});