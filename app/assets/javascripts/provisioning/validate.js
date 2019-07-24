$(function(){

  $.validate = function(_this, name, fields, url, formElement) {
    if ($.inArray(name, fields) >= 0) {
      var fieldName = $.grep(name.split(/[[\]]{1,2}/), function(e){ if (e !== "") {return e} });
      var formAttribute;
      $.call(url, formElement, _this, fieldName);
    } else {
      ((_this.attr("type") === "checkbox" && !_this.is(":checked")) || _this.val().length == 0) ? $.addErrorMessage(_this) : $.removeErrorMessage(_this);
    }
  }

  $.addErrorMessage = function(selector, msg='cant be blank') {
    selector.closest("div").addClass("has-error");
    selector.closest("div").find("span").remove();
    spanTxt = '<span class="help-block">'+ msg +'</span>';
    selector.closest("div").append(spanTxt);
  }

  $.removeErrorMessage = function(selector) {
    selector.closest("div").removeClass("has-error");
    selector.closest("div").find("span").remove();
  }

  $.showLoader = function() {
    $(".loading").show();
  }

  $.hideLoader = function() {
    $(".loading").hide();
  }

  $.call = function(url, formElement, _this="", fieldName="", submit=false) {
    var data = $.grep(formElement.serializeArray(), function(e, i) {return e.name == "_method"}, true)
    var editObj = formElement.serializeArray().reduce(function(prev, current) { return (current.name === "_method") ? current : prev; }, null);
    if (editObj !== null) { data.push({name: "id", value: formElement.attr("action").split("/").slice(-1)}) }

    $.ajax({
      type: "POST",
      url: url,
      data: data,
      beforeSend: function(){
        $.showLoader();
         document.onkeydown = function (e) { return false }
      },
      success: function(data) {
        if (_this !== "" && fieldName !== "") {
          var formAttribute = fieldName.slice(1).length > 1 ? ["entity", fieldName.slice(-1)[0]].join(".") : fieldName.slice(-1)[0]
          data[formAttribute] === undefined ? $.removeErrorMessage(_this) : $.addErrorMessage(_this, data[formAttribute][0]);
        } else {
          $.each($(".has-error"), function(i, errClass){ $(errClass).removeClass("has-error"); $(errClass).find("span").remove(); });
          $.each(Object.keys(data), function(i, err) {
            var fieldClass = "input[name$='[" + err.split(".").slice(-1) + "]']";
            var fieldSelector = formElement.find(fieldClass);
            fieldSelector.length > 0 ? $.addErrorMessage(fieldSelector, data[err][0]) : $.removeErrorMessage(fieldSelector);
          });
          if(submit && $(".has-error").length == 0 ) {
            formElement.submit();
          }
        }
        $.hideLoader();
        document.onkeydown = function (e) {return true }
      }
    });
  }

});
