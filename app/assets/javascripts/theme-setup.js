// collect datatables init status
var loadedDatatables = [];
var loadedTabs = [];
var selectedMarker = [];
var selectedRow = "";
/**
 * Mapped data for trip info modal map
 */
var tripInfoMarkersData = [];

$(function () {
    'use strict';
    showActiveTab();

    /**
     * ANIMATE SCROLL, define class .scroll to tag <a> will be activate this
     */
    $(document).on('click', 'a.scroll', function (e) {
        e.preventDefault();
        $("html,body").animate({scrollTop: $(this.hash).offset().top + 5}, 600);
    });
    // END ANIMATE SCROLL

    // init responsive bootstrap tabs
    setTimeout(function() { $('.nav-tabs').tabdrop({text: 'More'}) }, 1000)

    /**
     * TOGGLE SIDE RIGHT
     */
    $(document).on('click', '[data-toggle="side-right"]', function (e) {
        e.preventDefault();

        $('.section, .header').toggleClass('translate-left');
        $('.side-right').toggleClass('toggle');

        // side-right module chat
        // show scroll on module
        $('.module[data-toggle="niceScroll"]').getNiceScroll().show();
        // hide chatbox
        $('.chatbox').removeClass('show');
    });
    // END TOGGLE ACTIONS

    /**
     * BOOTSTRAP INPUT GROUP HACK
     */
    $(document).on('focus', '.input-group-in .form-control', function () {
        var group = $(this).parent();

        if (group.hasClass('twitter-typeahead') || group.hasClass('minicolors')) {
            group.parent().addClass('focus');
        }
        else if (group.hasClass('input-group-in')) {
            group.addClass('focus');
        }
    })
        .on('blur', '.input-group-in .form-control', function () {
            var group = $(this).parent();

            if (group.hasClass('twitter-typeahead') || group.hasClass('minicolors')) {
                group.parent().removeClass('focus');
            }
            else if (group.hasClass('input-group-in')) {
                group.removeClass('focus');
            }
        });
    // END BOOTSTRAP INPUT GROUP HACK


    /**
     * COLLAPSE
     */
    $(document).on('click.bs.collapse.data-api', '[data-toggle=collapse]', function (e) {
        var $this = $(this),
            panel_heading = ($this.parent().hasClass('panel-heading')) ? $this.parent() : $this.parent().parent(),
            group = $($this.data('parent'));

        // add all btn-collapsed
        group.find('[data-toggle="collapse"]').addClass('btn-collapsed');

        // remove .btn-collapsed if not .collapsed
        if (!$this.hasClass('collapsed')) {
            panel_heading.find('[data-toggle="collapse"]').removeClass('btn-collapsed');
        }
        ;
    });
    // END COLLAPSE

    /**
     * Change modal button text
     */
    $('.modal').on('show.bs.modal', function (e) {
        var $modalSubmit = $('.modal').find('.submit-modal');
        if ($(e.relatedTarget).hasClass('add-new-item')) {
            $modalSubmit.text('Submit');
        } else {
            $modalSubmit.text('Save changes');
        }
    });

    /**
     * Set focus on first input on modal open
     */
    $(".modal").on('shown.bs.modal', function () {
        $(this).find("input:visible:first").focus();
    });

    /**
     * Hide "add" button on logistic companies users
     */
    $('.logistic-companies-tabs a').on('show.bs.tab', function (e) {
        if ($(e.target).closest('li').hasClass('logistic-companies-users')) {
            $('.nav-actions .add-new-item').hide();
        } else {
            $('.nav-actions .add-new-item').show();
        }
    });


    /**
     * Select all checkboxes
     */
    $('#ch-all').change(function () {
        $('.ch-row [type="checkbox"]').prop('checked', $(this).prop("checked"));

    });

    // checkbox change
    $('.ch-row [type="checkbox"]').change(function () {
        if (false == $(this).prop("checked")) {
            $("#ch-all").prop('checked', false);
        }

        // check "select all" if all checkbox items are checked
        if ($('.ch-row [type="checkbox"]:checked').length == $('.ch-row [type="checkbox"]').length) {
            $("#ch-all").prop('checked', true);
        }
    });

    $(document).on('click', '.unassigned-roster-btn, .btn-trip-info, #assign-trip-roster, #complete_with_exception', function () {
        var $table = $(this).closest('table');

        // add loader
        $('<div class="loader-wrap"><div class="loader-typing"></div></div>').appendTo($table);

        $(this).closest('tr').addClass('is-show-info');
        var dataTable = $table.DataTable();
        var rowData = dataTable.row('.is-show-info').data();

        if(rowData == undefined) {
            table = '#operator-unassigned-rosters-table';
            dataTable = $(table).DataTable();
            rowData = dataTable.row({selected: true}).data();
        }
        tripInfoMarkersData = rowData;
    });

    // change assign roster modal title
    $(document).on('click', '#assign-trip-roster-modal', function () {  
        if (tripInfoMarkersData) {
            $.ajax({
                type: "POST",
                data: {
                    type: 'match'
                },
                url: '/trips/' + tripInfoMarkersData.id + '/get_drivers'
            });
        }
    });
    // function setTripMapData(rowData) {
    //     if(rowData){
    //         tripInfoMarkersData = {
    //             site: {lat: rowData.site_lat, lng: rowData.site_lng},
    //             data: []
    //         };

    //         // if (rowData.status === 'completed' || rowData.status === 'cancel') {
    //         //     tripInfoMarkersData.type = 'employee-basic'
    //         // }

    //         tripInfoMarkersData.data = setRouteMarkersData(rowData.trip_routes);
    //     }
    // }

    $(document).on('click','.unassigned-roster-btn', function () {
        var $table = $(this).closest('table');

        // add loader
        $('<div class="loader-wrap"><div class="loader-typing"></div></div>').appendTo($table);
    });

    // select map marker in table
    $(document).on('click', '.map-picker-ico a', function (e) {
        e.preventDefault();

        var self = $(this);
        var selected = self.hasClass('active');
        var $table = self.closest('table');

        var rowData = $table.DataTable().row('.is-selected').data();
        $table.find('.map-picker-ico a.active').removeClass('active');
        if (!selected) {
            selectedRow = rowData.DT_RowId;
            self.addClass('active');
            selectedMarker = self;
            if(rowData.status == 'completed' || rowData.status == 'canceled') {
                $('#employee_record').removeClass('hidden');
                var total = 0;
                var missed = 0;
                var serviced = 0;
                var canceled = 0;
                var canceled_with_exception = 0;
                for(var i = 0; i < rowData.trip_routes.length; i++) {
                    total++;
                    if(rowData.trip_routes[i].status == 'canceled') {
                        if(rowData.trip_routes[i].cancel_exception == null)
                            canceled++;
                        else
                            canceled_with_exception++;
                    } else if(rowData.trip_routes[i].status == 'missed') {
                        missed++;
                    } else {
                        serviced++;
                    }
                }
                $('#total-employees-count').text("Total Employees: " + total);
                $('#total-serviced-count').text("Serviced: " + serviced);
                $('#total-missed-count').text("No Shows: " + missed);
                $('#total-canceled-count').text("Cancelled: " + canceled);
                if(canceled_with_exception > 0) {
                    $('#complete_with_exception_row').removeClass('hidden');
                    $('#total-canceled-with-exception-count').text("Complete with Exception: " + canceled_with_exception);
                } else {
                    $('#complete_with_exception_row').addClass('hidden');
                }
            } else if(rowData.status == 'created' || rowData.status == 'assign_request_declined') {
                $('#employee_summary').removeClass('hidden');
                $('#total-employees-count').text("Total Employees: " + rowData.trip_routes.length);
                $('#total-distance').text("Total Duration: " + rowData.planned_approximate_duration);
                $('#total-duration').text("Total Distance: " + rowData.planned_approximate_distance);
            }
        } else {
            $('#employee_summary').addClass('hidden');
            $('#employee_record').addClass('hidden');
        }
    });

    var tripInfoModalMapID = 'map-trip-info';

    // init modal trip info route map
    // $(document).on('shown.bs.modal', '#modal-trip-info, #book-ola-uber-modal', function () {
    //     console.log(tripInfoMarkersData);
    //     if(tripInfoMarkersData.data) {
    //         initRouteMap(tripInfoMarkersData, tripInfoModalMapID)
    //     }
    // });

    $(document).on('shown.bs.modal', '#modal-trip-info, #book-ola-uber-modal, #modal_show_trip_on_dispatch', function() {
        showMapRouteOnModal(tripInfoModalMapID, tripInfoMarkersData);
    });

    $(document).on('hide.bs.modal', '#modal-employer-tr-confirm', function() {
      $('#error-message').text('');
    });

    // remove helper class on modal hide
    $(document).on('hide.bs.modal', '#modal-trip-info', function () {
        $('.is-show-info').removeClass('is-show-info');
        $('.loader-wrap').remove();
    });

    // Change hash for page-reload
    $('a[data-toggle="tab"]').on('click', function (e) {
        window.location.hash = this.hash;
    });

    // remove loader window
    $(document).on('hide.bs.modal', '#modal-operator-unassigned-rosters', function () {
        $('.is-show-info').removeClass('is-show-info');
        $('.loader-wrap').remove();
     });

    // remove loader window
    $(document).on('hide.bs.modal', '#book-ola-uber-modal', function () {
        $('.is-show-info').removeClass('is-show-info');
        $('.loader-wrap').remove();
     });

    // remove loader window
    $(document).on('hide.bs.modal', '#complete-with-exception', function () {
        $('.is-show-info').removeClass('is-show-info');
        $('.loader-wrap').remove();
     });

    // redraw datatables
    setInterval(function () {
        updateDataTables();
        updateBadgeCount();
    }, 60000);

    // update last active time every 5 minutes
    setInterval(function () {
        updateLastActiveTime();
    }, 120000);

    // update table on tab change
    $('.trips-tabs a[data-toggle="tab"]').on('shown.bs.tab', updateDataTables);

});

