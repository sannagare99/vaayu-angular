$(function() {
  'use strict';

  var ingest_error_table = $('#ingest-errors-table').DataTable({
    ordering: false,
    paging: false,
    info: false,
    searching: false,
    columns: [{
      name: 'Employee ID',
      data: 'employee_id'
    }, {
      name: 'Error',
      data: 'error'
    }]
  });

  var ingest_form_handler = function (form, data) {
    var modal_selector = '#modal-ingest-job-form';
    var stats_modal_selector = '#modal-ingest-job-stats';

    var ingest_job_id = data.id;
    $(form).find('.error-message').text('');

    $(modal_selector).modal('hide');
    $(stats_modal_selector).modal('show');
    $(stats_modal_selector).data('bs.modal').isShown = false;
    $(stats_modal_selector).find('.stats').addClass('hide');
    $(stats_modal_selector).find('.processing').removeClass('hide');
    $(stats_modal_selector).find('.modal-footer button').attr('disabled', true);

    var show_ingest_summary = function (data) {
      $(stats_modal_selector).data('bs.modal').isShown = true;
      $(stats_modal_selector).find('.processing').addClass('hide');
      $(stats_modal_selector).find('.stats').removeClass('hide');
      $(stats_modal_selector).find('.modal-footer button').attr('disabled', false);

      var stats = data.stats,
        error_data = data.error_data;

      form.reset();

      $('#processed-count').text(stats.processed_row_count);
      $('#schedules-updated-count').text(stats.schedule_updated_count);
      $('#employees-provisioned-count').text(stats.employee_provisioned_count);
      $('#schedules-provisioned-count').text(stats.schedule_provisioned_count);
      $('#schedules-assigned-count').text(stats.schedule_assigned_count);
      $('#failed-row-count').text(stats.failed_row_count);

      ingest_error_table.clear();
        if (error_data) {
        ingest_error_table.rows.add(error_data);
      }
      ingest_error_table.draw();
    };

    var ingest_interval;
    var ingest_poller = function () {
      $.ajax({
        type: 'GET',
        url: '/trips/ingest_job/' + ingest_job_id,
      }).done(function(res) {
        if (res.data.status === 'completed' || res.data.status === 'failed') {
          clearInterval(ingest_interval);
          show_ingest_summary(res.data);
        }
      });
    };
    ingest_interval = setInterval(ingest_poller, 1000);
  };

  $('#ingest_job_form').on('ajax:success', function(e, data, status, xhr) {
    var form = $(this)[0];
    ingest_form_handler(form, data);
  }).on('ajax:error', function(e, xhr, status, error) {
    var errorMessage = xhr.responseJSON.fieldErrors[0].status;
    $(this).find('.error-message').text(errorMessage);
  });
});
