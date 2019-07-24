$(function () {
    'use strict';

    /**
     * Configurator Users Table
     */
    var table = '#configurators-table';
    var configuratorTable = $();

    $('a[href="#configurators"]').on('shown.bs.tab', function (e) {
        // if (loadedTabs['configurators']) return;

        // set loaded state
        // loadedTabs['configurators'] = true;

        if (!loadedDatatables[table]) {

            configuratorTable = $(table).dataTable({
                serverSide: true,
                ajax: "/configurations",
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
                        data: "s_no",
                        orderable: false
                    },
                    {
                        data: "name",
                        orderable: false
                    },
                    {
                        data: null,
                        orderable: false,
                        render: function (data) {
                            return  '<a href="/configurators/edit" data-remote="true" class="edit"><span>Edit Configuration</span></a> ';
                        }
                    }
                ],
                initComplete: function () {
                    loadedDatatables[table] = true;
                }
            });

        }

    });
    
});

