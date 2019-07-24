$(function () {
    'use strict';

    // set notification options
    toastr.options = {
        iconClasses: {
            error: 'bg-danger',
            info: 'bg-info',
            success: 'bg-primary',
            warning: 'bg-warning'
        },
        "closeButton": true,
        "newestOnTop": true,
        "progressBar": false,
        "tapToDismiss": false,
        "timeOut": "0",
        "extendedTimeOut": "0"
    };

    this.App || (this.App = {});

    App.cable = ActionCable.createConsumer();

    var user = $('.profile-username');
    var openedRows = {};
    
    if (user.length > 0) {
        App.message = App.cable.subscriptions.create({
            channel: 'NotificationsChannel',
            user_id: user.data('user-id')
        }, {
            received: function (data) {
                // show notification depend on message type
                switch (data.type) {
                    case 'panic':
                    case 'employee_no_show':
                    case 'driver_no_show':
                    case 'car_break_down':
                    case 'car_broken_down':
                    case 'car_ok_pending':
                    case 'car_break_down_trip':
                    case 'not_on_board':
                    case 'still_on_board':
                        toastr.options.timeOut = 0;
                        toastr.options.extendedTimeOut = 0;
                        toastr.error(data.message);
                        break;
                    case 'on_leave':
                    case 'on_leave_trip':
                        toastr.options.timeOut = 0;
                        toastr.options.extendedTimeOut = 0;                    
                        toastr.warning(data.message);
                        break;
                    case 'trip_completed':
                    case 'driver_started_trip':
                        toastr.options.timeOut = 20000;
                        toastr.options.extendedTimeOut = 0;                    
                        toastr.success(data.message);
                        break;

                    default:
                        toastr.info(data.message);
                }

                updateDataTables();
            }
        });
    }

    /**
     * Init table
     */
    var table = '#trips-notifications-table';
    var tripsNotificationsTable = $();

    var startDate = '',
        endDate = '',
        origStartDate = moment().format('DD/MM/YYYY'),
        startTime = '',
        endTime = '',
        direction = 2,
        bus_rider = 2,
        status = 6,
        search = '';
    var dateSet = false;

    $('a[href="#trips-notifications"]').on('shown.bs.tab', function (e) {
        // $.ajax({
        //     type: "POST",
        //     url: '/notifications/1/mark_notifications_as_old'
        // }).done(function() {
        //     $("#new-notification").addClass('hidden');
        // });

        if (!loadedDatatables[table]) {

            tripsNotificationsTable = $(table).DataTable({
                destroy: true,
                serverSide: true,
                ajax: {
                    url: "/notifications",
                    data: function (d) {
                        d.startDate = startDate,
                        d.endDate = endDate,
                        d.bus_rider = bus_rider,
                        d.direction = direction,
                        d.trip_status = status,
                        d.search = search
                    }
                },
                lengthChange: false,
                searching: false,
                pagingType: "simple_numbers",
                paging: true,
                info: false,
                processing: true,
                ordering: false,
                autoWidth: false,
                pageLength: 15,
                columns: [
                    {
                        className: 'details-control text-center',
                        data: null,
                        width: '20px',
                        render: function(data){
                            if(data.last_notification.length == 0){
                                return '<i></i>';
                            }
                            return '<i class="fa fa-plus"></i>';
                        }
                    },                
                    {   
                        data: null,
                        className: 'full-height',
                        render: function(data){
                            return '<div style="float:left; padding: 8px 12px; width:100%; height:100%"><a href="" id="view-trip-modal" data-trip-id="' + data.trip_id + '" data-remote="true">' + data.roster_name + '</a></div>'
                        }
                    },
                    {data: 'created_at'},
                    // {
                    //     data: null,
                    //     render: function(data) {
                    //         var result = '';
                    //         return getReporter(data);
                    //         // if (data.driver_phone != '') {
                    //         //     if ((data.message == "Car Broke Down On Trip" || data.message == "Driver on Leave - Assigned Trip")) {
                    //         //         result += '<div style="float:left">' + data.driver_name + '</div>'  + ' <div style="float:right"><a href="#"><img id="call-person" data-number="' + data.driver_phone + '"src = "/assets/phonePrimary.svg"></a></div>'
                    //         //     } else {
                    //         //         result += '<div style="float:left">' + data.driver_name + '</div>'  + ' <div style="float:right"><a href="#"><img id="call-person" data-notification-id="' + data.id + '" data-number="' + data.driver_phone + '"src = "/assets/phonePrimary.svg"></a></div>'
                    //         //     }
                    //         // }
                    //         // return result;
                    //     }
                    // },
                    {data: 'reporter'},
                    {data: 'display_message'},                   
                    {
                        data: null,
                        render: function (data) {
                            if(data.role == 'operator' || data.role == 'admin'){
                                var result = '';
                                result += getCTA(data);
                                return result;
                            }   
                            return ""                         
                        }
                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                    // var info = this.api().page.info();
                    // $('#notification-count').text("Total Notifications: " + info.recordsTotal);
                }, 
                rowCallback: function (row, data) {
                    var className = getClassForNotification(data);
                    $("td:eq(1)",row).addClass(className);
                    
                    if(data.badge_count == 0) {
                        $("#badge-unresolved-notification").addClass('hidden');
                    } else {
                        $("#badge-unresolved-notification").text(data.badge_count);
                        $("#badge-unresolved-notification").removeClass('hidden');
                    }                    
                }, 
                drawCallback: function(){                 
                    //show already opened rows
                    $(table).DataTable().rows().every( function () {
                        var tr = $(this.node());
                        var id = tr[0].id;
                        if(id != undefined && openedRows[id] != undefined && openedRows[id] != null && openedRows[id] == 1){
                            tr.addClass('selected');
                            tr.css('background-color', 'white')
                            tr.find('i')[0].className = 'fa fa-minus';                            
                            var row = tripsNotificationsTable.row(tr);
                            row.child(format(row.data()), 'no-padding').show();
                        }
                    }); 
                    if(!dateSet){
                        $("#notification-date").val('SELECT DATE')
                        $("#notification-time").val('SELECT TIME')
                    }                  
                }
            });
        }

        $(table).off('click', 'tr td.details-control'); 
        // show child rows
        $(table).on('click', 'tr td.details-control', function () {
            onRowDetailsClick.call(this, table);
        });


        // Init datepicker
        $('#notification-date').daterangepicker({
          timePicker: false,
          singleDatePicker: true,
          applyClass: 'btn-primary',
          locale: {
            format: 'DD/MM/YYYY'
          }
        },
        function (start) {
          setNotificationDate(start)
        });

        // Init timepicker
        $('#notification-time').daterangepicker({
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

        setDateTimeListener();

        $('#notification-trip-direction').on('change', function () {
            direction = +$(this).val();
            tripsNotificationsTable.draw()

            $('#notification-clear-filters').css("display","block");
        });

        $('#notification-trip-status').on('change', function () {
            status = +$(this).val();
            tripsNotificationsTable.draw()

            $('#notification-clear-filters').css("display","block");
        });

        $('#notification-bus-cab').on('change', function () {
            bus_rider = +$(this).val();
            tripsNotificationsTable.draw()             

            $('#notification-clear-filters').css("display","block");
        });

        $('#notification-table_search').on('click', function(e){
            search = $('#notification-table_search_value')[0].value
            tripsNotificationsTable.draw()
            $('#notification-clear-filters').css("display","block");
        })

        $("#notification-table_search_value").keypress(function(e) {
            if(e.which == 13) {
              $('#notification-table_search').click();              
            }
        });  

        $(document).on('click', '#notification-clear-filters', function(e){
            startDate = '',
            endDate = '',
            startTime = '',
            endTime = '',
            startTime = '',
            endTime = '',
            direction = 2,
            bus_rider = 2,
            status = 6,
            search = '';
            dateSet = false;
            $('#notification-time').val('SELECT TIME')
            $('#notification-date').val('')
            $('#notification-trip-directionSelectBoxItText').text("DIRECTION")
            $('#notification-bus-cabSelectBoxItText').text("MODE")
            $('#notification-trip-statusSelectBoxItText').text("TRIP STATUS")
            $('#notification-clear-filters').css("display","none");

            // Init datepicker
            $('#notification-date').daterangepicker({
              timePicker: false,
              singleDatePicker: true,
              applyClass: 'btn-primary',
              locale: {
                format: 'DD/MM/YYYY'
              }
            },
            function (start) {
              setNotificationDate(start)
            });

            // Init timepicker
            $('#notification-time').daterangepicker({
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

            setDateTimeListener();
            tripsNotificationsTable.draw();
        })

    });

    function setDateTimeListener() {
      $('#notification-date').focusin(function(){
          $('.calendar-table').css("display","block");
      });

      $('#notification-date').focusout(function(e){
          if(startDate == ''){
              if($("#notification-date").val() == moment().format("DD/MM/YYYY")){
                  setDate(moment())
              }
          }
      });        

      $('#notification-time').focusin(function(){
          $('.calendar-table').css("display","none");
      });

      $('#notification-time').on('hide.daterangepicker', function(){
          if(startDate.split(" ").length == 1){
              $('#notification-time').val('SELECT TIME')
              // $('#notification-time').val(moment().startOf('day').format("h:mm A") + ' - ' + moment().endOf('day').format("h:mm A"))
          }
          else{
              $('#notification-time').val(startDate.split(" ")[1] + ' ' + startDate.split(" ")[2] + ' - ' + endDate.split(" ")[1] + ' ' + endDate.split(" ")[2])
          }
      });

      $('#notification-time').on('apply.daterangepicker', function(ev, picker) {  
          if(startDate != ''){
              startDate = moment(startDate, "DD-MM-YYYY").format("DD/MM/YYYY") + " " + picker.startDate.format('h:mm A');
          }
          if(endDate != ''){
              endDate = moment(endDate, "DD-MM-YYYY").format("DD/MM/YYYY") + " " + picker.endDate.format('h:mm A');
          }
          startTime = picker.startDate.format('h:mm A')
          endTime = picker.endDate.format('h:mm A')

          $('#notification-time').val(picker.startDate.format('h:mm A') + ' - ' + picker.endDate.format('h:mm A'))
          $('#clear-filters').css("display","block");
          tripsNotificationsTable.draw()
      });    
    }

    function setNotificationDate(start){
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
        $('#notification-clear-filters').css("display","block");
        tripsNotificationsTable.draw()            
    }

    function onRowDetailsClick(table){
        var tr = $(this).closest('tr');
        var id = tr[0].id;
        var row = tripsNotificationsTable.row(tr);
        if(row.data().last_notification.length == 0)                
            return;
        
        if (row.child.isShown()) {
            // This row is already open - close it
            row.child.hide();
            tr.removeClass('selected');
            $(this).find('i').removeClass('fa fa-minus');
            $(this).find('i').addClass('fa fa-plus');
            openedRows[id] = 0;
        }
        else {
            // Open this row
            row.child(format(row.data()), 'no-padding').show();
            tr.addClass('selected');
            tr.css('background-color', 'white')
            $(this).find('i').removeClass('fa fa-plus');
            $(this).find('i').addClass('fa fa-minus');
            openedRows[id] = 1;
        }
    }

    function getClassForNotification(data){
        if(data.resolved_status){
            return;
        }
        else if(data.message == 'driver_didnt_accept_trip' || data.message == 'trip_should_start' || data.message == 'car_break_down' || data.message == 'car_broken_down' || data.message == 'car_ok_pending' || data.message == 'vehicle_ok' || data.message == 'panic' || data.message == "not_on_board" || data.message == "still_on_board" || data.message == 'employee_no_show' || data.message == 'female_first_or_last_in_trip' || data.message == 'female_exception_driver_unassigned' || data.message == 'trip_not_started' || data.message == 'female_exception_female_removed' || data.message == 'car_break_down_driver_unassigned'){
            return 'bg-notification'
        }
        else if(data.message == 'out_of_geofence_check_in' || data.message == 'out_of_geofence_drop_off' || data.message == 'out_of_geofence_driver_arrived' || data.message == 'out_of_geofence_missed' || data.message == 'out_of_geofence_check_in_site' || data.message == 'out_of_geofence_drop_off_site' || data.message == 'out_of_geofence_driver_arrived_site' || data.message == 'out_of_geofence_missed_site' || data.message == 'employee_no_show_approved' || data.message == 'female_exception_route_resequenced' || data.message == 'book_ola_uber' || data.message == 'driver_over_speeding'){
            return 'bg-notification-yellow'
        }
    }

    function getCTA(elem){
        var result = '';
        if(elem.resolved_status){
            result += '<td style="width:20%">&nbsp;</td>';
        }
        else{
            if(elem.message == 'female_exception_route_resequenced' || elem.message == 'female_exception_female_removed') {
                result += '<td style="width:20%"><a id="call-person" class="remove text-danger" href="#" data-notification-id="' + elem.id + '" data-number="' + elem.employee_phone + '">Call Female Employee</a></td>';
            }
            else if(elem.message == 'panic' || elem.message == "not_on_board" || elem.message == "still_on_board" || elem.message == 'employee_no_show_approved'){
                result += '<td style="width:20%"><a id="call-person" class="remove text-danger" href="#" data-notification-id="' + elem.id + '" data-number="' + elem.employee_phone + '">Call Passenger</a></td>';
            }
            else if(elem.message == "employee_no_show"){
                result += '<td style="width:20%"><a style="cursor:pointer" id="move_to_next_step" class="remove text-danger" data-notification-id=' + elem.id + '>Move To Next Step</a></td>';   
            }
            else if (elem.message == 'car_break_down') {
                result += '<td style="width:20%"><a id="car-break-down" class="remove text-danger" href="#" data-request_id="' + elem.driver_request_id + '" data-approve="1">Approve</a> / <a id="car-break-down" class="remove text-danger" href="#" data-request_id="' + elem.driver_request_id + '" data-approve="0">Decline</a></td>';
            }
            else if (elem.message == 'driver_didnt_accept_trip' || elem.message == 'trip_not_started') {
                result += '<td style="width:20%"><a id="call-person" class="remove text-danger" href="#" data-number="' + elem.driver_phone + '" data-notification-id=' + elem.id + '">Call Driver</a> / <a id="assign_driver" class="remove text-danger" href="#" data-trip_id="' + elem.trip_id + '">Change Driver</a></td>';
            }
            else if (elem.message == 'car_break_down_driver_unassigned') {
                result += '<td style="width:20%"><a id="assign_driver" class="remove text-danger" href="#" data-trip_id="' + elem.trip_id + '">Change Driver</a></td> / <a id="book-ola-uber" class="remove text-danger" href="#" data-trip_id="' + elem.trip_id + '" data-driver_id="' + elem.driver_id + '">Book Ola Uber</a> ';
            }
            else if(elem.message == 'trip_should_start' || elem.message == 'out_of_geofence_check_in' || elem.message == 'out_of_geofence_drop_off' || elem.message == 'out_of_geofence_driver_arrived' || elem.message == 'out_of_geofence_missed' || elem.message == 'out_of_geofence_check_in_site' || elem.message == 'out_of_geofence_drop_off_site' || elem.message == 'out_of_geofence_driver_arrived_site' || elem.message == 'out_of_geofence_missed_site'){
                result += '<td style="width:20%"><a id="call-person" class="remove text-danger" href="#" data-number="' + elem.driver_phone + '" data-notification-id=' + elem.id + '">Call Driver</a></td>';
            }
            else if(elem.message == 'book_ola_uber'){
                result += '<td style="width:20%"><a class="remove text-danger" id="view-trip-modal" href="" data-trip-id=' + elem.trip_id + '" data-remote="true" data-method="GET">Enter Ola/Uber Cost</a></td>';
            }
            else if(elem.message == 'female_first_or_last_in_trip' || elem.message == 'female_exception_driver_unassigned'){
                result += '<td style="width:20%"><a class="remove text-danger" href="/trips/guards_list?trip_id=' + elem.trip_id + '" data-remote="true" data-method="GET">Add Guard</a></td>';
            }        
            else{
                result += '<td style="width:20%">&nbsp;</td>';
            }
        }
        return result;
    }

    function getReporter(elem){
        if(elem.message == 'panic' || elem.message == "not_on_board" || elem.message == "still_on_board"){
            return ' <div class="call-div bg-primary" style="display:inline-block"><a style="position:relative; top:2px; left:3px" href="#" id="call-person" data-number="' + elem.employee_phone + '" data-notification-id="' + elem.id + '"><svg width="13px" height="14px" viewBox="0 0 13 14" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">'+
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
'</svg></a></div> Passenger: ' + elem.employee_name;
        }
        else if(elem.message == 'employee_no_show' || elem.message == 'car_break_down' || elem.message == 'vehicle_ok'){
            return ' <div class="call-div bg-primary" style="display:inline-block"><a style="position:relative; top:2px; left:3px" href="#" id="call-person" data-number="' + elem.driver_phone + '" data-notification-id=' + elem.id + '"><svg width="13px" height="14px" viewBox="0 0 13 14" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">'+
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
'</svg></a></div> Driver: ' + elem.driver_name;   
        }
        else{
            return '--'
        }
    }

    /**
     * Format Data function for DataTable
     * @param d
     * @returns {string}
     */
    function format(d) {
        var notification = '';

        d.last_notification.forEach(function (elem, i) {
            notification +=
                '<tr style="background-color:#F1F6F9">' +
                '<td style="width:5%">' + '</td>' +
                '<td style="width:20%">' + '</td>' +
                '<td style="width:15%">' + elem.created_at + '</td>' +
                '<td style="width:15%">' + elem.reporter + '</td>' +
                '<td style="width:25%">' + elem.display_message + '</td>';

                notification += getCTA(elem);
                notification += '</tr>';
        });

        return '<table class="table table-bordered child-table">' +
            '<tbody>' + notification + '</tbody></table>';
    }

  $(document).on("click", "#move_to_next_step", function() {
    $.ajax({
        type: "POST",
        url: '/notifications/' + $(this).data("notification-id") + '/move_driver_to_next_step',
    success:  function(response) {
            updateDataTables();
        updateTripBoard();
    }
    });
  })

    $(document).on('click', '#view-trip-modal', function (e) {
        e.preventDefault();
        var tr = $(this).closest('tr');
        var id = tr[0].id;
        var row = tripsNotificationsTable.row(tr);
        var tripId = $(this).data("trip-id");
        $.ajax({
            type: "GET",
            url: '/trips/' + tripId + '/trip_details',
            success: function(result){
                setTripInfoMarkersData(result);
                $.ajax({
                    type: "GET",
                    url: '/trips/' + tripId + '/',
                    success: function(){
                        //do nothing            
                    }
                })
            }
        })
    });

    $(document).on('click', '#book-ola-uber', function (e) {
        e.preventDefault();
        var driverId = $(this).data("driver_id");
        var tripId = $(this).data("trip_id");
        console.log(driverId)
        console.log(tripId)
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
    });   


    $(document).on('click', '#car-break-down', function (e) {
        e.preventDefault();
        var approve = $(this).data("approve");
        var requestId = $(this).data("request_id");
        $.ajax({
            type: "POST",
            data: {
                request_id: requestId,
                approve: approve
            },
            url: '/vehicles/vehicle_break_down_approve_decline'
        }).done(function () {
            updateDataTables();
            updateTripBoard();
        }); 
    });        

    // delete row
    // $(table).on('click', '.remove', function (e) {
    //     e.preventDefault();
    //     var notificationID = $(this).data('notification-id');

    //     $.post('/notifications/' + notificationID + '/archive').done(function (r) {
    //         if (r) {
    //             tripsNotificationsTable.row($(this).closest('tr')).remove().draw(false);
    //         }
    //     });
    // });
});