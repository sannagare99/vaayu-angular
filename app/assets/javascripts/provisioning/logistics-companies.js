var logisticCompaniesTableEditor;

$(function () {
    'use strict';

    /**
     * Logistic Companies Table Editor
     *
     * @type {*|jQuery|HTMLElement}
     */

    var table = '#logistic-companies-table';
    var logisticCompaniesTable = $();

    logisticCompaniesTableEditor = new $.fn.dataTable.Editor({
        table: "#logistic-companies-table",
        ajax: {
            create: {
                type: 'POST',
                url: '/logistics_companies'
            },
            edit: {
                type: 'PUT',
                url: '/logistics_companies/_id_'
            },
            remove: {
                type: 'DELETE',
                url: '/logistics_companies/_id_'
            }
        },
        fields: [{
            label: 'Name',
            className: "col-md-4",
            name: "name"
        }, {
            label: 'HQ Address',
            className: "col-md-4",
            name: "hq_address"
        }, {
            label: 'Business Type',
            className: "col-md-4",
            name: "business_type"
        }, {
            label: 'PAN',
            className: "col-md-4",
            name: "pan"
        }, {
            label: 'Service Tax No.',
            className: "col-md-4",
            name: "service_tax_no"
        },{
            label: 'Phone',
            className: "col-md-4",
            name: "phone"
        }]
    });

    // New record
    $(document).on('click', '.provisioning a.editor_create.logistic-companies', function (e) {
        e.preventDefault();

        logisticCompaniesTableEditor
            .title('Create New Company')
            .buttons([{
                label: "Close",
                className: 'btn btn-sm btn-default',
                fn: function () {
                    this.close()
                }
            }, {
                label: "Submit",
                className: 'btn btn-sm btn-primary',
                fn: function () {
                    this.submit()
                }
            }])
            .create();
    });

    // Edit record
    $(table).on('click', 'a.modal_edit', function (e) {
        e.preventDefault();

        logisticCompaniesTableEditor
            .title('Edit company')
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
    $(table).on('click', 'a.editor_remove', function (e) {
        e.preventDefault();

        logisticCompaniesTableEditor
            .title('Delete company')
            .message("Are you sure you wish to delete this company?")
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


    $('a[href="#logistic-companies"]').on('shown.bs.tab', function () {
        if (loadedTabs['logistic-companies']) return;

        // set loaded state
        loadedTabs['logistic-companies'] = true;

        if (!loadedDatatables[table]) {

            logisticCompaniesTable = $(table).dataTable({
                serverSide: true,
                ajax: "/logistics_companies",
                lengthChange: false,
                order: [[0, 'desc']],
                searching: false,
                pagingType: "simple_numbers",
                processing: true,
                info: false,

                columns: [
                    {data: "id"},
                    {
                        data: "name",
                        render: function (data) {
                            return '<a href="" class="modal_edit">' + data + '</a>'
                        }

                    },
                    {data: 'hq_address'},
                    {data: 'business_type'},
                    {data: 'pan'},
                    {data: 'service_tax_no'},
                    {data: 'phone'},
                    {
                        data: null,
                        render: function (data) {
                            return '<a href="" class="text-danger editor_remove">Delete</a>'
                        }
                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });
        }
    });

    /**
     * Set add user id into form action
     */
    $('#modal-logistic-companies-users').on('show.bs.modal', function (e) {
        var button = $(e.relatedTarget);
        var id = button.data('id');
        $(this).find('form').attr('action', '/operators/?logistics_company_id=' + id).attr('method', 'POST');
    });

});