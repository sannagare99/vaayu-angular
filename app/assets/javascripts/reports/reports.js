$(function () {
  'use strict';

  $(".report-download-button").on("click", function(){
    $(this).closest(".reportDownloadModal").modal('hide');
  });

  $(".report-modal-button").on("click", function(){
    $(this).closest(".reports-section").find(".reportDownloadModal").modal('show');
  });
});

function send_report(start_date, end_date, modalElem) {  
  var emails = modalElem.find(".email").val();
  if (emails !== "") {
    $.post(modalElem.find(".send-report-button").attr("href"), { startDate: start_date, endDate: end_date, emails: emails }).done(function(data){
        modalElem.modal('hide');
    });
  }
  modalElem.find(".email").val("");
}
