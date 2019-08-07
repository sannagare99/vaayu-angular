// Calendar - Employee Trip Module

$(function () {
  'use strict';

  /* Init */
});

function toggleRowHighligh() {
  $(".datepicker table tr:has(td.active)").addClass("datepicker-current-week");
}

function updateCalendarTableHead(selectedDate) {
  weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  currentDate = new Date(selectedDate.date);
  weekNo = getWeek(currentDate);
  dateRange = getDateRangeOfWeek(weekNo, currentDate);
  dates = getDates(dateRange[0], dateRange[1])
  $.each($(".datepicker table tr:has(td.active) td"), function(i, td){
    tableHeadVal = [weekdays[i]]
    tableHeadVal.push(new Date(dates[i]).getMonth() + 1 + '/' + $(td).text())
    nodeVal = parseInt(i) + 1
    tableHeadSelector = ".calendar-week-details table th:nth-child(" + nodeVal + ")"
    $(tableHeadSelector).text(tableHeadVal.join(" "))
  });
}

function updateCalendarTitle(selectedDate) {
  monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
  currentDate = new Date(selectedDate.date);
  weekNo = getWeek(currentDate);
  dateRange = getDateRangeOfWeek(weekNo, currentDate)
  fromDate = monthNames[new Date(dateRange[0]).getMonth()].substr(0, 3) + " " + new Date(dateRange[0]).getDate();
  toDate = monthNames[new Date(dateRange[1]).getMonth()].substr(0, 3) + " " + new Date(dateRange[1]).getDate();
  $(".calendar-week-title").text(fromDate + " to " + toDate);
}

function weekForwardBackward(weekNo, selectedDate) {
  currentWeek = new Date()
  startDate = new Date(getDateRangeOfWeek(weekNo, selectedDate)[0]);
  if (JSON.parse(isAdmin) || isFutureDate(startDate) || (getWeek(currentWeek) == getWeek(startDate))) {
    if (getWeek(currentWeek) == getWeek(startDate)) {
      $('#schedule-date').datepicker('update', currentWeek);
      $(".datepicker table td.today").addClass("active").click();
    } else {
      $('#schedule-date').datepicker('update', startDate);
    }
    $(".datepicker table td.active").click();
  }
  // getEmployeeTrips(getDateRangeOfWeek(weekNo, selectedDate));
}

function isFutureDate(selectedDate){
  todayDate = moment(new Date()).format("MM/DD/YYYY");
  selectedDate = moment(selectedDate).format("MM/DD/YYYY");
  return new Date(todayDate) <= new Date(selectedDate)
}

function setSelectedDateVal(selectedDate) {
  weekNo = getWeek(selectedDate);
  dateRange = getDateRangeOfWeek(weekNo, selectedDate);
  dates = getDates(dateRange[0], dateRange[1])
  if (weekNo == getWeek(new Date())) {
    currentPageDate = dateFormatter(new Date());
  } else {
    currentPageDate = dates[0];
  }
  $.each($(".schedule-form"), function(i, currentAttr) {
    $(currentAttr).find("input.selected_date").val(dateFormatter(dates[i]));
  });
}

function getEmployeeTrips(dates) {
  clearFrom();
  applyDefaultContent();

  if (Object.keys(employeeTripObjects).indexOf(getWeek(new Date(dates[0])).toString()) < 0 ) {
    $.get( modalUrl, { range_from: dateFormatter(dates[0]), range_to: dateFormatter(dates[1]) } )
      .done(function( data ) {
        if(data.length !== 0) {
          employeeTripObjects[Object.keys(data[0])[0]] = Object.values(data[0])[0];
          reloadForm(getWeek(new Date(dates[0])), new Date(dates[0]));
        }
    });
  } else {
    reloadForm(getWeek(new Date(dates[0])), new Date(dates[0]));
  }
}

function clearFrom() {
  $(".schedule-form").find("input,select").not(".selected_date").val("");
  $(".schedule-form").find("select").removeClass("disabled");
}

function applyDefaultContent() {
  $(".schedule-content").html($("#default-content").html());
}

function reloadForm(weekNo, weekDate) {
  $.each(employeeTripObjects[weekNo], function(i, obj) {
    if (obj[scheduleType] == "check_in" || obj.check_in !== undefined) {
      updateCheckInForm(obj);
    } else {
      updateCheckOutForm(obj);
    }
  });
  reloadContent(weekNo, weekDate);
}

