var vehiclesTableEditor;
$(function () {
    'use strict';

    /**
     * Vehicles Table
     *
     */
    var table = '#vehicles-table';
    var vehicleTable = $();

    vehiclesTableEditor = new $.fn.dataTable.Editor({
        table: table,
        ajax: {
            remove: {
                type: 'DELETE',
                url: '/vehicles/_id_'
            }
        }
    });

    // Delete record
    $(table).on('click', 'a.editor_remove', function (e) {
        e.preventDefault();

        vehiclesTableEditor
            .title('Delete vehicle')
            .message("Are you sure you wish to delete this vehicle?")
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

    $(table).on('click', 'a.update_driver_request', function(e) {
        var type = $(this).data('type');
        var request_id = $(this).data('request-id')

        var data = {
            ids: [],
            type: type
        };

        data.ids.push(request_id);

        // send request
        $.post("/driver_requests", data, {dataType: 'json'})
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

    $(table).on('click', 'a.vehicle_broke_down', function() {
        var data = {
            id: $(this).data('id')
        }

        $.post('/vehicles/' + $(this).data('id') + '/vehicle_broke_down', data, {dataType: 'json'})
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

    $(table).on('click', 'a.vehicle_ok', function() {
        var data = {
            request_id : $(this).data('request-id')
        }
        $.post('/vehicles/' + $(this).data('id') + '/vehicle_ok', data, {dataType: 'json'})
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

    $('a[href="#vehicles"]').on('shown.bs.tab', function (e) {
        if (loadedTabs['vehicles']) return;

        // set loaded state
        loadedTabs['vehicles'] = true;

        if (!loadedDatatables[table]) {

            vehicleTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/vehicles",
                    data: function ( d ) {
                        d.search_input = $("#vehicles-table-search-input").val();
                        d.search_by = $("#vehicles-table-field-name").val();
                    }
                },
                lengthChange: false,
                searching: false,
                order: [[0, 'desc']],
                pagingType: "simple_numbers",
                ordering: false,
                info: false,
                processing: true,

                columns: [
                    {
                        data: null,
                        render: function (data) {
                            return '<a href="/vehicles/' + data.id + '/edit" class="edit" data-remote="true" data-method="GET">' + data.plate_number + '</a>';
                        }
                    },
                    {data: "make"},
                    {data: "model"},
                    {data: "colour"},
                    {data: "seats"},
                    {
                        data: null,
                        orderable: false,
                        className: "center",
                        render: function (data) {
                            var checklistId = data.checklist_attributes.id == null ? "" : data.checklist_attributes.id;
                            var className = "";
                            if(checklistId == ''){
                                return '<p class="text-primary" data-remote="true">'+ data.checklist_attributes.status +'</p>';
                            }
                            else{
                                if (data.checklist_attributes.notification_type === "checklist") {
                                    var className = "checklist-status" 
                                    return '<a href="/vehicles/'+ checklistId +'/checklist" class="'+ className +'" data-remote="true">'+ data.checklist_attributes.status +'</a>';
                                }
                                if (data.checklist_attributes.notification_type === "provisioning") {
                                    var className = "notification-status"
                                    return '<a href="/vehicles/' + data.id + '/edit" class="'+ className +' edit vehicle_edit" data-remote="true">'+ data.checklist_attributes.status +'</a>';
                                }
                                return '<a href="/vehicles/'+ checklistId +'/checklist" class="'+ className +'" data-remote="true">'+ data.checklist_attributes.status +'</a>';
                            }
                        }
                    },
                    {
                        data: null,
                        render: function(data) {
                            if(data.driver == null) {
                                return 'Unpaired'
                            } else {
                                if(data.status == 'vehicle_ok') {
                                    return 'Paired'
                                } else if(data.status == 'vehicle_broke_down') {
                                    return '<p style="margin-bottom:0px" class="text-danger">'+ 'Car Broke Down' +'</p>';
                                } else if(data.status == 'vehicle_broke_down_pending') {
                                    return '<p style="margin-bottom:0px" class="text-danger">'+ 'Request: Car Broke Down' +'</p>';
                                } else if(data.status == 'vehicle_ok_pending') {
                                    return '<p style="margin-bottom:0px" class="text-danger">'+ "Request: Car Ok" +'</p>';
                                }
                            }
                        }
                    },
                    {data: "driver"},
                    {
                        data: null,
                        render: function (data) {
                            var ret = ''
                            if(data.status == 'vehicle_ok') {
                                ret += '<a href="#" data-id="' + data.id + '" class="vehicle_broke_down text-teal">Car Broke Down</a> &nbsp;&nbsp;'
                                ret += '<a href="#" class="editor_remove text-danger">Delete</a>';
                            } else if(data.status == 'vehicle_ok_pending') {
                                ret += '<a href="#" data-type="decline" data-request-id="' + data.driver_request.id + '" class="update_driver_request text-danger">Decline</a> &nbsp;&nbsp;<a data-request-id="' + data.driver_request.id + '" href="#" data-type="approve" class="update_driver_request text-teal">Accept</a> '
                            } else if(data.status == 'vehicle_broke_down_pending') {
                                ret += '<a href="#" data-request-id="' + data.driver_request.id + '" class="update_driver_request text-danger" data-type="decline">Decline</a> &nbsp;&nbsp;<a data-request-id="' + data.driver_request.id + '" href="#" class="update_driver_request text-teal" data-type="approve">Accept</a> '
                            } else if(data.status == 'vehicle_broke_down') {
                                if(data.driver_request == null){
                                    ret += '<a data-id="' + data.id + '" href="#" class="vehicle_ok text-teal">Car OK</a> &nbsp;&nbsp;'
                                }
                                else{
                                    ret += '<a data-id="' + data.id + '" data-request-id="' + data.driver_request.id + '" href="#" class="vehicle_ok text-teal">Car OK</a> &nbsp;&nbsp;'
                                }
                            }                            
                            return ret
                        }
                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                    var info = this.api().page.info();
                    // $('#vehicles-count').text("Total Vehicles: " + info.recordsTotal);
                    if(info.recordsTotal == 0) {
                        $("#badge-vehicle-count").addClass('hidden');
                    } else {
                        $("#badge-vehicle-count").text(info.recordsTotal);
                        $("#badge-vehicle-count").removeClass('hidden');
                    }
                }
            });
        }

        $(document).on('click', '.checklist_radio', function(e){
            var total_fields = $('.total_fields').text()
            var total_ok = $('.ok_radio')
            var checked = 0
            for(var i = 0; i < total_ok.length; i++){
                if($(total_ok[i])[0].checked){
                    checked = checked + 1
                }
            }   
            var progress = Math.round(checked * 100 / total_fields)
            $('.progress-bar').width(progress + '%')
            $('.progress-section span').text(progress + '%')
        })

        // redraw table on edit action
        // $(document).on('click', '.save_checklist',function (e) {
        //     vehicleTable.draw(false);
        //     updateBadgeCount();
        // });
    });

    $(document).on('shown.bs.modal', '#driverChecklistModal', function() {
      $(".checklist-form-vehicle").on("ajax:success", function(xhr, status) {
        if(vehicleTable) {
          vehicleTable.draw(false);
          updateBadgeCount();
        }
      })
    });

    $('#vehicles-table_search').on('click', function(e) {
        $(table).DataTable().draw(true);
        e.preventDefault();
    });

    $("#vehicles-table-search-input").keypress(function(e) {
      if(e.which == 13) {
        $('#vehicles-table_search').click();
      }
    });

    // Reload table
    $("#vehicles.tab-pane").on('click', 'a.reload-button', function (e) {
        vehicleTable.draw(false);
        e.preventDefault();
    });
});
