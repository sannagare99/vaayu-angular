var trnasportDeskManagersTableEditor;

$(function () {
    'use strict';

    /**
     * Employers Users Table
     */
    var table = '#transport-desk-managers-table';
    var tdmTable = $()

    trnasportDeskManagersTableEditor = new $.fn.dataTable.Editor({
        table: table,
        ajax: {
            edit: {
                type: 'PATCH',
                url: '/transport_desk_managers/_id_'
            },
            remove: {
                type: 'DELETE',
                url: '/transport_desk_managers/_id_'
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

    $('a[href="#transport-desk-managers"]').on('shown.bs.tab', function () {
        if (loadedTabs['transport-desk-managers']) return;

        // set loaded state
        loadedTabs['transport-desk-managers'] = true;

        if (!loadedDatatables[table]) {

            tdmTable = $(table).DataTable({
                serverSide: true,
                ajax: "/transport_desk_managers",
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
                            return '<a href="/transport_desk_managers/'+ data.id +'/edit" class="edit" data-remote=true>' + data.name + '</a>';
                        }
                    },
                    {data: "entity_attributes.company"},
                    {data: "email"},
                    {data: "phone"},
                    {data: "status"},
                    {
                        data: null,
                        render: function (data) {
                            return '<a href="#" class="editor_remove transport_desk_manager_remove text-danger">Delete</a>';
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
    $(table).on('click', 'a.editor_edit.transport_desk_manager_edit', function (e) {
        e.preventDefault();

        trnasportDeskManagersTableEditor
            .title('Edit TransPort desk Manager')
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
    $(table).on('click', 'a.editor_remove.transport_desk_manager_remove', function (e) {
        e.preventDefault();

        trnasportDeskManagersTableEditor
            .title('Delete TransPort desk Manager')
            .message("Are you sure you wish to delete this TransPort desk Manager?")
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
    $("#transport-desk-managers.tab-pane").on('click', 'a.reload-button', function (e) {
        tdmTable.draw(false);
        e.preventDefault();
    });
});