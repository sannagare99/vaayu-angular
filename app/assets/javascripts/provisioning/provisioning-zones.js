var zonesTableEditor;

$(function () {
    'use strict';

    /**
     * Zones Table Editor
     */

    var table = '#zones-table';
    var zoneTable = $();

    zonesTableEditor = new $.fn.dataTable.Editor({
        table: table,
        ajax: {
            create: {
                type: 'POST',
                url: '/zones'
            },
            edit: {
                type: 'PUT',
                url: '/zones/_id_'
            },
            remove: {
                type: 'DELETE',
                url: '/zones/_id_'
            }
        },
        fields: [{
            label: 'Zone name',
            className: "col-md-6",
            name: "name"
        }]
    });

    // // New record
    // $(document).on('click', '.provisioning a.editor_create.zones', function (e) {
    //     e.preventDefault();

    //     zonesTableEditor
    //         .title('Create new zone')
    //         .buttons([{
    //             label: "Close",
    //             className: 'btn btn-sm btn-default',
    //             fn: function () {
    //                 this.close()
    //             }
    //         }, {
    //             label: "Submit",
    //             className: 'btn btn-sm btn-primary btn-fixed-width',
    //             fn: function () {
    //                 this.submit()
    //             }
    //         }])
    //         .create();
    // });

    // // Edit record
    // $(table).on('click', 'a.editor_edit', function (e) {
    //     e.preventDefault();

    //     zonesTableEditor
    //         .title('Edit zone')
    //         .buttons([
    //             {
    //                 label: "Close",
    //                 className: 'btn btn-sm btn-default',
    //                 fn: function () {
    //                     this.close()
    //                 }
    //             }, {
    //                 label: "Save changes",
    //                 className: 'btn btn-sm btn-primary',
    //                 fn: function () {
    //                     this.submit()
    //                 }
    //             }])
    //         .edit($(this).closest('tr'));
    // });

    // Delete record
    $(table).on('click', 'a.editor_remove', function (e) {
        e.preventDefault();

        zonesTableEditor
            .title('Delete zone')
            .message("Are you sure you wish to delete this zone?")
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

    $('a[href="#zones"]').on('shown.bs.tab', function (e) {
        if (loadedTabs['zones']) return;

        // set loaded state
        loadedTabs['zones'] = true;

        if (!loadedDatatables[table]) {

            zoneTable = $(table).DataTable({
                serverSide: true,
                ajax: "/zones",
                lengthChange: false,
                searching: false,
                order: [[0, 'desc']],
                pagingType: "simple_numbers",
                info: false,
                processing: true,

                columns: [
                    {data: "id"},
                    {
                        data: null,
                        render: function (data) {
                            return '<a href="/zones/'+ data.id +'/edit" class="edit" data-remote=true>' + data.name + '</a>'
                        }

                    },
                    {
                        data: null,
                        orderable: false,
                        render: function (data) {
                            return '<a href="" class="editor_remove text-danger">Delete</a>'
                        }
                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                     var info = this.api().page.info();
                     $('#zones-count').text("Total Zones: " + info.recordsTotal);
                }
            });
        }
    });

    // Reload table
    $("#zones.tab-pane").on('click', 'a.reload-button', function (e) {
        zoneTable.draw(false);
        e.preventDefault();
    });
});