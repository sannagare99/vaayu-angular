var operatorShiftManagersTableEditor;

$(function () {
    'use strict';

    /**
     * Employers Users Table
     */
    var table = '#operator-shift-managers-table';
    var osmTable = $();

    operatorShiftManagersTableEditor = new $.fn.dataTable.Editor({
        table: table,
        ajax: {
            edit: {
                type: 'PATCH',
                url: '/operator_shift_managers/_id_'
            },
            remove: {
                type: 'DELETE',
                url: '/operator_shift_managers/_id_'
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
            label: "Transport Desk Attributes:",
            className: "col-md-4 clear",
            name: "customer_info",
            type: "title"
        }, {
            label: 'Phone',
            className: "col-md-4",
            name: "phone"
        }]
    });

    $('a[href="#operator-shift-managers"]').on('shown.bs.tab', function () {
        if (loadedTabs['operator-shift-managers']) return;

        // set loaded state
        loadedTabs['operator-shift-managers'] = true;

        if (!loadedDatatables[table]) {

            osmTable = $(table).DataTable({
                serverSide: true,
                ajax: "/operator_shift_managers",
                order: [[0, 'desc']],
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
                        render: function (data) {
                            return '<a href="/operator_shift_managers/'+ data.id +'/edit" class="edit" data-remote=true>' + data.name + '</a>';
                        }
                    },
                    {data: "entity_attributes.logistics_company"},
                    {
                        data: null,
                        render: function (data) {
                            return '<a href="/shift_times/'+ data.id +'/schedule_time?sm_type=operator_shift_manager" data-remote=true>Edit Shifts</a>';
                        }
                    },
                    {data: "email"},
                    {data: "phone"},
                    {
                        data: null,
                        render: function (data) {
                            return '<a href="#" class="editor_remove operator_shift_manager_remove text-danger">Delete</a>';
                        }
                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Delete record
    $(table).on('click', 'a.editor_remove.operator_shift_manager_remove', function (e) {
        e.preventDefault();

        operatorShiftManagersTableEditor
            .title('Delete Operator Shift Manager')
            .message("Are you sure you wish to delete this shift manager?")
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

    // Reload table
    $("#operator-shift-managers.tab-pane").on('click', 'a.reload-button', function (e) {
        osmTable.draw(false);
        e.preventDefault();
    });

});