function reloadContent(weekNo, weekDate) {
  dateRange = getDateRangeOfWeek(weekNo, weekDate)
  dates = getDates(dateRange[0], dateRange[1])
  currentObject = employeeTripObjects[weekNo]

  $.each(dates, function(i, date) {
    obj = $.grep(currentObject, function(e) { return dateFormatter(new Date(date)) == dateFormatter(e.schedule_date) });
    if (obj.length > 0) {
      checkInObj = $.grep(obj, function(e) { return e.check_in !== undefined || (e[scheduleType] !== undefined && e[scheduleType] == "check_in") });
      if (Object.keys(checkInObj).length !== 0) { check_in = checkInObj[0].check_in == undefined ? dateFormatter(new Date(checkInObj[0].date), "HH:mm") : checkInObj[0].check_in } else { check_in = "" }
      check_in = check_in == "" ? "--" : check_in
      checkOutObj = $.grep(obj, function(e) { return e.check_out !== undefined || (e[scheduleType] !== undefined && e[scheduleType] == "check_out") });
      if (Object.keys(checkOutObj).length !== 0) { check_out = checkOutObj[0].check_out == undefined ? dateFormatter(new Date(checkOutObj[0].date), "HH:mm") : checkOutObj[0].check_out } else { check_out = "" }
      check_out = check_out == "" ? "--" : check_out
      updateFormContent(i, check_in, check_out, getSelectedSiteName(obj[0]));
      loadLocation(i, obj[0]);
    } else {
      content = $(".schedule-content")[i]
      $(content).html($("#default-content").html());
    }
  });
}

function updateFormContent(i, checkIn, checkOut, site) {
  content = $(".schedule-content")[i]
  cloneContent = $("#default-content").clone();
  cloneContent.find(".check_in").text(checkIn);
  cloneContent.find(".check_out").text(checkOut);
  cloneContent.find("p:last").text(site);
  $(content).html(cloneContent.html());
}

function getSelectedSiteName(obj) {
  selector = fieldStartWith + "check_out_site_id:first [value=" + obj.site_id + "]";
  txt = $(selector).text();
  return txt == "" ? "--" : txt;
}

function updateCheckInForm(etObj) {
  var inputId = fieldStartWith + "check_in_id input";
  var inputField = fieldStartWith + "check_in_check_in input";
  var check_in = ""
  selectedDateFinder = "input[value='" + dateFormatter(etObj.schedule_date) + "']:first";
  currentForm = $(selectedDateFinder).closest(".schedule-form");
  currentForm.find(fieldStartWith).val(etObj.id);
  if(etObj.check_in == undefined) {
    check_in = dateFormatter(new Date(etObj.date), "HH:mm");
    currentForm.find(inputField).val(check_in);
  } else {
    check_in = etObj.check_in;
    currentForm.find(inputField).val(check_in);
  }
  if (etObj.site_id !== "") { currentForm.find(".check_in_location_select").val(etObj.site_id) }
  // if (etObj.shift_id !== "") { currentForm.find(".check_in_shift_select").val(etObj.shift_id) }
  if (check_in !== "") {createOrSelectShift(check_in, currentForm, "check_in");}
  [undefined, 'upcoming', 'unassigned', 'reassigned'].includes(etObj.status) ? currentForm.find(".check_in_shift_select").removeClass("disabled") : currentForm.find(".check_in_shift_select").addClass("disabled")
}

function updateCheckOutForm(etObj) {
  var inputId = fieldStartWith + "check_out_id input";
  var inputField = fieldStartWith + "check_out_check_out input";
  var checkOutVal;
  selectedDateFinder = "input[value='" + dateFormatter(etObj.schedule_date) + "']:first";
  currentForm = $(selectedDateFinder).closest(".schedule-form");
  currentForm.find(inputId).val(etObj.id);
  if(etObj.check_out == undefined) {
    checkOutVal = dateFormatter(new Date(etObj.date), "HH:mm");
    currentForm.find(inputField).val(checkOutVal);
  } else {
    checkOutVal = etObj.check_out;
    currentForm.find(inputField).val(checkOutVal);
  }
  if (etObj.site_id !== "") { currentForm.find(".check_out_location_select").val(etObj.site_id) }
  // if (etObj.shift_id !== "") { currentForm.find(".check_out_shift_select").val(etObj.shift_id) }
  if(checkOutVal !== "") {createOrSelectShift(checkOutVal, currentForm, "check_out")}
  [undefined, 'upcoming', 'unassigned', 'reassigned'].includes(etObj.status) ? currentForm.find(".check_out_shift_select").removeClass("disabled") : currentForm.find(".check_out_shift_select").addClass("disabled")
}

