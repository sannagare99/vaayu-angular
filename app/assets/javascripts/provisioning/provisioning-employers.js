var employersTableEditor;

$(function () {
    'use strict';

    /**
     * Employers Users Table
     */
    var table = '#employers-table';
    var employersTable = $();

    employersTableEditor = new $.fn.dataTable.Editor({
        table: table,
        ajax: {
            edit: {
                type: 'PATCH',
                url: '/employers/_id_'
            },
            remove: {
                type: 'DELETE',
                url: '/employers/_id_'
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
            className: "col-md-4 col-md-offset-4",
            name: "email"
        }, {
            label: 'Company',
            className: "col-md-4",
            name: "entity_attributes.company",
            type: "select"
        }, {
            label: "Customer Attributes:",
            className: "col-md-4 clear",
            name: "customer_info",
            type: "title"
        }, {
            label: 'Phone',
            className: "col-md-4",
            name: "phone"
        }, {
            label: 'Legal name',
            className: "col-md-4",
            name: "entity_attributes.legal_name"
        }, {
            label: 'Pan',
            className: "col-md-4 col-md-offset-4",
            name: "entity_attributes.pan"
        }, {
            label: 'Tan',
            className: "col-md-4",
            name: "entity_attributes.tan"
        }, {
            label: 'Business type',
            className: "col-md-4 col-md-offset-4",
            name: "entity_attributes.business_type"
        }, {
            label: 'HQ Address',
            className: "col-md-4",
            name: "entity_attributes.hq_address"
        }, {
            label: 'Service tax number',
            className: "col-md-4 col-md-offset-4",
            name: "entity_attributes.service_tax_no"
        }]
    });

    $('a[href="#employers"]').on('shown.bs.tab', function () {
        if (loadedTabs['employers']) return;

        // set loaded state
        loadedTabs['employers'] = true;

        if (!loadedDatatables[table]) {

            employersTable = $(table).DataTable({
                serverSide: true,
                ajax: "/employers",
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
                            return '<a href="/employers/'+ data.id +'/edit" class="edit employer_edit" data-remote=true>' + data.name + '</a>';
                        }
                    },
                    {data: "entity_attributes.company"},
                    {data: "email"},
                    {data: "phone"},
                    {
                        data: null,
                        render: function (data) {
                            return '<a href="#" class="editor_remove employer_remove text-danger">Delete</a>';
                        }
                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                     var info = this.api().page.info();
                     $('#employers-count').text("Total Employers: " + info.recordsTotal);                                        
                }
            });
        }
    });

    // Edit record
    $(table).on('click', 'a.modal_edit.employer_edit', function (e) {
        e.preventDefault();

        employersTableEditor
            .title('Edit customer')
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
    $(table).on('click', 'a.editor_remove.employer_remove', function (e) {
        e.preventDefault();

        employersTableEditor
            .title('Delete customer')
            .message("Are you sure you wish to delete this customer?")
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
    $("#employers.tab-pane").on('click', 'a.reload-button', function (e) {
        employersTable.draw(false);
        e.preventDefault();
    });

});