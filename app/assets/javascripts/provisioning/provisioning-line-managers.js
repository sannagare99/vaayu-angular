var lineManagersTableEditor;

$(function () {
    'use strict';

    /**
     * Employers Users Table
     */
    var table = '#line-managers-table';;
    var lineManagerTable = $();

    lineManagersTableEditor = new $.fn.dataTable.Editor({
        table: table,
        ajax: {
            edit: {
                type: 'PATCH',
                url: '/line_managers/_id_'
            },
            remove: {
                type: 'DELETE',
                url: '/line_managers/_id_'
            }
        },
        fields: [{
            label: 'First name',
            className: "col-md-4",
            name: "f_name"
        }, {
            label: 'Middle name',
            className: "col-md-4",
            name: "m_name"
        }, {
            label: 'Last name',
            className: "col-md-4",
            name: "l_name"
        }, {
            label: 'Email',
            className: "col-md-4 col-md-offset-4 clear",
            name: "email"
        }, {
            label: "Line Manager Attributes:",
            className: "col-md-4 clear",
            name: "customer_info",
            type: "title"
        }, {
            label: 'Phone',
            className: "col-md-4",
            name: "phone"
        }]
    });

    $('a[href="#line-managers"]').on('shown.bs.tab', function () {
        if (loadedTabs['line-managers']) return;

        // set loaded state
        loadedTabs['line-managers'] = true;

        if (!loadedDatatables[table]) {

            lineManagerTable = $(table).DataTable({
                serverSide: true,
                ajax: "/line_managers",
                lengthChange: false,
                searching: false,
                pagingType: "simple_numbers",
                ordering: false,
                processing: true,
                info: false,

                columns: [
                    {data: "entity_attributes.id"},
                    {
                        data: null,
                        render: function (data) {
                            return '<a href="/line_managers/'+ data.id +'/edit" class="edit line_manager_edit" data-remote=true>' + data.name + '</a>';
                        }
                    },
                    {data: "entity_attributes.company"},
                    {data: "email"},
                    {data: "phone"},
                    {
                        data: null,
                        render: function (data) {
                            return '<a href="/line_managers/' + data.id + '/edit_list" data-remote="true" class="edit_employee_list">Edit List</a>';
                        }
                    },
                    {data: "status"},
                    {
                        data: null,
                        render: function (data) {
                            var txt = data.status === "Pending" ? '<a href="#" data-url="/line_managers/'+ data.id +'/invite" class="invite-count"><span>Invite('+ data.invite_count +')</span></a> ' : ''
                            txt += '<a href="#" class="editor_remove line_manager_remove text-danger">Delete</a>';
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

    // Edit record
    $(table).on('click', 'a.editor_edit.line_manager_edit', function (e) {
        e.preventDefault();

        lineManagersTableEditor
            .title('Edit Line Manager')
            .buttons([
                {
                    label: "Close",
                    className: 'btn btn-sm btn-default',
                    fn: function () {
                        this.close()
                    }
                }, {
                    label: "Save changes",
                    className: 'btn btn-sm btn-primary',
                    fn: function () {
                        this.submit()
                    }
                }])
            .edit($(this).closest('tr'));
    });

    // Delete record
    $(table).on('click', 'a.editor_remove.line_manager_remove', function (e) {
        e.preventDefault();

        lineManagersTableEditor
            .title('Delete Line Manager')
            .message("Are you sure you wish to delete this Line Manager?")
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

    // Re invite action
    $(table).on('click', 'a.invite-count', function (e) {
        $.getJSON( $(this).attr("data-url"))
          .done(function() {
            lineManagerTable.draw(false);
          });
        e.preventDefault();
    });

    // Reload table
    $("#line-managers.tab-pane").on('click', 'a.reload-button', function (e) {
        lineManagerTable.draw(false);
        e.preventDefault();
    });

});

function selectEmployeeCheckbox(currentObject, checkedVal="") {
  if (checkedVal === "") {
    inputVal = currentObject.is(":checked") ? line_manager_id : "";
  } else {
    inputVal = checkedVal ? line_manager_id : "";
    currentObject.prop("checked", checkedVal);
  }
  currentObject.closest("tr").find(".line-manager-id").val(inputVal);
  updateSelectedCount();
}

function updateSelectedCount() {
  $(".selected-employee-count span").text($(".employee-select-check:checked").length);
}

function reloadEmployeeList(search) {
  var tr = $(".employee-list-table tr");
  for (i = 0; i < tr.length; i++) {
    var trObj = $(tr[i]);
    td = trObj.find("td:first");
    if (td) {
      td.text().toLowerCase().indexOf(search.toLowerCase()) > -1 ? trObj.show() : trObj.hide();
    }
  }
}