function createOrSelectShift(objVal, currentForm, tripType) {
  if (tripType == "check_in") {
    currentSelect = ".check_in_shift_select";
    shift = $.grep(allShifts, function(e){ return e.start_time == objVal })[0];
  } else {
    currentSelect = ".check_out_shift_select";
    shift = $.grep(allShifts, function(e){ return e.end_time == objVal })[0];
  }

  if (shift == undefined) {
    customShift = $.grep(currentForm.find(currentSelect).find("option"), function(e) { return $(e).text() == objVal })[0];
    if (customShift !== undefined) {
      currentForm.find(currentSelect).val($(customShift).val());
    } else {
      optionCustom = "<option value="+ objVal +" selected='selected'>" + objVal + "</option>";
      currentForm.find(currentSelect).append(optionCustom);
    }
  } else {
    currentForm.find(currentSelect).val(shift.id);
  }
}

function dateFormatter(date, dateFormat) {
  // dateFormat="YYYY-MM-DD"
  // ES5
 dateFormat = typeof dateFormat !== 'undefined' ? dateFormat : "MM/DD/YYYY";
  return moment(new Date(date)).format(dateFormat);
}

function getWeek(selectedDate) {
  return moment(selectedDate).week();
}

function getDateRangeOfWeek(weekNo, selectedDate=new Date()){
  // var d1 = new Date();
  var d1 = selectedDate;
  d1.setDate(d1.getDate() - d1.getDay());
  weeksInTheFuture = weekNo - getWeek(d1);
  d1.setDate(d1.getDate() + eval( 7 * weeksInTheFuture ));
  rangeFrom = d1.getMonth()+1 +"/" + d1.getDate() + "/" + d1.getFullYear();
  d1.setDate(d1.getDate() + 6);
  rangeTo = d1.getMonth()+1 + "/" + d1.getDate() + "/" + d1.getFullYear();
  return [rangeFrom, rangeTo];
};

function getDates(startDate, stopDate) {
  endDate = new Date(stopDate);
  var dateArray = new Array();
  var currentDate = new Date(startDate);
  while (currentDate <= endDate) {
    dateArray.push(new Date(currentDate));
    currentDate.setDate(currentDate.getDate() + 1)
  }
  return dateArray;
}

function removeScheduleHighlight() {
  $(".schedule-form").hide();
  $(".schedule-form").closest("table td").removeClass("green-background");
  $(".schedule-content").show();
}

function scheduleContentHighlight(obj) {
  removeScheduleHighlight();
  // selectedDay = new Date(obj.date).getDay() + 1;
  selectedDay = $("#schedule-date").data("datepicker").getDate().getDay() + 1;
  queryStr = ".calendar-week-details table td:nth-child(" + selectedDay + ")"
  $(queryStr).addClass("green-background");
}

function updateEmployeeTripObjects(weekNo) {
  currentObject = employeeTripObjects[weekNo]
  if (currentObject === undefined) {
    employeeTripObjects[weekNo] = []
    currentObject = employeeTripObjects[weekNo]
  }
  inputFields = []
  $.each(["check_in", "check_out"], function(i, trip_type) {
    $.each($(".schedule-form"), function(i, currentForm) {
      currentValues = getCurrentFormValues(currentForm, trip_type);
      obj = $.grep(currentObject, function(e){
        return (e[scheduleType] == trip_type || e[trip_type] !== undefined) && (dateFormatter(e.schedule_date) == currentValues.schedule_date)
      })[0];

      if (obj !== undefined) {
        obj.site_id = currentValues.site_id;
        obj.shift_id = currentValues.shift_id;
        obj[trip_type] = currentValues[trip_type];
        obj.schedule_date = currentValues.schedule_date;
      } else {
        obj = createNewObject(currentForm, trip_type)
        currentObject.push(obj)
      }
    });
  });
  currentObject.sort(function(a, b) { return new Date(b.schedule_date) - new Date(a.schedule_date); })
}

