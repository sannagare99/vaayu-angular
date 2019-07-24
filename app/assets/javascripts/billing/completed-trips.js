$(function () {
    'use strict';
    $(document).on('click', '#generate-invoices', function(e){
        var selectedEntities = []
        if(billable_entity == 'trips'){
            selectedEntities = selectedTrips
        }
        else{
            selectedEntities = selectedVehicleTrips   
        }
        
        var html = ''
        html = html + 
        '<div>' + 
            '<p> Generating Invoice for <span style="font-weight:600">' + selectedEntities.length + '</span> trips... </p>' + 
        '</div>'
        $("#generate_invoices_body").html(html)        

        $.ajax({
            type: "POST",
            url: '/invoices/generate_invoice_for_trips',
            data: {
                trips: selectedEntities,
                select_all: select_all,
                startDate: startDate,
                endDate: endDate,
                invoice_type: invoice_type,
                billable_entity: billable_entity,
                vehicles: JSON.stringify(vehicleMapping),
                trips_vehicles: JSON.stringify(tripsVehicleMapping)
            }
        }).done(function (response) {
            selectedTrips = []
            selectedVehicleTrips = []
            vehicleMapping = {}
            tripsVehicleMapping = {}
            refreshDatatables()
            $("#select-all-trips").show()
            $("#generate-invoices").hide()
            $("#cancel-select-all").hide()
            var bad_results = []
            if(invoice_type == 'customer'){
                bad_results = response.bad_trips_customer
            }
            else{
                bad_results = response.bad_trips_ba   
            }
            html = ''
            html = html + 
            '<div>' + 
                '<p><span style="font-weight:600">' + (response.total_records) + '</span> trips processed </p>' + 
                '<p><span style="font-weight:600">' + (response.total_records - bad_results.length) + '</span> trips invoiced </p>' +                  
                '<p><span style="font-weight:600">' + bad_results.length + '</span> bad trips </p>' + 
                '<p><span style="font-weight:600">' + response.total_invoices + ' ' + invoice_type + '</span> invoice generated </p>'
            if(response.bad_trip_reason.length > 0){
                html = html + '<p><span style="font-weight:600">Reason: </span>' + response.bad_trip_reason + '</p>'
            }

            html = html + '</div>'
            $("#generate_invoices_body").html(html)
            $("#generate_success").modal('toggle')
            $("#close_invoice_summary").prop('disabled', false);            
        })
    })
    
    var select_all = false
    var selectedTrips = []
    var selectedVehicleTrips = []
    var vehicleMapping = {}
    var tripsVehicleMapping = {}
    var startDate = moment().startOf('month').format('DD/MM/YYYY h:mm A'),
        endDate = moment().endOf('day').format('DD/MM/YYYY h:mm A');

    var table = '#billing-completed-trips-table';
    var billingCompletedTripsTable = $();
    var vehiclesTable = '#billing-completed-vehicles-table';
    var billingCompletedVehiclesTable = $();
    var billable_entity = 'trips'
    var invoice_type = $("#invoice_type").val() == undefined ? "customer" : $("#invoice_type").val()
    var current_user = ''

    $('a[href="#completed-trips"]').on('shown.bs.tab', function (e) {        
        if (loadedTabs['completed-trips']) return;

        // set loaded state
        loadedTabs['completed-trips'] = true;

        billingCompletedTripsTable = $('#billing-completed-trips-table').DataTable({
            serverSide: true,
            ajax: {
                url: "/invoices/completed_trips",
                data: function (d) {
                    d.startDate = startDate;
                    d.endDate = endDate;
                    d.invoice_type = invoice_type;
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
                        return ''
                    }
                },
                {
                    data: null,
                    render: function (data) {
                        var tripDisplayName = data.date + ' - ' + data.id;
                        return '<a style="cursor:pointer" id="open-trip-modal" type="button" class="trip-info" data-trip_id='+ data.id + '>' + tripDisplayName + '</a>'
                        // return '<a href="/billing/detail_invoice/' + data.trip_id + '?tab_name=completed_trips" data-remote="true">'+ tripDisplayName + '</a>';
                    }
                },
                {data: "customer"},
                {data: "site"},
                {data: "operator"},
                {data: "business_associate"},
                {data: "vehicle_type"},
                {data: "is_guard"},
                {data: "total_employees"},
                {data: "served_employees"}
            ],
            drawCallback: function(){
                if($(table).DataTable().rows()[0].length == 0){
                    $("#select-all-trips").css('display', 'none')
                    $("#generate-invoices").css('display', 'none')
                    $("#cancel-select-all").css('display', 'none')
                }
                else{
                    $("#select-all-trips").css('display', 'block')
                    $("#generate-invoices").css('display', 'none')
                    $("#cancel-select-all").css('display', 'none')
                    $(table).DataTable().rows().every( function (row) {
                        var tr = $(this.node());
                        tr.find('td:first').addClass('checkbox-select');
                        if(select_all){
                            tr.addClass('selected');
                        }       
                    });                    
                }
                current_user = this.api().ajax.json().user.entity_type
                if(current_user == 'Operator'){
                    invoice_type = 'ba'
                    billingCompletedTripsTable.column(4).visible(false);
                }
                else if(current_user == 'Employer'){
                   billingCompletedTripsTable.column(2).visible(false);
                   billingCompletedTripsTable.column(5).visible(false);
                }
            }
        });

        billingCompletedTripsTable.on('select', function (e, dt, type, indexes) {
            var rowData = billingCompletedTripsTable.row(indexes).data();
            var index = selectedTrips.indexOf(rowData.DT_RowId);
            if (index === -1) {
              selectedTrips.push(rowData.DT_RowId)
            }
            $("#select-all-trips").css('display', 'none')
            $("#generate-invoices").css('display', 'block')
            $("#cancel-select-all").css('display', 'block')
        });

        billingCompletedTripsTable.on('deselect', function (e, dt, type, indexes) {  
            // remove selected row from track        
            select_all = false            
            if(selectedTrips.length > 0){
                var tripId = billingCompletedTripsTable.row(indexes).data().DT_RowId;
                var index = selectedTrips.indexOf(tripId)
                selectedTrips.splice(index, 1);
            }
            else{
                $("#generate-invoices").css('display', 'none')
                $("#cancel-select-all").css('display', 'none')
                $("#select-all-trips").css('display', 'block')
                return
            }
            if(selectedTrips.length == 0){
              $("#generate-invoices").css('display', 'none')
              $("#cancel-select-all").css('display', 'none')
              $("#select-all-trips").css('display', 'block')
            }
            else{
                $("#select-all-trips").css('display', 'none')
                $("#generate-invoices").css('display', 'block')
                $("#cancel-select-all").css('display', 'block')
            }
        });

        // Init picker
        $('#completed-trips-picker').daterangepicker({
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
            if(billable_entity == 'trips'){
                billingCompletedTripsTable.draw();
            }
            else{
                if(billingCompletedVehiclesTable.data() == undefined){
                    loadBillingCompletedVehiclesTable()
                }
                else{
                    billingCompletedVehiclesTable.draw();
                }
            }
        });
    });

    // select all rows using checkbox
    $('.ch-all-trips').on('click', function () {
        var row = $(this).closest('tr');
        var currentRows = billingCompletedTripsTable.rows()
        if (row.hasClass("selected")) {
            currentRows.deselect();
            row.removeClass('selected');
            selectedTrips = []
            $("#generate-invoices").attr('display', 'block')
        } 
        else {
            row.addClass('selected');
            currentRows.select();
            var indexes = currentRows[0]

            if(indexes.length > 1) {
                selectedTrips = []
                indexes.forEach(function (index) {
                    var rowData = billingCompletedTripsTable.row(index).data();
                    var index = selectedTrips.indexOf(rowData.DT_RowId);
                    if (index === -1) {
                        selectedTrips.push(rowData.DT_RowId);
                    }
                })
            }
        }
    });


    $(document).on('click', '#select-all-trips', function(e){
        select_all = true
        $("#select-all-trips").css('display', 'none')
        $("#generate-invoices").css('display', 'block')
        $("#cancel-select-all").css('display', 'block')

        if(billable_entity == 'trips'){
            var currentRows = billingCompletedTripsTable.rows()
            currentRows.select();
        }
        else{
            var currentRows = billingCompletedVehiclesTable.rows()
            currentRows.select();
        }     
    })

    $(document).on('click', '#cancel-select-all', function(e){
        select_all = false
        selectedTrips = []
        $("#select-all-trips").show()
        $("#generate-invoices").hide()
        $("#cancel-select-all").hide()
        var currentRows = billingCompletedTripsTable.rows()
        currentRows.deselect();
    })    

    $(document).on('click', '#open-trip-modal', function(e){
        var tripId = $(this).data("trip_id");
        $.ajax({
            type: "GET",
            url: '/trips/' + tripId + '/trip_details',
            success: function(result){                
                setTripInfoMarkersData(result);
                $.ajax({
                    type: "GET",
                    url: '/trips/' + tripId + '/',
                    success: function(result){                        
                    }
                })
            }
        })    
    })

    $('#billable_entities').on('change', function () {
        billable_entity = $(this).val();
        if(billable_entity == 'trips'){
            $("#billing-completed-trips-div").css("display", "block")
            $("#billing-completed-vehicles-div").css("display", "none")
        }
        else{
            $("#billing-completed-trips-div").css("display", "none")
            $("#billing-completed-vehicles-div").css("display", "block")            
        }
        refreshDatatables()
    });    

    $('#invoice_type').on('change', function () {
        invoice_type = $(this).val();
        refreshDatatables()
    });

    function refreshDatatables(){
        if(billable_entity == 'trips'){
            billingCompletedTripsTable.clear();
            billingCompletedTripsTable.draw();
        }
        else{
            if(billingCompletedVehiclesTable.data() == undefined){
                loadBillingCompletedVehiclesTable()
            }
            else{
                billingCompletedVehiclesTable.clear();
                billingCompletedVehiclesTable.draw();
            }
        } 
    }

    function loadBillingCompletedVehiclesTable(){
        billingCompletedVehiclesTable = $('#billing-completed-vehicles-table').DataTable({
            serverSide: true,
            ajax: {
                url: "/invoices/completed_vehicles",
                data: function (d) {
                    d.startDate = startDate;
                    d.endDate = endDate;
                    d.invoice_type = invoice_type;
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
                        return ''
                    }
                },
                {data: "customer"},
                {data: "site"},
                {data: "operator"},
                {data: "business_associate"},
                {data: "vehicle_number"},
                {data: "vehicle_type"},
                {data: "hours_on_duty"},
                {data: "mileage_on_duty"},
                {data: "total_trips"},
                {data: "hours_on_trips"},
                {data: "mileage_on_trips"}                
            ],
            drawCallback: function(){
                if($(vehiclesTable).DataTable().rows()[0].length == 0){
                    $("#select-all-trips").css('display', 'none')
                    $("#generate-invoices").css('display', 'none')
                    $("#cancel-select-all").css('display', 'none')
                }
                else{
                    $("#select-all-trips").css('display', 'block')
                    $("#generate-invoices").css('display', 'none')
                    $("#cancel-select-all").css('display', 'none')
                    $(vehiclesTable).DataTable().rows().every( function (row) {
                        var tr = $(this.node());
                        tr.find('td:first').addClass('checkbox-select');                        
                        if(select_all){
                            tr.addClass('selected');
                        }
                    });
                }
                current_user = this.api().ajax.json().user.entity_type
                vehicleMapping = this.api().ajax.json().vehicles
                tripsVehicleMapping = this.api().ajax.json().trips                
                if(current_user == 'Operator'){
                   billingCompletedVehiclesTable.column(2).visible(false);
                }
                else if(current_user == 'Employer'){
                   billingCompletedVehiclesTable.column(0).visible(false);
                   billingCompletedVehiclesTable.column(3).visible(false);
                }
            }
        });
        
        billingCompletedVehiclesTable.on('select', function (e, dt, type, indexes) {
            var rowData = billingCompletedVehiclesTable.row(indexes).data();
            for(var trip in rowData.trips){
                var index = selectedVehicleTrips.indexOf(rowData.trips[trip]);
                if (index === -1) {
                  selectedVehicleTrips.push(rowData.trips[trip])
                }
            }            
            $("#select-all-trips").css('display', 'none')
            $("#generate-invoices").css('display', 'block')
            $("#cancel-select-all").css('display', 'block')
        });

        billingCompletedVehiclesTable.on('deselect', function (e, dt, type, indexes) {
            // remove selected row from track        
            select_all = false
            if(selectedVehicleTrips.length > 0){
                var rowData = billingCompletedVehiclesTable.row(indexes).data();
                for(var trip in rowData.trips){
                    var index = selectedTrips.indexOf(rowData.trips[trip])
                    selectedVehicleTrips.splice(index, 1);
                }                
            }
            else{
                $("#generate-invoices").css('display', 'none')
                $("#cancel-select-all").css('display', 'none')
                $("#select-all-trips").css('display', 'block')
                return
            }                
            if(selectedVehicleTrips.length == 0){
                $("#generate-invoices").css('display', 'none')
                $("#cancel-select-all").css('display', 'none')
                $("#select-all-trips").css('display', 'block')
            }
            else{
                $("#select-all-trips").css('display', 'none')
                $("#generate-invoices").css('display', 'block')
                $("#cancel-select-all").css('display', 'block')
            }
        });
    }
});
