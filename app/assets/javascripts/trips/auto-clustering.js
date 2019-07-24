$(function() {
  var vehicleClasses = {};
  function vehicleClassEdit(ctx, editable) {
    var vehicleClassElem = $(ctx)
      .parent('.actions')
      .prevAll('.vehicle-class-capacity');
    vehicleClassElem
      .prop('contenteditable', editable)
      .toggleClass('editable', editable);

    var vehicleQuantityElem = $(ctx)
      .parent('.actions')
      .prevAll('.vehicle-class-quantity');
    vehicleQuantityElem
      .prop('contenteditable', editable)
      .toggleClass('editable', editable);
  }
  window.getFleetMix = function () {
    return Object.keys(vehicleClasses).map((k) => vehicleClasses[k]);
  };

  $(document).on('click', '.vehicle-class-edit', function(e) {
    e.preventDefault();
    $(this).addClass('hide');
    $(this).next('.vehicle-class-save').removeClass('hide');
    vehicleClassEdit(this, true);
  });

  $(document).on('click', '.vehicle-class-save', function(e) {
    e.preventDefault();
    $(this).addClass('hide');
    $(this).prev('.vehicle-class-edit').removeClass('hide');
    vehicleClassEdit(this, false);
    var id = $(this).parents('.vehicle-class').prop('id');
    vehicleClasses[id] = {
      capacity: parseInt($(this).parents('.actions').prevAll('.vehicle-class-capacity').text(), 10),
      quantity: parseInt($(this).parents('.actions').prevAll('.vehicle-class-quantity').text(), 10),
    };
  });

  $(document).on('click', '.vehicle-class-remove', function(e) {
    e.preventDefault();
    $(this).parents('.vehicle-class').remove();
  });

  $(document).on('click', '#add-vehicle-class', function() {
    var template = $('.vehicle-class-template').html();
    var id = 'vehicle-class-' + (Object.keys(vehicleClasses).length+1);
    $('<div id=' + id + ' class="vehicle-class">' + template + '</div>')
      .insertBefore('.vehicle-class-template')
      .find('.vehicle-class-edit')
      .trigger('click');
    vehicleClasses[id] = {
      capacity: 4,
      quantity: 1
    };
  });

  $('#clustering-strategy').on('change', function () {
    if ($(this).val() === 'routing' || $(this).val() === 'proximity' || $(this).val() === 'hybrid') {
      $('#clustering-threshold-wrapper').removeClass('hide');
      $('#clustering-large-vehicle-wrapper').removeClass('hide');
    } else {
      $('#clustering-threshold-wrapper').addClass('hide');
      $('#clustering-large-vehicle-wrapper').addClass('hide');
    }

    if ($(this).val() === 'hybrid') {
      $('#clustering-route-deviation-wrapper').removeClass('hide');
      $('#clustering-cluster-alone-threshold-wrapper').removeClass('hide');
    } else {
      $('#clustering-route-deviation-wrapper').addClass('hide');
      $('#clustering-cluster-alone-threshold-wrapper').addClass('hide');
    }
  });

  $('#modal-clustering-configuration').on('hidden.bs.modal', function() {
    $('.vehicle-class .vehicle-class-save').trigger('click');
  });
});
