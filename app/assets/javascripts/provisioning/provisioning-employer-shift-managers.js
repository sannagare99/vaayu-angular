var employerShiftManagersTableEditor;

$(function () {
    'use strict';

    /**
     * Employers Users Table
     */
    var table = '#employer-shift-managers-table';
    var esmTable = $();

    employerShiftManagersTableEditor = new $.fn.dataTable.Editor({
        table: table,
        ajax: {
            edit: {
                type: 'PATCH',
                url: '/employer_shift_managers/_id_'
            },
            remove: {
                type: 'DELETE',
                url: '/employer_shift_managers/_id_'
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

    $('a[href="#employer-shift-managers"]').on('shown.bs.tab', function () {
        if (loadedTabs['employer-shift-managers']) return;

        // set loaded state
        loadedTabs['employer-shift-managers'] = true;

        if (!loadedDatatables[table]) {

            esmTable = $(table).DataTable({
                serverSide: true,
                ajax: "/employer_shift_managers",
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
                            return '<a href="/employer_shift_managers/'+ data.id +'/edit" class="edit" data-remote=true>' + data.name + '</a>';
                        }
                    },
                    {data: "entity_attributes.company"},
                    {
                        data: null,
                        render: function (data) {
                            return '<a href="/shift_times/'+ data.id +'/schedule_time?sm_type=employer_shift_manager" data-remote=true>Edit Shifts</a>';
                        }
                    },
                    {data: "email"},
                    {data: "phone"},
                    {data: "status"},
                    {
                        data: null,
                        render: function (data) {
                            return '<a href="#" class="editor_remove employer_shift_manager_remove text-danger">Delete</a>';
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
    $(table).on('click', 'a.editor_remove.employer_shift_manager_remove', function (e) {
        e.preventDefault();

        employerShiftManagersTableEditor
            .title('Delete Employer Shift Manager')
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
    $("#employer-shift-managers.tab-pane").on('click', 'a.reload-button', function (e) {
        esmTable.draw(false);
        e.preventDefault();
    });
});