// $(function () {
//     'use strict';

//     /**
//      * Init table
//      */
//     var employerInvoicesTable = $('#employer-invoices-table').DataTable({
//         serverSide: true,
//         ajax: {
//             url: "/invoices",
//             data: {
//                 company_type: 'EmployeeCompany'
//             }
//         },
//         lengthChange: false,
//         searching: false,
//         processing: true,
//         ordering: false,
//         pageLength: 15,
//         pagingType: "simple_numbers",
//         paging: true,
//         info: false,
//         autoWidth: false,
//         columns: [
//             {
//                 data: null,
//                 render: function (data) {
//                     return '<a href="#">' + data.date + '-' + data.id + '</a>';
//                 }
//             },
//             {data: 'logistics_company'},
//             {data: 'trips_count'},
//             {data: 'amount'},
//             {
//                 data: 'status',
//                 className: 'text-center',
//                 render: function (data) {
//                     if (data === 'created') {
//                         return '<a href="#" class="text-primary invoice-status">Mark as paid</a>';
//                     }
//                     return data;
//                 }
//             }
//         ],
//         createdRow: function (row, data) {
//             $(row).data('id', data.id);
//         }
//     });

//     var operatorCustomerInvoicesTable = $('#operator-customer-invoices-table').DataTable({
//         serverSide: true,
//         ajax: {
//             url: "/invoices",
//             data: {
//                 company_type: 'EmployeeCompany'
//             }
//         },
//         lengthChange: false,
//         searching: false,
//         ordering: false,
//         pagingType: "simple_numbers",
//         info: false,
//         processing: true,
//         paging: false,
//         autoWidth: false,
//         columns: [
//             {
//                 data: null,
//                 render: function (data) {
//                     return '<a href="' + data.invoice_url + '">' + data.date + '-' + data.id + '</a>';
//                 }
//             },
//             {data: 'company'},
//             {data: 'trips_count'},
//             {data: 'amount'},
//             {
//                 data: 'status',
//                 className: 'text-center',
//                 render: function (data, type, row) {
//                     if (data === 'created') {
//                         return '<a href="#" class="text-primary invoice-status">Mark as paid</a>';
//                     }
//                     return data;
//                 }
//             }
//         ],
//         createdRow: function (row, data) {
//             $(row).data('id', data.id);
//         }
//     });

//     var operatorBaInvoicesTable = $('#operator-ba-invoices-table').DataTable({
//         serverSide: true,
//         ajax: {
//             url: "/invoices",
//             data: {
//                 company_type: 'BusinessAssociate'
//             }
//         },
//         lengthChange: false,
//         searching: false,
//         ordering: false,
//         pagingType: "simple_numbers",
//         paging: false,
//         info: false,
//         autoWidth: false,
//         columns: [
//             {
//                 data: null,
//                 render: function (data) {
//                     return '<a href="' + data.invoice_url + '">' + data.date + '-' + data.id + '</a>';
//                 }
//             },
//             {data: 'company'},
//             {data: 'trips_count'},
//             {data: 'amount'},
//             {
//                 data: 'status',
//                 className: 'text-center',
//                 render: function (data) {
//                     if (data === 'created') {
//                         return '<a href="#" class="text-primary invoice-status">Mark as paid</a>';
//                     }
//                     return data;
//                 }
//             }
//         ],
//         createdRow: function (row, data) {
//             $(row).data('id', data.id);
//         }
//     });

//     //change invoice status
//     $(document).on('click', 'table .invoice-status', function (e) {
//         e.preventDefault();

//         var id = $(this).closest('tr').data('id');
//         var cell = $(this).closest('td');
//         $.ajax({
//             url: '/invoices/' + id + '/paid/',
//             type: "POST",
//             dataType: 'text'
//         }).done(function (r) {
//             if (r) {
//                 cell.html('paid');
//             }
//         }).fail(function (r) {

//         });
//     });
// });