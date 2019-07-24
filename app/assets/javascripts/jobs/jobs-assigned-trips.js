var svg = '<svg width="13px" height="14px" viewBox="0 0 13 14" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">'+
    '<title>FEFA6A57-5826-4C2D-9960-CC14C19563A2</title>'+
    '<desc>Created with sketchtool.</desc>'+
    '<defs></defs>'+
    '<g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd" fill-opacity="1">'+
        '<g class="phone-ico" id="Employer_Active-Trip_02" transform="translate(-488.000000, -275.000000)" fill="#ffffff">'+
            '<g id="Group-3" transform="translate(170.000000, 228.946360)">'+
                '<g id="Group">'+
                    '<g id="Table">'+
                        '<g id="Assign" transform="translate(295.000000, 0.000000)">'+
                            '<path d="M30.3738889,57.3855556 L31.9627778,55.7966667 C32.1577778,55.6016667 32.4466667,55.5366667 32.6994444,55.6233333 C33.5083333,55.8905556 34.3822222,56.035 35.2777778,56.035 C35.675,56.035 36,56.36 36,56.7572222 L36,59.2777778 C36,59.675 35.675,60 35.2777778,60 C28.4961111,60 23,54.5038889 23,47.7222222 C23,47.325 23.325,47 23.7222222,47 L26.25,47 C26.6472222,47 26.9722222,47.325 26.9722222,47.7222222 C26.9722222,48.625 27.1166667,49.4916667 27.3838889,50.3005556 C27.4633333,50.5533333 27.4055556,50.835 27.2033333,51.0372222 L25.6144444,52.6261111 C26.6544444,54.67 28.33,56.3383333 30.3738889,57.3855556 Z" id="call" transform="translate(29.500000, 53.500000) scale(-1, 1) translate(-29.500000, -53.500000) "></path>'+
                        '</g>'+
                    '</g>'+
                '</g>'+
            '</g>'+
        '</g>'+
    '</g>'+
'</svg>';

