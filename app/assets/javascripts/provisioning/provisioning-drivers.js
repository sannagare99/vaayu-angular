var driversTableEditor;

$(function () {
    'use strict';

    /**
     * Drivers Users Table
     */
    var table = '#drivers-table';
    var driversTable = $();
    var focusOutTimer;

    driversTableEditor = new $.fn.dataTable.Editor({
        table: table,
        ajax: {
            remove: {
                type: 'DELETE',
                url: '/drivers/_id_'
            }
        }
    });

    /**
     * Init table
     */
    $('a[href="#drivers"]').on('shown.bs.tab',function (e) {
        if (loadedTabs['drivers']) return;

        // set loaded state
        loadedTabs['drivers'] = true;

        if (!loadedDatatables[table]) {

            driversTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/drivers",
                    data: function ( d ) {
                        d.search_input = $("#drivers-table-search-input").val();
                        d.search_by = $("#drivers-table-field-name").val();
                    }
                },
                lengthChange: false,
                order: [[0, 'desc']],
                searching: false,
                pagingType: "simple_numbers",
                processing: true,
                info: false,
                searchable: true,
                language: {
                    emptyTable: "No result"
                },

                columns: [
                    {
                        data: null,
                        orderable: false,                        
                        render: function (data) {
                            return '<a href="/drivers/' + data.id + '/edit" data-remote="true" class="edit driver_edit"><div style="float:left">' + data.name + '</div></a>'  + ' <div style="float:right; top:2px; position:relative"><a href="#" id="call-person" data-number="' + data.phone + '">'+
                            '<svg width="13px" height="14px" viewBox="0 0 13 14" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">'+
                                    '<title>FEFA6A57-5826-4C2D-9960-CC14C19563A2</title>'+
                                    '<desc>Created with sketchtool.</desc>'+
                                    '<defs></defs>'+
                                    '<g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd" fill-opacity="1">'+
                                        '<g class="phone-ico" id="Employer_Active-Trip_02" transform="translate(-488.000000, -275.000000)" fill="#13A89E">'+
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
                                '</svg>'+
                            '</a></div>'
                        }
                    },
                    {
                        data: "entity_attributes.business_associate",
                        orderable: false
                    },
                    {
                        data: "entity_attributes.licence_number",
                        orderable: false
                    },
                    {
                        data: "entity_attributes.aadhaar_number",
                        orderable: false
                    },
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
                                    return '<a href="/drivers/'+ checklistId +'/checklist" class="'+ className +'" data-remote="true">'+ data.checklist_attributes.status +'</a>';
                                }
                                if (data.checklist_attributes.notification_type === "provisioning") {
                                    var className = "notification-status"
                                    return '<a href="/drivers/' + data.id + '/edit" class="'+ className +' edit driver_edit" data-remote="true">'+ data.checklist_attributes.status +'</a>';
                                }
                                return '<a href="/drivers/'+ checklistId +'/checklist" class="'+ className +'" data-remote="true">'+ data.checklist_attributes.status +'</a>';
                            }                            
                        }
                    },
                    {
                        data: null,
                        orderable: false,
                        className: "status-column",
                        render: function (data) {
                            var txt = ""
                            if(data.status == "Pending") {
                                txt = data.status
                            } else if (data.status == "On leave") {
                                txt = "On Leave (Leave: " + data.on_leave_dates + ")"
                            } else {
                                txt = data.entity_attributes.status
                            }

                            if (data.driver_request) {
                                txt = "Leave Request: " + data.leave_request_dates
                            }
                            
                            return txt;
                        }
                    },
                    {
                        data: "status",
                        orderable: false
                    },                    
                    {
                        data: "last_active_time",
                        orderable: false
                    },
                    {
                        data: null,
                        orderable: false,
                        className: "center",
                        render: function (data) {
                            var txt = ''
                            if(data.status === "Pending") {
                                txt = '<a href="#" data-url="/drivers/'+ data.id +'/invite" class="invite-count"><span>Invite('+ data.invite_count +')</span></a> '
                                txt += '<a href="#" class="editor_remove driver_remove text-danger">Delete</a>';
                            } else if (data.status == "On leave"){
                                txt += '<a data-id="' + data.id + '" data-request-id="' + data.driver_request.id + '" href="#" class="stop_on_leave text-danger">Stop On Leave</a> '
                            } else {
                                if(data.driver_request) {
                                    txt += '<a href="#" data-type="decline" data-request-id="' + data.driver_request.id + '" class="update_driver_request text-danger">Decline</a>   <a data-request-id="' + data.driver_request.id + '" href="#" data-type="approve" class="update_driver_request text-teal">Accept</a> '
                                }
                            }                            
                            return txt;
                        }
                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                    var info = this.api().page.info();
                    if(info.recordsTotal == 0) {
                        $("#badge-driver-count").addClass('hidden');
                    } else {
                        $("#badge-driver-count").text(info.recordsTotal);
                        $("#badge-driver-count").removeClass('hidden');
                    }
                }
            });
        }

        // redraw table on edit action
        $(document).on('hidden.bs.modal', '#modal-drivers-edit',function (e) {
            driversTable.draw(false);
        });

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
        //     driversTable.draw(false);
        //     updateBadgeCount();
        // });        
    });

    $(document).on('shown.bs.modal', '#driverChecklistModal', function() {
      $(".checklist-form-driver").on("ajax:success", function(xhr, status) {
        if(driversTable) {
          driversTable.draw(false);
          updateBadgeCount();
        }
      })
    });

    // Delete record
    $(table).on('click', 'a.editor_remove.driver_remove', function (e) {
        e.preventDefault();

        driversTableEditor
            .title('Delete driver')
            .message("Are you sure you wish to delete this driver?")
            .buttons([
                {
                    label: "Close",
                    className: 'btn btn-sm btn-default',
                    fn: function () {
                        this.close()
                    }
                }, {
                    label: "Delete",
                    className: 'btn btn-sm btn-primary',
                    fn: function () {
                        this.submit()
                    }
                }])
            .remove($(this).closest('tr'));
    });

    $(table).on('click', 'a.stop_on_leave', function (e) {
        var data = {
            request_id : $(this).data('request-id')
        }
        $.post('/drivers/' + $(this).data('id') + '/stop_on_leave', data, {dataType: 'json'})
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

    // Re invite action
    $(table).on('click', 'a.invite-count', function (e) {
        $.getJSON( $(this).attr("data-url"))
          .done(function() {
            driversTable.draw(false);
          });
        e.preventDefault();
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

    $('#drivers-table_search').on('click', function(e) {
        driversTable.draw();
        e.preventDefault();
    });

    $("#drivers-table-search-input").keypress(function(e) {
      if(e.which == 13) {
        $('#drivers-table_search').click();
      }
    });

    // Form Validation
    $("#drivers").on("focusout", ".live-validation input.required, select.required, input.live-validate", function(){
        var _this = this;
        focusOutTimer = setTimeout(function () {
            var fields = ['user[email]', 'user[phone]', 'user[entity_attributes][aadhaar_number]'];
            $.validate($(_this), _this.name, fields, "/drivers/validate", $("#form-drivers"));
        }, 200)
    });

    $(".nav-actions").on("click", ".edit-buttons .submit-btn.form-drivers", function(e) {
        clearTimeout(focusOutTimer);
        $.call("/drivers/validate", $("#form-drivers"), "", "", true);
        $("select.required").focusout();
        e.preventDefault();
    })

    // Match Employees
    var typingTimer, matchTemplate, listItem;
    var doneTypingInterval = 600;

    $("#drivers").on("keyup", ".search-match input", function(e){
        if (![9, 17, 18, 91].includes(e.keyCode)) {
            var _this = this;
            var searchBy;
            clearTimeout(typingTimer);
            if ($(_this).val()) {
                typingTimer = setTimeout(function(){
                    if ($(_this).val().length >= 3) {
                        $(_this).closest("div").find(".match-result").remove();
                        $.get("/drivers", {search_input: $(_this).val(), search_by: $(_this).data("match-user"), format: "json", highlight: false, paginate: false}).done(function(data){
                            if ($(_this).is(":focus") && data.iTotalRecords > 0) {
                                matchTemplate = $(".match-result").clone();
                                $.each(data.aaData, function(i, emp) {
                                    listItem = '<li><a href="/drivers/' + emp.id + '/edit" data-remote="true" class="edit driver_edit"><div class="clearfix"><div class="col-md-8"><p>' + emp.name + '</p><p>'+ emp.email +'</p></div><div class="col-md-4"><p class="phone-no">'+ emp.phone +'</p></div></div></a></li>';
                                    matchTemplate.append(listItem);
                                });
                                $(_this).closest("div").append(matchTemplate.show());
                            }
                        });
                    }
                }, doneTypingInterval);
            }
        }
    });

    $("#drivers").on("focusin", ".live-validation input, select", function(){
        $(".form-group .match-result").remove();
    });

    // Reload table
    $("#drivers.tab-pane").on('click', 'a.reload-button', function (e) {
        driversTable.draw(false);
        e.preventDefault();
    });
});
