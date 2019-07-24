 $(function () {
    'use strict';

    var table = '#logistic-companies-users-table';
    var logisticCompaniesUsersTable = $();
    var logisticCompaniesUsersTableEditor;

    logisticCompaniesUsersTableEditor = new $.fn.dataTable.Editor({
        table: "#logistic-companies-users-table",
        ajax: {
            edit: {
                type: 'PATCH',
                url: '/operators/_id_'
            },
            remove: {
                type: 'DELETE',
                url: '/operators/_id_'
            }
        },
        fields: []
    });

    // Delete record
    $(table).on('click', 'a.editor_remove', function (e) {
        e.preventDefault();

        logisticCompaniesUsersTableEditor
            .title('Delete user')
            .message("Are you sure you wish to delete this user?")
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

    $('a[href="#logistic-companies-users"]').on('shown.bs.tab', function () {
        if (loadedTabs['logistic-companies-users']) return;

        // set loaded state
        loadedTabs['logistic-companies-users'] = true;

        if (!loadedDatatables[table]) {

            logisticCompaniesUsersTable = $(table).DataTable({
                serverSide: true,
                ajax: "/operators",
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
                            return '<a href="/operators/'+ data.DT_RowId +'/edit" class="edit" data-remote=true>' + data.name + '</a>';
                        }
                    },
                    {data: "entity_attributes.company"},
                    {data: "email"},
                    {data: "phone"},
                    {data: "status"},
                    {
                        data: null,
                        render: function (data) {
                            return '<a href="#" class="editor_remove text-danger">Delete</a>';
                        }
                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    // Reload table
    $("#logistic-companies-users.tab-pane").on('click', 'a.reload-button', function (e) {
        logisticCompaniesUsersTable.draw(false);
        e.preventDefault();
    });

});