function selectorNameConstructor(tripType, fieldName) {
  if (tripType == "check_out" && fieldName == "site_id") {
    return "input.check_in_location_select"
  } else {
    return fieldStartWith + tripType + "_"+ fieldName +" input"
  }
}

function createNewObject(currentForm, tripType) {
  obj = getCurrentFormValues(currentForm, tripType)
  return obj;
}

function getCurrentFormValues(currentForm, tripType) {
  obj = {};
  currentForm = $(currentForm)
  if (tripType == "check_out") {
    obj.site_id = currentForm.find(".check_out_location_select").val();
    obj.shift_id = currentForm.find(".check_out_shift_select").val();
  }else {
    obj.site_id = currentForm.find(selectorNameConstructor(tripType, "site_id")).val();
    obj.shift_id = currentForm.find(".check_in_shift_select").val();
  }

  obj.id = currentForm.find(selectorNameConstructor(tripType, "id")).val();
  obj[tripType] = currentForm.find(selectorNameConstructor(tripType, tripType)).val();
  obj.schedule_date = currentForm.find(selectorNameConstructor(tripType, "schedule_date")).val();
  return obj;
}

function generateFormParams() {
  check_in_attr = {}
  check_out_attr = {}
  values = [];
  keys = Object.keys(employeeTripObjects);

  $.each(keys, function(i, key) {if (parseInt(key) >= getWeek(new Date())) { values.push(Object.values(employeeTripObjects[key])) }});
  values = [].concat.apply([], values)
  check_in_values = $.grep(values, function(x){ return x[scheduleType] == "check_in" || x.check_in !== undefined })
  check_out_values = $.grep(values, function(x){ return x[scheduleType] == "check_out" || x.check_out !== undefined })
  $.each(check_in_values, function(i, val) { check_in_attr[i] = val; })
  $.each(check_out_values, function(i, val) { check_out_attr[i] = val; })
  return [check_in_attr, check_out_attr]
}

function submitForm(action) {
  data = generateFormParams();
  submitParams["employee"]["check_in_attributes"] = data[0];
  submitParams["employee"]["check_out_attributes"] = data[1];

  $.post(action, submitParams)
    .done(function(data){
    });
}

function toggleSubmitButtonVisiblity(inputField) {
  var checkOutField = inputField.closest(".schedule-form").find(checkOutFocusOut)
  var selectField = inputField.closest(".schedule-form").find("select:last")

  if (selectField.val() == "" && inputField.val() !== "" && checkOutField.val() !== "") {
    selectField.addClass("error-input-color");
  } else {
    selectField.removeClass("error-input-color");
  }
  enableDisableSubmit();
}

function enableDisableSubmit() {
  if ($(".error-input-color")[0] === undefined) {
    $(submitSelector).prop("disabled", false);
  } else {
    $(submitSelector).prop("disabled", true)
  }
}

function getFromShfitCollection(shift_id) {
  return $.grep(allShifts, function(e){ return e.id == shift_id })[0];
}

function updateCheckinTimeFields(shiftSelect) {
  var checkInField = shiftSelect.closest(".schedule-form").find(".employee_check_in_check_in input");
  var startTime = shiftSelect.val() !== "" ? getFromShfitCollection(shiftSelect.val()).start_time : "";
  if(shiftSelect.val !== "") {
    checkInField.val(startTime);
    contentTime = startTime == "" ? "--" : startTime;
    shiftSelect.closest(".schedule-column").find(".schedule-content .check_in").text(contentTime);
  }
}

function updateCheckoutTimeFields(shiftSelect) {
  var checkOutField = shiftSelect.closest(".schedule-form").find(".employee_check_out_check_out input");
  var endTime = shiftSelect.val() !== "" ? getFromShfitCollection(shiftSelect.val()).end_time : "";
  if(shiftSelect.val !== "") {
    checkOutField.val(endTime);
    contentTime = endTime == "" ? "--" : endTime;
    shiftSelect.closest(".schedule-column").find(".schedule-content .check_out").text(contentTime);
  }
}

function loadLocation(i, obj) {
  currentForm = $(".schedule-form")[i]
  $(currentForm).find(".check_out_location_select").val(obj.site_id);
}
