$(function () {
    'use strict';

    // init billing summary trips table
    $('#reports-billing-summary-table').DataTable({
        // serverSide: true,
        // ajax: {
        //     url: "/trips",
        //     data: {
        //         status: 'completed'
        //     }
        // },
        searching: false,
        lengthChange: false,
        pagingType: "simple_numbers",
        paging: false,
        info: false,
        autoWidth: false,
        ordering: false
        // columns: [
        //     {data: "company"},
        //     {data: "latitude"},
        //     {data: "longitude"}
        // ]
    });

});