/**
 * Set active tab based on page load
 */
function showActiveTab() {
    var hash = window.location.hash;

    setTimeout(function () {
        if (hash) {
            $('ul.nav-tabs a[href="' + hash + '"]').tab('show');
        } else {
            // set first tab active on page load
            $('.nav-tabs li a').eq(0).tab('show');
        }

        if ($('body').hasClass('provisioning')) {
            setTabActiveState();
        }
    });
}

/**
 * Redraw tables
 */
function updateDataTables() {
    updateBadgeCount();
    var table = $('.tab-pane.active').find('table.dataTable');
    if (loadedDatatables['#' + table.attr('id')]) {
        if (table.data('auto-update')) {
            var active_map = table.find('.map-picker-ico a.active');
            $('#' + table.attr('id')).on( 'draw.dt', function () {
                var data = $('#' + table.attr('id')).DataTable().rows().data().toArray();
                data.forEach(function(elem, index) {
                    if(selectedRow == elem.DT_RowId) {
                        $('#' + elem.DT_RowId).find('.map-picker-ico a').addClass('active');
                    }
                });
                //selectedMarker.removeClass('active');
                //selectedMarker.addClass('active');
                //table.find('.map-picker-ico a').addClass('active');
            });
	    //table.on( 'draw', function () {
            //   console.log("I am here");
            //   if(active_map.length > 0)
            //       active_map.addClass('active');
            //});
            table.DataTable().draw(false);
            //table.find('.map-picker-ico a.active').addClass('active');
            //if(table.DataTable.settings.length > 0)
            //console.log(table.DataTable.settings[table.DataTable.settings.length - 1]._iRecordsTotal);
        }
    }
}

