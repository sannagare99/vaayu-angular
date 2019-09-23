$(function () {
    'use strict';

    var table = '#shifts-table';
    var shiftsTable = $();
    var focusOutTimer;


    $('a[href="#shifts"]').on('shown.bs.tab', function (e) {
        if (loadedTabs['shifts']) return;

        // set loaded state
        loadedTabs['shifts'] = true;
        
        if (!loadedDatatables[table]) {

            shiftsTable = $(table).DataTable({
                serverSide: true,
                ajax: "/shifts",
                lengthChange: false,
                searching: false,
                order: [[0, 'desc']],
                pagingType: "simple_numbers",
                processing: true,
                info: false,
                language: {
                    emptyTable: "No result"
                },
                columns: [
                    {
                        data: null,
                        orderable: false,
                        render: function (data) {
                            return '<a href="/shifts/' + data.id + '/edit" data-remote="true" class="edit">' + data.name + '</a>';
                        }
                    },
                    { data: "start_time", orderable: false },
                    { data: "end_time", orderable: false },
                    { data: "status", orderable: false },
                    {
                        data: null,
                        orderable: false,
                        render: function (data) {
                            var txt = data.status.toLowerCase() === "active" ? '<a herf="#" data-url="/shifts/'+ data.id +'/change_status?status=deactivate" class="text-danger change-status">Deactivate</a>' : '<a href="#" data-url="/shifts/'+ data.id +'/change_status?status=activate" class="change-status">Activate</a>';
                            return txt;
                        }
                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            }); 

        }

    });

    // Activate and De-Activate
    $(table).on('click', 'a.change-status', function (e) {
        $.getJSON( $(this).attr("data-url"))
          .done(function(data) {
            shiftsTable.draw(false);
          })
          .fail(function(data) {
            $("#modal-shift-deactive-warning").modal();
          });
        e.preventDefault();
    });

    // Form Validation
    $("#shifts").on("focusout", ".live-validation input.required, select.required", function(e){
        var _this = this;
        focusOutTimer = setTimeout(function () {
            var fields = ['shift[name]', 'shift[start_time]', 'shift[end_time]','sift[name_2]']; // Rushikesh made changes here add field here
            $.validate($(_this), _this.name, fields, "/shifts/validate", $("#form-shifts"))
        }, 200)
    });

    $(".nav-actions").on("click", ".edit-buttons .submit-btn.form-shifts", function(e) {
        clearTimeout(focusOutTimer);
        $.call("/shifts/validate", $("#form-shifts"), "", "", true);
        $("select.required").focusout();
        e.preventDefault();
    })

    // Reload table
    $("#shifts.tab-pane").on('click', 'a.reload-button', function (e) {
        shiftsTable.draw(false);
        e.preventDefault();
    });
});

function timepickerChangeEvent(e, selector) {
    var timePicked = selector.val();
    if(timePicked.length < 5){ selector.val("0" + timePicked) };
}

function setDefaultTime() {
    $.each(['#shift_start_time', '#shift_end_time'], function(i, e){
        if ($(e).val() === "") { $(e).val("00:00") }
    });
}
