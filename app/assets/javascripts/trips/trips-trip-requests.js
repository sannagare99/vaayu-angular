var tripRequestEditor;
$(function () {
  'use strict';

  var selectedRows = {};
  var selectedClusterRows = {};
  var clusterMapping = {};
  var innerTable = {}
  var responseMessage = ''
  var employee_trips_array = []
  var individual_trips = []
  var selectedMarkersData = {};
  var firstDirection = ''
  var firstBusRide = ''
  var mapping = {'Check in' : '0', 'check_in' : '0', 'Check out' : '1', 'check_out' : '1', 'BUS' : 'true', 'CAB' : 'false'};
  var reverseMapping = {'0' : 'Check in', '1' : 'Check out', 'true' : 'BUS', 'false' : 'CAB'};
  var count = 0;
  var origTime = '';
  var finalTime = '';
  var tripOrderUpdated = false;
  var addPassengerSelected = {}; 
  var date = '';
  var trip_type = ''
  var bus_rider = ''
  var available_seats = ''
  var employee_cluster_id = ''
  var employee_trips_mapping = {}
  var female_exception = false
  var check_in_shift_times = []
  var check_out_shift_times = []
  var shift_times = []
  var innerTableData = {}
  var datestring = ''

  $('#prev-date-value').text(moment().subtract(1, 'day').format('DD/MM/YYYY'))
  $('#next-date-value').text(moment().add(1, 'day').format('DD/MM/YYYY'))

  $('#prev-date').on('click', function(e){
    selectedRows = {};
    $('#trip-time').val('')    
    startDate = $('#prev-date-value').text()

    $('#trip-date').data('daterangepicker').setStartDate(startDate);
    $('#trip-date').data('daterangepicker').setEndDate(startDate);

    $('#trip-date').val(startDate)
    $('#prev-date-value').text(moment(startDate, "DD/MM/YYYY").subtract(1, 'day').format('DD/MM/YYYY'))
    $('#next-date-value').text(moment(startDate, "DD/MM/YYYY").add(1, 'day').format('DD/MM/YYYY'))
    var time = moment().format("DD/MM/YYYY h:mm A").split(" ")
    startDate = startDate + " " + time[1] + " " + time[2]
    origStartDate = moment(startDate, "DD/MM/YYYY h:mm A").format("MM-DD-YYYY")
    endDate = ''
    document.getElementById('overlay').style.display = 'block';
    get_first_shift(false)
  })

  $('#queue-table_search').on('click', function(e){
    search = $('#queue-table_search_value')[0].value
    employeeTripRequestTable.draw();
    employeeTripRequestClusterTable.draw();
  })

  $("#queue-table_search_value").keypress(function(e) {
    if(e.which == 13) {
      $('#queue-table_search').click();
    }
  });  

  $('#next-date').on('click', function(e){
    selectedRows = {};
    $('#trip-time').val('')    
    startDate = $('#next-date-value').text()

    $('#trip-date').data('daterangepicker').setStartDate(startDate);
    $('#trip-date').data('daterangepicker').setEndDate(startDate);

    $('#trip-date').val(startDate)
    $('#prev-date-value').text(moment(startDate, "DD/MM/YYYY").subtract(1, 'day').format('DD/MM/YYYY'))
    $('#next-date-value').text(moment(startDate, "DD/MM/YYYY").add(1, 'day').format('DD/MM/YYYY'))
    var time = moment().format("DD/MM/YYYY h:mm A").split(" ")
    startDate = startDate + " " + time[1] + " " + time[2]
    origStartDate = moment(startDate, "DD/MM/YYYY h:mm A").format("MM-DD-YYYY")
    endDate = ''
    document.getElementById('overlay').style.display = 'block';
    get_first_shift(false)
  })

  var dateSet = false;
  var origStartDate = moment().format('MM-DD-YYYY');
  var startDate = moment().format('DD/MM/YYYY h:mm A'),
  endDate = '',
  direction = '',
  bus_rider = '',
  search = '';
  

  function get_first_shift(reinit){
    $.ajax({
        type: "GET",
        url: '/employee_trips/first_shift',
        data: {
          'startDate': startDate   
        }
    }).done(function (response) {
        direction = mapping[response.trip_type];
        firstDirection = direction;
        if(response.bus_rider == undefined){
          bus_rider = 0
          firstBusRide = bus_rider
        }
        else{
          bus_rider = response.bus_rider == false ? 0 : 1  
          firstBusRide = bus_rider
        }
        if(response.trip_time != undefined){
          startDate = moment(response.trip_time).format('DD/MM/YYYY h:mm A')  
        }
        else{
          startDate = moment().format('DD/MM/YYYY h:mm A')
        }
        endDate = ''
        if(reinit){
          initEmployeeTripRequestTable()
          initEmployeeTripRequestClusterTable()  
        }
        else{
          employeeTripRequestTable.draw();
          employeeTripRequestClusterTable.draw();       
        }
    });  
  }


  var table = '#employee-trip-request-table';
  var employeeTripRequestTable = $();

  var clusterTable = '#employee-trip-request-cluster-table';
  var employeeTripRequestClusterTable = $();

  var addPassengerTable = '#add-passenger-table';
  var addPassengerClusterTable = $();

  var employeeTrMarkersData = [];
  var employeeTrMapID = 'map-employee-trip-requests';

  // var confirmTable = '#trip-roster-confirm-table';
  // var tripRosterConfirmTable = $();

  function composeFinalTime(){
    var startDateArray = startDate.split(" ")
    var endDateArray = []
    if(finalTime == ''){
      if(startDateArray.length == 3){
        if(endDate != ''){
          endDateArray = endDate.split(" ")
          finalTime = startDateArray[1] + " " + startDateArray[2] + " - " + endDateArray[1] + " " + endDateArray[2]
        }
        else{
          finalTime = startDateArray[1] + " " + startDateArray[2]
        }  
      }
      else{
        if(endDate != ''){
          endDateArray = endDate.split(" ")
          finalTime = startDateArray[0] + " " + startDateArray[1] + " - " + endDateArray[1] + " " + endDateArray[2]
        }
        else{
          finalTime = startDateArray[0] + " " + startDateArray[1]
        }
      }
    }
  }

  function changeFilter(){
    composeFinalTime()
    $('#trip-time').val(finalTime)
    $('#trip-direction').find('option[value="' + direction + '"]').prop('selected',true).trigger('change');
    $('#bus-cab').find('option[value="' + bus_rider + '"]').prop('selected',true).trigger('change');

    validateButtons()
  }

  function setShiftTimes(){
    if(direction == 0){
      shift_times = check_in_shift_times
    }
    else{
      shift_times = check_out_shift_times
    }

    tripRequestEditor = new $.fn.dataTable.Editor({    
      ajax: {
        edit: {
          type: 'PUT',
          url: '/employee_trips/_id_'
        }
      },
      table: table,
      fields: [
      {
        className: "date mask-date",
        name: "date",
        attr: {
          placeholder: 'Date'
        }
      },
      {
        name: "datetime",
        type: "select",
        className: "tooltip-dropdown",
        options: shift_times,
        attr: {
          placeholder: 'Time'
        }
      }]
    });
  
    //add custom class to bubble modal
    tripRequestEditor.on('open', function (e, mode, action) {
      $('div.DTE_Bubble').addClass('modal-tr-time-edit');
    });
  }

  function formatDistance(distance) {
    if (distance > 1000) {
      return (distance / 1000).toFixed(2) + ' kms';
    } else {
      return distance.toFixed(2) + ' meters';
    }
  }

  function formatDuration(duration) {
    return moment.duration(duration, 'seconds').humanize();
  }

  function getRouteInfo(points, res) {
    var route = 'trips' in res ? res.trips[0] : res.routes[0];
    var distance = parseFloat(route.distance),
        duration = parseFloat(route.duration);
    return {
      emp_count: points.length - 1,
      distance: distance,
      formattedDistance: formatDistance(distance),
      duration: duration,
      formattedDuration: formatDuration(duration)
    };
  }

  function renderRouteInfo(points, res) {
    var routeInfo = getRouteInfo(points, res);
    $('#map-cluster-info')
      .find('.emp-count')
        .text(routeInfo.emp_count)
        .end()
      .find('.trip-distance')
        .text(routeInfo.formattedDistance)
        .end()
      .find('.trip-duration')
        .text(routeInfo.formattedDuration)
        .end();
  }

  var routeResponses = [];
  function renderIncrementalRouteInfo(points, res) {
    routeResponses.push({points: points, response: res})
    var routeInfoSummary = {
      emp_count: 0,
      distance: 0,
      duration: 0
    };
    routeResponses.forEach((routeResponse) => {
      var routeInfo = getRouteInfo(routeResponse.points, routeResponse.response);
      routeInfoSummary = {
        emp_count: routeInfoSummary.emp_count + routeInfo.emp_count,
        distance: routeInfoSummary.distance + routeInfo.distance,
        duration: routeInfoSummary.duration + routeInfo.duration
      };
    })
    $('#map-cluster-info')
      .find('.emp-count')
        .text(routeInfoSummary.emp_count)
        .end()
      .find('.trip-distance')
        .text(formatDistance(routeInfoSummary.distance))
        .end()
      .find('.trip-duration')
        .text(formatDuration(routeInfoSummary.duration))
        .end();
  }

  function clearRouteInfo() {
    $('#map-cluster-info')
      .find('.emp-count')
        .text('-')
        .end()
      .find('.trip-distance')
        .text('-')
        .end()
      .find('.trip-duration')
        .text('-')
        .end();
  }

  function renderQueueRoute() {
    var elem;
    var points = [];
    removePolylines(employeeTrMapID);
    for(var key in selectedRows) {
      elem = selectedRows[key];
      points.push({
        lat: elem.lat,
        lng: elem.lng,
        distance_to_site: elem.distance_to_site
      });
    }
    points = points.sort((a, b) => {
      return a.distance_to_site > b.distance_to_site ? 1 : -1
    })
    if (points.length) {
      points.push({lat: elem.site_lat, lng: elem.site_lng});
      osrm_client
        .getTrip(points, {overview: 'full'})
        .then(function(res) {
          let pts = google
            .maps
            .geometry
            .encoding
            .decodePath(res.trips[0].geometry)
            .map((p) => {
              return {lat: p.lat(), lng: p.lng()}
            });
          renderRouteInfo(points, res);
          addPolyline(employeeTrMapID, elem.id, pts, {
            strokeColor: elem.color,
          });
        })
        .fail(function(res) {
          var error = res.responseJSON;
          console.log('OSRM Call failed', error.message);
        });
    }
  }

  function markerClickHandler(markerData) {
    if (/nodal/i.test(markerData.infowindow)) {
      employeeTrMarkersData.filter((et) => {
        return et.lat === markerData.lat && et.lng === markerData.lng;
      }).forEach((et) => {
        var trId = '#empltrip-' + et.id;
        var row = employeeTripRequestTable.rows(trId);
        if ($(row.nodes()).is('.selected')) {
          row.deselect();
        } else {
          row.select();
        }
      });
    } else {
      var trId = '#empltrip-' + markerData.id;
      var row = employeeTripRequestTable.rows(trId);
      if ($(row.nodes()).is('.selected')) {
        row.deselect();
      } else {
        row.select();
      }
    }
  }

  function addEmployeeMarkers() {
    employeeTrMarkersData = [];
    removeMapMarkers(employeeTrMapID);
    var data = employeeTripRequestTable.rows().data().toArray();
    data.forEach((elem, index) => {
      employeeTrMarkersData[index] = {
        id: elem.id,
        lat: elem.lat,
        lng: elem.lng
      };
      if (/nodal/i.test(elem.status)) {
        $.extend(employeeTrMarkersData[index], {
          infowindow: 'Nodal Point: ' + elem.address
        });
      } else {
        $.extend(employeeTrMarkersData[index], {
          infowindow: getEmployeeInfo(elem)
        });
      }
    });
    if (data.length) {
      employeeTrMarkersData.push({
        type: 'site-marker',
        lat: data[0].site_lat,
        lng: data[0].site_lng,
        infowindow: data[0].site
      });
    }
    if (mapsLoaded[employeeTrMapID]) {
      addMapMarkers(employeeTrMapID, employeeTrMarkersData, '', markerClickHandler);
    }
  }


  function initEmployeeTripRequestTable() {
    employeeTripRequestTable = $(table).DataTable({
      serverSide: true,
      ajax: {
        url: "/employee_trips",
        data: function (d) {
          d.startDate = startDate;
          d.endDate = endDate;
          d.direction = direction;
          d.search = search;
          d.bus_rider = bus_rider;
        }
      },
      lengthChange: false,
      searching: false,
      paging: false,
      info: false,        
      autoWidth: false,
      processing: true,
      ordering: false,
      select: {
        style: 'multi',
        selector: 'td:last-child'
      },
      columns: [
        {data: "status"},
        {
          data: null,
          render: function(data, type, row) {
            if(data.original_date) {
              return '<p style="color:grey; font-size:10px; margin:0px">Orig. ' + data.original_date +'</p><p data-employee_trip=' + data.id + ' class="text-teal">' + data.datetime + ' ' + data.date + '</p>'
            } 
            else {
              return '<div data-employee_trip=' + data.id + ' class="text-teal" style="cursor:pointer">' + data.datetime + ' ' + data.date + '</div>'
            }              
            // if orig date present return above statement else return below statement
            // return '<p class="text-teal"> + data.datetime + ' ' + data.date + </p>'
          },
          editField: ["date", "datetime"]
        },
        {data: "trip_type"},
        {
          data:null,
          render: function(data, type, row) {
            return '<div style="overflow: hidden; max-width:90px; text-overflow:ellipsis; white-space: no-wrap">' + data.site + '</div>'
          }
        },
        {
          data: null,
          render: function (data, type, row) {
            return getEmployeeName(data.employee_name, data.employee_l_name, data.phone, data.employee_id)
          },
          className: 'overflow-scroll'
        },
        {
          data: 'sex',
          className: 'text-center'
        },
        {
          data: null,
          render: function(data, type, row){
            return '<p style="max-width:140px; white-space:nowrap; margin-bottom:0px; overflow-x:scroll">' + data.area + '</p>'
          }
        },
        {data: 'message'},
        {
          data: null,
          render: function(data, type, row) {
            if(data.current_user.role == "line_manager" || !data.is_approver)
              return ''
            if(data.status == "Change" || data.status == "Cancel" || data.status == "New trip") {
              return '<a href="#" data-request-id="' + data.request_id + '" data-type="approve" class="update_request text-danger">Approve</a>&nbsp;&nbsp;<a href="#" data-request-id="' + data.request_id + '" data-type="decline" class="update_request text-teal">Cancel</a> '
            } else {                
              return ''
            }
          }
        }
      ],
      initComplete: function () {
        loadedDatatables[table] = true;
        employeeTripRequestTable.column(0).visible(false);
        employeeTripRequestTable.column(2).visible(false);
        employeeTripRequestTable.column(7).visible(false);
      },
      rowCallback: function (row, data) {
        var autoClusteredRows = data.selected_zone;
        var index = $.inArray(data.DT_RowId, autoClusteredRows);          
        if (index !== -1) {
          employeeTripRequestTable.row(row).select();
          if (!selectedRows.hasOwnProperty(data.DT_RowId)) {
            selectedRows[data.DT_RowId] = data
          }
        }
      }, 
      drawCallback: function(){
        setShiftTimes()

        tripOrderUpdated = false;

        if($(table).DataTable().rows()[0].length == 0){
          $(this).parent().hide();
          finalTime = ''
          // if(finalTime == ''){
          //   finalTime = startDateArray[1] + " " + startDateArray[2]
          // }
        }
        else{
          $(this).parent().show();
          if(endDate == ''){
            finalTime = employeeTripRequestTable.rows(0).data()[0].datetime
            // var time = employeeTripRequestTable.rows(0).data()[0].datetime
            // time = time.split(":")
            // var hour = time[0]
            // var minute = time[1]
            // if(parseInt(hour) > 12){
            //   finalTime = (parseInt(hour) - 12) + ':' + minute + ' PM'
            // }
            // else{
            //   finalTime = hour + ':' + minute + ' AM' 
            // }
          }
          else{
            finalTime = ''
            composeFinalTime()
          }            
          $(table).DataTable().rows().every( function (row) {
              var tr = $(this.node());
              var id = tr[0].id;                
              var status = employeeTripRequestTable.row("#" + id).data().status;
              var current_user = employeeTripRequestTable.row("#" + id).data().current_user;
              // firstDirection = employeeTripRequestTable.row("#" + id).data().trip_type;
              // firstBusRide = employeeTripRequestTable.row("#" + id).data().bus_rider != undefined ? 'BUS' : 'CAB';
              if(current_user.role == "line_manager") {
                if(row == 0) {
                  employeeTripRequestTable.column(0).visible(true);
                  employeeTripRequestTable.column(2).visible(true);
                  employeeTripRequestTable.column(7).visible(true);
                  employeeTripRequestTable.column(6).visible(false);
                }                
                tr.find('td:last').addClass('checkbox-select');
                tr.find('td:last').addClass('text-primary');
              } 
              else {
                if(!(status == "Change" || status == "Cancel" || status == "New trip")) {
                    tr.find('td:last').addClass('checkbox-select');
                    tr.find('td:last').addClass('text-primary');
                }
              }
          });                      
        }
        // origTime = finalTime;
        // $('#trip-time').val(finalTime)        
        document.getElementById('overlay').style.display = 'none';
        count = count + 1;
        if(count == 2){
          changeFilter()
        }
      }
    });

    // add markers on table redraw
    employeeTripRequestTable.on('draw.dt', function () {
      $('#auto-cluster').text('Cluster');
      $('#auto-cluster').data('action', 'cluster');

      setShiftTimes();

      addEmployeeMarkers();

      if (mapsLoaded[employeeTrMapID]) {
        for(var key in selectedRows) {
          selectMarker(employeeTrMapID, selectedRows[key].id);
        }
        renderQueueRoute();
      }
      validateButtons();
    });

    // select markers on map
    employeeTripRequestTable.on('select', function (e, dt, type, indexes) {
      tripOrderUpdated = true;
      employeeTripRequestClusterTable.rows().deselect();
      var rowData = employeeTripRequestTable.rows(indexes).data().toArray();
      rowData.forEach(function (elem) {
        if(mapsLoaded[employeeTrMapID]){
          selectMarker(employeeTrMapID, elem.id);
        }
      });
    });

    // table row select event
    employeeTripRequestTable.on('select', function (e, dt, type, indexes) {
      $('#auto-cluster').text('Cluster');
      $('#auto-cluster').data('action', 'cluster');

      tripOrderUpdated = true;
      var rowData = employeeTripRequestTable.row(indexes).data();
      var index = $.inArray(rowData.DT_RowId, selectedRows);
      if (index === -1) {
        selectedRows[rowData.DT_RowId] = rowData;
      }
      renderQueueRoute();
      validateButtons();
    });

    // table row deselect event
    employeeTripRequestTable.on('deselect', function (e, dt, type, indexes) {
      tripOrderUpdated = true;
      var rowID = employeeTripRequestTable.row(indexes).data().DT_RowId;
      delete selectedRows[rowID];
      renderQueueRoute();
      clearRouteInfo();
      validateButtons();
    });

    // deselect markers
    employeeTripRequestTable.on('deselect', function (e, dt, type, indexes) {      
      tripOrderUpdated = true;
      $('.ch-all').closest('tr').removeClass('selected')
      var rowData = employeeTripRequestTable.rows(indexes).data().toArray();
      rowData.forEach(function (elem) {
        if(mapsLoaded[employeeTrMapID])
          deselectMarker(employeeTrMapID, elem.id);
      });
    });
  };


  $(table).on('click', 'thead th:last-child', function (e) {
    validateButtons()
  });   

  
  $(table).on('click', 'tbody td:nth-child(1)', function (e) {
    var that = this
    var employee_trip = $(this)[0].firstChild.dataset.employee_trip
    $.ajax({
        type: "POST",
        url: '/employee_trips/unique_shifts',
        data: {
          'employee_trip': employee_trip
        }
    }).done(function (response) {    
      check_in_shift_times = response.check_in_shifts
      check_out_shift_times = response.check_out_shifts
      
      setShiftTimes()

      try{
        tripRequestEditor.bubble(that);
      }
      catch(e){
        console.log(e)
      }
    })
  });   

  $(table).on('click', 'tbody td:nth-child(2)', function (e) {
    var that = this
    var employee_trip = $(this)[0].firstChild.dataset.employee_trip
    $.ajax({
        type: "POST",
        url: '/employee_trips/unique_shifts',
        data: {
          'employee_trip': employee_trip
        }
    }).done(function (response) {    
      check_in_shift_times = response.check_in_shifts
      check_out_shift_times = response.check_out_shifts
      
      setShiftTimes()

      try{
        tripRequestEditor.bubble(that);
      }
      catch(e){
        console.log(e)
      }
    })
  });

  function renderClusterRoutes() {
    removePolylines(employeeTrMapID);
    routeResponses = [];
    Object.keys(selectedClusterRows).forEach((key, index) => {
      if(mapsLoaded[employeeTrMapID]){
        var elem = selectedClusterRows[key];
        var points = elem.employee_trips.slice(0);
        if (/check.in/i.test(elem.trip_type)) {
          points.push({lat: elem.site_lat, lng: elem.site_lng});
        } else {
          points.unshift({lat: elem.site_lat, lng: elem.site_lng});
        }
        osrm_client
          .getRoute(points, {overview: 'full'})
          .then(function(res) {
            let pts = google
              .maps
              .geometry
              .encoding
              .decodePath(res.routes[0].geometry)
              .map((p) => {
                return {lat: p.lat(), lng: p.lng()}
              });
            renderIncrementalRouteInfo(points, res)
            addPolyline(employeeTrMapID, elem.employee_cluster_id, pts, {
              strokeColor: elem.color,
            });
          })
          .fail(function(res) {
            var error = res.responseJSON;
            console.log('OSRM Call failed', error.message);
          });
      }
    });
  }

  function initEmployeeTripRequestClusterTable(){
    employeeTripRequestClusterTable = $(clusterTable).removeAttr('width').DataTable({
      serverSide: true,
      ajax: {
        url: "/employee_trips/get_clusters",
        data: function (d) {
          d.startDate = startDate;
          d.endDate = endDate;
          d.direction = direction;
          d.search = search;
          d.bus_rider = bus_rider;
        }
      },
      lengthChange: false,
      searching: false,
      paging: false,
      info: false,        
      autoWidth: false,
      processing: true,
      ordering: false,
      select: {
        style: 'multi',
        selector: 'td:first-child'
      },
      columns: [
        {
          data: null,
          className: 'dt-col1',
          render: function(data, type, row) {
            return '<div style="font-weight:600; color:black"># ' + data.trip_id + '</div>' 
          }
        },
        {
          data: null,
          className: 'dt-col2',
          render: function(data, type, row) {
            return '<div style="font-weight:600">' + data.date +'</div>'              
          },
          editField: ["date"]
        },
        {
          data:null,
          className: 'dt-col3',
          render: function(data, type, row) {
            return '<div style="overflow: hidden; text-overflow:ellipsis; white-space: no-wrap; font-weight:600">' + data.site + '</div>'
          }
        },
        {
          data: null,
          className: 'dt-col4',
          render: function(data, type, row) {
            return '<div style="font-weight:600">' + data.trip_type + '</div>'
          }
        },
        {
          data:null,
          className: 'dt-col5',
          render: function(data, type, row){
            if(data.bus_rider){
              return '<div style="font-weight:600">' + data.bus_route_name + '</div>'
            }              
            return '<div style="font-weight:600">' + padDate(data.size) + ' <span style="font-size:11px; color:grey">Available seats: ' + parseInt(data.max_seats - data.employee_trips.length) + '</span></div>'
          }
        },
        {
          data:null,
          className: 'dt-col5',
          render: function(data, type, row){
            if(data.cluster_error && data.cluster_error != null){
              return '<div class="text-danger">' + data.cluster_error + '</div>'  
            }
            return '<div class="text-danger"></div>'
          }
        },
        {
          className: 'details-control text-center dt-col6 cursor-pointer',
          data: null,
          render: function(data){
            return '<i class="fa fa-chevron-right"></i>';
          }
        }
      ],
      initComplete: function () {
        loadedDatatables[clusterTable] = true;          
      },
      rowCallback: function (row, data, index) {
        data.color = colors[index % colors.length];
        var size = data.employee_trips.length + 1;
        if (size < data.max_seats) {
          size = data.max_seats;
        }

        // Sort employee_trips by route order to show the right sequence
        data.employee_trips = data.employee_trips.sort(function(a, b) {
          return a.route_order - b.route_order;
        });
        innerTableData[data.DT_RowId] = {
          'row_id': data.DT_RowId,
          'employee_trips': data.employee_trips,
          'current_user': data.current_user,
          'size': size,
          'trip_type': data.trip_type,
          'orig_date': data.orig_date,
          'employee_cluster_id': data.employee_cluster_id,
          'bus_rider': data.bus_rider
        }
        innerTable[data.DT_RowId] = format(
          data.DT_RowId,
          data.employee_trips,
          data.current_user,
          size,
          data.trip_type,
          data.orig_date,
          data.employee_cluster_id,
          data.bus_rider
        );
      }, 
      drawCallback: function(){
        tripOrderUpdated = false;
        if($(clusterTable).DataTable().rows()[0].length == 0){
          $(this).parent().hide();
        }
        else{
          $(this).parent().show();
          $(clusterTable).DataTable().rows().every(function (row) {
              var tr = $(this.node());
              tr.addClass('collapsed');
              tr.find('td:first').addClass('checkbox-select');
              tr.find('td:first').addClass('text-primary');
              tr.find('td:first').css({'padding-left':'40px'});
          });
        }
        count = count + 1;
        if(count == 2){
          changeFilter()
        }
      }
    });

    const colors = ['#1abc9c', '#f39c12','#2ecc71','#d35400','#3498db','#c0392b','#9b59b6','#7f8c8d']

    // add markers on table redraw
    employeeTripRequestClusterTable.on('draw.dt', function () {
      renderClusterRoutes();
      addEmployeeMarkers();
      var tableData = employeeTripRequestClusterTable.rows().data().toArray();
      if  (tableData.length) {
        $('#export-clusters').removeClass('hidden');
      } else {
        $('#export-clusters').addClass('hidden');
      }
      validateButtons()
    });

    employeeTripRequestClusterTable.on('select', function (e, dt, type, indexes) {
      // track selected row
      tripOrderUpdated = true;
      var rowData = employeeTripRequestClusterTable.row(indexes).data();
      var index = $.inArray(rowData.DT_RowId, selectedClusterRows);
      if (index === -1) {
        selectedClusterRows[rowData.DT_RowId] = rowData;
      }
      if (mapsLoaded[employeeTrMapID]) {
        var tr = $(employeeTripRequestClusterTable.rows(indexes).nodes());
        tr.find('.checkbox-select').removeClass('text-primary').css({
          color: colors[indexes[0] % colors.length]
        });
        var elem;
        employeeTrMarkersData = [];
        removeMapMarkers(employeeTrMapID);
        employeeTripRequestTable.rows().deselect();
        employeeTripRequestTable.rows().data().toArray().forEach((elem, index) => {
          employeeTrMarkersData[index] = {
            id: elem.id,
            lat: elem.lat,
            lng: elem.lng,
          };
          if (/nodal/i.test(elem.status)) {
            $.extend(employeeTrMarkersData[index], {
              infowindow: 'Nodal Point: ' + elem.address
            });
          } else {
            $.extend(employeeTrMarkersData[index], {
              infowindow: getEmployeeInfo(elem)
            });
          }
        });
        for(var key in selectedClusterRows) {
          elem = selectedClusterRows[key];
          elem.employee_trips.forEach(function(emp_trip, index) {
            employeeTrMarkersData.push({
              type: 'cluster-employee',
              id: elem.employee_cluster_id,
              lat: emp_trip.lat,
              lng: emp_trip.lng,
              color: elem.color,
              infowindow: getEmployeeInfo(emp_trip),
              label: index + 1,
            });
          });
        }
        employeeTrMarkersData.push({
          type: 'site-marker',
          lat: elem.site_lat,
          lng: elem.site_lng,
          infowindow: elem.site
        })
        addMapMarkers(employeeTrMapID, employeeTrMarkersData);
        for(var key in selectedClusterRows) {
          var cluster = selectedClusterRows[key];
          selectMarker(employeeTrMapID, cluster.employee_cluster_id, cluster.color);
        }
      }
      renderClusterRoutes();
      validateButtons();
    });

    // deselect markers
    employeeTripRequestClusterTable.on('deselect', function (e, dt, type, indexes) { 
      tripOrderUpdated = true;
      var rowData = employeeTripRequestClusterTable.rows(indexes).data().toArray();
      rowData.forEach(function (elem) {
        if(mapsLoaded[employeeTrMapID]){
          removeMapMarkersGroup(employeeTrMapID, elem.employee_cluster_id);
        }
      });
    });

    // table row deselect event
    employeeTripRequestClusterTable.on('deselect', function (e, dt, type, indexes) {
      tripOrderUpdated = true;
      // remove selected row from track
      var rowID = employeeTripRequestClusterTable.row(indexes).data().DT_RowId;
      delete selectedClusterRows[rowID];
      renderClusterRoutes();
      clearRouteInfo();
      var tr = $(employeeTripRequestClusterTable.rows(indexes).nodes());
      tr.find('.checkbox-select').addClass('text-primary');
      validateButtons();
    });
  }

  function onRowDetailsClick(table){
    var tr = $(this).closest('tr');
    var id = tr[0].id;
    var row = employeeTripRequestClusterTable.row(tr);
    if (row.child.isShown()) {
        // This row is already open - close it
        row.child.hide();
        $(this).find('i').removeClass('fa fa-chevron-down');
        $(this).find('i').addClass('fa fa-chevron-right');
        tr.addClass('collapsed');
    }
    else {
        // Open this row
        var row_id = row.data().DT_RowId
        innerTable[row_id] = format(row_id, row.data().employee_trips, innerTableData[row_id].current_user, innerTableData[row_id].size, innerTableData[row_id].trip_type, innerTableData[row_id].orig_date, innerTableData[row_id].employee_cluster_id, innerTableData[row_id].bus_rider)
        row.child(innerTable[row.data().DT_RowId], 'no-padding').show();  
        $(this).find('i').removeClass('fa fa-chevron-right');
        $(this).find('i').addClass('fa fa-chevron-down');
        tr.removeClass('collapsed');
    }
  }

  function getEmployeeInfo(elem) {
    return '<div>' +
      `<div>Name: <strong>${elem.employee_name} ${elem.employee_l_name}</strong></div>` +
      `<div>Emp ID: <strong>${elem.employee_id}</strong></div>` +
    '</div>';
  }

  function getEmployeeName(employee_name, employee_l_name, phone, employee_id){
    return ' <div class="call-div bg-primary" style="display:inline-block"><a style="position:relative; top:2px; left:3px" href="#" id="call-person" data-number="' + phone + '"><svg width="13px" height="14px" viewBox="0 0 13 14" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">'+
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
          '</svg></a></div><span style="padding-left:5px">' + employee_name + ' ' + employee_l_name + '<span style="color:grey"> (ID: ' + employee_id + ') </span></span>';      
  }

  /**
   * Format Data function for DataTable     
   */
  function format(row_id, employee_trips, current_user, size, trip_type, date, employee_cluster_id, bus_rider) {
    employee_trips_mapping[row_id] = employee_trips
    clusterMapping[row_id] = []
    var trip_type_value = 1
    var available_seats = size - employee_trips.length
    if(trip_type == 'Check in'){
      trip_type_value = 0
    }

    var className = ''
    if(current_user.role != "line_manager"){
      className = 'hidden'
    }
    var trip = '';
    var addPassengerFlag = false;

    for(var i = 0; i < size; i++){
      var elem = employee_trips[i];
      if(!elem){
        if (addPassengerFlag) {
          continue
        }
        trip += 
            '<tr>' +
            '<td></td>' +
            '<td style="text-transform: capitalize" class="hideable ' + className + '" ></td>' +
            '<td></td>' +
            '<td class="hideable ' + className + '" ></td>' +
            '<td></td>' +
            '<td></td>' +
            '<td class="hideable ' + className + '" ></td>' +
            '<td class="hideable ' + className + '" ></td>' +
            '<td id="addPassenger" class="text-teal" style="cursor:pointer" data-toggle="modal" data-target="#modal-add-passenger-cluster" data-date="' + date + '" data-trip-type="' + trip_type_value + '" data-bus_rider="' + bus_rider + '" data-available_seats="'+ available_seats + '" data-employee_cluster_id="' + employee_cluster_id + '">Add Passenger</td>' + 
            '<td></td>' +
            '</tr>';
        addPassengerFlag = true            
      }
      else{
        clusterMapping[row_id].push(elem.trip_id)
        if(elem.area == null || elem.area == undefined){
          elem.area = ''
        }
        if(elem.eta == null || elem.eta == undefined){
          elem.eta = ''
        }

        trip += 
            '<tr>' +
            '<td style="max-width:220px; overflow-x:auto">' + getEmployeeName(elem.employee_name, elem.employee_l_name, elem.phone, elem.employee_id) + '</td>' +
            '<td style="text-transform: capitalize" class="hideable ' + className + '" >' + elem.status + '</td>' +
            '<td>' + elem.date + '</td>' +
            '<td class="hideable ' + className + '" >' + elem.site + '</td>' +
            '<td>' + elem.sex + '</td>' +
            '<td>' + elem.area + '</td>' +
            '<td class="hideable ' + className + '" >' + elem.eta + '</td>' +
            '<td class="hideable ' + className + '" >' + elem.message + '</td>' +
            '<td id="removePassenger" class="text-danger" style="cursor:pointer" data-toggle="modal" data-target="#modal-confirm-remove" data-trip_date="' + elem.date + '" data-trip_employee_cluster_id="' + employee_cluster_id + '" data-bus_rider="' + bus_rider + '" data-trip_id="' + elem.trip_id + '">Remove</td>'

        if (i == 0){
          trip = trip + '<td style="text-align:center"><i style="cursor:pointer" class="fa fa-chevron-down sequencedowncluster" data-index="' + i + '" data-row_id="' + row_id + '" data-current_user="' + current_user + '" data-size="' + size + '" data-trip_type="' + trip_type + '" data-date="' + date + '" data-employee_cluster_id="' + employee_cluster_id + '" data-bus_rider="' + bus_rider + '"></i></td>'
        }
        else if(i == employee_trips.length - 1){
          trip = trip + '<td style="text-align:center"><i style="cursor:pointer" class="fa fa-chevron-up sequenceupcluster" data-index="' + i + '" data-row_id="' + row_id + '" data-current_user="' + current_user + '" data-size="' + size + '" data-trip_type="' + trip_type + '" data-date="' + date + '" data-employee_cluster_id="' + employee_cluster_id + '" data-bus_rider="' + bus_rider + '"></i></td>'
        }
        else{
          trip = trip + '<td style="text-align:center"><i style="cursor:pointer; padding-right:2px" class="fa fa-chevron-down sequencedowncluster" data-index="' + i + '" data-row_id="' + row_id + '" data-current_user="' + current_user + '" data-size="' + size + '" data-trip_type="' + trip_type + '" data-date="' + date + '" data-employee_cluster_id="' + employee_cluster_id + '" data-bus_rider="' + bus_rider + '"></i><i style="cursor:pointer; padding-left:2px" class="fa fa-chevron-up sequenceupcluster" data-index="' + i + '" data-row_id="' + row_id + '" data-current_user="' + current_user + '" data-size="' + size + '" data-trip_type="' + trip_type + '" data-date="' + date + '" data-employee_cluster_id="' + employee_cluster_id + '" data-bus_rider="' + bus_rider + '"></i></td>'
        }

        trip += '</tr>';
      }
    }

    var tableHtml = '<table id="inner_' + row_id + '" class="table table-bordered child-table">' +
                    '<thead>' + 
                      '<tr style="font-weight:600">' + 
                        '<td>Employee</td>' + 
                        '<td class="hideable ' + className + '" >Status</td>' +
                        '<td>Date</td>' +
                        '<td class="hideable ' + className + '" >Site</td>' +
                        '<td>Sex</td>' +
                        '<td>Area</td>' +
                        '<td class="hideable ' + className + '" >ETA</td>' +
                        '<td class="hideable ' + className + '" >Message</td>' +
                        '<td>Action</td>' +
                        '<td>Sequence</td>' +
                      '</tr>' + 
                    '</thead>' +
              '<tbody>' + trip + '</tbody></table>';


    return tableHtml    
  }

  $(clusterTable).off('click', 'tr td.details-control'); 
  // show child rows
  $(clusterTable).on('click', 'tr td.details-control', function () {
      onRowDetailsClick.call(this, clusterTable);
  });

  $('#modal-confirm-remove').on('show.bs.modal', function (e) {    
    var el = e.relatedTarget;
    var trip_id = $(el).data('trip_id');
    var trip_date = $(el).data('trip_date');
    var trip_employee_cluster_id = $(el).data('trip_employee_cluster_id');
    var bus_rider = $(el).data('bus_rider');
    $('#submit-remove-passenger').attr('data-trip_id', trip_id);
    $('#submit-remove-passenger').attr('data-trip_employee_cluster_id', trip_employee_cluster_id);
    $('#submit-remove-passenger').attr('data-trip_date', trip_date);
    $('#submit-remove-passenger').attr('data-bus_rider', bus_rider);
  })

  $('#submit-remove-passenger').on('click', function (e) {
    document.getElementById('overlay').style.display = 'block';
    $.ajax({
          type: "POST",
          url: '/employee_trips/' + $(this).data("trip_id") + '/remove_passenger',
          data: {
            'date': $(this).data("trip_date"),
            'bus_rider': $(this).data("bus_rider"),
            'employee_cluster_id': $(this).data("trip_employee_cluster_id"),
          }
      }).done(function () {
          employeeTripRequestTable.draw();
          employeeTripRequestClusterTable.draw();
          try {
            addPassengerClusterTable.draw()
          } catch(e) {}

          $('#submit-remove-passenger').removeData();
          $('#modal-confirm-remove').modal('toggle');
      });        
  })

  function padDate(val){
    if(val < 10){
      return '0' + val;
    }
    return val
  }

  $('#modal-add-passenger-cluster').on('show.bs.modal', function (e) {
    addPassengerSelected = {}; 
    var $el =  $(e.relatedTarget);
    date = $el.data('date');
    trip_type = $el.data('trip-type')
    bus_rider = $el.data('bus_rider')
    available_seats = $el.data('available_seats')
    employee_cluster_id = $el.data('employee_cluster_id')
    var d = new Date(date)
    datestring = d.getUTCFullYear()  + "-" + padDate(d.getUTCMonth()+1) + "-" + padDate(d.getUTCDate()) + " " + padDate(d.getUTCHours()) + ":" + padDate(d.getUTCMinutes()) + ":" + padDate(d.getUTCSeconds());
    
    if (!loadedDatatables[addPassengerTable]) {
       addPassengerClusterTable = $(addPassengerTable).DataTable({
        serverSide: true,
        ajax: {
          url: "/employee_trips/add_passengers",
          data: function (d) {
            d.date = datestring;
            d.trip_type = $el.data('trip-type');
            d.bus_rider = $el.data('bus_rider');
          }
        },
        lengthChange: false,
        searching: false,
        paging: false,
        info: false,        
        autoWidth: false,
        processing: true,
        ordering: false,
        select: {
          style: 'multi',
          selector: 'td:last-child'
        },
        columns: [
          {
            data: null,
            render: function (data, type, row) {
              return getEmployeeName(data.employee_name, data.employee_l_name, data.phone, data.employee_id);
            },
            className: 'dt-col overflow-scroll'
          },
          {
            data: null,
            render: function(data, type, row) {
              return '<div style="white-space:no-wrap">' + data.status + '</div>'
            }
          },
          {
            data: null,
            render: function(data, type, row) {
              return '<div style="white-space:no-wrap">' + data.date + '</div>'
            }
          },
          {
            data: 'sex'
          },
          {
            data: 'area'
          },
          {
            data: null,
            render: function(data, type, row) {
              return '<div style="white-space:no-wrap">' + data.site + '</div>'
            }
          },
          {
            data: null,
            render: function(data, type, row) {
              return '<div style="white-space:no-wrap">' + data.message + '</div>'
            }
          },
          {
            data: null,
            render: function(data, type, row) {
              return ''
            }
          }
        ],
        initComplete: function () {
          loadedDatatables[addPassengerTable] = true;            
        },
        rowCallback: function (row, data) {
          
        }, 
        drawCallback: function(){
          $(addPassengerTable).DataTable().rows().every( function (row) {            
            var tr = $(this.node());
            tr.removeClass('selected');
            tr.find('td:last').addClass('checkbox-select');
            tr.find('td:last').addClass('text-primary');
            tr.find('td:last').css({'padding-left':'40px'});
        });  
        }
      });
    }
    else{
      addPassengerClusterTable.draw();
    }

    addPassengerClusterTable.on('select', function (e, dt, type, indexes) {
      $("#submit-add-passenger").prop('disabled', false);
      $('#count-error').text('')
      // track selected row
      var rowData = addPassengerClusterTable.row(indexes).data();
      var index = $.inArray(rowData.id, addPassengerSelected);
      if (index === -1) {
        addPassengerSelected[rowData.id] = rowData;
        // remove it from selected rows
        delete selectedRows[rowData.DT_RowId];
      }
    });

    // table row deselect event
    addPassengerClusterTable.on('deselect', function (e, dt, type, indexes) {
      // remove selected row from track
      var tripId = addPassengerClusterTable.row(indexes).data().id;
      delete addPassengerSelected[tripId];
      if(Object.keys(addPassengerSelected).length > 0){
        $("#submit-add-passenger").prop('disabled', false);
      }
      $('#count-error').text('')
    });

  });  

  // select all rows using checkbox
  $('.ch-all-add-passenger').on('click', function () {
    $('#count-error').text('');
    var row = $(this).closest('tr');
    var currentRows = addPassengerClusterTable.rows({page: 'current'})
    if (row.hasClass("selected")) {
      currentRows.deselect();
      row.removeClass('selected');
      addPassengerSelected = {}
      $("#submit-add-passenger").prop('disabled', true);
    } 
    else {
      row.addClass('selected');
      currentRows.select();
      var indexes = currentRows[0]

      if(indexes.length > 1) {
        addPassengerSelected = {}
        indexes.forEach(function (index) {
          var rowData = addPassengerClusterTable.row(index).data();
          var index = $.inArray(rowData.id, addPassengerSelected);
          if (index === -1) {
            addPassengerSelected[rowData.id] = rowData;
          }
        })
      }
      $("#submit-add-passenger").prop('disabled', false);
    }
  });

  $('#submit-add-passenger').on('click', function(e){
    var ids = Object.keys(addPassengerSelected)
    if(ids.length == 0){
      $('#count-error').text('Add atleast 1 passenger');
      $("#submit-add-passenger").prop('disabled', true);
    }
    else{
      if(ids.length > available_seats){
        $('#count-error').text('Cannot add more than ' + available_seats + ' passengers');
        $("#submit-add-passenger").prop('disabled', true);
        return; 
      }
      else{
        document.getElementById('overlay').style.display = 'block';
        $.ajax({
            type: "POST",
            url: '/employee_trips/add_passengers_submit',
            data: {
              'ids': ids,
              'date': date,
              'employee_cluster_id': employee_cluster_id,
            }
        }).done(function(){
            addPassengerSelected = {}
            employeeTripRequestTable.draw();
            employeeTripRequestClusterTable.draw();
            addPassengerClusterTable.draw();
            $('#modal-add-passenger-cluster').modal('toggle');
        })
      }         
    }      
  }) 

  // Set direction on filter change
  $('#trip-direction').on('change', function () {
    count = 0;
    direction = +$(this).val();
    if(firstDirection + '' != direction + ''){
      firstDirection = direction
      document.getElementById('overlay').style.display = 'block';
      employeeTripRequestTable.row
      employeeTripRequestTable.draw(false);
      employeeTripRequestClusterTable.draw(false);
      selectedRows = {};
    }      
  });

  // Set bus_rider on filter change
  $('#bus-cab').on('change', function () {
    count = 0;
    bus_rider = +$(this).val();
    if(firstBusRide + '' != bus_rider + ''){        
      firstBusRide = bus_rider
      document.getElementById('overlay').style.display = 'block';
      employeeTripRequestTable.draw(false);
      employeeTripRequestClusterTable.draw(false);
      selectedRows = {};
    }      
  });

  // select all rows using checkbox
  $('.ch-all').on('click', function () {
    var row = $(this).closest('tr');
    var currentRows = employeeTripRequestTable.rows({page: 'current'})
    if (row.hasClass("selected")) {
      currentRows.deselect();
      row.removeClass('selected');
      selectedRows = {}
      // Fix bug of remnant polyline
      setTimeout(() => {
        clearRouteInfo()
        removePolylines(employeeTrMapID)
      }, 200);
    } else {
      row.addClass('selected');
      currentRows.select();
      var indexes = currentRows[0]

      if(indexes.length > 1) {
        selectedRows = {}
        indexes.forEach(function (index) {
          var rowData = employeeTripRequestTable.row(index).data();
          var index = $.inArray(rowData.DT_RowId, selectedRows);
          if (index === -1) {
            selectedRows[rowData.DT_RowId] = rowData;
          }
        })
      }
      renderQueueRoute()
    }
  });

  function validateButtons(){
    if(Object.keys(selectedClusterRows).length > 0 && Object.keys(selectedRows).length > 0){
      $('.adhoc-controls').find('.btn').prop('disabled', true);

      $('#auto-cluster').text('Cluster');
      $('#auto-cluster').data('action', 'cluster');
      $('#auto-cluster').prop('disabled', true);

      $("#cancel-trip-request").prop('disabled', true);
      $("#create-trip-roster").prop('disabled', true);
    }
    else if(Object.keys(selectedClusterRows).length > 0 && Object.keys(selectedRows).length == 0){

      $('#auto-cluster').text('De-Cluster');
      $('#auto-cluster').data('action', 'de-cluster');
      $('#auto-cluster').prop('disabled', false);

      $('.adhoc-controls').find('.btn').prop('disabled', false);
      $("#cancel-trip-request").prop('disabled', false);
      $("#create-trip-roster").prop('disabled', false); 
    }
    else if(Object.keys(selectedClusterRows).length == 0 && Object.keys(selectedRows).length > 0){

      $('#auto-cluster').text('Cluster');
      $('#auto-cluster').data('action', 'cluster');
      $('#auto-cluster').prop('disabled', false);

      $('.adhoc-controls').find('.btn').prop('disabled', false);
      $("#cancel-trip-request").prop('disabled', false);
      $("#create-trip-roster").prop('disabled', false);  
    }
    else{
      $('#auto-cluster').text('Cluster');
      $('#auto-cluster').data('action', 'cluster');
      $('#auto-cluster').prop('disabled', true);

      $('.adhoc-controls').find('.btn').prop('disabled', true);
      $("#cancel-trip-request").prop('disabled', true);
      $("#create-trip-roster").prop('disabled', true); 
    }
  }

  $('#trip-date').focusin(function(){
    $('.calendar-table').css("display","block");
  });

  $('#trip-time').focusin(function(){
    $('.calendar-table').css("display","none");
  });

  $('#trip-time').on('hide.daterangepicker', function(){      
    $('#trip-time').val(finalTime)
  });

  $('#trip-time').on('apply.daterangepicker', function(ev, picker) {    
    startDate = moment(origStartDate, "MM-DD-YYYY").format("DD/MM/YYYY") + " " + picker.startDate.format('h:mm A');
    endDate = moment(origStartDate, "MM-DD-YYYY").format("DD/MM/YYYY") + " " + picker.endDate.format('h:mm A');    
    var startDateArray = startDate.split(" ")
    var endDateArray = endDate.split(" ")
    var finalTime = startDateArray[1] + " " + startDateArray[2] + " - " + endDateArray[1] + " " + endDateArray[2]
    $('#trip-time').val(finalTime)
    
    selectedRows = {};
    document.getElementById('overlay').style.display = 'block';
    employeeTripRequestTable.draw();
    employeeTripRequestClusterTable.draw();
  });

  /**
   * Init Table
   */
  $('a[href="#employee-trip-request"]').on('shown.bs.tab', function (e) {
    $('#ingest-manifest').removeClass('hidden');

    if (loadedTabs['employee-trip-request']) return;

    // set loaded state
    loadedTabs['employee-trip-request'] = true;

    // Init datepicker
    $('#trip-date').daterangepicker({
      timePicker: false,
      singleDatePicker: true,
      applyClass: 'btn-primary',
      locale: {
        format: 'DD/MM/YYYY'
      }
    },
    function (start) {
      var nowTime = moment().format('h:mm A')
      startDate = start.format('DD/MM/YYYY') + ' ' + nowTime;
      origStartDate = start.format('MM-DD-YYYY');
      // endDate = moment(startDate, "DD/MM/YYYY h:mm A").add(3, 'hour').format('DD/MM/YYYY h:mm A')
      endDate = ''
      selectedRows = {};
      dateSet = true;
      $('#trip-time').val('');
      $('#prev-date-value').text(moment(origStartDate, "MM-DD-YYYY").subtract(1, 'day').format('DD/MM/YYYY'))
      $('#next-date-value').text(moment(origStartDate, "MM-DD-YYYY").add(1, 'day').format('DD/MM/YYYY'))
      document.getElementById('overlay').style.display = 'block';
      employeeTripRequestTable.draw();
      employeeTripRequestClusterTable.draw();
    });

    // Init timepicker
    $('#trip-time').daterangepicker({
      timePicker: true,
      applyClass: 'btn-primary',
      timePickerIncrement: 15,
      autoUpdateInput: true,
      startDate: moment().subtract((moment().minute() % 30), "minutes"),
      endDate: moment().add(30 - (moment().minute() % 30), "minutes"),
      locale: {
        format: 'h:mm A'
      }
    });

    if(!dateSet){
      $('#trip-time').val('');
    }

    if ($('#map-employee-trip-requests')) {
      maps[employeeTrMapID] = Gmaps.build('Google', {markers: {clusterer: undefined}});
      maps[employeeTrMapID].buildMap(
      {
        internal: {
          id: employeeTrMapID
        },
        provider: mapProviderOpts
      },
      function () {
        addMapMarkers(employeeTrMapID, employeeTrMarkersData);
        for(var key in selectedRows) {
          selectMarker(employeeTrMapID, selectedRows[key].id);
        }
      });

        // check map full load
        checkMapLoading(employeeTrMapID);
    }

    get_first_shift(true)

    // Collect & change table data for modal
    $('#create-trip-roster').on('click', function (e) {
      employee_trips_array = []
      individual_trips = []
      if(Object.keys(selectedClusterRows).length > 0){
        for(var key in selectedClusterRows){
          employee_trips_array.push(clusterMapping[key])
          tripOrderUpdated = false
        }
        createTripRoster(false);
      }
      else{
        var html = '';
        var i = 0;
        var datetime = []        

        var trip_ids = []
        for(var tripId in selectedRows){
          trip_ids.push(selectedRows[tripId].id)
          datetime.push(selectedRows[tripId].datetime)
        }

        if(new Set(datetime).size > 1){
          $('#modal-manifest-shift-time-error').modal('toggle');
          return
        }        

        if (trip_ids.length > 0) {
          $.ajax({
              type: "GET",
              url: '/sorted_routes',
              data: {
                'ids': trip_ids
              }
          }).done(function(response){
              for(var i = 0; i < response.sorted_employee_trips.length; i++){
                var tripId = response.sorted_employee_trips[i];

                individual_trips.push(selectedRows[tripId].id)
                selectedMarkersData[i] = {id: selectedRows[tripId].id, lat: selectedRows[tripId].lat, lng: selectedRows[tripId].lng, site_lat: selectedRows[tripId].site_lat, site_lng: selectedRows[tripId].site_lng, trip_type: selectedRows[tripId].trip_type};
                html = html + generateHtml(tripId, i)
              }
              employee_trips_array.push(individual_trips)
              //show modal here to confirm create trip
              document.getElementById("trip-roster-confirm-body").innerHTML = html;
              $('#modal-employer-tr-confirm').modal('toggle');          

              female_exception = response.show_female_exception_error
              showMapRoute(response.error)
          })
        } 
        // else {
        //   for(var tripId in selectedRows){
        //     individual_trips.push(selectedRows[tripId].id)
        //     selectedMarkersData[i] = {id: selectedRows[tripId].id, lat: selectedRows[tripId].lat, lng: selectedRows[tripId].lng, site_lat: selectedRows[tripId].site_lat, site_lng: selectedRows[tripId].site_lng, trip_type: selectedRows[tripId].trip_type};
        //     html = html + generateHtml(tripId, i)
        //     i = i + 1;
        //   }
        //   employee_trips_array.push(individual_trips)
        //   //show modal here to confirm create trip
        //   document.getElementById("trip-roster-confirm-body").innerHTML = html;
        //   $('#modal-employer-tr-confirm').modal('toggle');
        //   showMapRoute("");
        // }        
      }
    });

    $(document).on('click', '.sequenceupcluster', function (e) {
      e.preventDefault();
      var row_id = e.target.dataset.row_id
      var employee_trips = employee_trips_mapping[row_id]
      var current_user = e.target.dataset.current_user
      var size = e.target.dataset.size
      var trip_type = e.target.dataset.trip_type
      var date = e.target.dataset.date
      var employee_cluster_id = e.target.dataset.employee_cluster_id
      var bus_rider = e.target.dataset.bus_rider

      var index = parseInt(e.target.dataset.index)
      if(index - 1 >= 0){
        var temp = employee_trips[index]
        employee_trips[index] = employee_trips[index - 1]
        employee_trips[index - 1] = temp        
      }
      document.getElementById("inner_" + row_id).innerHTML = format(row_id, employee_trips, current_user, size , trip_type, date, employee_cluster_id, bus_rider)
    })

    $(document).on('click', '.sequencedowncluster', function (e) {
      e.preventDefault();
      var row_id = e.target.dataset.row_id
      var employee_trips = employee_trips_mapping[row_id]
      var current_user = e.target.dataset.current_user
      var size = e.target.dataset.size
      var trip_type = e.target.dataset.trip_type
      var date = e.target.dataset.date
      var employee_cluster_id = e.target.dataset.employee_cluster_id
      var bus_rider = e.target.dataset.bus_rider

      var index = parseInt(e.target.dataset.index)
      if(index < employee_trips.length - 1){
        var temp = employee_trips[index]
        employee_trips[index] = employee_trips[index + 1]
        employee_trips[index + 1] = temp
      }
      document.getElementById("inner_" + row_id).innerHTML = format(row_id, employee_trips, current_user, size , trip_type, date, employee_cluster_id, bus_rider)
    })    

    $(document).on('click', '.sequenceup', function (e) {
        e.preventDefault();
        document.getElementById('submit-trip-roster').style.display = 'none';
        document.getElementById('save-sequence').style.display = 'inline-block';
        var index = parseInt(e.target.id.split("_")[1])
        if(index - 1 >= 0){
          var temp = individual_trips[index]
          individual_trips[index] = individual_trips[index - 1]
          individual_trips[index - 1] = temp
        }
        var html = ''
        for(var i = 0; i < individual_trips.length; i++){
          html = html + generateHtml('empltrip-' + individual_trips[i], i)
        }
        document.getElementById("trip-roster-confirm-body").innerHTML = html;
      })

    $(document).on('click', '.sequencedown', function (e) {
      e.preventDefault();
      document.getElementById('submit-trip-roster').style.display = 'none';
      document.getElementById('save-sequence').style.display = 'inline-block';
      var index = parseInt(e.target.id.split("_")[1]) 
      if(index < individual_trips.length - 1){
        var temp = individual_trips[index]
        individual_trips[index] = individual_trips[index + 1]
        individual_trips[index + 1] = temp
      }
      var html = ''
      for(var i = 0; i < individual_trips.length; i++){
        html = html + generateHtml('empltrip-' + individual_trips[i], i)
      }
      document.getElementById("trip-roster-confirm-body").innerHTML = html;
    })

    function generateHtml(tripId, i){
      var html = '<tr>'
                  + '<td>' + selectedRows[tripId].employee_name + " " + selectedRows[tripId].employee_l_name + '</td>'
                  + '<td>' + selectedRows[tripId].date + " " + selectedRows[tripId].datetime + '</td>'
                  + '<td>' + selectedRows[tripId].sex + '</td>'
                  + '<td>' + selectedRows[tripId].area + '</td>'          
      if(i == 0){
        html = html + '<td style="text-align:center"><i id="sequencedown_' + i + '" style="cursor:pointer" class="fa fa-chevron-down sequencedown"></i></td>'
      }
      else if(i == Object.keys(selectedRows).length - 1){
        html = html + '<td style="text-align:center"><i id="sequenceup_' + i + '" style="cursor:pointer" class="fa fa-chevron-up sequenceup"></i></td>'
      }
      else{
        html = html + '<td style="text-align:center"><i id="sequencedown_' + i + '" style="cursor:pointer; padding-right:2px" class="fa fa-chevron-down sequencedown"></i><i id="sequenceup_' + i + '" style="cursor:pointer; padding-left:2px" class="fa fa-chevron-up sequenceup"></i></td>'
      }
      html = html + '</tr>'      
      return html
    }

    function createTripRoster(toggle){    
      $('#employee-trip-request-table_processing').attr('style', 'display : block');
      $('#employee-trip-request-cluster-table_processing').attr('style', 'display : block');

      document.getElementById('overlay').style.display = 'block';      
      try{
          $.ajax({
            type: "POST",
            url: '/employee_trips/create_trip_rosters',
            data: {
              'employee_trips_array': employee_trips_array,
              'tripOrderUpdated': tripOrderUpdated
            },
            error: function(err){
              if(err != undefined && err != null && err.responseText != null && err.responseText != undefined && (err.responseText.indexOf("Google") != -1 || err.responseText.indexOf("google") != -1)){
                $('#error-message').text("Google Maps Error!");
              }
              else{
                $('#error-message').text("Network Issue!");                
              }              
              document.getElementById('overlay').style.display = 'none';
            },
        }).done(function(response){
            // responseMessage = ''
            // error_trips = []
            // if(!response.success){
            //   alert(response.message + '' + response.error_trips)
            //   responseMessage = response.message;
            //   error_trips = response.error_trips;
            // }
            if(response.message.length > 0){
              $('#error-message').text("Network Issue!");
              document.getElementById('overlay').style.display = 'none';
            }
            else{
              selectedClusterRows = {}
              selectedRows = {}
              employeeTripRequestClusterTable.rows({selected: true}).remove().draw();
              employeeTripRequestTable.rows({selected: true}).remove().draw();
              $("#cancel-trip-request").prop('disabled', true);
              $("#create-trip-roster").prop('disabled', true);              
              if(toggle){
                $('#modal-employer-tr-confirm').modal('toggle');
              }  
            }
        })
          // $('#employee-trip-request-cluster-table_processing').attr('style', 'display : none');
      }
      catch(e){
        console.log(e)        
        document.getElementById('overlay').style.display = 'none';
      }
    }    

    // Cancel trip request on btn click
    $('#cancel-trip-request').on('click', function () {
      var employee_trips_array = []
      var individual_trips = []
      for(var key in selectedClusterRows){
        for(var employee_trip in clusterMapping[key]){
          employee_trips_array.push(clusterMapping[key][employee_trip])  
        }
      }
      for(var tripId in selectedRows){
        employee_trips_array.push(selectedRows[tripId].id)
      }
      $('#employee-trip-request-cluster-table_processing').attr('style', 'display : block');

      document.getElementById('overlay').style.display = 'block';

      $.ajax({
          type: "DELETE",
          url: '/employee_trips/cancel_trip_request',
          data: {
            'ids': employee_trips_array
          }
      }).done(function(response){
          selectedClusterRows = {}
          selectedRows = {}          
          employeeTripRequestClusterTable.rows({selected: true}).remove().draw();
          employeeTripRequestTable.rows({selected: true}).remove().draw();          
          $("#cancel-trip-request").prop('disabled', true);
          $("#create-trip-roster").prop('disabled', true);
      })
    });

    // send ad-hoc request
    $('.adhoc-controls').on('click', '.btn', function () {
        var type = $(this).data('type');
        var rowData = employeeTripRequestTable.rows('.selected').data().toArray();
        var data = {
            ids: [],
            type: type
        };

        rowData.forEach(function (item) {
            data.ids.push(item.id);
        });

        // send request
        $.post("/employee_trips_changes", data, {dataType: 'json'})
            .done(function (r) {
                employeeTripRequestTable.rows({selected: true}).remove().draw(false);
            })
            .fail(function (r) {
                $('#error-placement').html(
                    '<div class="alert alert-danger fade in"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>' + r.responseText + '</div>'
                );
            });
    });

    $(table).on('click', 'a.update_request', function (e) {
      var data = {
          ids : [$(this).data('request-id')],
          type: $(this).data('type')
      }

      $.post('/employee_trips_changes', data, {dataType: 'json'})
          .done(function (r) {
              // update the vehicle tab
              $(table).DataTable().draw(true);
          })
          .fail(function (r) {
              $('#error-placement').html(
                  '<div class="alert alert-danger fade in"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>' + r.responseText + '</div>'
              );
          });
      });

    $(document).on('click', '#request-list', function (e) {
        e.preventDefault();
        
        var dataTable = $(table).DataTable()
        dataTable.column(0).visible(true);
        dataTable.column(2).visible(true);
        dataTable.column(7).visible(true);

        // var clusterDataTable = $(clusterTable).DataTable()
        // clusterDataTable.column(5).visible(true);

        $(".hideable").removeClass('hidden')
        
        $('#trip-tables').addClass('col-lg-12')
        $('#trip-tables').removeClass('col-lg-8')

        $('#map-employee-trip-requests').addClass('hidden')

        $('#request-list-map').removeClass('bg-cloud');
        $('#request-list').removeClass('bg-white');

        $('#request-list-map').addClass('bg-white');
        $('#request-list').addClass('bg-cloud');
    });

    $(document).on('click', '#request-list-map', function (e) {
        e.preventDefault();
        var dataTable = $(table).DataTable()
        dataTable.column(0).visible(false);
        dataTable.column(2).visible(false);
        dataTable.column(7).visible(false);

        // var clusterDataTable = $(clusterTable).DataTable()
        // clusterDataTable.column(5).visible(false);

        $(".hideable").addClass('hidden')
        
        $('#map-employee-trip-requests').removeClass('hidden')
        $('#trip-tables').removeClass('col-lg-12')
        $('#trip-tables').addClass('col-lg-8')

        $('#request-list').removeClass('bg-cloud');
        $('#request-list-map').removeClass('bg-white');

        $('#request-list').addClass('bg-white');
        $('#request-list-map').addClass('bg-cloud');
    });

    $(document).on('click', '#auto-cluster', function () {
      if ($(this).data('action') === "cluster") {
        var data = [];
        //add loader
        document.getElementById('overlay').style.display = 'block';
        $('#employee-trip-request-table_processing').attr('style', 'display : block');
        $('#employee-trip-request-table_processing').attr('style', 'display : block');
        if (window.cluster_algorithm === "clustering_service") {
          for (var key in selectedRows) {
            data.push(selectedRows[key].id);
          }
        } else if (window.cluster_algorithm === "historical") {
          employeeTripRequestTable.rows().every( function ( rowIdx, tableLoop, rowLoop ) {
            var d = this.data();
            data.push(d.id);
          });
        }
        var threshold    = $('#clustering-threshold').val() || 1500,
            strategy     = $('#clustering-strategy').val() || 'routing',
            largeVehicle = $('#clustering-large-vehicle').val() || 12000,
            routeDeviation = $('#clustering-route-deviation').val() || 1500,
            checkFemaleException = $('#clustering-female-exception').is(':checked') || false,
            clusterAloneThreshold = $('#clustering-cluster-alone-threshold').val() || 60000;
        $.ajax({
          url: '/auto_cluster',
          type: 'POST',
          contentType: 'application/json',
          data: JSON.stringify({
            ids: data,
            strategy: strategy,
            trip_type: direction,
            threshold: threshold,
            fleet_mix: getFleetMix(),
            large_vehicle: largeVehicle,
            route_deviation: routeDeviation,
            check_female_exception: checkFemaleException,
            cluster_alone_threshold: clusterAloneThreshold,
            bus_rider: bus_rider,
            startDate: startDate,
            endDate: endDate
          })
        }).done(function (response) {
          selectedRows = {};
          selectedClusterRows = {};
          if(response.success == false) {
            $('#error-message').text("Something went wrong!");
            $('#employee-trip-request-table_processing').attr('style', 'display : none');
          } else {
            employeeTripRequestTable.draw();
            employeeTripRequestClusterTable.draw();
            document.getElementById('overlay').style.display = 'none';
            $('#employee-trip-request-table_processing').attr('style', 'display : none');
          }
        }).fail((resp) => {
          employeeTripRequestTable.draw();
          employeeTripRequestClusterTable.draw();
          document.getElementById('overlay').style.display = 'none';
          $('#employee-trip-request-table_processing').attr('style', 'display : none');
        });
      } else if ($(this).data('action') === "de-cluster") {
        var employee_cluster_ids = []
        for (var key in selectedClusterRows) {
          var cluster = selectedClusterRows[key];
          if (employee_cluster_ids.indexOf(cluster.employee_cluster_id) < 0) {
            employee_cluster_ids.push(cluster.employee_cluster_id);
          }
        }
        $.post('/decluster', {
          ids: employee_cluster_ids
        }).done(function(response) {
          selectedRows = {};
          selectedClusterRows = {};
          if(response.success == false) {
            $('#error-message').text("Something went wrong!");
            $('#employee-trip-request-table_processing').attr('style', 'display : none');
          } else {
            employeeTripRequestTable.draw();
            employeeTripRequestClusterTable.draw();
            document.getElementById('overlay').style.display = 'none';
            $('#employee-trip-request-table_processing').attr('style', 'display : none');
          }
        });
      }
    });

    $(document).on('click', '#export-clusters', function() {
      window.location = '/employee_trips/get_clusters.xlsx?' + $.param({
        startDate: startDate,
        endDate: endDate,
        direction: direction,
        bus_rider: bus_rider,
        search: search
      });
    });

    $('.modal-footer').on('click', '#save-sequence', function () {
      document.getElementById('submit-trip-roster').style.display = 'inline-block';
      document.getElementById('save-sequence').style.display = 'none';

      showMapRoute("");
    });

    // Submit trip roster modal
    $('.modal-footer').on('click', '#submit-trip-roster', function () {
      // $('#modal-employer-tr-confirm').modal('toggle')
      createTripRoster(true)
    });

    /**
     * Trip request modal
     */
     var employeeTrModalMapID = 'map-trip-roster-confirm';

    // init map on modal show
    $('#modal-employer-tr-confirm').on('shown.bs.modal', function () {
      document.getElementById('save-sequence').style.display = 'none';
      document.getElementById('submit-trip-roster').style.display = 'inline-block';
    });

    function showMapRoute(error) {      
      /* Ajax Call to get Map Data */
      var mapsArray = []
      var female_exception_message = "Female is now the first/last pick-up"

      if (error) {
        $('#error-message').text(error);  
      } else {
        $('#error-message').text("");
      }
      

      for(var i = 0; i < individual_trips.length; i++) {
        var tripId = "empltrip-" + individual_trips[i]
        mapsArray[i] = {id: selectedRows[tripId].id, lat: selectedRows[tripId].lat, lng: selectedRows[tripId].lng, site_lat: selectedRows[tripId].site_lat, site_lng: selectedRows[tripId].site_lng, trip_type: selectedRows[tripId].trip_type};

        if (female_exception) {
          if(i == 0 && selectedRows[tripId].sex == 'F' && selectedRows[tripId].trip_type == "Check in") {
            $('#error-message').text(female_exception_message);
          }

          if(i == individual_trips.length - 1 && selectedRows[tripId].sex == 'F' && selectedRows[tripId].trip_type == "Check out") {
            $('#error-message').text(female_exception_message);
          }
        }
      }

      if(mapsArray.length > 0) {
        showRouteForUnclusteredTrips(employeeTrModalMapID, mapsArray);
      }
    }

  });

  $('a[href="#employee-trip-request"]').on('hide.bs.tab', function (e) {
    $('#export-clusters').addClass('hidden');
    $('#ingest-manifest').addClass('hidden');
  });

  $('#modal-ingest-job-stats').on('hidden.bs.modal', function() {
    if (employeeTripRequestTable && employeeTripRequestClusterTable) {
      employeeTripRequestTable.draw();
      employeeTripRequestClusterTable.draw();
    }
  });
});
