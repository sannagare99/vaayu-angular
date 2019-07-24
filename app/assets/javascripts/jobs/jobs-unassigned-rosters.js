$(function () {
    'use strict';

    /**
     * Init table
     */
    var table = '#operator-unassigned-rosters-table';
    var operatorUnassignedRostersTable = $();
    var exception_status_mapping = {}

    $('a[href="#operator-unassigned-rosters"]').on('shown.bs.tab', function (e) {
        if (loadedTabs['operator-unassigned-rosters']) return;

        // set loaded state
        loadedTabs['operator-unassigned-rosters'] = true;

        if (!loadedDatatables[table]) {

            operatorUnassignedRostersTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/trips",
                    data: {
                        status: ['created', 'assign_request_declined']
                    }
                },
                lengthChange: false,
                searching: false,
                paging: true,
                info: false,
                ordering: false,
                autoWidth: false,
                order: [[1, "asc"]],
                select: {
                    style: 'single',
                    selector: 'td:first-child'
                },
                columns: [
                    {
                        data: null,
                        width: '30px',
                        className: 'radio-select text-primary',
                        orderable: false,
                        defaultContent: ''
                    },
                    {
                        data: null,
                        orderable: false,
                        render: function (data) {
                            var txt = '<a class="unassigned-roster-btn" href="/trips/' + data.id + '/employee_trips" data-remote="true" data-method="GET">' + data.date + ' - ' + data.id + '</a>';
                            if(data.is_guard_required && data.status == 'created') {txt += '&nbsp;&nbsp;<i class="fa fa-exclamation-circle fa-lg"></i>';}
                            // if (data.trip_type == "check_in") {
                            //     if (data.is_guard_provisioning_enabled && data.is_first_female_pickup && data.is_day_shift) {txt += '&nbsp;&nbsp;<i class="fa fa-exclamation-circle fa-lg"></i>';}
                            // } else {
                            //     if (data.is_guard_provisioning_enabled && data.is_last_female_drop && data.is_day_shift) {txt += '&nbsp;&nbsp;<i class="fa fa-exclamation-circle fa-lg"></i>';}
                            // }
                            return txt;
                        }
                    },
                    {data: 'shift'},
                    {data: 'direction'},
                    {
                        data: null,
                        orderable: false,
                        className: 'text-center map-picker-ico',
                        width: '2%',
                        render: function (data) {
                            return '<a href="#"><svg width="14" height="23" viewBox="0 0 14 23" xmlns="http://www.w3.org/2000/svg">' +
                                '<title>9B2F9D7E-96D4-441D-9598-6A0CE8BB4800</title>' +
                                '<path d="M12.253 3.92c-.71-1.27-1.828-2.248-3.32-2.765-.263-.094-.527-.17-.8-.216-.29-.058-.61-.095-.936-.114h-.39c-.33.02-.647.056-.938.113-.283.046-.547.12-.8.215-1.493.517-2.62 1.496-3.33 2.766-.482.876-.81 1.967-.727 3.303.027.61.19 1.166.372 1.665.19.49.41.93.664 1.355.99 1.665 2.327 3.142 3.082 5.042.39.96.728 1.966 1.02 3.04.28 1.062.544 2.18.654 3.414h.39c.11-1.234.364-2.353.646-3.416.29-1.073.637-2.08 1.02-3.04.763-1.9 2.1-3.376 3.082-5.04.264-.425.482-.867.673-1.356.182-.5.336-1.054.373-1.665.072-1.336-.246-2.427-.737-3.302zM6.995 9.147c-1.266 0-2.286-1.01-2.286-2.253s1.02-2.245 2.285-2.245c1.267 0 2.296 1.002 2.296 2.245 0 1.242-1.028 2.253-2.295 2.253z" ' +
                                'class="pin-body" stroke="#00A89F" fill="none" fill-rule="evenodd"/></svg></a>';
                        }
                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                     var info = this.api().page.info();
                     $('#unassigned-trips-count').text("Total Unassigned Trips: " + info.recordsTotal);                    
                }
            });
        }

        // enable dispatch button
        operatorUnassignedRostersTable.on('select', function () {
            if ($("#operator-unassigned-rosters-table tr.selected td i").length < 1) {
                $('#assign-trip-roster').attr('disabled', false);
                $('#complete_with_exception').attr('disabled', false);
            } else {
                $('#assign-trip-roster').attr('disabled', true);
                $('#complete_with_exception').attr('disabled', true);
            }
        });

        // disable dispatch button
        operatorUnassignedRostersTable.on('deselect', function () {
            $('#assign-trip-roster').attr('disabled', true);
            $('#complete_with_exception').attr('disabled', true);
        });

        // init trip modal info route map
        // $(document).on('shown.bs.modal', '#modal_show_trip_on_dispatch', function () {
        //         initRouteMap(tripInfoMarkersData, tripInfoModalMapID);
        //     }
        // );
    });

    // change assign roster modal title
    $('#assign-trip-roster').on('click', function () {
        var rosterData = operatorUnassignedRostersTable.row({selected: true}).data();
        if (rosterData) {
            $.ajax({
                type: "POST",
                data: {
                    type: 'match'
                },
                url: '/trips/' + rosterData.id + '/get_drivers'
            });
        }
    });

    $(document).on('click', '#all-drivers', function (e) {
        e.preventDefault();
        $('#all-drivers').removeClass('bg-cloud');
        $('#available-drivers').removeClass('bg-white');
        $('#match-drivers').removeClass('bg-white');

        $('#all-drivers').addClass('bg-white');
        $('#available-drivers').addClass('bg-cloud');
        $('#match-drivers').addClass('bg-cloud');

        $('#available-drivers-div').addClass('hidden');
        $('#match-drivers-div').addClass('hidden');
        $('#all-drivers-div').removeClass('hidden');
    });

    $(document).on('click', '#available-drivers', function (e) {
        e.preventDefault();
        $('#all-drivers').removeClass('bg-white');
        $('#match-drivers').removeClass('bg-white');
        $('#available-drivers').removeClass('bg-cloud');

        $('#all-drivers').addClass('bg-cloud');
        $('#match-drivers').addClass('bg-cloud');
        $('#available-drivers').addClass('bg-white');

        $('#all-drivers-div').addClass('hidden');
        $('#available-drivers-div').removeClass('hidden');
        $('#match-drivers-div').addClass('hidden');
    });

    $(document).on('click', '#match-drivers', function (e) {
        e.preventDefault();
        $('#all-drivers').removeClass('bg-white');
        $('#available-drivers').removeClass('bg-white');
        $('#match-drivers').removeClass('bg-cloud');

        $('#all-drivers').addClass('bg-cloud');
        $('#available-drivers').addClass('bg-cloud');
        $('#match-drivers').addClass('bg-white');

        $('#all-drivers-div').addClass('hidden');
        $('#match-drivers-div').removeClass('hidden');
        $('#available-drivers-div').addClass('hidden');      
    });

    $(document).on('click', '.select_ola_button', function(e){
        var id = e.target.id.split("_")[2]
        $("#ola_button_" + id).removeClass('bg-white');
        $("#uber_button_" + id).removeClass('bg-cloud');
        $('#ola_button_' + id).addClass('bg-cloud');
        $("#uber_button_" + id).addClass('bg-white');
    })

    $(document).on('click', '.select_uber_button', function(e){
        var id = e.target.id.split("_")[2]
        $("#uber_button_" + id).removeClass('bg-white');
        $("#ola_button_" + id).removeClass('bg-cloud');
        $("#uber_button_" + id).addClass('bg-cloud');
        $("#ola_button_" + id).addClass('bg-white');
    })

    // dispatch roster action
    $(document).on('click', '#book-ola-uber-submit', function (e) {
        e.preventDefault();

        var data = {};

        var tripId = $(this).data('trip-id');

        var rows = $("#book-ola-uber-table > tbody > tr");        

        // get ids
        data.ids = rows.map(function (element) {
            return rows[element].id;
        });

        var ola_uber_data = {};

        for(var i = 0; i < data.ids.length; i++) {
            var employee_data = {};
            employee_data.id = data.ids[i];
            employee_data.driver_name = $('#driver-name-' + data.ids[i])[0].value;
            employee_data.licence_number = $('#driver-number-' + data.ids[i])[0].value;
            employee_data.location = $('#location-' + data.ids[i])[0].value;
            if($(this).data('show-cost')) {
                employee_data.cost = $('#cost-' + data.ids[i])[0].value;
            }
            ola_uber_data[i] = (employee_data);
        }

        /* Call book ola uber submit api */
        $.ajax({
            type: "POST",
            data: {
                employee_data: ola_uber_data
            },
            url: '/trips/' + tripId + '/book_ola_uber_submit'
        }).done(function () {
            updateDataTables();
            updateTripBoard();
            $('#book-ola-uber-modal').modal('hide');            
        });        
    });

    // init unassigned rosters table in modal
    // var operatorUnassignedRosterTable;
    
    $(document).on('show.bs.modal', '#modal-operator-unassigned-rosters', function () {
        if (!$.fn.DataTable.isDataTable('#operator-unassigned-roster-table')) {
            operatorUnassignedRostersTable = $('#operator-unassigned-roster-table').DataTable({
                lengthChange: false,
                searching: false,
                pagingType: "simple_numbers",
                info: false,
                autoWidth: false,
                paging: false,
                ordering: false,
                select: {
                    style: 'multi',
                    selector: '.text-danger'
                }
            });
        }

        // //enable modal footer buttons
        // operatorUnassignedRosterTable.on('select', function () {
        //     $('#assign-roster').removeClass('disabled-default');
        // });

        // //disable modal footer buttons
        // operatorUnassignedRosterTable.on('deselect', function () {
        //     if (operatorUnassignedRosterTable.rows({selected: true}).count() == 0) {
        //         $('#assign-roster').addClass('disabled-default');
        //     }
        // });
    });

    $(document).on('show.bs.modal', '#modal-trip-info', function () {
        exception_status_mapping = {}
        if (!$.fn.DataTable.isDataTable('#trip-info-content-table')) {
            // operatorUnassignedRosterTable = $('#trip-info-content-table').DataTable({
            //     lengthChange: false,
            //     searching: false,
            //     info: false,
            //     autoWidth: false,
            //     paging: false,
            //     ordering: false,
            //     select: {
            //         style: 'multi'
            //     }
            // });
        }

        // //enable modal footer buttons
        // operatorUnassignedRosterTable.on('select', function () {
        //     $('#assign-roster').removeClass('disabled-default');
        // });

        // //disable modal footer buttons
        // operatorUnassignedRosterTable.on('deselect', function () {
        //     if (operatorUnassignedRosterTable.rows({selected: true}).count() == 0) {
        //         $('#assign-roster').addClass('disabled-default');
        //     }
        // });
    });

    $(document).on('change', '#exception-status', function(e){        
        document.getElementById('save-exception-status').style.display = 'block';
        var exception_status = $(this).val();
        var employee_trip_id = $(this).data('employee_trip_id')
        var trip_route_id = $(this).data('route_id')
        exception_status_mapping[trip_route_id] = {'employee_trip_id': employee_trip_id, 'trip_route_id': trip_route_id, 'exception_status': exception_status}
    })

    $(document).on('click', '#save-exception-status', function(e){
        $.ajax({
            type: "POST",
            data: {
                exception_status_mapping: exception_status_mapping
            },
            url: '/employee_trips/set_exception_status'
        }).done(function (response) {
            console.log(response)            
            $('#modal-trip-info').modal('toggle');
            document.getElementById('save-exception-status').style.display = 'hidden';
        });  
    })
    
    $(document).on('click', '#complete-with-exception-search-driver', function (e) {
        e.preventDefault();
        var data = {};
        var tripId = $(this).data('trip-id');
        var search = $('#complete_with_exception_driver_name')[0].value
        $.ajax({
            type: "GET",
            data: {
                search: search
            },
            url: '/trips/' + tripId + '/search_driver'
        }).done(function (response) {
            console.log(response)
            // if(response.assigned_driver != null)
            var html = '<tbody>'
            for(var i = 0; i < response.drivers.length; i++){
                html = html + '<tr data-driver-id=' + response.drivers[i].id + '>' + 
                            '<td class="text-center text-default radio-row col-md-2">' + 
                                '<div class="nice-radio text-default"><input id="' + response.drivers[i].id + '" name="driver_id" type="radio" value="' + response.drivers[i].id + '"><label for="' + response.drivers[i].id + '"></label></div>' + 
                            '</td>' + 
                            '<td class="col-md-6">' + response.drivers[i].name + '</td>' + 
                            '<td class="col-md-4">' + response.drivers[i].plate_number + '</td>' + 
                            '</tr>'
            }

            html = html + '</tr></tbody>'
            $('#complete-with-exception-drivers').html(html)
        });  
    });

    $(document).on('keyup', '#complete_with_exception_driver_name', function(e){
        e.preventDefault();
        if(e.which == 13) {
          $('#complete-with-exception-search-driver').click();
        }
    });

    // change disable/enable modal button state
    $(document).on('change', '#complete-with-exception-reasons .nice-radio [type="radio"]', function () {
        if ($(this).is(':checked')) {
            var exception_value = $('#complete-with-exception-reasons').find('.nice-radio :checked').closest('div').data('exception');
            var driverId = $('#complete-with-exception-drivers').find('.nice-radio :checked').closest('tr').data('driver-id');

            // if(exception_value == "Driver Completed Trip" || exception_value == "Driver Was Off Duty") {
            //     $('#exception_reasons_sm').addClass("modal-md")
            //     $('#complete-with-exception-reasons-div').removeClass("col-sm-12")
            //     $('#complete-with-exception-reasons-div').addClass("col-md-6")
            //     $('#exception_reasons_sm').attr('style', 'width : 50%');
            //     $('#driver_names').removeClass("hidden")
            // }
            // else{
            //     $('#exception_reasons_sm').addClass("modal-sm")                
            //     $('#exception_reasons_sm').attr('style', 'width : 25%');
            //     $('#driver_names').addClass("hidden")
            //     $('#complete-with-exception-reasons-div').addClass("col-sm-12")
            //     $('#complete-with-exception-reasons-div').removeClass("col-md-6")
            // }
            if(exception_value == "Other") {
                /* Unhide the text box for other exception */
                $('#complete_with_exception_text').removeClass('hidden');
                $('#exception_text').removeClass('has-error');
            }
            else {
                $('#complete_with_exception_text').addClass('hidden');
            }
            if(driverId != '' && driverId != null && driverId != undefined){
                $('#complete-with-exception-submit').removeClass('disabled-default');
                $('#book-ola-uber').removeClass('disabled-default');    
            }
            else{
                $('#complete-with-exception-submit').addClass('disabled-default');
                $('#book-ola-uber').addClass('disabled-default');    
            }
        }
        else {
            $('#complete-with-exception-submit').addClass('disabled-default');
            $('#book-ola-uber').addClass('disabled-default');
        }
    });

    $(document).on('change', '#complete-with-exception-drivers .nice-radio [type="radio"]', function () {
        if ($(this).is(':checked')) {
            var exception_value = $('#complete-with-exception-reasons').find('.nice-radio :checked').closest('div').data('exception');
            var driverId = $('#complete-with-exception-drivers').find('.nice-radio :checked').closest('tr').data('driver-id');

            if(exception_value != '' && exception_value != null && exception_value != undefined){
                $('#complete-with-exception-submit').removeClass('disabled-default');
                $('#book-ola-uber').removeClass('disabled-default');    
            }
            else{
                $('#complete-with-exception-submit').addClass('disabled-default');
                $('#book-ola-uber').addClass('disabled-default');    
            }
        }
        else {
            $('#complete-with-exception-submit').addClass('disabled-default');
            $('#book-ola-uber').addClass('disabled-default');
        }
    });

    // change disable/enable modal button state
    $(document).on('change', '#assign-driver-table .nice-radio [type="radio"]', function () {        
        if ($(this).is(':checked')) {
            if($(this).data("driver-status") == "on_duty" && $(this).data("vehicle-status") == "vehicle_ok") {
                $('#assign-roster-confirm').removeClass('disabled-default');
            } else {
                $('#assign-roster-confirm').addClass('disabled-default');    
            }
            $('#assign_with_exception').removeClass('disabled-default');
        }
        else {
            $('#assign-roster-confirm').addClass('disabled-default');
            $('#assign_with_exception').addClass('disabled-default');
        }
    });

    $(document).on('click', '#open-map', function(e){
        $('#trip-board-driver-info').attr("style", "visibility: hidden; z-index:0; position:fixed");
        $('#trip-board-map-info').attr("style", "visibility: visible; z-index:1; position: relative");
    })

    $(document).on('click', '#close-map', function(e){
        $('#trip-board-driver-info').attr("style", "visibility: visible; z-index:1; position:relative");
        $('#trip-board-map-info').attr("style", "visibility: hidden; z-index:0; position:fixed");
    })

    // Complete trip with exception
    $(document).on('click', '#complete-with-exception-submit', function (e) {
        e.preventDefault();
        var exception_value = $('#complete-with-exception-reasons').find('.nice-radio :checked').closest('div').data('exception');
        if(exception_value == "Other") {
            /* Save the text box value */
            var otherException = $('#complete_with_exception_text')[0].value;
            if(otherException == "") {
                $('#exception_text').addClass('has-error');
                return;
            } else {
                $('#exception_text').removeClass('has-error');
                exception_value = otherException;
            }
        }

        /* Cancel the trip with exception text */
        var tripId = $(this).data("trip-id");
        var notificationId = $(this).data("notification-id");
        var driverId = $(this).data("driver-id");
        var bookOla = $(this).data('book-ola');

        if(driverId == '' || driverId == null || driverId == undefined) {
            driverId = $('#complete-with-exception-drivers').find('.nice-radio :checked').closest('tr').data('driver-id');
        }
        
        $.ajax({
            type: "POST",
            data: {
                status: exception_value,
                notification_id: notificationId,
                driver_id: driverId,
                book_ola: bookOla
            },
            url: '/trips/' + tripId + '/complete_with_exception_submit'
        }).done(function () {            
            updateDataTables();
            updateTripBoard()
            $.ajax({
                type: "GET",
                url: '/trips/' + tripId
            }).done(function () {
                $('#complete-with-exception').modal('hide');
            });            
        });
    });

    // Complete trip with exception
    $(document).on('click', '#book-ola-uber', function (e) {
        e.preventDefault();

        var exception_value = $('#complete-with-exception-table').find('.nice-radio :checked').closest('tr').data('exception');
        if(exception_value == "Other") {
            /* Save the text box value */
            var otherException = $('#complete_with_exception_text')[0].value;
            if(otherException == "") {
                $('#exception_text').addClass('has-error');
                return;
            } else {
                $('#exception_text').removeClass('has-error');
                exception_value = otherException;
            }
        }

        /* Cancel the trip with exception text */
        var tripId = $(this).data("trip-id");
        var driverId = $(this).data("driver-id");

        $.ajax({
            type: "POST",
            data: {
                status: exception_value, 
                driver_id: driverId
            },
            url: '/trips/' + tripId + '/book_ola_uber'
        }).done(function () {
            $('#complete-with-exception').modal('hide');
            updateDataTables();
            updateTripBoard();
        });
    });

    // Complete with Exception and record fare
    $(document).on('click', '#complete-and-record-fare', function (e) {
        e.preventDefault();

        /* Cancel the trip with exception text */
        var tripId = $(this).data("trip_id");
        var rideCost = $('#ride_cost')[0].value;

        if(rideCost == "") {
            $('#ride_cost_div').addClass('has-error');
            return;
        }

        $.ajax({
            type: "POST",
            data: {
                ride_cost: rideCost
            },
            url: '/trips/' + tripId + '/complete_with_exception_submit'
        }).done(function () {
            $('#modal-trip-info').modal('hide');
            updateDataTables();
            updateTripBoard();
        });
    });

    var deleteClicked = 0;
    $(document).on('click', '#operator-unassigned-roster-table .text-danger', function(e){
        var text = $('#' + e.toElement.id).text();
        if(text == 'Delete'){
            deleteClicked ++;
            $('#' + e.toElement.id).text('Undo');            
        }
        else if(text == 'Undo'){
            deleteClicked --;
            $('#' + e.toElement.id).text('Delete');
        }

        if(deleteClicked){
            $('#assign-roster').removeClass('disabled-default');
            $('#assign-trip-roster-modal').addClass('disabled-default');
        }
        else{
            $('#assign-roster').addClass('disabled-default');
            $('#assign-trip-roster-modal').removeClass('disabled-default');   
        }
    });

    $(document).on('dblclick', '#operator-unassigned-roster-table .text-danger', function(e){
        var text = $('#' + e.toElement.id).text();
        if(text == 'Delete'){
        deleteClicked ++;
            $('#' + e.toElement.id).text('Undo');
        }
        else if(text == 'Undo'){
        deleteClicked --;
            $('#' + e.toElement.id).text('Delete');   
        }
        if(deleteClicked){
            $('#assign-roster').removeClass('disabled-default');
            $('#assign-trip-roster-modal').addClass('disabled-default');
        }
        else{
            $('#assign-roster').addClass('disabled-default');
            $('#assign-trip-roster-modal').removeClass('disabled-default');
        }
    });    

    $(document).on('click', '.employee-trip-info-table .text-danger', function(e){
        var text = $('#' + e.toElement.id).text();
        var tr = $(this).closest('tr');
        if(text == 'Delete'){
            $('#' + e.toElement.id).text('Undo');
            $('#save_changes').removeClass('hidden');
            $('#annotate-modal').addClass('hidden');
            $(tr).addClass('selected bg-selected');            
        }
        else if(text == 'Undo'){          
            $('#' + e.toElement.id).text('Delete');
            $(tr).removeClass('selected bg-selected');
        }
    });

    $(document).on('dblclick', '.employee-trip-info-table .text-danger', function(e){
        var text = $('#' + e.toElement.id).text();
        var tr = $(this).closest('tr');
        if(text == 'Delete'){
            $('#' + e.toElement.id).text('Undo');
            $('#save_changes').removeClass('hidden');
            $('#annotate-modal').addClass('hidden');
            $(tr).addClass('selected bg-selected');
        }
        else if(text == 'Undo'){
            $('#' + e.toElement.id).text('Delete');
            $(tr).addClass('selected bg-selected');
        }
    });

    $(document).on('click', '#save_changes', function(e){
        e.preventDefault();
        var data = {'action_type' : 'delete'};
        var tripId = $('#trip-info-content-table').data('trip-id');
        var selectedRows = $('#trip-info-content-table').find('.selected');

        // get ids
        data.ids = selectedRows.toArray().map(function (element) {
            var tdElement = $(element)[0].childNodes[$(element)[0].childNodes.length - 1];            
            return $(tdElement).data('employee-trip-id');
        });

        $.ajax({
            type: "POST",
            data: data,
            url: '/trips/' + tripId + '/update_employee_trips'
        }).done(function () {
            var $modal = $('#modal-trip-info');
            $modal.modal('hide');
            updateDataTables();
            updateTripBoard();
        });
    })

    $(document).on('click', '#complete_with_exception', function (e) {
        e.preventDefault();
        var trip_id = "";
        if($(this).data('trip_id') != undefined) {
            trip_id = $(this).data('trip_id');
        } 
        else {
            var rosterData = operatorUnassignedRostersTable.row({selected: true}).data();
            trip_id = rosterData.id;
        }
        openCompleteWithExceptionModal(trip_id, $(this).data('notification_id'), $(this).data('book-ola'), $('#modal-trip-info'));
    });

    $(document).on('click', '#call-person', function (e) {
        e.preventDefault();
        var datanumber = $(this).data( "number" );
        var notificationId = $(this).data( "notification-id" );
        initiateCall(datanumber, notificationId);
    });   

    $(document).on('click', '#contact-operator', function (e) {
       
    });

    $(document).on('click', '#annotate-modal', function (e) {
        e.preventDefault();
        var trip_id = $(this).data( "trip_id" );
        $('#modal-trip-info').modal('hide');
        $('#modal-trip-info').on('hidden.bs.modal', function () {
            $('#modal-annotate-trip').modal('show');
            $("#add-annotation-to-trip").attr('data-trip_id', trip_id);
            $("#annotate_modal_header").text("Add Remarks to #" + trip_id);
        });
    });    

    $(document).on('keyup', '#annotate_body_text', function (e){
        if($("#annotate_subject_text").val() != undefined && $("#annotate_subject_text").val() != '' && $("#annotate_body_text").val() != undefined && $("#annotate_body_text").val() != ''){
            $("#add-annotation-to-trip").attr("disabled", false);
        }
        else{
            $("#add-annotation-to-trip").attr("disabled", true);   
        }
    })

    $(document).on('keyup', '#annotate_subject_text', function (e){
        if($("#annotate_subject_text").val() != undefined && $("#annotate_subject_text").val() != '' && $("#annotate_body_text").val() != undefined && $("#annotate_body_text").val() != ''){
            $("#add-annotation-to-trip").attr("disabled", false);
        }
        else{
            $("#add-annotation-to-trip").attr("disabled", true);   
        }
    })

    $(document).on('click', '#add-annotation-to-trip', function(e){
        e.preventDefault()
        var trip_id = $(this).data( "trip_id" );
        var subject = $("#annotate_subject_text").val()
        var body = $("#annotate_body_text").val()
        var data = {
            'subject': subject,
            'body': body
        }
        $.ajax({
            type: "POST",
            data: data,
            url: '/trips/' + trip_id + '/annotate_trip'
        }).done(function (response) {
            $('#modal-annotate-trip').modal('hide');
        })
    })

    // Assign or delete roster
    $(document).on('click', '#modal-operator-unassigned-rosters .modal-footer .action-button .btn', function (e) {
        e.preventDefault();        
        var data = {};
        var actionType = $(this).data('roster-action');
        var bookOla = $(this).data('book-ola');
        data.action_type = actionType;
        var tripId = $('#operator-unassigned-roster-table').data('trip-id');
        var selectedRows = $('#operator-unassigned-roster-table').find('.selected');

        // get ids
        data.ids = selectedRows.toArray().map(function (element) {
            return $(element).data('employee-trip-id');
        });

        if(actionType == "complete_with_exception") {
            /* Open the complete with exceptions modal */
            e.preventDefault();
            openCompleteWithExceptionModal(tripId, null, bookOla, $('#modal-operator-unassigned-rosters'))
            return;            
        }        
        document.getElementById('unassigned_overlay').style.display = 'block';
        $.ajax({
            type: "POST",
            data: data,
            url: '/trips/' + tripId + '/update_employee_trips'
        }).done(function (response) {
            var $modal = $('#modal-operator-unassigned-rosters');
            document.getElementById('unassigned_overlay').style.display = 'none';
            // if(response.length > 0){
            //     console.log(response)                
            //     $('#delete_error_message').text("Something went wrong!");
            //     operatorUnassignedRostersTable.draw(true)
            // }
            // else{
                // try{
                //     // operatorUnassignedRostersTable.draw();

                //     // remove fields if action == delete
                //     if (actionType === 'delete') {
                //         operatorUnassignedRostersTable.rows({selected: false}).remove().draw();

                //         if (operatorUnassignedRostersTable.rows({selected: false}).count() == 0) {
                //             $('#assign-roster, #delete-roster').addClass('disabled-default');
                //         }

                //         if (!operatorUnassignedRostersTable.data().count()) {
                //             $modal.modal('hide');
                //         }
                //     } 
                //     else {
                //         $modal.modal('hide');
                //         $modal.on('hidden.bs.modal', function () {
                //             // $('#modal-operator-available-drivers').modal('show');
                //         });
                //     }
                // }
                // catch(err){
                //     console.log(err);
                // }              
                // finally {
                    $modal.modal('hide');                    
                    updateDataTables();
                    updateTripBoard();
                // }
            // }                    
        });
    });

    function openCompleteWithExceptionModal(tripId, notificationId, bookOla, $modal) {
        $.ajax({
            type: "GET",
            data: {
                notification_id: notificationId,
                book_ola: bookOla
            },
            url: '/trips/' + tripId + '/complete_with_exception'
        }).done(function(response) {
            $modal.modal('hide');
            $modal.on('hidden.bs.modal', function () {
                $('#complete-with-exception').modal('show');
            });
        });
    }
    var tripInfoMarkersData = [];
    var tripInfoModalMapID = 'map-trip-info';
    var dispatchTripId;
    var driverId;

    // assign manifest to driver
    $(document).on('click', '#assign-roster-confirm', function (e) {
        e.preventDefault();
        // var rowId = $(operatorUnassignedRostersTable.row({selected: true}).node()).attr('id');
        // var tripId = rowId.slice(rowId.indexOf('-') + 1);
        var tripId = $('#assign-driver-table').data('trip-id')
        driverId = $('#assign-driver-table').find('.nice-radio :checked').closest('tr').data('assign-driver-id');
        var lastPairedVehicle = $('#assign-driver-table').find('.nice-radio :checked').closest('tr').data('last-paired-vehicle');
        $('#modal-operator-available-drivers').modal('hide');

        $.ajax({
            type: "POST",
            data: {
                driver_id: driverId,
                exception: false,
                last_paired_vehicle: lastPairedVehicle
            },
            url: '/trips/' + tripId + '/assign_driver'
        }).done(function () {
            $('#annotate-modal').addClass('hidden');
            $('#assign-driver-submit').addClass('pull-right leftMargin')
            updateDataTables();
            updateTripBoard();
            // var rowData = operatorUnassignedRostersTable.row({selected: true}).data();
            // dispatchTripId = rowData.id;            
            // tripInfoMarkersData = {
            //     site: {lat: rowData.site_lat, lng: rowData.site_lng},
            //     data: []
            // };

            // if (rowData.status === 'completed' || rowData.status === 'cancel') {
            //     tripInfoMarkersData.type = 'employee-basic'
            // }

            // tripInfoMarkersData.data = setRouteMarkersData(rowData.trip_routes);
        })
    });

    // assign manifest to driver
    $(document).on('click', '#assign_with_exception', function (e) {
        e.preventDefault();

        var rowId = $(operatorUnassignedRostersTable.row({selected: true}).node()).attr('id');
        var tripId = rowId.slice(rowId.indexOf('-') + 1);
        driverId = $('#assign-driver-table').find('.nice-radio :checked').closest('tr').data('assign-driver-id');
        $('#modal-operator-available-drivers').modal('hide');

        $.ajax({
            type: "POST",
            data: {
                driver_id: driverId,
                exception: true
            },
            url: '/trips/' + tripId + '/assign_driver'
        }).done(function () {
            updateDataTables();
            updateTripBoard();
            if(operatorUnassignedRostersTable != null && operatorUnassignedRostersTable != undefined) {
                var rowData = operatorUnassignedRostersTable.row({selected: true}).data();
                dispatchTripId = rowData.id;

                tripInfoMarkersData = {
                    site: {lat: rowData.site_lat, lng: rowData.site_lng},
                    data: []
                };

                if (rowData.status === 'completed' || rowData.status === 'cancel') {
                    tripInfoMarkersData.type = 'employee-basic'
                }

                tripInfoMarkersData.data = setRouteMarkersData(rowData.trip_routes);
            }
        })
    });

    // dispatch roster action
    $(document).on('click', '#assign-driver-submit, #assign-driver-continue', function (e) {
        e.preventDefault();

        if(dispatchTripId == null) {
            dispatchTripId = $(this).data("trip-id");
        }

        if(driverId == null) {
            driverId = $(this).data("driver-trip-id");   
        }

        var last_paired_vehicle = $(this).data("last-paired-vehicle");
        $.ajax({
            type: "POST",
            data: {
                driver_id: driverId,
                last_paired_vehicle: last_paired_vehicle
            },
            url: '/trips/' + dispatchTripId + '/assign_driver_submit'
        }).done(function (response) {
            if (response.error == true) {
                if (response.error_type == 'change_driver') {
                    $('#assign-driver-submit').addClass('hidden')
                    $('#assign-driver-change-driver').removeClass('hidden')
                } else if (response.error_type == 'continue') {
                    $('#assign-driver-submit').addClass('hidden')
                    $('#assign-driver-continue').removeClass('hidden')
                }

                $('#notification-text').text(response.error_message)
            } else {
                updateDataTables();
                updateTripBoard();
                $('#modal_show_trip_on_dispatch').modal('hide');
                driverId = null;
                dispatchTripId = null;
            }
        })
    });

    $(document).on('click', '#change-driver, #assign-driver-change-driver', function (e) {
        var tripId = $(this).data('trip_id');
        e.preventDefault();
        $.ajax({
            type: "POST",
            data: {
                type: 'match'
            },
            url: '/trips/' + tripId + '/get_drivers'
        }).done(function () {
            $('#modal-trip-info').modal('hide');

        })
    });

    // dispatch roster action
    $(document).on('click', '#assign-driver-exception', function (e) {
        e.preventDefault();
        var bookOla = $(this).data('book-ola');

        $.ajax({
            type: "POST",
            data: {
                driver_id: driverId,
                book_ola: bookOla
            },
            url: '/trips/' + dispatchTripId + '/assign_driver_exception'
        }).done(function () {
            updateDataTables();
            updateTripBoard();
            $('#modal_show_trip_on_dispatch').modal('hide');
        })
    });

    /**
     * Init map
     */
    var operatorUnassignedRostersMapID = 'map-operator-unassigned-rosters';

    if ($('#map-operator-unassigned-rosters').length) {
        maps[operatorUnassignedRostersMapID] = Gmaps.build('Google', {markers: {clusterer: undefined}});

        maps[operatorUnassignedRostersMapID].buildMap({
            internal: {
                id: operatorUnassignedRostersMapID
            },
            provider: mapProviderOpts
        });
    }

    // show markers on map
    $(table).on('click', '.map-picker-ico a', {
        mapId: operatorUnassignedRostersMapID,
        table: table
    }, showRouteMarkersData);

    // Guard Module

  $(document).on("change", "input[name='employee_id']", function() {
    $("#add-guard-to-trip").attr("disabled", false);
  });

  $(document).on("click", "#move_driver_to_next_step", function() {
    $.ajax({
        type: "POST",
        url: '/notifications/' + $(this).data("notification-id") + '/move_driver_to_next_step',
	success: function(response) {
            updateDataTables();
            updateTripBoard();
	}
    });
  })

  $(document).on("click", "#book-ola-uber-car-break-down", function() {
    e.preventDefault();
    var driverId = $(this).data("driver-id");
    var tripId = $(this).data("trip-id");
    $.ajax({
        type: "POST",
        data: {
            status: 'Car Break down', 
            driver_id: driverId
        },
        url: '/trips/' + tripId + '/book_ola_uber'
    }).done(function () {
        updateDataTables();
        updateTripBoard();
    });
  })

  $(document).on("click", "#add-guard-to-trip", function(e){
    var tripUrl = "/trips/" + $(this).data("trip-id") + "/add_guard_to_trip";
    var employeeId = $("input[name='employee_id']:checked").val();

    if (employeeId !== undefined && $(this).attr("disabled") === undefined) {
      $(this).attr("disabled", true);
      $.post( tripUrl, {employee_id: employeeId})
        .done(function( data ) {
          $("#modal-rosters-guards-assignment").modal('hide');
          $("#modal-operator-unassigned-rosters").modal('hide');
          // operatorUnassignedRostersTable.draw(false)
          updateDataTables();
          updateTripBoard();
        });
    }
  }); 
});
