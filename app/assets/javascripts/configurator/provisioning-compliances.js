var compliancesTableEditor;

$(function () {
    'use strict';
    /**
     * Compliances Users Table
     */
    var table = '#compliances-table';
    var compliancesTable = $();
    var focusOutTimer;

    compliancesTableEditor = new $.fn.dataTable.Editor({
        table: table,
        ajax: {
            remove: {
                type: 'DELETE',
                url: '/compliances/_id_'
            }
        }
    });

    // Delete record
    $(table).on('click', 'a.editor_remove.compliance_remove', function (e) {
        e.preventDefault()
        
        compliancesTableEditor
            .title('Delete Compliance')
            .message("Are you sure you wish to delete this Compliance?")
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

    $('a[href="#compliances"]').on('shown.bs.tab', function (e) {
        if (loadedTabs['compliances']) return;

        // set loaded state
        loadedTabs['compliances'] = true;

        if (!loadedDatatables[table]) {

            compliancesTable = $(table).DataTable({
                serverSide: true,
                ajax: "/compliances",
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
                    {data: "id"},
                    {
                        data: null,
                        orderable: false,
                        render: function (data) {
                            return '<a href="/compliances/' + data.id + '/edit" data-remote="true" class="edit employer_edit">' + data.key + '</a>';
                        }
                    },
                    {data: "modal_type"},
                    {data: "compliance_type"},
                    {
                        data: null,
                        orderable: false,
                        render: function (data) {
                            return '<a href="#" class="editor_remove compliance_remove text-danger">Delete</a>';
                        }
                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });
});

