$(function () {
    'use strict';

    /**
     * Init Table
     */
    var table = '#operator-leave-requests-table';
    var leaveRequestTable = $();

    $('a[href="#operator-leave-requests"]').on('shown.bs.tab', function (e) {
        if (loadedTabs['operator-leave-requests']) return;

        // set loaded state
        loadedTabs['operator-leave-requests'] = true;

        if (!loadedDatatables[table]) {

            leaveRequestTable = $(table).DataTable({
                serverSide: true,
                ajax: "/driver_requests",
                lengthChange: false,
                searching: false,
                pagingType: "simple_numbers",
                info: false,
                processing: true,
                autoWidth: false,
                ordering: false,
                select: {
                    style: 'multi',
                    selector: '.nice-checkbox label'
                },
                columns: [
                    {data: "request_date"},
                    {
                        data: null,
                        orderable: false,
                        render: function (data) {
                            return data.type + " - " + data.status
                        }
                    },
                    {
                        data: null,
                        render: function(data) {
                            var result = '';
                            if (data.driver_phone != '') {
                                result += '<div style="float:left">' + data.driver_name + '</div>'  + ' <div style="float:right; top:2px; position:relative"><a href="#" id="call-person" data-number="' + data.driver_phone + '>'+
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
                            return result;
                        }
                    },
                    {data: 'reason'},
                    {data: 'start_date'},
                    {data: 'end_date'},
                    {
                        data: null,
                        width: '5%',
                        className: 'text-center ch-row',
                        orderable: false,
                        render: function (data) {
                            return '<div class="nice-checkbox text-primary"><input id="ch-' + data.id + '" type="checkbox"><label for="ch-' + data.id + '"></label></div>';
                        }

                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                     // var info = this.api().page.info();
                     // $('#adhoc-trips-count').text("Total Adhoc Trips: " + info.recordsTotal);
                },
                rowCallback: function ( row, data, displayIndex ) {
                    if ( $.inArray(data.DT_RowId, selected) !== -1 ) {
                        $(row).find('td:last input[type="checkbox"]').prop('checked', true);
                    }
                }
            });

        }
    });

    var selected = [];

    $('#operator-leave-requests-table').on('change', 'tbody td:last input', function () {
        var id = $(this).parents('tr').attr("id");
        var index = $.inArray(id, selected);

        if ( index === -1 ) {
            selected.push(id);
        }
        else {
            selected.splice(index, 1)
        }
    });
    $('#ch-all').on('change', function () {
        selected = $('#operator-leave-requests-table tbody td input:checked').map(function() {
          return $(this).parents('tr').attr("id")
        }).get();
    });

    // enable action buttons
    leaveRequestTable.on('select', function (e, dt, type, indexes) {
        $('.leave-controls').find('.btn').prop('disabled', false);
    });

    // disable action buttons
    leaveRequestTable.on('deselect', function (e, dt, type, indexes) {
        if (dt.rows({selected: true}).count() == 0) {
            $('.leave-controls').find('.btn').prop('disabled', true);
        }
    });

    leaveRequestTable.on('draw.dt', function () {
        if (leaveRequestTable.rows().count() == 0) {
            $('.leave-controls').find('.btn').prop('disabled', true);
        }
    });

    // send ad-hoc request
    $('.leave-controls').on('click', '.btn', function () {
        var type = $(this).data('type');
        var rowData = leaveRequestTable.rows('.selected').data().toArray();
        var data = {
            ids: [],
            type: type
        };

        rowData.forEach(function (item) {
            data.ids.push(item.id);
        });

        // send request
        $.post("/driver_requests", data, {dataType: 'json'})
            .done(function (r) {
                leaveRequestTable.rows({selected: true}).remove().draw(false);
            })
            .fail(function (r) {
                $('#error-placement').html(
                    '<div class="alert alert-danger fade in"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>' + r.responseText + '</div>'
                );
            });
    });
});
