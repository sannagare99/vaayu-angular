var routesTableEditor;
var bus_stop_length = 1;
var busTripTable = $();
var edit_route = false;
var bus_trip_id = '';

$(function () {
    'use strict';

    /**
     * Bus Trip Table
     *
     */
    var table = '#routes-table';    
    $('a[href="#routes"]').on('shown.bs.tab', function () {
        if (loadedTabs['routes']) return;
        // set loaded state
        loadedTabs['routes'] = true;

        if (!loadedDatatables[table]) {
            busTripTable = $(table).DataTable({
                serverSide: true,
                ajax: "/bus_trips",
                lengthChange: false,
                searching: false,
                pagingType: "simple_numbers",
                ordering: false,
                info: false,
                processing: true,
                columns: [
                    {
                        data: null,
                        render: function (data) {         
                            return '<a href="/bus_trips/'+ data.id +'/edit" class="editor_edit" data-remote="true" data-bus_stop_length="' + data.stops + '" data-bus_trip_id="' + data.id + '">' + data.route_name + '</a>'
                        }
                    },
                    {data: "stops"},
                    {data: "start"},
                    {data: "end"},
                    {data: "status"},
                    {
                        data: null,
                        render: function (data) {
                            if(data && data.status == 'Operating'){
                                return '<a href="#" class="editor_remove text-danger" data-bus_trip_id="' + data.id + '">Stop</a>';    
                            }
                            return '<a href="#" class="editor_remove text-teal" data-bus_trip_id="' + data.id + '">Activate</a>';
                        }
                    }
                ],
                initComplete: function () {                    
                    loadedDatatables[table] = true;
                     var info = this.api().page.info();
                     $('#routes-count').text("Total Routes: " + info.recordsTotal);
                }
            });
        }
    });

    // var routesTableEditor = new $.fn.dataTable.Editor({
    //     table: table,
    //     ajax: {
    //         edit: {
    //             type: 'PUT',
    //             url: '/bus_trips/_id_'
    //         },
    //         remove: {
    //             type: 'DELETE',
    //             url: '/bus_trips/_id_'
    //         }
    //     },
    //     fields: [{
    //         label: 'Route Name',
    //         name: "name",
    //         className: "col-md-6"
    //     }]
    // });

    // // set selectboxes
    // routesTableEditor.on('preOpen', function () {
    //     window.setTimeout(function () {
    //         initModalSelectBox();
    //     }, 100);
    // });

    // Toggle route
    $(table).on('click', 'a.editor_remove', function (e) {
        bus_trip_id = e.target.dataset.bus_trip_id
        e.preventDefault();
        $.ajax({
                type: "POST",
                url: '/bus_trips/' + bus_trip_id + '/toggle_state'
            }).done(function (e) {
                busTripTable.draw()
            });
        
    });

    // Edit record
    $(document).on('click', 'a.editor_edit', function (e) {
        // if(window.location.href.indexOf("routes") != -1){
            $(".add-new-item").hide()
            $(".edit-buttons").css("display","block")
            edit_route = true;
            bus_trip_id = e.target.dataset.bus_trip_id
            bus_stop_length = e.target.dataset.bus_stop_length
            showEditContentArea();
            // window.setTimeout(initMap, 1000);
        // }
    });

    $(document).on('click', '.cancel', function (e) {
        // e.preventDefault();
        // if(window.location.href.indexOf("routes") != -1){
            $(".edit-buttons").css("display","none")
            edit_route = false;        
            restoreDefaultTabState();
            $(".add-new-item").show()
        // }
    });    

    /**
     * Init map
     */

    function initMap(){        
        var employeeTrMapID = 'map-bus-trip';
        if ($('#map-bus-trip')) {
            maps[employeeTrMapID] = Gmaps.build('Google', {markers: {clusterer: undefined}});
            maps[employeeTrMapID].buildMap(
            {
                internal: {
                  id: employeeTrMapID
                },
                provider: mapProviderOpts
            });
        }
    };    

    // var busTripMapID = 'map-bus-trip';
    // if ($('#map-bus-trip').length) {
    //     maps[busTripMapID] = Gmaps.build('Google', {markers: {clusterer: undefined}});

    //     maps[busTripMapID].buildMap({
    //         internal: {
    //             id: busTripMapID
    //         },
    //         provider: mapProviderOpts
    //     });
    // }

    $(document).on('click', '#add-stop', function(e){
        bus_stop_length = parseInt(e.target.dataset.bus_trip_routes)        
        var html = '';
        for(var i = 1; i <= bus_stop_length; i++){
            $("#stop_" + i + "_name").attr("value", $("#stop_" + i + "_name").val())
            $("#stop_" + i + "_address").attr("value", $("#stop_" + i + "_address").val())
        }

        if($("#stop_" + bus_stop_length + "_name").val() == '' && $("#stop_" + bus_stop_length + "_address").val() == ''){
            return;
        }

        bus_stop_length = bus_stop_length + 1;
        $("#add-stop").attr("data-bus_trip_routes", bus_stop_length)
        var html = $("#bus_stops")[0].innerHTML;
        html = html + '<div class="col-md-12" style="padding:10px 0px">' + 
                    '<div class="col-md-1" style="padding:18px 0px 0px 0px">' +
                        '<div style="border-radius:15px; height: 30px; width:30px; background-color:#2b3152">' + 
                            '<p style="color:white; position:relative; text-align:center; top:5px;">' + bus_stop_length + '</p>' +
                        '</div>' + 
                    '</div>' +
                    '<div class="col-md-4" style="padding:0px">' + 
                        '<p class="route_form_label">STOP #' + bus_stop_length + ' NAME</p>' + 
                        '<input class="col-md-12" id="stop_' + bus_stop_length + '_name" placeholder="*Stop #' + bus_stop_length + ' Name" style="height:30px" value="">' + 
                    '</div>' + 
                    '<div class="col-md-7" style="padding-left:10px">' + 
                        '<p class="route_form_label">STOP #' + bus_stop_length + ' ADDRESS</p>' + 
                        '<input class="col-md-12" id="stop_' + bus_stop_length +'_address" placeholder="*Stop #' + bus_stop_length + ' Address" style="height:30px" value="">' + 
                    '</div>' +
                '</div>';        
        $("#bus_stops").html(html)
    })

    $(document).on('click', ".submit-btn", function(e){
        if(e.target.formAction.indexOf("routes") != -1){
            var error = false;
            var data = {
                'route_name': $("#route_name").val(),
                'stop': []
            }            

            for(var i = 1; i <= bus_stop_length; i++){
                error = false;
                if(document.getElementById('stop_' + i + '_name') && (document.getElementById('stop_' + i + '_name').value == '' || document.getElementById('stop_' + i + '_name').value == undefined || document.getElementById('stop_' + i + '_name').value == null)){
                    document.getElementById('stop_' + i + '_name').classList.add("border-danger")
                    error = true
                }
                if(document.getElementById('stop_' + i + '_address') && (document.getElementById('stop_' + i + '_address').value == '' || document.getElementById('stop_' + i + '_address').value == undefined || document.getElementById('stop_' + i + '_address').value == null)){
                    document.getElementById('stop_' + i + '_address').classList.add("border-danger")
                    error = true
                }
                if(!error){
                    data.stop.push({
                        'name': document.getElementById('#stop_' + i + '_name') ? document.getElementById('#stop_' + i + '_name').value : $('#stop_' + i + '_name').val(),
                        'address': document.getElementById('#stop_' + i + '_address') ? document.getElementById('#stop_' + i + '_address').value : $('#stop_' + i + '_address').val(),
                        'order': i
                    })
                }           
            }
            if(!error){
                $('.submit-btn').prop('disabled', true)            
                if(edit_route){
                    $.ajax({
                        type: "PUT",
                        data: data,
                        dataType: "json",
                        url: '/bus_trips/' + bus_trip_id
                    }).done(function (e) {
                        $('.submit-btn').prop('disabled', false)
                        $(".edit-buttons").css("display","none")
                        bus_stop_length = 1;
                        edit_route = false;
                        bus_trip_id = '';
                        restoreDefaultTabState();
                        busTripTable.draw()                        
                        $(".add-new-item").show()
                    });   
                }
                else{
                    $.ajax({
                        type: "POST",
                        data: data,
                        dataType: "json",
                        url: '/bus_trips'
                    }).done(function (e) {
                        $('.submit-btn').prop('disabled', false)
                        $(".edit-buttons").css("display","none")
                        bus_stop_length = 1;
                        restoreDefaultTabState();
                        busTripTable.draw()
                        $(".add-new-item").show()
                    });   
                }
            }            
        }
    })

});