$(function () {
    'use strict';

    var startDate = '',
        endDate = '',
        startTime = '',
        endTime = '',
        direction = 2,
        bus_rider = 2,
        status = 6,
        search = '';
    var dateSet = false;

    /**
     * Init table
     */
    var table = '#operator-assigned-trips-table';
    var operatorAssignedTripsTable = $(); 

    $('a[href="#operator-assigned-trips"]').on('shown.bs.tab', function (e) {
        if (loadedTabs['operator-assigned-trips']) return;

        // set loaded state
        loadedTabs['operator-assigned-trips'] = true;

        if (!loadedDatatables[table]) {
            operatorAssignedTripsTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/trips",
                    data: function (d) {
                        d.status = 'manifest_status',
                        d.startDate = startDate,
                        d.endDate = endDate,
                        d.bus_rider = bus_rider,
                        d.direction = direction,
                        d.search = search,
                        d.trip_status = status
                    }
                },
                lengthChange: false,
                searching: false,
                pagingType: "simple_numbers",
                info: false,
                processing: true,
                ordering: false,
                autoWidth: false,
                select: {
                    style: 'multi',
                    selector: '.text-primary'
                },
                // columns: [
                //     {
                //         width: '2%',
                //         data: 'status',
                //         render: function (data) {
                //             return '<span class="trip-status ' + data + '"></span>';
                //         }
                //     },
                //     {
                //         data: null,
                //         orderable: false,
                //         render: function (data) {
                //             return '<a href="/trips/' + data.id + '/" class="btn-trip-info" data-remote="true" data-method="GET" data-status=' + data.status + '>' + data.date + ' - ' + data.id + '</a>'
                //         }
                //     },
                //     {data: 'direction'},
                //     {data: 'shift'},
                //     {data: 'driver_name'},
                //     {data: 'plate_number'},
                //     {
                //         data: null,
                //         orderable: false,
                //         width: '2%',
                //         className: 'text-center map-picker-ico',
                //         render: function (data) {
                //             return '<a href="#"><svg width="14" height="23" viewBox="0 0 14 23" xmlns="http://www.w3.org/2000/svg">' +
                //                 '<title>9B2F9D7E-96D4-441D-9598-6A0CE8BB4800</title>' +
                //                 '<path d="M12.253 3.92c-.71-1.27-1.828-2.248-3.32-2.765-.263-.094-.527-.17-.8-.216-.29-.058-.61-.095-.936-.114h-.39c-.33.02-.647.056-.938.113-.283.046-.547.12-.8.215-1.493.517-2.62 1.496-3.33 2.766-.482.876-.81 1.967-.727 3.303.027.61.19 1.166.372 1.665.19.49.41.93.664 1.355.99 1.665 2.327 3.142 3.082 5.042.39.96.728 1.966 1.02 3.04.28 1.062.544 2.18.654 3.414h.39c.11-1.234.364-2.353.646-3.416.29-1.073.637-2.08 1.02-3.04.763-1.9 2.1-3.376 3.082-5.04.264-.425.482-.867.673-1.356.182-.5.336-1.054.373-1.665.072-1.336-.246-2.427-.737-3.302zM6.995 9.147c-1.266 0-2.286-1.01-2.286-2.253s1.02-2.245 2.285-2.245c1.267 0 2.296 1.002 2.296 2.245 0 1.242-1.028 2.253-2.295 2.253z" ' +
                //                 'class="pin-body" stroke="#00A89F" fill="none" fill-rule="evenodd"/></svg></a>';
                //         }
                //     }
                // ],
                columns: [
                    {
                        data: null,
                        orderable: false,
                        render: function (data) {
                            if (data.is_guard_required){
                                if(data.status == 'created' || data.status == 'assign_request_declined'){
                                    return '<a href="/trips/' + data.id + '/employee_trips" class="unassigned-roster-btn" data-remote="true" data-method="GET" data-status=' + data.status + '>' + data.date + ' ' + data.direction + ' ' + data.scheduled_date + ' - ' + data.id + '</a>&nbsp;&nbsp;<i class="fa fa-exclamation-circle fa-lg" style="color:red"></i>'    
                                }
                                else if(data.status == 'completed' || data.status == 'canceled' || data.status == 'active') {
                                    return '<a href="/trips/' + data.id + '/" class="btn-trip-info" data-remote="true" data-method="GET" data-status=' + data.status + '>' + data.date + ' ' + data.direction + ' ' + data.scheduled_date + ' - ' + data.id + '</a>'
                                } else {
                                    return '<a href="/trips/' + data.id + '/" class="btn-trip-info" data-remote="true" data-method="GET" data-status=' + data.status + '>' + data.date + ' ' + data.direction + ' ' + data.scheduled_date + ' - ' + data.id + '</a>&nbsp;&nbsp;<i class="fa fa-exclamation-circle fa-lg" style="color:red"></i>'
                                }
                            }
                            else{
                                if(data.status == 'created' || data.status == 'assign_request_declined'){
                                    return '<a href="/trips/' + data.id + '/employee_trips" class="unassigned-roster-btn" data-remote="true" data-method="GET" data-status=' + data.status + '>' + data.date + ' ' + data.direction + ' ' + data.scheduled_date + ' - ' + data.id + '</a>';    
                                }
                                return '<a href="/trips/' + data.id + '/" class="btn-trip-info" data-remote="true" data-method="GET" data-status=' + data.status + '>' + data.date + ' ' + data.direction + ' ' + data.scheduled_date + ' - ' + data.id + '</a>';
                            }
                        }
                    },
                    {data: 'area'},
                    {
                        data: null,
                        orderable: false,
                        render: function(data){
                            if (data.driver_name == "") {
                                return '--'
                            } 
                            else if(data.status == 'assign_request_expired'){
                                return '<div class="call-div bg-primary" style="display:inline-block"><a style="position:relative; top:2px; left:3px" id="call-person" href="#" data-number="' + data.driver_phone + '">' + svg + '</a></div>&nbsp;&nbsp;<div style="display:inline-block">' + data.driver_name + ' ' + data.driver_l_name + ' (' + data.plate_number + ')' + '&nbsp;<span style="color:grey">(Expired)</span></div>'
                            }
                            else if(data.status == 'assign_requested'){
                                return '<div class="call-div bg-primary" style="display:inline-block"><a style="position:relative; top:2px; left:3px" id="call-person" href="#" data-number="' + data.driver_phone + '">' + svg + '</a></div>&nbsp;&nbsp;<div style="display:inline-block">' + data.driver_name + ' ' + data.driver_l_name + ' (' + data.plate_number + ')' + '&nbsp;<span style="color:grey">(Pending)</span></div>'
                            }
                            else if(data.status == 'created' || data.status == 'assign_request_declined'){
                                return '--'
                            }
                            return '<div class="call-div bg-primary" style="display:inline-block"><a style="position:relative; top:2px; left:3px" id="call-person" href="#" data-number="' + data.driver_phone + '">' + svg + '</a></div>&nbsp;&nbsp;<div style="display:inline-block">' + data.driver_name + ' ' + data.driver_l_name + ' (' + data.plate_number + ')' + '&nbsp;</div>'
                        }
                    },
                    {data: 'planned_passengers'},
                    {data: 'actual_passengers'},
                    {
                        data: null,
                        orderable: false,
                        render: function (data) {
                            if(data.role == 'admin' || data.role == 'operator'){
                                if(data.status == 'created' || data.status == 'assign_request_declined'){
                                    if (data.is_guard_required){
                                        return '<a id="guards_list_manifest" href="/trips/guards_list?trip_id=' + data.id + '" data-remote="true">Assign Guard</a>&nbsp;&nbsp;&nbsp;<a href="#" id="complete_with_exception" class="text-danger" data-trip_id="' + data.id + '">Complete With Exception</a>'    
                                    }
                                    else{
                                        return '<a href="#" class="text-primary" id="assign_driver" type="button" data-dismiss="modal" aria-hidden="true" data-trip_id="' + data.id + '">Assign Driver</a>&nbsp;&nbsp;&nbsp;<a href="#" id="complete_with_exception" class="text-danger" data-trip_id="' + data.id + '">Complete With Exception</a>'
                                    }
                                }
                                else if(data.status == 'accepted' || data.status == 'assigned' || data.status == 'assign_request_expired' || data.status == 'assign_requested'){
                                    return '<a href="#" class="text-primary" id="assign_driver" type="button" data-dismiss="modal" aria-hidden="true" data-trip_id="' + data.id + '">Change Driver</a>&nbsp;&nbsp;&nbsp;<a href="#" id="complete_with_exception" class="text-danger" data-trip_id="' + data.id + '">Complete With Exception</a>'
                                }
                                else{
                                    return ''
                                }
                            }
                            else if(data.role == 'employer'){
                                if(data.status == 'created' || data.status == 'assign_request_declined'){
                                    if (data.is_guard_required){
                                        return '<a id="guards_list_manifest" href="/trips/guards_list?trip_id=' + data.id + '" data-remote="true">Assign Guard</a>'    
                                    }
                                    else{
                                        return ''
                                    }                                    
                                }
                                else{
                                    return ''
                                }
                            }
                            else{
                                return ''
                            }
                        }
                    }
                ],
                initComplete: function () {                    
                    loadedDatatables[table] = true;
                    var info = this.api().page.info();
                    $('#assigned-trips-count').text("Total Assigned Trips: " + info.recordsTotal);                    
                },
                drawCallback: function(){
                    if(!dateSet){
                        $("#manifest-date").val('SELECT DATE')
                        $("#manifest-time").val('SELECT TIME')
                    }
                    var info = this.api().page.info();
                    if(info.recordsTotal == 0){
                        $("#auto-assign-driver").addClass('disabled-default');
                        $("#auto-assign-guard").addClass('disabled-default');
                    }
                    else{
                        $("#auto-assign-driver").removeClass('disabled-default');
                        $("#auto-assign-guard").removeClass('disabled-default');
                    }
                }
            });
        }

        // Init datepicker
        $('#manifest-date').daterangepicker({
          timePicker: false,
          singleDatePicker: true,
          applyClass: 'btn-primary',
          locale: {
            format: 'DD/MM/YYYY'
          }
        },
        function (start) {            
            setDate(start)
        });

        // Init timepicker
        $('#manifest-time').daterangepicker({
          timePicker: true,
          applyClass: 'btn-primary',
          timePickerIncrement: 30,
          autoUpdateInput: true,
          startDate: moment().startOf('day'),
          endDate: moment().endOf('day'),
          locale: {
            format: 'h:mm A'
          }
        });

        setDateTimeListeners();

        $('#manifest-trip-direction').on('change', function () {
            direction = +$(this).val();
            $('#clear-filters').css("display","block");
            operatorAssignedTripsTable.draw()
        });

        $('#manifest-trip-status').on('change', function () {
            status = +$(this).val();
            $('#clear-filters').css("display","block");
            operatorAssignedTripsTable.draw()
        });

        $('#manifest-bus-cab').on('change', function () {
            bus_rider = +$(this).val();
            $('#clear-filters').css("display","block");
            operatorAssignedTripsTable.draw()             
        });

        $('#manifest-table_search').on('click', function(e){
            search = $('#manifest-table_search_value')[0].value
            $('#clear-filters').css("display","block");
            operatorAssignedTripsTable.draw()
        })

        $("#manifest-table_search_value").keypress(function(e) {
            if(e.which == 13) {
              $('#manifest-table_search').click();
            }
        });        

    });

    function setDateTimeListeners() {
      $('#manifest-date').focusin(function(){
          $('.calendar-table').css("display","block");
      });

      $('#manifest-date').focusout(function(e){
          if(startDate == ''){
              if($("#manifest-date").val() == moment().format("DD/MM/YYYY")){
                  setDate(moment())
              }
          }
      });        

      $('#manifest-time').focusin(function(){
          $('.calendar-table').css("display","none");
      });

      $('#manifest-time').on('hide.daterangepicker', function(){
          if(startDate.split(" ").length == 1){
              $('#manifest-time').val('SELECT TIME')
              // $('#manifest-time').val(moment().startOf('day').format("h:mm A") + ' - ' + moment().endOf('day').format("h:mm A"))
          }
          else{
              $('#manifest-time').val(startDate.split(" ")[1] + ' ' + startDate.split(" ")[2] + ' - ' + endDate.split(" ")[1] + ' ' + endDate.split(" ")[2])
          }
      });

      $('#manifest-time').on('apply.daterangepicker', function(ev, picker) {  
          if(startDate != ''){
              startDate = moment(startDate, "DD-MM-YYYY").format("DD/MM/YYYY") + " " + picker.startDate.format('h:mm A');
          }
          if(endDate != ''){
              endDate = moment(endDate, "DD-MM-YYYY").format("DD/MM/YYYY") + " " + picker.endDate.format('h:mm A');
          }
          startTime = picker.startDate.format('h:mm A')
          endTime = picker.endDate.format('h:mm A')

          $('#manifest-time').val(picker.startDate.format('h:mm A') + ' - ' + picker.endDate.format('h:mm A'))
          $('#clear-filters').css("display","block");
          operatorAssignedTripsTable.draw()
      });      
    }

    function setDate(start){
        dateSet = true
        if(startTime == ''){
            startDate = moment(start).startOf('day').format('DD/MM/YYYY h:mm A')
        }
        else{
            startDate = moment(start).format('DD/MM/YYYY') + ' ' + startTime
        }
        if(endTime == ''){
            endDate = moment(start).endOf('day').format('DD/MM/YYYY h:mm A')
        }
        else{
            endDate = moment(start).format('DD/MM/YYYY') + ' ' + endTime
        }
        $('#clear-filters').css("display","block");
        operatorAssignedTripsTable.draw()            
    }

    $(document).on('click', '#guards_list_manifest', function(e){
        document.getElementById('overlay_manifest').style.display = 'block';
    })

    $(document).on('show.bs.modal', '#modal-rosters-guards-assignment', function(e){
        setTimeout(function(){ 
            document.getElementById('overlay_manifest').style.display = 'none';  
        }, 500);        
    })

    /**
     * Unassign a already assigned driver
     */
    $(document).on('click', '#unassign_driver_submit', function (e) {
        e.preventDefault();
        var driverId = $(this).data( "driver_id" );
        var tripId = $(this).data( "trip_id" );
        $('#modal-trip-info').modal('hide');

        $.ajax({
            type: "POST",
            data: {driver_id: driverId},
            url: '/trips/' + tripId + '/unassign_driver_submit'
        }).done(function () {
            updateDataTables();
            // operatorAssignedTripsTable.row($(this).parents('tr')).remove().draw();
        })
    });    

    $(document).on('click', '#assign_driver', function (e) {
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
            if(operatorAssignedTripsTable != null && operatorAssignedTripsTable != undefined) {
                var rowData = operatorAssignedTripsTable.row({selected: true}).data();                

                tripInfoMarkersData = {
                    site: {lat: rowData.site_lat, lng: rowData.site_lng},
                    data: []
                };

                if (rowData.status === 'completed' || rowData.status === 'cancel') {
                    tripInfoMarkersData.type = 'employee-basic'
                }
                setTripInfoMarkersData(rowData);
            }
        })
    });    

    /**
     * Init map
     */

    $(document).on('click', '#open-map', function(e){
        $('#trip-board-driver-info').attr("style", "visibility: hidden; z-index:0; position:fixed");
        $('#trip-board-map-info').attr("style", "visibility: visible; z-index:1; position: relative");
    })

    $(document).on('click', '#close-map', function(e){
        $('#trip-board-driver-info').attr("style", "visibility: visible; z-index:1; position:relative");
        $('#trip-board-map-info').attr("style", "visibility: hidden; z-index:0; position:fixed");
    })

    $(document).on('click', '#clear-filters', function(e){
        startDate = '',
        endDate = '',
        startTime = '',
        endTime = '',
        direction = 2,
        bus_rider = 2,
        status = 6,
        search = '';
        dateSet = false;
        // $('#manifest-time').val(moment().startOf('day').format("h:mm A") + ' - ' + moment().endOf('day').format("h:mm A"))
        $('#manifest-time').val('SELECT TIME')
        $('#manifest-date').val('')
        $('#manifest-trip-directionSelectBoxItText').text("DIRECTION")
        $('#manifest-bus-cabSelectBoxItText').text("MODE")
        $('#manifest-trip-statusSelectBoxItText').text("TRIP STATUS")
        $('#clear-filters').css("display","none");

        // Init datepicker
        $('#manifest-date').daterangepicker({
          timePicker: false,
          singleDatePicker: true,
          applyClass: 'btn-primary',
          locale: {
            format: 'DD/MM/YYYY'
          }
        },
        function (start) {            
            setDate(start)
        });

        // Init timepicker
        $('#manifest-time').daterangepicker({
          timePicker: true,
          applyClass: 'btn-primary',
          timePickerIncrement: 30,
          autoUpdateInput: true,
          startDate: moment().startOf('day'),
          endDate: moment().endOf('day'),
          locale: {
            format: 'h:mm A'
          }
        });

        setDateTimeListeners();
        operatorAssignedTripsTable.draw();
    })
    
    var operatorAssignedTripsMapID = 'map-operator-assigned-trips';

    if ($('#map-operator-assigned-trips').length) {
        maps[operatorAssignedTripsMapID] = Gmaps.build('Google', {markers: {clusterer: undefined}});

        maps[operatorAssignedTripsMapID].buildMap({
            internal: {
                id: operatorAssignedTripsMapID
            },
            provider: mapProviderOpts
        });
    }

    // init unassigned rosters table in modal
    var operatorUnassignedRosterTable;
    $(document).on('show.bs.modal', '#modal-operator-unassigned-rosters', function () {
        if (!$.fn.DataTable.isDataTable('#operator-unassigned-roster-table')) {
            operatorUnassignedRosterTable = $('#operator-unassigned-roster-table').DataTable({
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

        // enable modal footer buttons
        // operatorUnassignedRosterTable.on('select', function () {
        //     $('#assign-roster, #delete-roster').removeClass('disabled-default');
        // });

        // disable modal footer buttons
        // operatorUnassignedRosterTable.on('deselect', function () {
        //     if (operatorUnassignedRosterTable.rows({selected: true}).count() == 0) {
        //         $('#assign-roster, #delete-roster').addClass('disabled-default');
        //     }
        // });
    });

    // show markers on map
    $(table).on('click', '.map-picker-ico a', {
        mapId: operatorAssignedTripsMapID,
        table: $(table)
    }, showRouteMarkersData);

  var auto_assign_driver_errors_table = $('#auto-assign-driver-errors').DataTable({
    ordering: false,
    paging: false,
    info: false,
    searching: false,
    columns: [{
      name: 'Manifest ID',
      data: 'trip_id'
    }, {
      name: 'Error',
      data: 'error'
    }]
  });

  $('#auto-assign-driver').on('click', function() {
    document.getElementById('overlay_manifest').style.display = 'block';
    $.ajax({
      type: 'POST',
      url: '/trips/auto_assign_driver'
    }).done(function (res) {
      document.getElementById('overlay_manifest').style.display = 'none';
      operatorAssignedTripsTable.draw();

      $('#modal-auto-assign-driver-summary').modal('show');

      $('#auto-assign-driver-total-count').text(res.data.total_trips_count);
      $('#auto-assign-driver-error-count').text(res.data.errors_count);

      auto_assign_driver_errors_table.clear();
      auto_assign_driver_errors_table.rows.add(res.data.errors);
      auto_assign_driver_errors_table.draw();
    });
  });

  var auto_assign_guard_errors_table = $('#auto-assign-guard-errors').DataTable({
    ordering: false,
    paging: false,
    info: false,
    searching: false,
    columns: [{
      name: 'Manifest ID',
      data: 'trip_id'
    }, {
      name: 'Error',
      data: 'error'
    }]
  });

  $('#auto-assign-guard').on('click', function() {
    document.getElementById('overlay_manifest').style.display = 'block';
    $.ajax({
      type: 'POST',
      url: '/trips/auto_assign_guard'
    }).done(function (res) {
      document.getElementById('overlay_manifest').style.display = 'none';
      operatorAssignedTripsTable.draw();

      $('#modal-auto-assign-guard-summary').modal('show');

      $('#auto-assign-guard-total-count').text(res.data.total_trips_count);
      $('#auto-assign-guard-error-count').text(res.data.errors_count);

      auto_assign_guard_errors_table.clear();
      auto_assign_guard_errors_table.rows.add(res.data.errors);
      auto_assign_guard_errors_table.draw();
    });
  });  
});