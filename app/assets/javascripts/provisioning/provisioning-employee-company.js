var employeeCompaniesTableEditor;

$(function () {
    'use strict';

    /**
     * Employee Companies Operator Table
     */

    var table = '#employee-companies-table';
    /**
     * Init table
     */
    $('a[href="#employee-company"]').on('shown.bs.tab', function () {
        if (!loadedDatatables[table]) {

            $(table).dataTable({
                serverSide: true,
                ajax: "/employee_companies",
                order: [[0, 'desc']],
                lengthChange: false,
                searching: false,
                pagingType: "simple_numbers",
                ordering: false,
                info: false,
                processing: true,

                columns: [
                    {data: "id"},
                    {
                        data: "name",
                        render: function (data) {
                            return '<a href="" class="modal_view">' + data + '</a>'
                        }
                    },
                    {data: 'hq_address'},
                    {data: 'business_type'},
                    {data: 'pan'},
                    {data: 'service_tax_no'},
                    {
                        data: null,
                        render: function (data) {   
                            return '<a href="" class="modal_edit">Edit</a>&nbsp<a href="" class="modal_view">View</a>&nbsp<a href="" class="editor_remove text-danger">Delete</a>' //Rushikesh made changes here
                        }
                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                     var info = this.api().page.info();
                     $('#employee-companies-count').text("Total Employee Companies: " + info.recordsTotal);
                }
            });
        }
    });

    employeeCompaniesTableEditor = new $.fn.dataTable.Editor({
        table: table,
        ajax: {
            create: {
                type: 'POST',
                url: '/employee_companies'
            },
            edit: {
                type: 'PUT',
                url: '/employee_companies/_id_'
            },
            remove: {
                type: 'DELETE',
                url: '/employee_companies/_id_'
            }
        },
        fields: [{
            label: "Name",
            className: "col-md-4",
            name: "name"
        },
        {
            label: "HQ Address",
            className: "col-md-4",
            name: "hq_address"
        }, {
            label: "Business Type",
            className: "col-md-4",
            name: "business_type"
        }, {
            label: 'PAN',
            className: "col-md-offset-4 col-md-4 clear",
            name: "pan"
        }, {
            label: 'Service Tax No.',
            className: "col-md-4",
            name: "service_tax_no"
        },
        {   //Rushikesh made changes here
            label: "Zone",
            className: "col-md-4",
            name: "zone"
        }
    
    ]
    });

    // set selectboxes
    employeeCompaniesTableEditor.on('preOpen', function (e, mode, action) {
        window.setTimeout(function () {
            initModalSelectBox();
        }, 100);
    });

    // validate fields
    employeeCompaniesTableEditor.on('preSubmit', function (e, o, action) {
        if (action !== 'remove') {
            var name = employeeCompaniesTableEditor.field('name');

            if (!name.isMultiValue()) {
                if (!name.val()) {
                    name.error('A company name must be given');
                }
                if (name.val().length <= 3) {
                    name.error('The company name length must be more than 3 characters');
                }
            }

            if (this.inError()) {
                return false;
            }
        }
    });


    // Edit record
    $(table).on('click', 'a.modal_edit', function (e) {
        e.preventDefault();

        employeeCompaniesTableEditor
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
                    className: 'btn btn-sm btn-primary btn-fixed-width',
                    fn: function () {
                        this.submit()
                    }
                }])
            .edit($(this).closest('tr'));
            $('input').removeAttr('disabled'); //Rushikesh added code here
            $('.btn-primary').removeAttr('disabled'); //Rushikesh added code here
    });
    //Rushikesh made changes here, added View Record function
    $(table).on('click', 'a.modal_view', function (e) {
        e.preventDefault();

        employeeCompaniesTableEditor
            .title('View Company')
            .edit($(this).closest('tr'));
            $('input').attr('disabled','disabled'); //Rushikesh added code here
            $('.btn-primary').attr('disabled','disabled');//Rushikesh added code here
            //$('input').css({
            // 'background-color': 'red',
            //'color': 'white',
            // 'font-size': '44px'
             // }); 
        
       
    });

    // New record
    $(document).on('click', '.provisioning a.editor_create.employee-company', function (e) {
        e.preventDefault();

        employeeCompaniesTableEditor
            .title('Add New Company')
            .buttons([{
                label: "Close",
                className: 'btn btn-sm btn-default',
                fn: function () {
                    this.close()
                }
            }, {
                label: "Submit",
                className: 'btn btn-sm btn-primary btn-fixed-width',
                fn: function () {
                    this.submit()
                }
            }])
            .create();
            $('input').removeAttr('disabled'); //Rushikesh added code here
    });

    // Delete record
    $(table).on('click', 'a.editor_remove', function (e) {
        e.preventDefault();

        employeeCompaniesTableEditor
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
                    className: 'btn btn-sm btn-primary',
                    fn: function () {
                        this.submit()
                    }
                }])
            .remove($(this).closest('tr'));
    });
});