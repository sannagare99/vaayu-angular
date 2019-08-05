$(function () {
  var $timeline = $('#driver-schedule-timeline');  

  var groups = [];
  var items = new vis.DataSet();
  var female = false;
  var cabs = false;
  var logistics_company_id = 0;

  // get timeline data from server
  var $loader = $('<div class="timeline-loading"><div class="loader-spinner"></div></div>');
  $timeline.append($loader);

  setTimeout(function () {
    $loader.remove();
  }, 1000);

  window.updateTripBoard = function() {
    // check if element exist
    if ($timeline.length) {

      groups = [];
      items = new vis.DataSet();

      $.post(
        "/trips/drivers_timeline", {"female": female, "cabs": cabs, "logistics_company_id": logistics_company_id}
      ).done(function (r) {
        table = ''   
        groups.push({
          id: -1,
          order: -1,
          name: "Driver Name",
          license: "License Plate",
          seats: "Seats",
          content: '<div class="op-board" data-status=Seats><span>Seats</span><span>License Plate</span><span>Driver Name</span></div>'
        });     
        if (!$.isEmptyObject(r)) {
          if(!r.data.length){
            r.data.push({
              id: 0,
              name: "Driver Name",
              plate_number: "License Plate",
              seats: "Seats",
              trips: [],
              content: '<div class="op-board" data-status=Seats><span>Seats</span><span>License Plate</span><span>Driver Name</span></div>'
            })
          }

          // set group data          
          r.data.forEach(function (driver, index) {
            if(driver.trips.length != 0){
              groups.push({
                id: index,
                order: index,
                name: driver.name,
                license: driver.plate_number,
                seats: driver.seats,
                content: '<div class="op-board" data-status='+driver.seats+'><span style="padding-left:10px">'+driver.seats+'</span><span style="padding-left:20px">'+driver.plate_number+'</span><span>'+driver.name+'</span></div>'
              });

              // set items data
              driver.trips.forEach(function (trip) {
                var notifyStatus = popoverContent(trip)
                items.add({
                  id: trip.id,
                  group: index,
                  content: '<a style="cursor:pointer" id="open-modal" type="button" class="trip-info" data-toggle="popover" data-trigger="hover" data-trip_id='+ trip.id + ' data-content="'+ tripNotifications[notifyStatus] +'">' + trip.name + '</a>',
                  start: trip.date,
                  end: checkEndDate(trip),
                  className: getNotificationClass(notifyStatus, trip)
                })
              });
            }            
          });

          initTimeline();
        } 
        else {
          $timeline.append('<p>No trips available.</p>')
        }

      });
    }
    $timeline.html(""); 
  }

  function formatString(text, length){
    if(text.length >= length){
      return text;
    }
    else{
      var dummy = new Array(length).join(' ');
      text = text + dummy;
      return text.substr(0, length);
    }
  }

  function checkEndDate(trip){
    if(trip.status == 'active' && moment(trip.end_date).isBefore(new Date())){
      return new Date();
    }
    else{
      return trip.end_date;
    }
  }
  
  $.get(
    "/logistics_companies/get_all"
  ).done(function(result){
    if(result.logistics_company_id != null){
      logistics_company_id = result.logistics_company_id
    }
    else{
      if($("#select_operators")[0] != undefined){
        for(var i = 0; i < result.logistics_companies.length; i++){
          $("#select_operators").data("selectBox-selectBoxIt").add({value: result.logistics_companies[i].id, text: result.logistics_companies[i].name})      
        }
      }      
    }      
    window.updateTripBoard();
  })  

  // redraw datatables
  setInterval(function () {
    updateTripBoard();
  }, 60000);

  /**
   * Init timeline
   */
  function initTimeline() {
    var container = document.getElementById('driver-schedule-timeline');
    var date = new Date()
    var options = {
      selectable: false,
      zoomable: false,
      min: moment().subtract(6, 'hour').startOf('hour'),
      max: moment().add(6, 'hour').endOf('hour'),
      timeAxis: {scale: 'minute', step: 30},
      start: new Date().setHours(date.getHours() - 2, date.getMinutes() - 15),
      end: new Date().setHours(date.getHours() + 2, date.getMinutes() + 15),
      orientation: 'top',
      format: {
        minorLabels: {hour: 'hA'}
      }
    };

    var timeline = new vis.Timeline(container);
    timeline.setOptions(options);
    timeline.setGroups(groups);
    timeline.setItems(items);
  }

  function popoverContent(trip){
    for(var notification in trip.notifications){
      if(trip.notifications[notification]==null) {
        return trip.status;
      }
      if(!trip.notifications[notification].resolved_status){
        return trip.notifications[notification].message
      }
    }
    return trip.status
  }

  // set timeline trip items bar color via class
  function getNotificationClass(notifyStatus, trip) {    
    var type = findNotificationType(notifyStatus);    
    type = type != '' ? type : getClassByStatus(trip.status);
    return type
  }

  function findNotificationType(status) {
    // notification depend on message type    
    switch (status) {
      case 'panic':
      case 'employee_no_show':
      case 'driver_no_show':
      case 'car_break_down':
      case 'car_broken_down':
      case 'car_ok_pending':
      case 'car_broke_down_trip':
      case 'not_on_board':
      case 'still_on_board':
      case 'driver_didnt_accept_trip':
      case 'trip_should_start':
      case 'vehicle_ok':
      case 'female_first_or_last_in_trip':
      case 'first_pickup_delayed':
      case 'site_arrival_delay':
      case 'employee_changed_trip':
      case 'trip_not_started':
      case 'female_exception_driver_unassigned':
      case 'female_exception_female_removed':
      case 'car_break_down_driver_unassigned':      
        return 'error-trip'
        break;
      case 'on_leave':
      case 'on_leave_trip':
      case 'out_of_geofence_check_in':
      case 'out_of_geofence_drop_off':
      case 'out_of_geofence_driver_arrived':
      case 'out_of_geofence_missed':
      case 'out_of_geofence_check_in_site':
      case 'out_of_geofence_drop_off_site':
      case 'out_of_geofence_driver_arrived_site':
      case 'out_of_geofence_missed_site':      
      case 'female_exception_route_resequenced':
      case 'book_ola_uber':
      case 'employee_no_show_approved':
      case 'driver_over_speeding':
        return 'warning-trip'
        break;
      case 'driver_started_trip':
      case 'driver_face_detection':
      case 'trip_completed':
      case 'driver_accepted_trip':
      case 'operator_assigned_trip':
      case 'complete_with_exception':
      case 'operator_created_trip':
      case 'driver_arrived_login':
      case 'driver_on_board_login':
      case 'driver_dropped_employee_logout':
      case 'reassigned_trip':
      case 'employee_canceled_trip':
      case 'employee_canceled_trip_auto_approved':
      case 'cancel_request_approved':
      case 'employee_changed_trip_auto_approved':
      case 'change_request_approved':
      case 'call_employee':
      case 'call_driver':
      case 'guard_added':
      case 'car_break_down_approved':
      case 'car_break_down_declined':      
      case 'driver_arrived_check_in':
      case 'driver_arrived_check_out':
      case 'employee_on_board_check_in':
      case 'employee_on_board_check_out':
      case 'employee_drop_off_check_in':
      case 'employee_drop_off_check_out':
      case 'completed_with_exception':
      case 'driver_called_employee':
      case 'employee_called_driver':                                
        return 'completed-trip'
        break;
      default:
        return ''
    }
  }

  function getClassByStatus(status){
    switch(status){
      case 'unassigned':
      case 'assign_requested':
        return 'resolved-trip'
        break;
      case 'assigned':
      case 'active':
        return 'active-trip'
        break;
      case 'assign_request_expired':
      case 'canceled':
        return 'completed-trip'
        break;
      case 'completed':
        return 'completed-trip'
        break;
      default :
        return ''
    }
  }

  var tripNotifications = {
    "not_accepted_manifest": "Driver didn't Accepted Manifest",
    "employer_planned_trip": "Employer planned trip",
    "driver_started_trip": "Trip started by Driver",
    "employee_no_show": "Employee No Show: %{employee_name}",
    "employee_no_show_no_approval_required": "Employee No Show(Auto Approved): %{employee_name}",
    "passanger_no_show": "Passanger No Show",
    "driver_no_show": "Driver No Show",
    "not_on_board": "I'm not on board",
    "panic": "Panic",
    "still_on_board": "I'm still in the car",
    "trip_completed": "Trip completed",
    "out_of_geofence": "Driver out of Geofence",
    "out_of_geofence_check_in": "Out-of-geofence - pickup",
    "out_of_geofence_drop_off": "Out-of-geofence - dropoff",
    "out_of_geofence_driver_arrived": "Out-of-geofence - driver arrived",
    "out_of_geofence_missed": "Out-of-geofence - no show",
    "out_of_geofence_check_in_site": "Out-of-geofence - pickup",
    "out_of_geofence_drop_off_site": "Out-of-geofence - dropoff",
    "out_of_geofence_driver_arrived_site": "Out-of-geofence - driver arrived",
    "out_of_geofence_missed_site": "Out-of-geofence - no show",    
    "car_broke_down": "Car Broke Down",
    "car_broken_down": "Car Broken Down",
    "car_ok_pending": "Car OK Requested",
    "vehicle_ok": "Vehicle OK Now",
    "car_broke_down_trip": "Car Broke Down On Trip",
    "on_leave": "Driver Leave Request",
    "cancel_leave": "Driver Cancel Leave Request",
    "on_leave_trip": "Driver on Leave - Assigned Trip",
    "driver_didnt_accept_trip": "Trip not accepted",
    "trip_should_start": "Trip Should Start",
    "complete_with_exception": "Complete With Exception",
    "operator_assigned_trip": "Trip Assigned",
    "driver_accepted_trip": "Driver accepted the Trip",
    "female_first_or_last_in_trip": "Female first / last exception",
    "book_ola_uber": "Book Ola/Uber",
    "operator_created_trip": "Trip Created",
    "driver_arrived_check_in": "Arrived at Employee Location",
    "driver_arrived_check_out": "Arrived at Site Name",
    "employee_on_board_check_in": "Picked Up Employee",
    "driver_face_detection" : "Driver Face Detection"
    "employee_on_board_check_out": "Picked Up Employee",
    "employee_drop_off_check_in": "Dropped Off at Site",
    "employee_drop_off_check_out": "Dropped Off Employee Name",
    "reassigned_trip": "Re-try Trip assignment",
    "employee_canceled_trip_auto_approved": "Ride Canceled(Auto Approved)",
    "employee_canceled_trip": "Ride Canceled",
    "cancel_request_approved": "Cancel request approved",
    "employee_changed_trip_auto_approved": "Ride Canceled(Auto Approved)",
    "employee_changed_trip": "Ride Canceled",
    "change_request_approved": "Change request approved",
    "annotate_trip": "Remarks Added",
    "completed_with_exception": "Trip completed with exception",
    "trip_not_started": "Trip not started",
    "employee_no_show_approved": "Employee No Show Approved",
    "driver_called_employee": "Call Employee",
    "employee_called_driver": "Call Driver",
    "guard_added": "Guard added to Trip",
    "female_exception_driver_unassigned": "Driver Unassigned due to Female Exception",
    "female_exception_route_resequenced": "Female Exception: handled by re-sequencing",
    "female_exception_female_removed": "Female Exception: Employee removed from active Trip",
    "car_break_down": "Car Break Down",
    "car_break_down_approved": "Car Break Down: Approved",
    "car_break_down_declined": "Car Break Down: Declined",
    "car_break_down_driver_unassigned": "Car Break Down: Driver Unassigned",
    "employee_deleted_from_trip": "Employee Removed",
    "active": "Active Trip",
    "completed": "Completed Trip",
    "assigned": "Assigned Trip",
    "canceled": "Completed with Exception",
    "assign_requested": "Trip Requested",
    "assign_request_expired": "Trip Request Expired",
    "driver_over_speeding": "Driver Over Speeding"
  }

  //popover for new items inserted onto timeline
  $(document).on('DOMNodeInserted', '.vis-foreground .vis-group', function(){
    var $this = $(this).find('.trip-info')
    if($this) {
      template = '<div class="popover trips"><div class="arrow"></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"><p></p></div></div></div>';
      $this.popover({
        placement: 'top',
        template: template,
        html: true,
        title: '',
        content: '<div> ' + $this.data('content') + '</div>',
        container: 'body'
      });
    }
  })

  $(document).on('dblclick', '#open-modal', function(e){
    var tripId = $(this).data("trip_id");
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
  })

  $(document).on('click', '#open-map', function(e){
    $('#trip-board-driver-info').attr("style", "visibility: hidden; z-index:0; position:fixed");
    $('#trip-board-map-info').attr("style", "visibility: visible; z-index:1; position: relative");
  })

  $(document).on('click', '#close-map', function(e){
    $('#trip-board-driver-info').attr("style", "visibility: visible; z-index:1; position:relative");
    $('#trip-board-map-info').attr("style", "visibility: hidden; z-index:0; position:fixed");
  })

  $(document).on('click', '#trip_board_all_employees', function(e){
    $('#trip_board_all_employees').removeClass('bg-white');
    $('#trip_board_female_trips').removeClass('bg-cloud');
    $('#trip_board_all_employees').addClass('bg-cloud');
    $('#trip_board_female_trips').addClass('bg-white');

    female = false;
    updateTripBoard();
  })

  $(document).on('click', '#trip_board_female_trips', function(e){
    $('#trip_board_female_trips').removeClass('bg-white');
    $('#trip_board_all_employees').removeClass('bg-cloud');
    $('#trip_board_female_trips').addClass('bg-cloud');
    $('#trip_board_all_employees').addClass('bg-white');

    female = true;
    updateTripBoard();
  })

  $(document).on('click', '#trip_board_all_type', function(e){
    $('#trip_board_all_type').removeClass('bg-white');
    $('#trip_board_cab').removeClass('bg-cloud');
    $('#trip_board_all_type').addClass('bg-cloud');
    $('#trip_board_cab').addClass('bg-white');

    cabs = false;
    updateTripBoard();
  })

  $(document).on('click', '#trip_board_cab', function(e){
    $('#trip_board_cab').removeClass('bg-white');
    $('#trip_board_all_type').removeClass('bg-cloud');
    $('#trip_board_cab').addClass('bg-cloud');
    $('#trip_board_all_type').addClass('bg-white');

    cabs = true;
    updateTripBoard();
  })

  $('#select_operators').on('change', function () {    
    logistics_company_id = +$(this).val();
    updateTripBoard();
  });
    
  var tripModalHandler = function() {
    var tripId = $(this).data("trip_id")
    $('#modal-trip-info').modal('hide')

    $.ajax({
      type: "GET",
      url: '/trips/' + tripId + '/',
      success: function(){
        $(document).one('click', '.trip-info', tripModalHandler)
      }
    })
    return false
  }

  // $(document).one('click', '.trip-info', tripModalHandler)

  // hide popover by clicking outside
  $(document).on('click', function (e) {
    $('.btn-trip-info').each(function () {
      if (!$(this).is(e.target) && $(this).has(e.target).length === 0) {
        var data = $(this).popover('hide').data('bs.popover')
        if(data) {data.inState.click = false}
      }
    });
  });

});
