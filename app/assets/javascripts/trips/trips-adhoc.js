$(function () {
    'use strict';    

    /**
     * Init Table
     */
    var table = '#employee-change-request-table';
    var employeeAdHocTable = $();
    var startDate = '',
        endDate = '',
        startTime = '',
        endTime = '';
    var dateSet = false;
    var direction = 2;
    var search = '';
    var type = 3;

    $('a[href="#employee-change-request"]').on('shown.bs.tab', function (e) {
        if (loadedTabs['employee-change-request']) return;

        // set loaded state
        loadedTabs['employee-change-request'] = true;

        if (!loadedDatatables[table]) {
            employeeAdHocTable = $(table).DataTable({
                serverSide: true,
                ajax: {
                    url: "/employee_trips_changes",
                    data: function (d) {
                        d.startDate = startDate,
                        d.endDate = endDate,
                        d.direction = direction,
                        d.search = search,
                        d.type = type
                    }
                },
                lengthChange: false,
                searching: false,
                pagingType: "simple_numbers",
                info: false,
                processing: true,
                autoWidth: false,
                ordering: false,
                select: false,
                columns: [
                    {data: "request_type"},
                    {
                        data: null,
                        render: function (data){
                            if(data.original_date == null){
                                return '<div>' + data.new_date + '</div>'
                            }
                            else if(data.new_date == null){
                                return '<div>' + data.original_date + '</div>'                                
                            }
                            else{
                                return '<div><p style="font-size:12px; color:darkgrey; margin-bottom:0px">Orig. ' + data.original_date + '</p> ' + data.new_date +  '</div>'
                            }
                        }
                    },
                    {data: 'trip_type'},
                    {data: 'site_name'},
                    {data: 'employee_id'},                    
                    {
                        data: null,
                        render: function (data) {
                            return ' <div class="call-div bg-primary" style="display:inline-block; white-space:no-wrap">' + 
                                '<a style="position:relative; top:2px; left:3px" href="#" id="call-person" data-number="' + data.phone + '">' + 
                                    '<svg width="13px" height="14px" viewBox="0 0 13 14" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">'+
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
                                    '</svg>' + 
                                '</a>' +
                            '</div> ' + data.employee_name + ' ' + data.employee_l_name
                        }
                    },
                    {
                        data: 'gender',
                        className: 'text-center'
                    },
                    {
                        data: "reason"
                    },
                    {
                        data: null,
                        render: function (data){
                            if(data.request_state == 'Created'){
                                return '<div style="font-weight:bold"><span class="text-primary change-request-button" style="cursor:pointer" data-id=' + data.id + ' data-type="approve">Approve</span>&nbsp;&nbsp;<span class="text-danger change-request-button" style="cursor:pointer" data-id=' + data.id + ' data-type="decline">Cancel</span></div>'
                            }
                            else{
                                return data.request_state
                            }
                            
                        }
                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                     var info = this.api().page.info();
                     $('#adhoc-trips-count').text("Total Adhoc Trips: " + info.recordsTotal);
                },
                rowCallback: function ( row, data, displayIndex ) {
                    if ( $.inArray(data.DT_RowId, selected) !== -1 ) {
                        $(row).find('td:first input').prop('checked', true);
                    }
                },
                drawCallback: function(){
                    if(!dateSet){
                        $("#change-request-date").val('SELECT DATE')
                        $("#change-request-time").val('SELECT TIME')
                    }
                }
            });
        }

        // Init picker
        $('#change-request-date').daterangepicker({
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
            $('#change-request-clear-filters').css("display","block");
            employeeAdHocTable.draw()            
        }

        $('#change-request-date').focusin(function(){
            $('.calendar-table').css("display","block");
        });

        $('#change-request-date').focusout(function(e){
            if(startDate == ''){
                if($("#change-request-date").val() == moment().format("DD/MM/YYYY")){
                    setDate(moment())
                }
            }
        });        

        $('#change-request-time').daterangepicker({
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

        $('#change-request-time').focusin(function(){
            $('.calendar-table').css("display","none");
        });

        $('#change-request-time').on('hide.daterangepicker', function(){
            if(startDate.split(" ").length == 1){
                $('#change-request-time').val('SELECT TIME')
                // $('#manifest-time').val(moment().startOf('day').format("h:mm A") + ' - ' + moment().endOf('day').format("h:mm A"))
            }
            else{
                $('#change-request-time').val(startDate.split(" ")[1] + ' ' + startDate.split(" ")[2] + ' - ' + endDate.split(" ")[1] + ' ' + endDate.split(" ")[2])
            }
        });

        $('#change-request-time').on('apply.daterangepicker', function(ev, picker) {  
            if(startDate != ''){
                startDate = moment(startDate, "DD-MM-YYYY").format("DD/MM/YYYY") + " " + picker.startDate.format('h:mm A');
            }
            if(endDate != ''){
                endDate = moment(endDate, "DD-MM-YYYY").format("DD/MM/YYYY") + " " + picker.endDate.format('h:mm A');
            }
            startTime = picker.startDate.format('h:mm A')
            endTime = picker.endDate.format('h:mm A')

            $('#change-request-time').val(picker.startDate.format('h:mm A') + ' - ' + picker.endDate.format('h:mm A'))
            $('#change-request-clear-filters').css("display","block");
            employeeAdHocTable.draw()
        });

        $(document).on('click', '.change-request-button', function (e) {
            var data = {
                ids : [$(this).data('id')],
                type: $(this).data('type')
            }

            $.post('/employee_trips_changes', data, {dataType: 'json'})
                .done(function (r) {                  
                    employeeAdHocTable.draw()
                })            
        })

        $('#change-request-direction').on('change', function () {
            direction = +$(this).val();
            $('#change-request-clear-filters').css("display","block");
            employeeAdHocTable.draw()
        });

        $('#change-request-type').on('change', function () {
            type = +$(this).val();
            $('#change-request-clear-filters').css("display","block");
            employeeAdHocTable.draw()             
        });

        $('#change-request-search').on('click', function(e){
            search = $('#change-request-value')[0].value
            $('#change-request-clear-filters').css("display","block"); 
            employeeAdHocTable.draw()
        })

        $("#change-request-value").keypress(function(e) {
            if(e.which == 13) {
                $('#change-request-clear-filters').css("display","block");
                $('#change-request-search').click();              
            }
        });
    });

    var selected = [];

    $('#employee-adhoc-trip-table').on('change', 'tbody td input', function () {
        var id = $(this).parents('tr').attr("id");
        var index = $.inArray(id, selected);

        if ( index === -1 ) {
            selected.push(id);
        }
        else {
            selected.splice(index, 1)
        }
    });

    // $('#ch-all').on('change', function () {
    //     selected = $('#employee-adhoc-trip-table tbody td input:checked').map(function() {
    //       return $(this).parents('tr').attr("id")
    //     }).get();
    // });

    // // enable action buttons
    // employeeAdHocTable.on('select', function (e, dt, type, indexes) {
    //     $('.adhoc-controls').find('.btn').prop('disabled', false);
    // });

    // // disable action buttons
    // employeeAdHocTable.on('deselect', function (e, dt, type, indexes) {
    //     if (dt.rows({selected: true}).count() == 0) {
    //         $('.adhoc-controls').find('.btn').prop('disabled', true);
    //     }
    // });

    employeeAdHocTable.on('draw.dt', function () {
        if (employeeAdHocTable.rows().count() == 0) {
            $('.adhoc-controls').find('.btn').prop('disabled', true);
        }
    });

    $(document).on('click', '#change-request-clear-filters', function(e){
        startDate = '',
        endDate = '',
        startTime = '',
        endTime = '',
        direction = 2,
        search = '';
        dateSet = false;
        type = 3;

        $('#change-request-date').val('SELECT DATE')
        $('#change-request-time').val('SELECT TIME')
        $('#change-request-typeSelectBoxItText').text("TYPE")        
        $('#change-request-directionSelectBoxItText').text("DIRECTION")
        $('#change-request-value').val('')
        $('#change-request-clear-filters').css("display","none");
        employeeAdHocTable.draw()
    })

    // send ad-hoc request
    // $('.adhoc-controls').on('click', '.btn', function () {
    //     var type = $(this).data('type');
    //     var rowData = employeeAdHocTable.rows('.selected').data().toArray();
    //     var data = {
    //         ids: [],
    //         type: type
    //     };

    //     rowData.forEach(function (item) {
    //         data.ids.push(item.id);
    //     });

    //     // send request
    //     $.post("/employee_trips_changes", data, {dataType: 'json'})
    //         .done(function (r) {
    //             employeeAdHocTable.rows({selected: true}).remove().draw(false);
    //         })
    //         .fail(function (r) {
    //             $('#error-placement').html(
    //                 '<div class="alert alert-danger fade in"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>' + r.responseText + '</div>'
    //             );
    //         });
    // });
});