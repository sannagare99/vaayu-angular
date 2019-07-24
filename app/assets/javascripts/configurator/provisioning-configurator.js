$(function () {
    'use strict';

    $('a[href="#general_settings"]').on('shown.bs.tab', function (e) {
        $("#general_settings").on("click", ".consider_non_compliant_cancel_as_no_show", function(e){
            if(e.target.value == '1'){
                $(".cancel_time_check_in").removeClass('hidden')
                $(".cancel_time_check_out").removeClass('hidden')
            }
            else{
                $(".cancel_time_check_in").addClass('hidden')
                $(".cancel_time_check_out").addClass('hidden')
            }
        });

        $("#general_settings").on("click", ".is_nodal_trip_allowed", function(e){
            if(e.target.value == '1'){
                $(".start_time_NODAL").removeClass('hidden')
                $(".end_time_NODAL").removeClass('hidden')
            }
            else{
                $(".start_time_NODAL").addClass('hidden')
                $(".end_time_NODAL").addClass('hidden')
            }
        });

        $("#general_settings").on("click", ".female_exception_required", function(e){
            if(e.target.value == '1'){
                $(".female_exception_check_in_time").removeClass('hidden')
                $(".female_exception_check_out_time").removeClass('hidden')
                $(".female_exception_resequence_required").removeClass('hidden')
                $(".female_exception_aerial_distance").removeClass('hidden')
            }
            else{
                $(".female_exception_check_in_time").addClass('hidden')
                $(".female_exception_check_out_time").addClass('hidden')
                $(".female_exception_resequence_required").addClass('hidden')
                $(".female_exception_aerial_distance").addClass('hidden')
            }
        });

        $("#general_settings").on("click", ".female_exception_resequence_required", function(e){
            if(e.target.value == '1'){
                $(".female_exception_aerial_distance").removeClass('hidden')
            }
            else{
                $(".female_exception_aerial_distance").addClass('hidden')
            }
        });

        $("#general_settings").on("click", ".buffer_time_allowed_check_in", function(e){
            if(e.target.value == '1'){
                $(".report_time_delay_check_in").removeClass('hidden')
            }
            else{
                $(".report_time_delay_check_in").addClass('hidden')
            }
        });

        $("#general_settings").on("click", ".show_driver_licence_expiry_date_notification", function(e){
            if(e.target.value == '1'){
                $(".driver_licence_expiry_date_notification_lead_time").removeClass('hidden')
            }
            else{
                $(".driver_licence_expiry_date_notification_lead_time").addClass('hidden')
            }
        });

        $("#general_settings").on("click", ".show_driver_badge_expiry_date_notification", function(e){
            if(e.target.value == '1'){
                $(".driver_badge_expiry_date_notification_lead_time").removeClass('hidden')
            }
            else{
                $(".driver_badge_expiry_date_notification_lead_time").addClass('hidden')
            }
        });

        $("#general_settings").on("click", ".show_vehicle_insurance_expiry_date_notification", function(e){
            if(e.target.value == '1'){
                $(".vehicle_insurance_expiry_date_notification_lead_time").removeClass('hidden')
            }
            else{
                $(".vehicle_insurance_expiry_date_notification_lead_time").addClass('hidden')
            }
        });

        $("#general_settings").on("click", ".show_vehicle_permit_expiry_date_notification", function(e){
            if(e.target.value == '1'){
                $(".vehicle_permit_expiry_date_notification_lead_time").removeClass('hidden')
            }
            else{
                $(".vehicle_permit_expiry_date_notification_lead_time").addClass('hidden')
            }
        });        

        $("#general_settings").on("click", ".show_vehicle_puc_expiry_date_notification", function(e){
            if(e.target.value == '1'){
                $(".vehicle_puc_expiry_date_notification_lead_time").removeClass('hidden')
            }
            else{
                $(".vehicle_puc_expiry_date_notification_lead_time").addClass('hidden')
            }
        });

        $("#general_settings").on("click", ".show_vehicle_fc_expiry_date_notification", function(e){
            if(e.target.value == '1'){
                $(".vehicle_fc_expiry_date_notification_lead_time").removeClass('hidden')
            }
            else{
                $(".vehicle_fc_expiry_date_notification_lead_time").addClass('hidden')
            }
        });
    });

    $("#system_settings").on("click", ".remove-google-api", function(e){
        if ($(".google-api-form").length > 1) {$(this).closest(".google-api-form").remove()};
        e.preventDefault();
    });

    $("#system_settings").on("click", ".add-google-api", function(e){
        var cloneData = $(".row.google-api-form:last").clone();
        var indexVal = cloneData.find("input:first").data('index-val') + 1;
        cloneData.find("input:first").attr({name: 'google_configs[' + indexVal + '][google_api_key]', id: 'google_api_key-' + indexVal, value: ""});
        cloneData.find("input:first").attr("data-index-val", indexVal);
        cloneData.find("input:last").attr({name: 'google_configs[' + indexVal + '][google_api_key_id]', value: ""});
        $(".google-api-section").append('<div class="row google-api-form">' + cloneData.html() + '</div>');
        e.preventDefault();
    });

});