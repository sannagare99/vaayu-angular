var businessAssociatesTableEditor;
$(function () {
    'use strict';

    var logisticsCompanies = []
    var edit_ba = false;    
    var ba_id = '';
    var baTable = $()
    var current_user = ''
    var logistics_company_id = null
    var orig_service_html = ''
    var choose_operator = true

    /**
     * Init table
     */
    var table = '#business-associates-table';

    $('a[href="#business-associates"]').on('shown.bs.tab', function (e) {
        resetBillingParameters();        
        if (loadedTabs['business-associates']) return;

        // set loaded state
        loadedTabs['business-associates'] = true;

        if (!loadedDatatables[table]) {

            baTable = $(table).DataTable({
                serverSide: true,
                ajax: "/business_associates",
                lengthChange: false,
                searching: false,
                pagingType: "simple_numbers",
                ordering: false,
                info: false,
                processing: true,

                columns: [
                    {data: "id"},
                    {
                        data: null,
                        render: function (data) {
                            return '<a style="cursor:pointer" id="editBa" class="editor_edit" data-remote="true" data-ba_id="' + data.id + '">' + data.legal_name + '</a>'                            
                        }
                    },
                    {data: "hq_address"},
                    {data: "business_type"},
                    {data: "name"},
                    {data: "phone"},
                    {data: "email"},
                    {
                        data: null,
                        render: function () {
                            return '<a href="#" class="editor_remove text-danger">Delete</a>';
                        }
                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                     var info = this.api().page.info();
                     $('#business-associates-count').text("Total Business Accociates: " + info.recordsTotal);                    
                     current_user = this.api().ajax.json().user.entity_type
                     if(current_user == 'Operator'){
                        choose_operator = false
                     }
                }
            });
        }

        businessAssociatesTableEditor = new $.fn.dataTable.Editor({
            table: table,
            ajax: {
                remove: {
                    type: 'DELETE',
                    url: '/business_associates/_id_'
                }
            }
        });

        // Delete record
        $(table).on('click', 'a.editor_remove', function (e) {
            e.preventDefault()
            businessAssociatesTableEditor
                .title('Delete Business Associate')
                .message("Are you sure you wish to delete this business associate?")
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

        $(document).on('click', '#editBa', function(e){
            e.preventDefault()
            ba_id = e.target.dataset.ba_id
            // $("#services").html('')
            $.ajax({
                type: "GET",                
                url: '/business_associates/' + ba_id + '/edit'
            }).done(function (response) {
                $.ajax({
                    type: "POST",
                    url: '/business_associates/details',
                    data: {
                        'id': ba_id
                    }
                }).done(function(response){   
                    logistics_company_id = response.logistics_company_id                    
                    orig_service_html = $("#services").html()
                    edit_ba = true                    
                    var html = generate_edit(response, 'business_associates', response.logistics_company_id, orig_service_html)
                    $("#serviceContainer").html(html)
                    if(logistics_company_id == null){
                        $("#cgst_1").parent().css("display", "none")
                        $("#sgst_1").parent().css("display", "none")
                        $("#addServicesDiv").css("display", "none")
                        $("#services").css("display", "none")
                    }
                    else{
                        $("#cgst_1").parent().css("display", "block")
                        $("#sgst_1").parent().css("display", "block")
                        $("#addServicesDiv").css("display", "block")
                        $("#services").css("display", "block")   
                    }
                })            
            });
        });

        $(document).on('click', '.editor_create', function(e){
            if(e.target.baseURI.indexOf("business-associates") != -1){
                $.ajax({
                    type: "GET",
                    url: '/employee_companies/get_all'
                }).done(function (response) {
                    logisticsCompanies = response.logistics_companies
                    current_user = response.current_user.entity_type
                    logistics_company_id = response.logistics_company_id
                    orig_service_html = $("#services").html()
                    setTimeout(function(){                     
                        for(var i = 0; i < logisticsCompanies.length; i++){
                            $('#ba_operator').append($('<option>', {
                                value: logisticsCompanies[i].id,
                                text: logisticsCompanies[i].name
                            }));
                        }   
                        if(current_user == 'Operator') {
                            $("#cgst_1").parent().css("display", "block")
                            $("#sgst_1").parent().css("display", "block")
                            $("#addServicesDiv").css("display", "block")
                            $("#services").css("display", "block")
                        }
                    }, 500);            
                });
            }        
        })

        $(document).on('change', '#ba_operator', function(e){
            choose_operator = false
            logistics_company_id = $("#ba_operator").val()
            if(edit_ba){
                getService('business_associates', ba_id, logistics_company_id, orig_service_html)                
            }
            // else{
                $("#cgst_1").parent().css("display", "block")
                $("#sgst_1").parent().css("display", "block")
                $("#addServicesDiv").css("display", "block")
                $("#services").css("display", "block")
            // }
        })

        function validateBa(ba, validationError){
            if($("#business_associate_admin_f_name").val() == '' || $("#business_associate_admin_f_name").val() == undefined || $("#business_associate_admin_f_name").val() == null){
                document.getElementById("business_associate_admin_f_name").classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("business_associate_admin_f_name").classList.remove("border-danger")
                validationError = validationError || false
            }
            if($("#business_associate_admin_m_name").val() == '' || $("#business_associate_admin_m_name").val() == undefined || $("#business_associate_admin_m_name").val() == null){
                document.getElementById("business_associate_admin_m_name").classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("business_associate_admin_m_name").classList.remove("border-danger")
                validationError = validationError || false
            }
            if($("#business_associate_admin_l_name").val() == '' || $("#business_associate_admin_l_name").val() == undefined || $("#business_associate_admin_l_name").val() == null){
                document.getElementById("business_associate_admin_l_name").classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("business_associate_admin_l_name").classList.remove("border-danger")
                validationError = validationError || false
            }
            if($("#business_associate_admin_email").val() == '' || $("#business_associate_admin_email").val() == undefined || $("#business_associate_admin_email").val() == null){
                document.getElementById("business_associate_admin_email").classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("business_associate_admin_email").classList.remove("border-danger")
                validationError = validationError || false
            }
            if($("#business_associate_admin_phone").val() == '' || $("#business_associate_admin_phone").val() == undefined || $("#business_associate_admin_phone").val() == null){
                document.getElementById("business_associate_admin_phone").classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("business_associate_admin_phone").classList.remove("border-danger")
                validationError = validationError || false
            }
            if($("#business_associate_name").val() == '' || $("#business_associate_name").val() == undefined || $("#business_associate_name").val() == null){
                document.getElementById("business_associate_name").classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("business_associate_name").classList.remove("border-danger")
                validationError = validationError || false
            }
            if($("#business_associate_legal_name").val() == '' || $("#business_associate_legal_name").val() == undefined || $("#business_associate_legal_name").val() == null){
                document.getElementById("business_associate_legal_name").classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("business_associate_legal_name").classList.remove("border-danger")
                validationError = validationError || false
            }
            if($("#business_associate_pan").val() == '' || $("#business_associate_pan").val() == undefined || $("#business_associate_pan").val() == null || $("#business_associate_pan").val().length != 10){
                document.getElementById("business_associate_pan").classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("business_associate_pan").classList.remove("border-danger")
                validationError = validationError || false
            }
            if($("#business_associate_tan").val() == '' || $("#business_associate_tan").val() == undefined || $("#business_associate_tan").val() == null || $("#business_associate_pan").val().length != 10){
                document.getElementById("business_associate_tan").classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("business_associate_tan").classList.remove("border-danger")
                validationError = validationError || false
            }
            if($("#business_associate_business_type").val() == '' || $("#business_associate_business_type").val() == undefined || $("#business_associate_business_type").val() == null){
                document.getElementById("business_associate_business_type").classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("business_associate_business_type").classList.remove("border-danger")
                validationError = validationError || false
            }
            if($("#business_associate_service_tax_no").val() == '' || $("#business_associate_service_tax_no").val() == undefined || $("#business_associate_service_tax_no").val() == null){
                document.getElementById("business_associate_service_tax_no").classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("business_associate_service_tax_no").classList.remove("border-danger")
                validationError = validationError || false
            }
            if($("#business_associate_hq_address").val() == '' || $("#business_associate_hq_address").val() == undefined || $("#business_associate_hq_address").val() == null){
                document.getElementById("business_associate_hq_address").classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("business_associate_hq_address").classList.remove("border-danger")
                validationError = validationError || false
            }

            return validationError
        }


        $(document).on('click', ".submit-btn", function(e){
            e.preventDefault()
            if(e.target.baseURI.indexOf("business-associates") != -1){
                var ba = {
                    'admin_f_name': $("#business_associate_admin_f_name").val(),
                    'admin_m_name': $("#business_associate_admin_m_name").val(),
                    'admin_l_name': $("#business_associate_admin_l_name").val(),
                    'admin_email': $("#business_associate_admin_email").val(),
                    'admin_phone': $("#business_associate_admin_phone").val(),
                    'name': $("#business_associate_name").val(),
                    'legal_name': $("#business_associate_legal_name").val(),
                    'pan': $("#business_associate_pan").val(),
                    'tan': $("#business_associate_tan").val(),
                    'business_type': $("#business_associate_business_type").val(),
                    'service_tax_no': $("#business_associate_service_tax_no").val(),
                    'hq_address': $("#business_associate_hq_address").val()
                }
                if(current_user == 'Operator'){
                    ba['logistics_company_id'] = $("#ba_operator_id").val()                
                }
                else{
                    ba['logistics_company_id'] = $("#ba_operator").val()
                }
                var validationError = false
                var services = getServiceData()
                validationError = validateBa(ba, validationError)
                if(!choose_operator){
                    validationError = validateServices(services, validationError)
                }
                
                if(!validationError){
                    $('.submit-btn').prop('disabled', true)            
                    if(edit_ba){
                        $.ajax({
                            type: "PUT",
                            data: {
                                'ba': ba,
                                'services': services
                            },
                            url: '/business_associates/' + ba_id + '/update_ba'
                        }).done(function (e) {
                            $('.submit-btn').prop('disabled', false)
                            ba_id = ''                        
                            edit_ba = false;
                            resetBillingParameters();
                            restoreDefaultTabState()
                            baTable.draw()
                            $(".add-new-item").show()
                        });
                    }
                    else{
                        $.ajax({
                            type: "POST",
                            data: {
                                'ba': ba,
                                'services': services
                            },
                            url: '/business_associates'
                        }).done(function (e) {
                            $('.submit-btn').prop('disabled', false)
                            ba_id = ''
                            edit_ba = false
                            resetBillingParameters();
                            restoreDefaultTabState();
                            baTable.draw()
                            $(".add-new-item").show()
                        });
                    }
                }    
            }
        })

        $(document).on('click', '.cancel', function(e){
            if(e.target.baseURI.indexOf("business-associates") != -1){
                edit_ba = false
                ba_id = ''
                logistics_company_id = ''
            }
        })
    });
});