function setTripInfoMarkersData(rowData) {
    tripInfoMarkersData = rowData;
}

/**
 * Setup call
 */
function initiateCall(number, notificationId) {
    $.ajax({
        type: "GET",
        data: {
            "To": number,
            "notification": notificationId
        },
        url: '/initiate_call'
    }).done(function() {
        alert("You will be contacted soon!");
    });
}

/**
 * Update last active time
 */
function updateLastActiveTime() {
    $.ajax({
        type: "POST",
        url: '/update_last_active_time'
    }).done(function() {
    });
}

/**
 * Update last active time
 */
function updateBadgeCount() {
    // $.ajax({
    //     type: "GET",
    //     url: '/badge_count'
    // }).done(function(response) {
    //     if(response.new_notifications == true) {
    //         $("#new-notification").removeClass('hidden');
    //     } else {
    //         $("#new-notification").addClass('hidden');
    //     }
    //     // if(response.unresolved_notification_count == 0) {
    //     //     $("#badge-unresolved-notification").addClass('hidden');
    //     // } else {
    //     //     $("#badge-unresolved-notification").text(response.unresolved_notification_count);
    //     //     $("#badge-unresolved-notification").removeClass('hidden');
    //     // }
    //     if(response.active_trips_count == 0) {
    //         $("#badge-active-trips").addClass('hidden');
    //     } else {
    //         $("#badge-active-trips").text(response.active_trips_count);
    //         $("#badge-active-trips").removeClass('hidden');
    //     }
    //     if(response.manifest_count == 0) {
    //         $("#badge-assigned-trips").addClass('hidden');
    //     } else {
    //         $("#badge-assigned-trips").text(response.manifest_count);
    //         $("#badge-assigned-trips").removeClass('hidden');
    //     }
    //     // if(response.adhoc_trips_count == 0) {
    //     //     $("#badge-adhoc-trips").addClass('hidden');
    //     // } else {
    //     //     $("#badge-adhoc-trips").text(response.adhoc_trips_count);
    //     //     $("#badge-adhoc-trips").removeClass('hidden');
    //     // }
    //     if(response.unassigned_trips_count == 0) {
    //         $("#badge-unassigned-trips").addClass('hidden');
    //     } else {
    //         $("#badge-unassigned-trips").text(response.unassigned_trips_count);
    //         $("#badge-unassigned-trips").removeClass('hidden');
    //     }
    //     if(response.trip_rosters_count == 0) {
    //         $("#badge-trip-rosters").addClass('hidden');
    //     } else {
    //         $("#badge-trip-rosters").text(response.trip_rosters_count);
    //         $("#badge-trip-rosters").removeClass('hidden');            
    //     }        
    //     if(response.completed_trips_count == 0) {
    //         $("#badge-completed-trips").addClass('hidden');
    //     } else {
    //         $("#badge-completed-trips").text(response.completed_trips_count);
    //         $("#badge-completed-trips").removeClass('hidden');
    //     }
    //     if(response.leave_requests_count == 0) {
    //         $("#badge-leave-requests").addClass('hidden');
    //     } else {
    //         $("#badge-leave-requests").text(response.leave_requests_count);
    //         $("#badge-leave-requests").removeClass('hidden');
    //     }
    //     if(!response.vehicle_tab_notify){
    //         $("#badge-vehicle").addClass('hidden');
    //         $("#badge-things").addClass('hidden');
    //     } else{
    //         $("#badge-vehicle").removeClass('hidden');
    //         $("#badge-things").removeClass('hidden');
    //     }
    //     if(!response.driver_tab_notify){
    //         $("#badge-driver").addClass('hidden');
    //         $("#badge-people").addClass('hidden');
    //     } else{
    //         $("#badge-driver").removeClass('hidden');
    //         $("#badge-people").removeClass('hidden');
    //     }
    //     if(!response.provisioning_tab_notify){
    //         $("#badge-provisioning").addClass('hidden');
    //     } else{
    //         $("#badge-provisioning").removeClass('hidden');
    //     }
    // });
}
