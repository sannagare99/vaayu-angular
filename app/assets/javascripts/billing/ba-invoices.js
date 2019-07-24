$(function () {
    'use strict';
    
    $(document).on('click', '#ba_delete_invoices', function(e){
        $.ajax({
            type: "POST",
            url: '/invoices/delete_ba_invoices',
            data: {
                invoices: Object.keys(baSelectedInvoices)
            }                  
        }).done(function (response) {
        	baSelectedInvoices= {}
            baInvoicesTable.clear().draw()
        })
    })
    
    var baSelectedInvoices = []
    var invoiceId = ''
    var trip_total = 0;
    var startDate = moment().startOf('month').format('DD/MM/YYYY h:mm A'),
        endDate = moment().endOf('day').format('DD/MM/YYYY h:mm A');

    var table = '#ba-invoices-table';
    var baInvoicesTable = $();
    var baDetailInfoTripTable = $();
    var baTripDataTable = $();
    var baBillDataTable = $();
    var current_user = ''
    var billing_model = ''

    var invoiceStatusMapping = {
    	'created' : 'New',
    	'dirty' : 'Dirty',
    	'paid' : 'Paid',
    	'approved' : 'Approved'
    }

    $('a[href="#ba-invoices"]').on('shown.bs.tab', function (e) {
        // if (loadedTabs['customer-invoices']) return;

        // set loaded state
        loadedTabs['ba-invoices'] = true;
        if (!loadedDatatables['#ba-invoices-table']) {
	        baInvoicesTable = $('#ba-invoices-table').DataTable({
	            serverSide: true,
	            ajax: {
	                url: "/invoices/ba_invoices",
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
	                		return '<a style="cursor:pointer" id="ba-open-bill-modal" type="button" class="trip-info" data-invoice_id='+ data.id + '>View Detail</a>'
	                	}
	                },
	                {
	                	data: null,
	                	render: function(data){
	                		return '<a style="cursor:pointer" id="ba-open-trips-modal" type="button" class="trip-info" data-invoice_id='+ data.id + '>View Detail</a>'
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
	                        return '<a style="cursor:pointer" id="ba-open-status-modal" type="button" class="trip-info" data-invoice_id='+ data.id + ' data-invoice_status=' + data.status + '>' + invoiceStatusMapping[data.status] +'</a>'
	                    }
	                }	                
	            ],
	            drawCallback: function(){
	                $("#ba_download_invoices").attr('disabled', true)
	                $("#ba_download_invoices").removeAttr('href')
            		$("#ba_delete_invoices").attr('disabled', true)
	                $(table).DataTable().rows().every( function (row) {
	                    var tr = $(this.node());                
	                    tr.find('td:first').addClass('checkbox-select');
	                });
	                loadedDatatables['#ba-invoices-table'] = true
	            },
	            initComplete: function () {
	                current_user = this.api().ajax.json().user.entity_type
	                if(current_user == 'Operator'){
	                   baInvoicesTable.column(6).visible(false);
	                }
	                else if(current_user == 'Employer'){
	                   baInvoicesTable.column(4).visible(false);
	                   baInvoicesTable.column(7).visible(false);
	                }
	            }
	        });
		}
		else{
			baInvoicesTable.ajax.reload();
			baInvoicesTable.clear().draw()
		}

        baInvoicesTable.on('select', function (e, dt, type, indexes) {        
            var rowData = baInvoicesTable.row(indexes).data();
            var index = $.inArray(rowData.DT_RowId, baSelectedInvoices);
            if (index === -1) {
              baSelectedInvoices[rowData.DT_RowId] = rowData;
            }
            $('#ba_download_invoices').attr('href', '/invoices/ba_download?selected=' + Object.keys(baSelectedInvoices).join());
            $("#ba_download_invoices").attr('disabled', false)
            $("#ba_delete_invoices").attr('disabled', false)
        });

        baInvoicesTable.on('deselect', function (e, dt, type, indexes) {  
            // remove selected row from track        
            var tripId = baInvoicesTable.row(indexes).data().DT_RowId;
            delete baSelectedInvoices[tripId];
            if(Object.keys(baSelectedInvoices).length > 0){
              	$('#ba_download_invoices').attr('href', '/invoices/ba_download?selected=' + Object.keys(baSelectedInvoices).join());
              	$("#ba_download_invoices").attr('disabled', false)
            	$("#ba_delete_invoices").attr('disabled', false)
            }
            else{
                $("#ba_download_invoices").attr('disabled', true)
                $("#ba_download_invoices").removeAttr('href')
            	$("#ba_delete_invoices").attr('disabled', true)
            }
        });
    });    
	
	// select all rows using checkbox
    $('.ch-all-ba-invoices').on('click', function () {
        var row = $(this).closest('tr');
        var currentRows = baInvoicesTable.rows()
        if (row.hasClass("selected")) {
            currentRows.deselect();
            row.removeClass('selected');
            baSelectedInvoices = []
            $("#ba_download_invoices").attr('disabled', true)
            $("#ba_download_invoices").removeAttr('href')
        	$("#ba_delete_invoices").attr('disabled', true)
        }
        else {
            row.addClass('selected');
            currentRows.select();
            var indexes = currentRows[0]

            if(indexes.length > 1) {
                baSelectedInvoices = []
                indexes.forEach(function (index) {
                    var rowData = baInvoicesTable.row(index).data();
                    var index = $.inArray(rowData.DT_RowId, baSelectedInvoices);
                    if (index === -1) {
                        baSelectedInvoices[rowData.DT_RowId] = rowData;
                    }
                })
                $('#ba_download_invoices').attr('href', '/invoices/ba_download?selected=' + Object.keys(baSelectedInvoices).join());	             
                $("#ba_download_invoices").attr('disabled', false)
        		$("#ba_delete_invoices").attr('disabled', false)
            }
        }
    });

    $(document).on('click', '#ba-open-invoice-modal', function(e){
        invoiceId = $(this).data("invoice_id");
        $('#ba-modal-billing-detail').modal('toggle');
    })

    $(document).on('click', '#ba-open-bill-modal', function(e){
        invoiceId = $(this).data("invoice_id");
        $('#ba-modal-bill-data').modal('toggle');
    })

    $(document).on('click', '#ba-open-trips-modal', function(e){
        invoiceId = $(this).data("invoice_id");
        $('#ba-modal-trips-data').modal('toggle');
    })

    $(document).on('click', "#ba-open-status-modal", function(e){
    	invoiceId = $(this).data("invoice_id");
    	var currentStatus = $(this).data("invoice_status");
        $('#ba-modal-billing-status').modal('toggle');
        $("input[name=status][value='" + currentStatus + "']").prop("checked",true);
    })

    $(document).on('click', "#ba_save_status", function(e){
        var status = $("input[name='status']:checked").val()
        $.ajax({
            type: "POST",
            url: '/invoices/' + invoiceId + '/ba_update_status',
            data: {
                status: status
            }                  
        }).done(function (response) {
        	if(response.success){
        		baInvoicesTable.draw()
        		$('#ba-modal-billing-status').modal('toggle');
        	}
        })        
    })

    $('#ba-modal-trips-data').on('show.bs.modal', function (e) {    	
    	if (!loadedDatatables["#ba-trip-data-table"]) {
        	baTripDataTable = $("#ba-trip-data-table").DataTable({
	        	serverSide: true,
	          	ajax: {
	            	url: "/invoices/ba_trip_data",
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
	              selector: 'td:last-child'
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
	                loadedDatatables["#ba-trip-data-table"] = true;
	                billing_model = this.api().ajax.json().billing_model
	                if(current_user == 'Operator'){
	                   baTripDataTable.column(3).visible(false);
	                }
	                else if(current_user == 'Employer'){
	                   baTripDataTable.column(1).visible(false);
	                   baTripDataTable.column(4).visible(false);
	                }
	                if(billing_model == 'Package Rates'){
	                	baTripDataTable.column(18).visible(true);
	                	baTripDataTable.column(19).visible(true);
	                	baTripDataTable.column(20).visible(true);
	                	baTripDataTable.column(21).visible(true);
	                }
	                else{
	                	baTripDataTable.column(18).visible(false);
	                	baTripDataTable.column(19).visible(false);
	                	baTripDataTable.column(20).visible(false);
	                	baTripDataTable.column(21).visible(false);
	                }

	            }
          	});
		}
		else{
			baTripDataTable.ajax.reload();
			baTripDataTable.clear().draw()
		}
    })

    $('#ba-modal-bill-data').on('show.bs.modal', function (e) {    	
    	if (!loadedDatatables["#ba-bill-data-table"]) {
    		trip_total = 0 
    		var bill_trips_total = 0
        	baBillDataTable = $("#ba-bill-data-table").DataTable({
	        	serverSide: true,
	          	ajax: {
	            	url: "/invoices/ba_bill_data",
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
	              selector: 'td:last-child'
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
	            	$("#ba_bill_total").text(trip_total)
	            	$("#ba_bill_trips_total").text(bill_trips_total)
	            	trip_total = 0
	            	bill_trips_total = 0
	                loadedDatatables["#ba-bill-data-table"] = true;
	                console.log(this.api().ajax.json())
	                billing_model = this.api().ajax.json().billing_model
	                if(current_user == 'Operator'){
	                   baBillDataTable.column(2).visible(false);
	                }
	                else if(current_user == 'Employer'){
	                   baBillDataTable.column(0).visible(false);
	                   baBillDataTable.column(3).visible(false);
	                }
	                if(billing_model == 'Package Rates'){
	                	baBillDataTable.column(6).visible(false);
	                	baBillDataTable.column(8).visible(false);
	                	baBillDataTable.column(9).visible(false);
	                	baBillDataTable.column(10).visible(false);

	                	baBillDataTable.column(11).visible(true);
	                	baBillDataTable.column(12).visible(true);
	                	baBillDataTable.column(13).visible(true);
	                	baBillDataTable.column(14).visible(true);
	                }
	                else{
	                	baBillDataTable.column(11).visible(false);
	                	baBillDataTable.column(12).visible(false);
	                	baBillDataTable.column(13).visible(false);
	                	baBillDataTable.column(14).visible(false);

	                	baBillDataTable.column(6).visible(true);
	                	baBillDataTable.column(8).visible(true);
	                	baBillDataTable.column(9).visible(true);
	                	baBillDataTable.column(10).visible(true);
	                }
	            }
          	});
		}
		else{
			baBillDataTable.ajax.reload();
			baBillDataTable.clear().draw()
		}
    })

    $('#ba-modal-billing-detail').on('show.bs.modal', function (e) {    	
      	if (!loadedDatatables["#ba-detail-info-trips-table"]) {
      		trip_total = 0 
        	baDetailInfoTripTable = $("#ba-detail-info-trips-table").DataTable({
	        	serverSide: true,
	          	ajax: {
	            	url: "/invoices/ba_invoice_details",
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
	              selector: 'td:last-child'
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
	                {data: "ba"},
	                {data: "vehicle_type"},
	                {data: "is_guard"},
	                {data: "ba_toll"},
	                {data: "ba_penalty"},
	                {data: "total_employees"},
	                {data: "served_employees"},
	                {
	                    data: null,
	                    render: function(data){
	                    	trip_total = trip_total + parseFloat(data.ba_toll + data.ba_penalty + data.ba_amount)
	                        return '<i class="fa fa-inr"></i><span>' + parseFloat(data.ba_amount + data.ba_toll + data.ba_penalty).toFixed(2) + '<span>'
	                    }
	                }
	            ],
	            drawCallback: function(){
	                $("#ba_trip_total").text(trip_total)
	                trip_total = 0 
	                loadedDatatables["#ba-detail-info-trips-table"] = true;	                
	            }
          	});
		}
		else{
			baDetailInfoTripTable.ajax.reload();
			baDetailInfoTripTable.clear().draw()
		}
    });

    // Init picker
    $('#ba-invoices-picker').daterangepicker({
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
            baInvoicesTable.draw();
        });
});
