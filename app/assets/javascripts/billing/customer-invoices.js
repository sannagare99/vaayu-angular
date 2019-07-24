$(function () {
    'use strict';
    
    $(document).on('click', '#delete_customer_invoices', function(e){
        $.ajax({
            type: "POST",
            url: '/invoices/delete_customer_invoices',
            data: {
                invoices: Object.keys(selectedInvoices)
            }                  
        }).done(function (response) {
        	selectedInvoices= {}
            customerInvoicesTable.clear().draw()
        })
    })
    
    var selectedInvoices = []
    var invoiceId = ''
    var trip_total = 0;
    var startDate = moment().startOf('month').format('DD/MM/YYYY h:mm A'),
        endDate = moment().endOf('day').format('DD/MM/YYYY h:mm A');

    var table = '#customer-invoices-table';
    var customerInvoicesTable = $();
    var detailInfoTripTable = $();
    var tripDataTable = $();
    var billDataTable = $();
    var current_user = ''
    var billing_model = ''

    var invoiceStatusMapping = {
    	'created' : 'New',
    	'dirty' : 'Dirty',
    	'paid' : 'Paid',
    	'approved' : 'Approved'
    }

    $('a[href="#customer-invoices"]').on('shown.bs.tab', function (e) {
        // if (loadedTabs['customer-invoices']) return;

        // set loaded state
        loadedTabs['customer-invoices'] = true;
        if (!loadedDatatables['#customer-invoices-table']) {
	        customerInvoicesTable = $('#customer-invoices-table').DataTable({
	            serverSide: true,
	            ajax: {
	                url: "/invoices/customer_invoices",
	                data: function (d) {
	                    d.startDate = startDate;
	                    d.endDate = endDate;
	                }
	            },
	            searching: false,
	            lengthChange: false,
	            pagingType: "simple_numbers",
	            processing: true,
	            info: false,
	            autoWidth: false,
	            ordering: false,
	            select: {
	              style: 'multi',
	              selector: 'td:first-child'
	            },
	            columns: [
	            	{
	                    data: null,
	                    render: function(data){
	                    	return ""
	                    }
	                },
	                {
	                    data: null,
	                    render: function (data) {
	                        var tripDisplayName = data.date + ' - ' + data.id;
	                        // return '<a style="cursor:pointer" id="open-invoice-modal" type="button" class="trip-info" data-invoice_id='+ data.id + '>' + tripDisplayName + '</a>'
	                        return tripDisplayName
	                    }
	                },
	                {
	                	data: null,
	                	render: function(data){
	                		return '<a style="cursor:pointer" id="open-bill-modal" type="button" class="trip-info" data-invoice_id='+ data.id + '>View Detail</a>'
	                	}
	                },
	                {
	                	data: null,
	                	render: function(data){
	                		return '<a style="cursor:pointer" id="open-trips-modal" type="button" class="trip-info" data-invoice_id='+ data.id + '>View Detail</a>'
	                	}
	                },
	                {data: "customer"},
	                {data: "site"},
	                {data: "operator"},
	                {data: "business_associate"},
	                {
	                	data: null,
	                	render: function(data){
	                		return '<span>' + parseFloat((data.amount + data.toll + data.penalty) * data.cgst * 0.01).toFixed(2) + '<span>'
	                	}
	                },
	                {
	                	data: null,
	                	render: function(data){
	                		return '<span>' + parseFloat((data.amount + data.toll + data.penalty) * data.sgst * 0.01).toFixed(2) + '<span>'
	                	}
	                },
	                {
	                    data: null,
	                    render: function(data){
	                    	var cgst = parseFloat((data.amount + data.toll + data.penalty) * data.cgst * 0.01)
	                    	var sgst = parseFloat((data.amount + data.toll + data.penalty) * data.sgst * 0.01)
	                        return '<i class="fa fa-inr"></i><span>' + parseFloat(data.amount + data.toll + data.penalty + cgst + sgst).toFixed(2) + '<span>'
	                    }
	                },
	                {
	                	data: null,
	                	render: function(data){
	                        return '<a style="cursor:pointer" id="open-status-modal" type="button" class="trip-info" data-invoice_id='+ data.id + ' data-invoice_status=' + data.status + '>' + invoiceStatusMapping[data.status] +'</a>'
	                    }
	                }	                
	            ],
	            drawCallback: function(){
	                $("#download_customer_invoices").attr('disabled', true)
	                $('#download_customer_invoices').removeAttr('href');
            		$("#delete_customer_invoices").attr('disabled', true)
	                $(table).DataTable().rows().every( function (row) {
	                    var tr = $(this.node());                
	                    tr.find('td:first').addClass('checkbox-select');
	                });
	                loadedDatatables['#customer-invoices-table'] = true
	            },
	            initComplete: function () {
	                current_user = this.api().ajax.json().user.entity_type
	                if(current_user == 'Operator'){
	                   	customerInvoicesTable.column(6).visible(false);
	                   	$('#delete_customer_invoices').css("display","none");
	                }
	                else if(current_user == 'Employer'){
	                   customerInvoicesTable.column(4).visible(false);
	                   customerInvoicesTable.column(7).visible(false);
	                }
	            }
	        });
		}
		else{
			customerInvoicesTable.ajax.reload();
			customerInvoicesTable.clear().draw()
		}

        customerInvoicesTable.on('select', function (e, dt, type, indexes) {        
            var rowData = customerInvoicesTable.row(indexes).data();
            var index = $.inArray(rowData.DT_RowId, selectedInvoices);
            if (index === -1) {
              selectedInvoices[rowData.DT_RowId] = rowData;
            }
            $('#download_customer_invoices').attr('href', '/invoices/download?selected=' + Object.keys(selectedInvoices).join());
            $("#download_customer_invoices").attr('disabled', false)
            $("#delete_customer_invoices").attr('disabled', false)
        });

        customerInvoicesTable.on('deselect', function (e, dt, type, indexes) {  
            // remove selected row from track        
            var tripId = customerInvoicesTable.row(indexes).data().DT_RowId;
            delete selectedInvoices[tripId];
            if(Object.keys(selectedInvoices).length > 0){
              	$('#download_customer_invoices').attr('href', '/invoices/download?selected=' + Object.keys(selectedInvoices).join());
              	$("#download-invoices").attr('disabled', false)
            	$("#delete_customer_invoices").attr('disabled', false)
            }
            else{
                $("#download_customer_invoices").attr('disabled', true)
                $('#download_customer_invoices').removeAttr('href');
            	$("#delete_customer_invoices").attr('disabled', true)
            }
        });        
    });    

	// select all rows using checkbox
    $('.ch-all-customer-invoices').on('click', function () {
    	console.log("customer invoices select all")
        var row = $(this).closest('tr');
        var currentRows = customerInvoicesTable.rows()
        if (row.hasClass("selected")) {
            currentRows.deselect();
            row.removeClass('selected');
            selectedInvoices = []
            $("#download_customer_invoices").attr('disabled', true)
            $('#download_customer_invoices').removeAttr('href');
        	$("#delete_customer_invoices").attr('disabled', true)
        }
        else {
            row.addClass('selected');
            currentRows.select();
            var indexes = currentRows[0]

            if(indexes.length > 1) {
                selectedInvoices = []
                indexes.forEach(function (index) {
                    var rowData = customerInvoicesTable.row(index).data();
                    var index = $.inArray(rowData.DT_RowId, selectedInvoices);
                    if (index === -1) {
                        selectedInvoices[rowData.DT_RowId] = rowData;
                    }
                })
                $('#download_customer_invoices').attr('href', '/invoices/download?selected=' + Object.keys(selectedInvoices).join());	             
                $("#download_customer_invoices").attr('disabled', false)
        		$("#delete_customer_invoices").attr('disabled', false)
            }
        }
    });

    $(document).on('click', '#open-invoice-modal', function(e){
        invoiceId = $(this).data("invoice_id");
        $('#modal-billing-detail').modal('toggle');
    })

    $(document).on('click', '#open-bill-modal', function(e){
        invoiceId = $(this).data("invoice_id");
        $('#modal-bill-data').modal('toggle');
    })

    $(document).on('click', '#open-trips-modal', function(e){
        invoiceId = $(this).data("invoice_id");
        $('#modal-trips-data').modal('toggle');
    })

    $(document).on('click', "#open-status-modal", function(e){
    	invoiceId = $(this).data("invoice_id");
    	var currentStatus = $(this).data("invoice_status");
        $('#modal-billing-status').modal('toggle');
        $("input[name=status][value='" + currentStatus + "']").prop("checked",true);
    })

    $(document).on('click', "#save_status", function(e){
        var status = $("input[name='status']:checked").val()
        $.ajax({
            type: "POST",
            url: '/invoices/' + invoiceId + '/update_status',
            data: {
                status: status
            }                  
        }).done(function (response) {
        	if(response.success){
        		customerInvoicesTable.draw()
        		$('#modal-billing-status').modal('toggle');
        	}
        })        
    })

    $('#modal-trips-data').on('show.bs.modal', function (e) {    	
    	if (!loadedDatatables["#trip-data-table"]) {
        	tripDataTable = $("#trip-data-table").DataTable({
	        	serverSide: true,
	          	ajax: {
	            	url: "/invoices/trip_data",
	            	data: function(d){
	            		d.invoice_id = invoiceId
	            	}
	          	},
	          	searching: false,
	            lengthChange: false,
	            paging: false,
	            processing: true,
	            info: false,
	            autoWidth: false,
	            deferRender : true,
	            ordering: false,
	            select: {
	              style: 'multi',
	              selector: 'td:first-child'
	            },
	            columns: [
	                {data: "date"},
	                {data: "customer"},
	                {data: "site"},
	                {data: "operator"},
	                {data: "business_associate"},
	                {data: "tripsheet"},
	                {data: "trip_type"},
	                {data: "shift_time"},
	                {data: "reporting_time"},
	                {data: "actual_time"},
	                {data: "vehicle_no"},
	                {data: "vehicle_type"},
	                {data: "seating_capacity"},
	                {data: "driver"},
	                {data: "planned_employees"},
	                {data: "actual_employees"},
	                {data: "guard"},
	                {data: "gps"},
	                {data: "planned_mileage"},
	                {data: "planned_duration"},
	                {data: "actual_mileage"},
	                {data: "actual_duration"}	                        
	            ],
	            drawCallback: function(){
	                loadedDatatables["#trip-data-table"] = true;
	                billing_model = this.api().ajax.json().billing_model
	                if(current_user == 'Operator'){
	                   tripDataTable.column(3).visible(false);
	                }
	                else if(current_user == 'Employer'){
	                   tripDataTable.column(1).visible(false);
	                   tripDataTable.column(4).visible(false);
	                }
	                if(billing_model == 'Package Rates'){
	                	tripDataTable.column(18).visible(true);
	                	tripDataTable.column(19).visible(true);
	                	tripDataTable.column(20).visible(true);
	                	tripDataTable.column(21).visible(true);
	                }
	                else{
	                	tripDataTable.column(18).visible(false);
	                	tripDataTable.column(19).visible(false);
	                	tripDataTable.column(20).visible(false);
	                	tripDataTable.column(21).visible(false);
	                }

	            }
          	});
		}
		else{
			tripDataTable.ajax.reload();
			tripDataTable.clear().draw()
		}
    })

    $('#modal-bill-data').on('show.bs.modal', function (e) {    	
    	if (!loadedDatatables["#bill-data-table"]) {
    		trip_total = 0 
    		var bill_trips_total = 0
        	billDataTable = $("#bill-data-table").DataTable({
	        	serverSide: true,
	          	ajax: {
	            	url: "/invoices/bill_data",
	            	data: function(d){
	            		d.invoice_id = invoiceId
	            	}
	          	},
	          	searching: false,
	            lengthChange: false,
	            paging: false,
	            processing: true,
	            info: false,
	            autoWidth: false,
	            deferRender : true,
	            ordering: false,
	            select: {
	              style: 'multi',
	              selector: 'td:first-child'
	            },
	            columns: [
	            	{data: "customer"},
	            	{data: "site"},
	            	{data: "operator"},
	            	{data: "business_associate"},
	            	{data: "vehicle_number"},
	            	{data: "vehicle_type"},
	            	{data: "zone"},
	                {data: "total_trips"},
	                {data: "guard_trips"},
	                {data: "rate"},
	                {data: "guard_rate"},
	                {data: "hours_on_duty"},
	                {data: "mileage_on_duty"},
	                {data: "hours_on_trips"},
	                {data: "mileage_on_trips"},
	                {
	                	data: null,
	                	render: function(data){
	                		trip_total = trip_total + parseFloat(data.toll + data.amount)
	                		bill_trips_total = bill_trips_total + data.total_trips
	                        return '<i class="fa fa-inr"></i><span>' + parseFloat(data.amount + data.toll).toFixed(2) + '<span>'
	                	}
	                }
	            ],
	            drawCallback: function(){
	            	console.log(bill_trips_total)
	            	$("#bill_total").text(trip_total)
	            	$("#bill_trips_total").text(bill_trips_total)
	            	trip_total = 0
	            	bill_trips_total = 0
	                loadedDatatables["#bill-data-table"] = true;
	                console.log(this.api().ajax.json())
	                billing_model = this.api().ajax.json().billing_model
	                if(current_user == 'Operator'){
	                   billDataTable.column(2).visible(false);
	                }
	                else if(current_user == 'Employer'){
	                   billDataTable.column(0).visible(false);
	                   billDataTable.column(3).visible(false);
	                }
	                if(billing_model == 'Package Rates'){
	                	billDataTable.column(6).visible(false);
	                	billDataTable.column(8).visible(false);
	                	billDataTable.column(9).visible(false);
	                	billDataTable.column(10).visible(false);

	                	billDataTable.column(11).visible(true);
	                	billDataTable.column(12).visible(true);
	                	billDataTable.column(13).visible(true);
	                	billDataTable.column(14).visible(true);
	                }
	                else{
	                	billDataTable.column(11).visible(false);
	                	billDataTable.column(12).visible(false);
	                	billDataTable.column(13).visible(false);
	                	billDataTable.column(14).visible(false);

	                	billDataTable.column(6).visible(true);
	                	billDataTable.column(8).visible(true);
	                	billDataTable.column(9).visible(true);
	                	billDataTable.column(10).visible(true);
	                }
	            }
          	});
		}
		else{
			billDataTable.ajax.reload();
			billDataTable.clear().draw()
		}
    })

    $('#modal-billing-detail').on('show.bs.modal', function (e) {    	
      	if (!loadedDatatables["#detail-info-trips-table"]) {
      		trip_total = 0 
        	detailInfoTripTable = $("#detail-info-trips-table").DataTable({
	        	serverSide: true,
	          	ajax: {
	            	url: "/invoices/invoice_details",
	            	data: function(d){
	            		d.invoice_id = invoiceId
	            	}
	          	},
	          	searching: false,
	            lengthChange: false,
	            paging: false,
	            processing: true,
	            info: false,
	            autoWidth: false,
	            deferRender : true,
	            ordering: false,
	            select: {
	              style: 'multi',
	              selector: 'td:first-child'
	            },
	            columns: [
	                {
	                    data: null,
	                    render: function (data) {
	                        var tripDisplayName = data.date + ' - ' + data.id;	                        
	                        return '<a style="cursor:pointer" id="open-trip-modal" type="button" class="trip-info" data-trip_id='+ data.id + '>' + tripDisplayName + '</a>'
	                        // return '<a href="/billing/detail_invoice/' + data.trip_id + '?tab_name=completed_trips" data-remote="true">'+ tripDisplayName + '</a>';
	                    }
	                },
	                {data: "customer"},
	                {data: "vehicle_type"},
	                {data: "is_guard"},
	                {data: "toll"},
	                {data: "penalty"},
	                {data: "total_employees"},
	                {data: "served_employees"},
	                {
	                    data: null,
	                    render: function(data){
	                    	trip_total = trip_total + parseFloat(data.toll + data.penalty + data.amount)
	                        return '<i class="fa fa-inr"></i><span>' + parseFloat(data.amount + data.toll + data.penalty).toFixed(2) + '<span>'
	                    }
	                }
	            ],
	            drawCallback: function(){
	                $("#trip_total").text(trip_total)
	                trip_total = 0 
	                loadedDatatables["#detail-info-trips-table"] = true;	                
	            }
          	});
		}
		else{
			detailInfoTripTable.ajax.reload();
			detailInfoTripTable.clear().draw()
		}
    });

    // Init picker
    $('#customer-invoices-picker').daterangepicker({
            timePicker: true,
            applyClass: 'btn-primary',
            timePickerIncrement: 30,
            startDate: moment().startOf('month'),
            endDate: moment().endOf('day'),
            locale: {
                format: 'DD/MM/YYYY h:mm A'
            }
        },

        function (start, end) {
            startDate = start.format('DD/MM/YYYY h:mm A');
            endDate = end.format('DD/MM/YYYY h:mm A');
            customerInvoicesTable.draw();
        });
});
