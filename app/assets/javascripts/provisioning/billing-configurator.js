var zone_length = 1;    
var overage = false;
var serviceNumber = 1;
var vehicleNumber = 1;
var zoneNumber = 1;
var serviceTypes = []
var zone_names = {'1': []}
var zone_name_services = {'1': {'1': []}}
var deletedServices = []
var deletedVehicles = {}
var deletedZones = {}
var deletedVehicleZones = {}
var MAX_LIMIT = 100

function resetBillingParameters(){    
    zone_length = 1;                        
    validationError = false;
    zone_names = {'1': []}
    zone_name_services = {'1': {'1': []}}
    deletedZones = {}
    deletedServices = []
    deletedVehicles = {}
    deletedVehicleZones = {}
}


function formatNull(value){
    if (value == undefined || value == null){
        return ""
    }
    else{
        return value
    }
}

function getService(type, concerned_id, logistics_company_id, orig_service_html){
    if(type == 'site'){
        $.ajax({
            type: "POST",
            url: '/sites/details',
            data: {
                'id': concerned_id,
                'logistics_company_id': logistics_company_id
            }
        }).done(function (response) {
            setTimeout(function(){                                
                var html = generate_edit(response, 'site', logistics_company_id, orig_service_html)
                $("#site_html").html(html)
                $("#operator").val(logistics_company_id);
                if(response.services.length == 2){
                    $(".addService").attr("disabled", "disabled")
                }
            }, 500);
        });    
    }
    else{
        $.ajax({
            type: "POST",
            url: '/business_associates/details',
            data: {
                'id': concerned_id,
                'logistics_company_id': logistics_company_id
            }
        }).done(function (response) {
            setTimeout(function(){
                var html = generate_edit(response, type, logistics_company_id, orig_service_html)
                $("#serviceContainer").html(html)
                $("#ba_operator").val(logistics_company_id);
                if(response.services.length == 2){
                    $(".addService").attr("disabled", "disabled")
                }
            }, 500);
        });       
    } 
}

function generate_edit(response, type, operator_id, orig_service_html){
    var html = ''
    if(type == 'site'){
        var phone = ''
        if (response.site != null && response.site.phone != null) {
          phone = response.site.phone
        }
        html = html + 
        '<div class="row">' + 
            '<div class="col-md-4 no-margin">' + 
                '<label class="site_labels" for="siteName">Name    </label>' + 
                '<input class="form-control" id="siteName" name="siteName" type="text" value="' + response.site.name + '">' + 
            '</div>' + 
            '<div class="col-md-4 no-margin">' + 
                '<label class="site_labels" for="phone">Phone    </label>' + 
                '<input class="form-control" id="phone" name="phone" type="text" value="' + phone + '">' + 
            '</div>' +             
            '<div class="col-md-4 no-margin">' + 
                '<label class="site_labels" for="company">Company    </label>' + 
                '<select class="form-control" id="company">' + 
                    '<option value="' + response.site.employee_company_id + '">' + response.company.name + '</option>'
                for(var i = 0; i < response.employee_companies.length; i++){             
                    if(response.employee_companies[i].id != response.site.employee_company_id){
                        html = html + 
                    '<option value="' + response.employee_companies[i].id + '">' + response.employee_companies[i].name + '</option>'
                    }                                   
                }
            html = html + 
                '</select>' + 
            '</div>' + 
            '<div class="col-md-4 no-margin">' + 
                '<label class="site_labels" for="address">Address</label>' + 
                '<input class="form-control" id="address" name="address" type="text" value="' + response.site.address + '">' + 
            '</div>' + 
        '</div>' + 
        '<p style="font-size:18px; font-weight:600; margin-left:10px">Billing Attributes</p>' + 
        '<div class="row">'
            if(response.current_user_type != 'Operator'){
                html = html + 
            '<div class="col-md-4 no-margin">' + 
                '<label class="site_labels" for="operator">Operator</label>' + 
                '<select class="form-control" id="operator">' +
                '<option value="">Choose Operator</option>'
                for(var i = 0; i < response.logistics_companies.length; i++){                            
                    html = html + 
                    '<option value="' + response.logistics_companies[i].id + '">' + response.logistics_companies[i].name + '</option>'
                }
                html = html + 
                '</select>' + 
            '</div>'
            }
            else{
                logistics_company_id = response.logistics_company_id
            }
            html = html +                     
        '</div>' + 
        '<div class="services" id="services">'
    }
    else{
        var operator_html = '<div class="row">'
            if(response.current_user_type != 'Operator'){
                operator_html = operator_html + 
            '<div class="col-md-4 no-margin">' + 
                '<label class="site_labels" for="ba_operator">Operator</label>' + 
                '<select class="form-control" id="ba_operator">' +
                '<option value="">Choose Operator</option>'
                for(var i = 0; i < response.logistics_companies.length; i++){                            
                    operator_html = operator_html + 
                    '<option value="' + response.logistics_companies[i].id + '">' + response.logistics_companies[i].name + '</option>'
                }
                operator_html = operator_html + 
                '</select>' + 
            '</div>'
            }
            else{
                logistics_company_id = response.logistics_company_id
            }
            operator_html = operator_html +                     
        '</div>'
        $("#ba_operator").html(operator_html)
        html = html + '<div class="services" id="services">'
    }
    if(response.services.length > 0){
        html = html + generate_configurator(response, type);
    }
    else{
        html = html + orig_service_html
        html = html + generate_configurator(response, type);
        // console.log(html)
        // $("#services").html(html)
    }
    return html
};

function generate_configurator(response, type){    
    console.log(response)
    var html = '';
    for(var i = 0; i < response.services.length; i++){
        var service = response.services[i]
        html = html + '' + 
        '<div class="row vehicle-div" id="service_' + (i + 1) + '" >' +                 
            '<div class="col-md-4 margin-top">' + 
                '<label class="site_labels" for="serviceType">Service Type</label>' + 
                '<select class="form-control serviceType" id="serviceType_' + (i + 1) + '">';
        if(service.service_type == 'Door To Door'){
            html = html + '<option checked="true" value="Door To Door">Door To Door</option>' + 
                    '<option value="Nodal">Nodal</option>';
        }
        else if(service.service_type == 'Nodal'){
            html = html + '<option checked = "true" value="Nodal">Nodal</option>' + 
                '<option value="Door To Door">Door To Door</option>'                        
        }
        html = html + '</select>' + 
            '</div>' + 
            '<div class="col-md-4 margin-top">' + 
                '<label class="site_labels" for="billingModel">Billing Model</label>' + 
                '<select class="form-control billingModel" data-vehiclenumber="' + (response.service_vehicles[service.id].length) + '" id="billingModel_' + (i + 1) + '">';
        if(service.billing_model == 'Fixed Rate per Trip'){
            html = html + '<option checked="true" value="Fixed Rate per Trip">Fixed Rate per Trip</option>' + 
                    '<option value="Fixed Rate per Zone">Fixed Rate per Zone</option>' + 
                    '<option value="Package Rates">Package Rates</option>'
        }
        else if(service.billing_model == 'Fixed Rate per Zone'){
            html = html + '<option checked="true" value="Fixed Rate per Zone">Fixed Rate per Zone</option>' + 
            '<option value="Fixed Rate per Trip">Fixed Rate per Trip</option>' +
            '<option value="Package Rates">Package Rates</option>'
        }
        else if(service.billing_model == 'Package Rates'){
            html = html + '<option checked="true" value="Package Rates">Package Rates</option>' + 
            '<option value="Fixed Rate per Trip">Fixed Rate per Trip</option>' +
            '<option value="Fixed Rate per Zone">Fixed Rate per Zone</option>'             
        }
                    
        html = html + '</select></div>' + 
        '<div class="col-md-4 margin-top pull-right">' + 
            '<button class="fa fa-times deleteIcon pull-right" data-servicenumber="' + (i + 1) + '" id="serviceDelete_' + (i + 1) + '">' + 
            '</button>' + 
        '</div>' + 
        '<div class="col-md-4 margin-top" style="clear:left">' + 
            '<label class="site_labels" for="varyWithVehicle_' + (i + 1) + '">Vary With Vehicle</label>' + 
            '<div class="row" style="margin-left:5px">';
        if(service.vary_with_vehicle == true){
            html = html + '<input checked="true" class="varyWithVehicle" data-vehiclenumber="' + (response.service_vehicles[service.id].length) + '" id="varyWithVehicleYes_' + (i + 1) + '" name="varyWithVehicle_' + (i + 1) + '" type="radio" value="true">   Yes' + 
            '<input class="varyWithVehicle" data-vehiclenumber="' + (response.service_vehicles[service.id].length) + '" id="varyWithVehicleNo_' + (i + 1) + '" name="varyWithVehicle_' + (i + 1) + '" style="margin-left:20px" type="radio" value="false">   No'
        }
        else{
            html = html + '<input class="varyWithVehicle" data-vehiclenumber="' + (response.service_vehicles[service.id].length) + '" id="varyWithVehicleYes_' + (i + 1) + '" name="varyWithVehicle_' + (i + 1) + '" type="radio" value="true">   Yes' + 
            '<input checked="true" class="varyWithVehicle" data-vehiclenumber="' + (response.service_vehicles[service.id].length) + '" id="varyWithVehicleNo_' + (i + 1) + '" name="varyWithVehicle_' + (i + 1) + '" style="margin-left:20px" type="radio" value="false">   No'
        }

        html = html + '</div></div>'                


        if(service.billing_model == 'Fixed Rate per Trip'){                
            if(service.vary_with_vehicle == true){
                console.log("per trip per vehicle")
                // otherHtml(i, j, k, zonesDisplay, vehiclesDisplay, defaultRateDisplay, vehicleZonesDisplay, response, service, packageRatesDisplay, vehiclePackageRatesDisplay)      
                html = html + otherHtml(i, response.service_vehicles[service.id].length, 0, 'none', 'block', 'none', 'none', response, service, 'none', 'none')  
            }
            else{
                console.log("per trip no vehicle")
                // otherHtml(i, j, k, zonesDisplay, vehiclesDisplay, defaultRateDisplay, vehicleZonesDisplay, response, service, packageRatesDisplay, vehiclePackageRatesDisplay)
                html = html + otherHtml(i, 0, 0, 'none', 'none', 'block', 'none', response, service, 'none', 'none')
            }
        }
        else if(service.billing_model == 'Fixed Rate per Zone'){
            if(service.vary_with_vehicle == true){
                console.log("per zone per vehicle")
                // otherHtml(i, j, k, zonesDisplay, vehiclesDisplay, defaultRateDisplay, vehicleZonesDisplay, response, service, packageRatesDisplay, vehiclePackageRatesDisplay)      
                html = html + otherHtml(i, response.service_vehicles[service.id].length, 0, 'none', 'block', 'none', 'block', response, service, 'none', 'none')
            }
            else{
                console.log("per trip no vehicle")
                // otherHtml(i, j, k, zonesDisplay, vehiclesDisplay, defaultRateDisplay, vehicleZonesDisplay, response, service, packageRatesDisplay, vehiclePackageRatesDisplay)      
                html = html + otherHtml(i, response.service_vehicles[service.id].length, response.vehicle_zones[response.service_vehicles[service.id][0].id].length - 1, 'block', 'none', 'block', 'none', response, service, 'none', 'none')
            }
        }
        else if(service.billing_model == 'Package Rates'){
            if(service.vary_with_vehicle == true){
                console.log("package rates")
                // otherHtml(i, j, k, zonesDisplay, vehiclesDisplay, defaultRateDisplay, vehicleZonesDisplay, response, service, packageRatesDisplay, vehiclePackageRatesDisplay)      
                html = html + otherHtml(i, response.service_vehicles[service.id].length, 0, 'none', 'block', 'none', 'none', response, service, 'none', 'block')
            }
            else{
                console.log("package rates")
                // otherHtml(i, j, k, zonesDisplay, vehiclesDisplay, defaultRateDisplay, vehicleZonesDisplay, response, service, packageRatesDisplay, vehiclePackageRatesDisplay)      
                html = html + otherHtml(i, response.service_vehicles[service.id].length, 0, 'none', 'none', 'none', 'none', response, service, 'block', 'none')
            }
        }
        html = html +                 
        '</div>'
    }

    // console.log(html)
    html = html + 
    '</div>'
    if(Object.keys(response.service_vehicles).length > 0){
        // if(type == 'site'){
            html = html + 
        '<div class="col-md-12" id="addServicesDiv">' + 
            '<button class="margin-top margin-right btn btn-primary pull-right addService" data-servicenumber="2" data-vehiclenumber="1" data-zonenumber="1">Add Service' + 
            '</button>' + 
        '</div>' + 
        '<div class="col-md-4 margin-top" style="clear:left">' + 
            '<label class="site_labels" for="cgst_1">CGST(%)</label>' + 
            '<input class="form-control" id="cgst_1" name="cgst_1" type="number" value="' + response.service_vehicles[service.id][0].cgst + '">' + 
        '</div>' + 
        '<div class="col-md-4 margin-top">' + 
            '<label class="site_labels" for="sgst_1">SGST(%)</label>' + 
            '<input class="form-control" id="sgst_1" name="sgst_1" type="number" value="' + response.service_vehicles[service.id][0].sgst + '">' + 
        '</div>'
        // }
        // else{
        //     $("#cgst_1").val(response.service_vehicles[service.id][0].cgst)
        //     $("#sgst_1").val(response.service_vehicles[service.id][0].sgst)
        // }
    }
    else{
        // if(type == 'site'){
            html = html + 
        '<div class="col-md-12" id="addServicesDiv">' + 
            '<button class="margin-top margin-right btn btn-primary pull-right addService" data-servicenumber="2" data-vehiclenumber="1" data-zonenumber="1">Add Service' + 
            '</button>' + 
        '</div>' + 
        '<div class="col-md-4 margin-top" style="clear:left">' + 
            '<label class="site_labels" for="cgst_1">CGST(%)</label>' + 
            '<input class="form-control" id="cgst_1" name="cgst_1" type="number" value="">' + 
        '</div>' + 
        '<div class="col-md-4 margin-top">' + 
            '<label class="site_labels" for="sgst_1">SGST(%)</label>' + 
            '<input class="form-control" id="sgst_1" name="sgst_1" type="number" value="">' + 
        '</div>'
        // }
        // else{
        //     $("#cgst_1").val("")
        //     $("#sgst_1").val("")
        // }   
    }
    return html
}

function otherHtml(i, j, k, zonesDisplay, vehiclesDisplay, defaultRateDisplay, vehicleZonesDisplay, response, service, packageRatesDisplay, vehiclePackageRatesDisplay){    
    var defaultRate = ''
    var guardRate = ''
    if(response.vehicle_zones[response.service_vehicles[service.id][0].id].length > 0){
        defaultRate = formatNull(response.vehicle_zones[response.service_vehicles[service.id][0].id][0].rate)
        guardRate = formatNull(response.vehicle_zones[response.service_vehicles[service.id][0].id][0].guard_rate)
    }
    var html =  '<div class="col-md-4 margin-top" id="defaultRateDiv_' + (i + 1) + '" style="display:' + defaultRateDisplay + '">' + 
                    '<label class="site_labels" for="defaultRate_' + (i + 1) + '">Default Rate</label>' + 
                    '<input class="form-control" id="defaultRate_' + (i + 1) + '" name="defaultRate_' + (i + 1) + '" type="number" value="' + defaultRate + '">' + 
                '</div>' + 
                '<div class="col-md-4 margin-top" id="guardRateDiv_' + (i + 1) + '" style="display:' + defaultRateDisplay + '">' + 
                    '<label class="site_labels" for="guardRate_' + (i + 1) + '">Default Guard Rate</label>' + 
                    '<input class="form-control" id="guardRate_' + (i + 1) + '" name="guardRate_' + (i + 1) + '" type="number" value="' + guardRate + '">' + 
                '</div>'
        //         '<div class="col-md-4 col-md-offset-4 margin-top" id="overageDiv_' + (i + 1) + '" style="display:' + defaultRateDisplay + '">' + 
        //             '<label class="site_labels" for="overage">Overage</label>' + 
        //             '<div class="row" style="margin-left:5px">'
        // if(response.service_vehicles[service.id][0].overage){
        //     html = html + 
        //                 '<input checked="true" class="overage" id="overageYes_' + (i + 1) + '" name="overage_' + (i + 1) + '" type="radio" value="true">   Yes' + 
        //                 '<input class="overage" id="overageNo_' + (i + 1) + '" name="overage_' + (i + 1) + '" style="margin-left:20px" type="radio" value="false">   No' + 
        //             '</div>' + 
        //         '</div>' + 
        //         '<div class="col-md-4 col-md-offset-4 hidden margin-top" id="timeOnDutyDiv_' + (i + 1) + '">' + 
        //             '<label class="site_labels" for="timeOnDuty_' + (i + 1) + '">Time on Duty per Day</label>' + 
        //             '<input class="form-control" id="timeOnDuty_' + (i + 1) + '" name="timeOnDuty_' + (i + 1) + '" type="number" value="' + formatNull(response.service_vehicles[service.id][0].time_on_duty) + '">' + 
        //         '</div>' + 
        //         '<div class="col-md-4 margin-top hidden" id="overageRateDiv_' + (i + 1) + '">' + 
        //             '<label class="site_labels" for="overageRate_' + (i + 1) + '">Overage Rate</label>' + 
        //             '<input class="form-control" id="overageRate_' + (i + 1) + '" name="overageRate_' + (i + 1) + '" type="number" value="' + formatNull(response.service_vehicles[service.id][0].overage_per_hour) + '">' + 
        //         '</div>'
        // }
        // else{
        //     html = html + 
        //                 '<input class="overage" id="overageYes_' + (i + 1) + '" name="overage_' + (i + 1) + '" type="radio" value="true">   Yes' + 
        //                 '<input checked="true" class="overage" id="overageNo_' + (i + 1) + '" name="overage_' + (i + 1) + '" style="margin-left:20px" type="radio" value="false">   No' + 
        //             '</div>' + 
        //         '</div>' + 
        //         '<div class="col-md-4 col-md-offset-4 margin-top" id="timeOnDutyDiv_' + (i + 1) + '" style="display:none">' + 
        //             '<label class="site_labels" for="timeOnDuty_' + (i + 1) + '">Time on Duty per Day</label>' + 
        //             '<input class="form-control" id="timeOnDuty_' + (i + 1) + '" name="timeOnDuty_' + (i + 1) + '" type="number" value="' + formatNull(response.service_vehicles[service.id][0].time_on_duty) + '">' + 
        //         '</div>' + 
        //         '<div class="col-md-4 margin-top" id="overageRateDiv_' + (i + 1) + '" style="display:none">' + 
        //             '<label class="site_labels" for="overageRate_' + (i + 1) + '">Overage Rate</label>' + 
        //             '<input class="form-control" id="overageRate_' + (i + 1) + '" name="overageRate_' + (i + 1) + '" type="number" value="' + formatNull(response.service_vehicles[service.id][0].overage_per_hour) + '">' + 
        //         '</div>'
        // }
    html = html + 
                '<div id="zones_' + (i + 1) + '" style="display:' + zonesDisplay + '">'
for(var z = 0; z < k + 1; z++){
    if(response.vehicle_zones[response.service_vehicles[service.id][0].id].length > 0){
        if(formatNull(response.vehicle_zones[response.service_vehicles[service.id][0].id][z].name) != 'Default'){
            html = html + 
                    '<div class="col-md-12">' + 
                        '<div class="col-md-4 margin-top">' + 
                            '<label class="site_labels" for="zoneName_' + (i + 1) + '_' + (z) + '">Zone Name</label>' + 
                            '<input class="form-control" id="zoneName_' + (i + 1) + '_' + (z) + '" name="zoneName_' + (i + 1) + '_' + (z) + '" value="' + formatNull(response.vehicle_zones[response.service_vehicles[service.id][0].id][z].name) + '">' + 
                        '</div>' + 
                        '<div class="col-md-4 margin-top">' + 
                            '<label class="site_labels" for="zoneRate_' + (i + 1) + '_' + (z) + '">Zone Rate</label>' + 
                            '<input class="form-control" id="zoneRate_' + (i + 1) + '_' + (z) + '" name="zoneRate_' + (i + 1) + '_' + (z) + '" type="number" value="' + formatNull(response.vehicle_zones[response.service_vehicles[service.id][0].id][z].rate) + '">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top">' + 
                            '<label class="site_labels" for="zoneGuardRate_' + (i + 1) + '_' + (z) + '">Guard Rate</label>' + 
                            '<input class="form-control" id="zoneGuardRate_' + (i + 1) + '_' + (z) + '" name="zoneGuardRate_' + (i + 1) + '_' + (z) + '" type="number" value="' + formatNull(response.vehicle_zones[response.service_vehicles[service.id][0].id][z].guard_rate) + '">' + 
                        '</div>' + 
                        '<div class="col-md-1 margin-top">' +
                            '<button id="zoneDelete_' + (i + 1) + '_' + (z) + '" class="fa fa-times deleteIcon" data-serviceNumber="' + (i + 1) + '" data-zoneNumber="' + (z) + '">' + 
                            '</button>' + 
                        '</div>' +
                    '</div>'
        }  
    }
    else{
            html = html + 
                    '<div class="col-md-12">' + 
                        '<div class="col-md-4 margin-top">' + 
                            '<label class="site_labels" for="zoneName_' + (i + 1) + '_' + (z) + '">Zone Name</label>' + 
                            '<input class="form-control" id="zoneName_' + (i + 1) + '_' + (z) + '" name="zoneName_' + (i + 1) + '_' + (z) + '" value="">' + 
                        '</div>' + 
                        '<div class="col-md-4 margin-top">' + 
                            '<label class="site_labels" for="zoneRate_' + (i + 1) + '_' + (z) + '">Zone Rate</label>' + 
                            '<input class="form-control" id="zoneRate_' + (i + 1) + '_' + (z) + '" name="zoneRate_' + (i + 1) + '_' + (z) + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top">' + 
                            '<label class="site_labels" for="zoneGuardRate_' + (i + 1) + '_' + (z) + '">Guard Rate</label>' + 
                            '<input class="form-control" id="zoneGuardRate_' + (i + 1) + '_' + (z) + '" name="zoneGuardRate_' + (i + 1) + '_' + (z) + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-1 margin-top">' +
                            '<button id="zoneDelete_' + (i + 1) + '_' + (z) + '" class="fa fa-times deleteIcon" data-serviceNumber="' + (i + 1) + '" data-zoneNumber="' + (z) + '">' + 
                            '</button>' + 
                        '</div>' +
                    '</div>'   
    }
}

    html = html + 
                    '<div class="col-md-12">' + 
                        '<div class="col-md-4 margin-top">' + 
                            '<label class="site_labels" for="zoneName_' + (i + 1) + '_' + (k + 1) + '">Zone Name</label>' + 
                            '<input class="form-control" id="zoneName_' + (i + 1) + '_' + (k + 1) + '" name="zoneName_' + (i + 1) + '_' + (k + 1) + '" value="">' + 
                        '</div>' + 
                        '<div class="col-md-4 margin-top">' + 
                            '<label class="site_labels" for="zoneRate_' + (i + 1) + '_' + (k + 1) + '">Zone Rate</label>' + 
                            '<input class="form-control" id="zoneRate_' + (i + 1) + '_' + (k + 1) + '" name="zoneRate_' + (i + 1) + '_' + (k + 1) + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top">' + 
                            '<label class="site_labels" for="zoneGuardRate_' + (i + 1) + '_' + (k + 1) + '">Guard Rate</label>' + 
                            '<input class="form-control" id="zoneGuardRate_' + (i + 1) + '_' + (k + 1) + '" name="zoneGuardRate_' + (i + 1) + '_' + (k + 1) + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-1 margin-top">' +
                            '<button id="zoneDelete_' + (i + 1) + '_' + (k + 1) + '" class="fa fa-times deleteIcon" data-serviceNumber="' + (i + 1) + '" data-zoneNumber="' + (k + 1) + '">' + 
                            '</button>' + 
                        '</div>' +
                    '</div>'
                
    html = html + 
                '</div>' + 
                '<div class="col-md-12" id="addZonesDiv_' + (i + 1) + '" style="display:' + zonesDisplay + '">' + 
                    '<button id="addZones_' + (i + 1) + '" class="margin-top margin-right btn btn-primary pull-right addZone" data-servicenumber="' + (i + 1) + '" data-zonenumber="' + (k + 2) + '">Add Zone Rate</button>' + 
                '</div>' + 

                '<div id="package_' + (i + 1) + '" style="display: ' + packageRatesDisplay + '">' + 
                    '<div class="col-md-12" style="padding:0px">' + 
                        '<div class="col-md-3 margin-top">' + 
                            '<label class="site_labels" for="packageDuration_' + (i + 1) + '">Package Duration</label>' + 
                            '<select class="form-control billingModel" data-vehiclenumber="1" id="packageDuration_' + (i + 1) + '">' 
                        if(packageRatesDisplay == 'block'){
                            if(response.vehicle_package_rates[response.service_vehicles[service.id][0].id][0].duration == 'Daily'){
                                html = html + 
                                '<option checked="true" value="Daily">Daily</option>' + 
                                '<option value="">Choose Package Duration</option>' +                                 
                                '<option value="Weekly">Weekly</option>' + 
                                '<option value="Monthly">Monthly</option>'
                            }
                            else if(response.vehicle_package_rates[response.service_vehicles[service.id][0].id][0].duration == 'Weekly'){
                                html = html + 
                                '<option checked="true" value="Weekly">Weekly</option>' + 
                                '<option value="">Choose Package Duration</option>' + 
                                '<option value="Daily">Daily</option>' +                                 
                                '<option value="Monthly">Monthly</option>'
                            }
                            else if(response.vehicle_package_rates[response.service_vehicles[service.id][0].id][0].duration == 'Monthly'){
                                html = html + 
                                '<option checked="true" value="Monthly">Monthly</option>' + 
                                '<option value="">Choose Package Duration</option>' + 
                                '<option value="Daily">Daily</option>' + 
                                '<option value="Weekly">Weekly</option>'                                
                            }
                            html = html + 
                            '</select>' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top">' + 
                            '<label class="site_labels" for="packageKm_' + (i + 1) + '">Package KMs</label>' + 
                            '<input class="form-control" id="packageKm_' + (i + 1) + '" name="packageKm_' + (i + 1) + '" type="number" value="' + response.vehicle_package_rates[response.service_vehicles[service.id][0].id][0].package_km + '">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top">' + 
                            '<label class="site_labels" for="packageRate_' + (i + 1) + '">Package Rate</label>' + 
                            '<input class="form-control" id="packageRate_' + (i + 1) + '" name="packageRate_' + (i + 1) + '" type="number" value="' + response.vehicle_package_rates[response.service_vehicles[service.id][0].id][0].package_rate + '">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top">' + 
                            '<label class="site_labels" for="packageOveragePerKm_' + (i + 1) + '">Overage (per KM)</label>' + 
                            '<input class="form-control" id="packageOveragePerKm_' + (i + 1) + '" name="packageOveragePerKm_' + (i + 1) + '" type="number" value="' + response.vehicle_package_rates[response.service_vehicles[service.id][0].id][0].package_overage_per_km + '">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageMileageCalculationDiv_' + (i + 1) + '">' + 
                            '<label class="site_labels" for="packageMileageCalculation_' + (i + 1) + '">Mileage Calculation</label>' + 
                            '<div class="row">'
                            if(response.vehicle_package_rates[response.service_vehicles[service.id][0].id][0].package_mileage_calculation == "On Duty Hours"){
                                console.log("----------")
                                html = html +
                                '<input checked="true" class="packageMileageCalculation" id="packageMileageCalculationOnDuty_' + (i + 1) + '" name="packageMileageCalculation_' + (i + 1) + '" style="margin-left:20px" type="radio" value="On Duty Hours">   On Duty Hours' + 
                                '<input class="packageMileageCalculation" id="packageMileageCalculationTripDuration_' + (i + 1) + '" name="packageMileageCalculation_' + (i + 1) + '" style="margin-left:5px" type="radio" value="Trip Duration">   Trip Duration'
                            }
                            else if (response.vehicle_package_rates[response.service_vehicles[service.id][0].id][0].package_mileage_calculation == "Trip Duration"){
                                console.log("+++++++++++")
                                html = html +                                 
                                '<input class="packageMileageCalculation" id="packageMileageCalculationOnDuty_' + (i + 1) + '" name="packageMileageCalculation_' + (i + 1) + '" style="margin-left:20px" type="radio" value="On Duty Hours">   On Duty Hours' + 
                                '<input checked="true" class="packageMileageCalculation" id="packageMileageCalculationTripDuration_' + (i + 1) + '" name="packageMileageCalculation_' + (i + 1) + '" style="margin-left:5px" type="radio" value="Trip Duration">   Trip Duration'
                            }
                            html = html + 
                            '</div>' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top">' + 
                            '<label class="site_labels" for="packageOverageTime_' + (i + 1) + '">Overage for Duty Time</label>' + 
                            '<div class="row">'
                            if(response.vehicle_package_rates[response.service_vehicles[service.id][0].id][0].package_overage_time == "true"){
                                html = html +                                 
                                '<input class="packageOverage" id="packageOverageNo_' + (i + 1) + '" name="packageOverageTime_' + (i + 1) + '" style="margin-left:20px" type="radio" value="false">   No' + 
                                '<input checked="true" class="packageOverage" id="packageOverageTimeYes_' + (i + 1) + '" name="packageOverageTime_' + (i + 1) + '" style="margin-left:5px" type="radio" value="true">   Yes' + 
                            '</div>' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageDutyHoursDiv_' + (i + 1) + '" style="display:block">' + 
                            '<label class="site_labels" for="packageDutyHours_' + (i + 1) + '">Package Duty Hours</label>' + 
                            '<input class="form-control" id="packageDutyHours_' + (i + 1) + '" name="packageDutyHours_' + (i + 1) + '" type="number" value="' + response.vehicle_package_rates[response.service_vehicles[service.id][0].id][0].package_duty_hours + '">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageOveragePerTimeDiv_' + (i + 1) + '" style="display:block">' + 
                            '<label class="site_labels" for="packageOveragePerTime_' + (i + 1) + '">Overage (per hour)</label>' + 
                            '<input class="form-control" id="packageOveragePerTime_' + (i + 1) + '" name="packageOveragePerTime_' + (i + 1) + '" type="number" value="' + response.vehicle_package_rates[response.service_vehicles[service.id][0].id][0].package_overage_per_time + '">' + 
                        '</div>'
                            }
                            else{
                                html = html +                                 
                                '<input checked="true" class="packageOverage" id="packageOverageNo_' + (i + 1) + '" name="packageOverageTime_' + (i + 1) + '" style="margin-left:20px" type="radio" value="false">   No' + 
                                '<input class="packageOverage" id="packageOverageTimeYes_' + (i + 1) + '" name="packageOverageTime_' + (i + 1) + '" style="margin-left:5px" type="radio" value="true">   Yes' + 
                            '</div>' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageDutyHoursDiv_' + (i + 1) + '" style="display:none">' + 
                            '<label class="site_labels" for="packageDutyHours_' + (i + 1) + '">Package Duty Hours</label>' + 
                            '<input class="form-control" id="packageDutyHours_' + (i + 1) + '" name="packageDutyHours_' + (i + 1) + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageOveragePerTimeDiv_' + (i + 1) + '" style="display:none">' + 
                            '<label class="site_labels" for="packageOveragePerTime_' + (i + 1) + '">Overage (per hour)</label>' + 
                            '<input class="form-control" id="packageOveragePerTime_' + (i + 1) + '" name="packageOveragePerTime_' + (i + 1) + '" type="number" value="">' + 
                        '</div>'   
                            }                                
                        }
                        else{
                            html = html + 
                                '<option value="">Choose Package Duration</option>' + 
                                '<option value="Daily">Daily</option>' + 
                                '<option value="Weekly">Weekly</option>' + 
                                '<option value="Monthly">Monthly</option>' + 
                            '</select>' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top">' + 
                            '<label class="site_labels" for="packageKm_' + (i + 1) + '">Package KMs</label>' + 
                            '<input class="form-control" id="packageKm_' + (i + 1) + '" name="packageKm_' + (i + 1) + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top">' + 
                            '<label class="site_labels" for="packageRate_' + (i + 1) + '">Package Rate</label>' + 
                            '<input class="form-control" id="packageRate_' + (i + 1) + '" name="packageRate_' + (i + 1) + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top">' + 
                            '<label class="site_labels" for="packageOveragePerKm_' + (i + 1) + '">Overage (per KM)</label>' + 
                            '<input class="form-control" id="packageOveragePerKm_' + (i + 1) + '" name="packageOveragePerKm_' + (i + 1) + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageMileageCalculationDiv_' + (i + 1) + '">' + 
                            '<label class="site_labels" for="packageMileageCalculation_' + (i + 1) + '">Mileage Calculation</label>' + 
                            '<div class="row">' +                                 
                                '<input checked="true" class="packageMileageCalculation" id="packageMileageCalculationOnDuty_' + (i + 1) + '" name="packageMileageCalculation_' + (i + 1) + '" style="margin-left:20px" type="radio" value="On Duty Hours">   On Duty Hours' + 
                                '<input class="packageMileageCalculation" id="packageMileageCalculationTripDuration_' + (i + 1) + '" name="packageMileageCalculation_' + (i + 1) + '" style="margin-left:5px" type="radio" value="Trip Duration">   Trip Duration' + 
                            '</div>' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top">' + 
                            '<label class="site_labels" for="packageOverageTime_' + (i + 1) + '">Overage for Duty Time</label>' + 
                            '<div class="row">' +                                 
                                '<input checked="true" class="packageOverage" id="packageOverageNo_' + (i + 1) + '" name="packageOverageTime_' + (i + 1) + '" style="margin-left:20px" type="radio" value="false">   No' + 
                                '<input class="packageOverage" id="packageOverageTimeYes_' + (i + 1) + '" name="packageOverageTime_' + (i + 1) + '" style="margin-left:5px" type="radio" value="true">   Yes' + 
                            '</div>' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageDutyHoursDiv_' + (i + 1) + '" style="display:none">' + 
                            '<label class="site_labels" for="packageDutyHours_' + (i + 1) + '">Package Duty Hours</label>' + 
                            '<input class="form-control" id="packageDutyHours_' + (i + 1) + '" name="packageDutyHours_' + (i + 1) + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageOveragePerTimeDiv_' + (i + 1) + '" style="display:none">' + 
                            '<label class="site_labels" for="packageOveragePerTime_' + (i + 1) + '">Overage (per hour)</label>' + 
                            '<input class="form-control" id="packageOveragePerTime_' + (i + 1) + '" name="packageOveragePerTime_' + (i + 1) + '" type="number" value="">' + 
                        '</div>'
                        }                            
                    html = html +                             
                    '</div>' + 
                '</div>' + 

                '<div class="vehicles" id="vehicles_' + (i + 1) + '" style="display:' + vehiclesDisplay + '">'
                zone_name_services[i + 1] = {}
                for(var y = 0; y < j; y++){                        
                    zone_name_services[i + 1][y + 1] = []
                    var defaultRate = ''
                    var guardRate = ''
                    if(response.vehicle_zones[response.service_vehicles[service.id][y].id].length > 0){
                        defaultRate = formatNull(response.vehicle_zones[response.service_vehicles[service.id][y].id][0].rate)
                        guardRate = formatNull(response.vehicle_zones[response.service_vehicles[service.id][y].id][0].guard_rate)
                    }
                    html = html + 
                    '<div class="col-md-12 vehicle-div">' + 
                        '<div class="col-md-3 margin-top">' + 
                            '<label class="site_labels" for="vehicleCapacity_' + (i + 1) + '_' + (y + 1) + '">Vehicle Capacity</label>' + 
                            '<input class="form-control" id="vehicleCapacity_' + (i + 1) + '_' + (y + 1) + '" name="vehicleCapacity_' + (i + 1) + '_' + (y + 1) + '" type="number" value="' + formatNull(response.service_vehicles[service.id][y].vehicle_capacity) + '">' + 
                        '</div>'                    
                    if(vehiclePackageRatesDisplay == 'none'){
                        html = html + 
                        '<div class="col-md-3 margin-top" id="packageDurationDiv_' + (i + 1) + '_' + (y + 1) + '"  style="display: none">' + 
                            '<label class="site_labels" for="packageDuration_' + (i + 1) + '_' + (y + 1) + '">Package Duration</label>' + 
                            '<select class="form-control billingModel" data-vehiclenumber="' + (y + 1) + '" id="packageDuration_' + (i + 1) + '_' + (y + 1) + '">' + 
                                '<option value="">Choose Package Duration</option>' + 
                                '<option value="Daily">Daily</option>' + 
                                '<option value="Weekly">Weekly</option>' + 
                                '<option value="Monthly">Monthly</option>' + 
                            '</select>' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageKmDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:none">' + 
                            '<label class="site_labels" for="packageKm_' + (i + 1) + '_' + (y + 1) + '">Package KMs</label>' + 
                            '<input class="form-control" id="packageKm_' + (i + 1) + '_' + (y + 1) + '" name="packageKm_' + (i + 1) + '_' + (y + 1) + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageRateDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:none">' + 
                            '<label class="site_labels" for="packageRate_' + (i + 1) + '_' + (y + 1) + '">Package Rate</label>' + 
                            '<input class="form-control" id="packageRate_' + (i + 1) + '_' + (y + 1) + '" name="packageRate_' + (i + 1) + '_' + (y + 1) + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageOveragePerKmDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:none">' + 
                            '<label class="site_labels" for="packageOveragePerKm_' + (i + 1) + '_' + (y + 1) + '">Overage (per KM)</label>' + 
                            '<input class="form-control" id="packageOveragePerKm_' + (i + 1) + '_' + (y + 1) + '" name="packageOveragePerKm_' + (i + 1) + '_' + (y + 1) + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageMileageCalculationDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:none">' + 
                            '<label class="site_labels" for="packageMileageCalculation_' + (i + 1) + '_' + (y + 1) + '">Mileage Calculation</label>' + 
                            '<div class="row">' +                                 
                                '<input checked="true" class="packageMileageCalculation" id="packageMileageCalculationOnDuty_' + (i + 1) + '_' + (y + 1) + '" name="packageMileageCalculation_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:20px" type="radio" value="On Duty Hours">   On Duty Hours' + 
                                '<input class="packageMileageCalculation" id="packageMileageCalculationTripDuration_' + (i + 1) + '_' + (y + 1) + '" name="packageMileageCalculation_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:5px" type="radio" value="Trip Duration">   Trip Duration' + 
                            '</div>' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageOverageTimeDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:none">' + 
                            '<label class="site_labels" for="packageOverageTime_' + (i + 1) + '_' + (y + 1) + '">Overage for Duty Time</label>' + 
                            '<div class="row">' +                           
                                '<input class="packageOverage" id="packageOverageTimeYes_' + (i + 1) + '_' + (y + 1) + '" name="packageOverageTime_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:5px" type="radio" value="true">   Yes' + 
                                '<input checked="true" class="packageOverage" id="packageOverageNo_' + (i + 1) + '_' + (y + 1) + '" name="packageOverageTime_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:20px" type="radio" value="false">   No' + 
                            '</div>' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageDutyHoursDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:none">' + 
                            '<label class="site_labels" for="packageDutyHours_' + (i + 1) + '_' + (y + 1) + '">Package Duty Hours</label>' + 
                            '<input class="form-control" id="packageDutyHours_' + (i + 1) + '_' + (y + 1) + '" name="packageDutyHours_' + (i + 1) + '_' + (y + 1) + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageOveragePerTimeDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:none">' + 
                            '<label class="site_labels" for="packageOveragePerTime_' + (i + 1) + '_' + (y + 1) + '">Overage (per hour)</label>' + 
                            '<input class="form-control" id="packageOveragePerTime_' + (i + 1) + '_' + (y + 1) + '" name="packageOveragePerTime_' + (i + 1) + '_' + (y + 1) + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="vehicleDefaultRateDiv_' + (i + 1) + '_' + (y + 1) + '">' + 
                            '<label class="site_labels" for="vehicleDefaultRate_' + (i + 1) + '_' + (y + 1) + '">Default Rate</label>' + 
                            '<input class="form-control" id="vehicleDefaultRate_' + (i + 1) + '_' + (y + 1) + '" name="vehicleDefaultRate_' + (i + 1) + '_' + (y + 1) + '" type="number" value="' + defaultRate + '">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="vehicleGuardRateDiv_' + (i + 1) + '_' + (y + 1) + '">' + 
                            '<label class="site_labels" for="vehicleGuardRate_' + (i + 1) + '_' + (y + 1) + '">Default Guard Rate</label>' + 
                            '<input class="form-control" id="vehicleGuardRate_' + (i + 1) + '_' + (y + 1) + '" name="vehicleGuardRate_' + (i + 1) + '_' + (y + 1) + '" type="number" value="' + guardRate + '">' + 
                        '</div>'
                    }
                    else{
                        html = html +
                        '<div class="col-md-3 margin-top" id="packageDurationDiv_' + (i + 1) + '_' + (y + 1) + '"  style="display:' + vehiclePackageRatesDisplay + '">' + 
                            '<label class="site_labels" for="packageDuration_' + (i + 1) + '_' + (y + 1) + '">Package Duration</label>' + 
                            '<select class="form-control billingModel" data-vehiclenumber="' + (y + 1) + '" id="packageDuration_' + (i + 1) + '_' + (y + 1) + '">'                            
                            if(response.vehicle_package_rates[response.service_vehicles[service.id][y].id][0].duration == "Daily"){
                                html = html + 
                                '<option checked="true" value="Daily">Daily</option>' + 
                                '<option value="">Choose Package Duration</option>' +                                 
                                '<option value="Weekly">Weekly</option>' + 
                                '<option value="Monthly">Monthly</option>'
                            }
                            else if(response.vehicle_package_rates[response.service_vehicles[service.id][y].id][0].duration == "Weekly"){
                                html = html + 
                                '<option checked="true" value="Weekly">Weekly</option>' + 
                                '<option value="">Choose Package Duration</option>' + 
                                '<option value="Daily">Daily</option>' +                                 
                                '<option value="Monthly">Monthly</option>'
                            }
                            else if(response.vehicle_package_rates[response.service_vehicles[service.id][y].id][0].duration == "Monthly"){
                                html = html + 
                                '<option checked="true" value="Monthly">Monthly</option>' + 
                                '<option value="">Choose Package Duration</option>' + 
                                '<option value="Daily">Daily</option>' + 
                                '<option value="Weekly">Weekly</option>'                                 
                            }
                            else{
                                html = html + 
                                '<option value="">Choose Package Duration</option>' + 
                                '<option value="Daily">Daily</option>' + 
                                '<option value="Weekly">Weekly</option>' + 
                                '<option value="Monthly">Monthly</option>'
                            }
                            html = html +                             
                            '</select>' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageKmDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:' + vehiclePackageRatesDisplay + '">' + 
                            '<label class="site_labels" for="packageKm_' + (i + 1) + '_' + (y + 1) + '">Package KMs</label>' + 
                            '<input class="form-control" id="packageKm_' + (i + 1) + '_' + (y + 1) + '" name="packageKm_' + (i + 1) + '_' + (y + 1) + '" type="number" value="' + response.vehicle_package_rates[response.service_vehicles[service.id][y].id][0].package_km + '">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageRateDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:' + vehiclePackageRatesDisplay + '">' + 
                            '<label class="site_labels" for="packageRate_' + (i + 1) + '_' + (y + 1) + '">Package Rate</label>' + 
                            '<input class="form-control" id="packageRate_' + (i + 1) + '_' + (y + 1) + '" name="packageRate_' + (i + 1) + '_' + (y + 1) + '" type="number" value="' + response.vehicle_package_rates[response.service_vehicles[service.id][y].id][0].package_rate + '">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageOveragePerKmDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:' + vehiclePackageRatesDisplay + '">' + 
                            '<label class="site_labels" for="packageOveragePerKm_' + (i + 1) + '_' + (y + 1) + '">Overage (per KM)</label>' + 
                            '<input class="form-control" id="packageOveragePerKm_' + (i + 1) + '_' + (y + 1) + '" name="packageOveragePerKm_' + (i + 1) + '_' + (y + 1) + '" type="number" value="' + response.vehicle_package_rates[response.service_vehicles[service.id][y].id][0].package_overage_per_km + '">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageMileageCalculationDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:' + vehiclePackageRatesDisplay + '">' + 
                            '<label class="site_labels" for="packageMileageCalculation_' + (i + 1) + '_' + (y + 1) + '">Mileage Calculation</label>' + 
                            '<div class="row">'
                            if(response.vehicle_package_rates[response.service_vehicles[service.id][y].id][0].package_mileage_calculation == "On Duty Hours"){
                                html = html +                                 
                                '<input checked="true" class="packageMileageCalculation" id="packageMileageCalculationOnDuty_' + (i + 1) + '_' + (y + 1) + '" name="packageMileageCalculation_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:20px" type="radio" value="On Duty Hours">   On Duty Hours' + 
                                '<input class="packageMileageCalculation" id="packageMileageCalculationTripDuration_' + (i + 1) + '_' + (y + 1) + '" name="packageMileageCalculation_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:5px" type="radio" value="Trip Duration">   Trip Duration'
                            }
                            else if(response.vehicle_package_rates[response.service_vehicles[service.id][y].id][0].package_mileage_calculation == "Trip Duration"){
                                html = html +                                 
                                '<input class="packageMileageCalculation" id="packageMileageCalculationOnDuty_' + (i + 1) + '_' + (y + 1) + '" name="packageMileageCalculation_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:20px" type="radio" value="On Duty Hours">   On Duty Hours' + 
                                '<input checked="true" class="packageMileageCalculation" id="packageMileageCalculationTripDuration_' + (i + 1) + '_' + (y + 1) + '" name="packageMileageCalculation_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:5px" type="radio" value="Trip Duration">   Trip Duration'
                            }
                            html = html + 
                            '</div>' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageOverageTimeDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:' + vehiclePackageRatesDisplay + '">' + 
                            '<label class="site_labels" for="packageOverageTime_' + (i + 1) + '_' + (y + 1) + '">Overage for Duty Time</label>' + 
                            '<div class="row">'
                            if(response.vehicle_package_rates[response.service_vehicles[service.id][y].id][0].package_overage_time == true){
                                html = html +                                 
                                '<input class="packageOverage" id="packageOverageNo_' + (i + 1) + '_' + (y + 1) + '" name="packageOverageTime_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:20px" type="radio" value="false">   No' + 
                                '<input checked="true" class="packageOverage" id="packageOverageTimeYes_' + (i + 1) + '_' + (y + 1) + '" name="packageOverageTime_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:5px" type="radio" value="true">   Yes' + 
                            '</div>' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageDutyHoursDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:' + vehiclePackageRatesDisplay + '">' + 
                            '<label class="site_labels" for="packageDutyHours_' + (i + 1) + '_' + (y + 1) + '">Package Duty Hours</label>' + 
                            '<input class="form-control" id="packageDutyHours_' + (i + 1) + '_' + (y + 1) + '" name="packageDutyHours_' + (i + 1) + '_' + (y + 1) + '" type="number" value="' + response.vehicle_package_rates[response.service_vehicles[service.id][y].id][0].package_duty_hours + '">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageOveragePerTimeDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:' + vehiclePackageRatesDisplay + '">' + 
                            '<label class="site_labels" for="packageOveragePerTime_' + (i + 1) + '_' + (y + 1) + '">Overage (per hour)</label>' + 
                            '<input class="form-control" id="packageOveragePerTime_' + (i + 1) + '_' + (y + 1) + '" name="packageOveragePerTime_' + (i + 1) + '_' + (y + 1) + '" type="number" value="' + response.vehicle_package_rates[response.service_vehicles[service.id][y].id][0].package_overage_per_time + '">' + 
                        '</div>'
                            }
                            else{
                                html = html +                                 
                                '<input checked="true" class="packageOverage" id="packageOverageNo_' + (i + 1) + '_' + (y + 1) + '" name="packageOverageTime_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:20px" type="radio" value="false">   No' + 
                                '<input class="packageOverage" id="packageOverageTimeYes_' + (i + 1) + '_' + (y + 1) + '" name="packageOverageTime_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:5px" type="radio" value="true">   Yes' + 
                            '</div>' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageDutyHoursDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:none">' + 
                            '<label class="site_labels" for="packageDutyHours_' + (i + 1) + '_' + (y + 1) + '">Package Duty Hours</label>' + 
                            '<input class="form-control" id="packageDutyHours_' + (i + 1) + '_' + (y + 1) + '" name="packageDutyHours_' + (i + 1) + '_' + (y + 1) + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="packageOveragePerTimeDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:none">' + 
                            '<label class="site_labels" for="packageOveragePerTime_' + (i + 1) + '_' + (y + 1) + '">Overage (per hour)</label>' + 
                            '<input class="form-control" id="packageOveragePerTime_' + (i + 1) + '_' + (y + 1) + '" name="packageOveragePerTime_' + (i + 1) + '_' + (y + 1) + '" type="number" value="">' + 
                        '</div>'   
                            }
                        html = html + 
                        '<div class="col-md-3 margin-top" id="vehicleDefaultRateDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:none">' + 
                            '<label class="site_labels" for="vehicleDefaultRate_' + (i + 1) + '_' + (y + 1) + '">Default Rate</label>' + 
                            '<input class="form-control" id="vehicleDefaultRate_' + (i + 1) + '_' + (y + 1) + '" name="vehicleDefaultRate_' + (i + 1) + '_' + (y + 1) + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top" id="vehicleGuardRateDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:none">' + 
                            '<label class="site_labels" for="vehicleGuardRate_' + (i + 1) + '_' + (y + 1) + '">Default Guard Rate</label>' + 
                            '<input class="form-control" id="vehicleGuardRate_' + (i + 1) + '_' + (y + 1) + '" name="vehicleGuardRate_' + (i + 1) + '_' + (y + 1) + '" type="number" value="">' + 
                        '</div>'
                    }
                        
                        html = html + 
                        '<div class="col-md-2 margin-top">'
                            
                        if(response.service_vehicles[service.id][y].ac){
                            html = html + 
                            '<label class="site_labels" for="vehicleAc_' + (i + 1) + '_' + (y + 1) + '" style="margin-right:20px">AC/Non-AC</label>' + 
                            '<div class="row">' + 
                                '<input checked="true" id="vehicleAcYes_' + (i + 1) + '_' + (y + 1) + '" name="vehicleAc_' + (i + 1) + '_' + (y + 1) + '" type="radio" value="true">   AC' + 
                                '<input id="vehicleAcNo_' + (i + 1) + '_' + (y + 1) + '" name="vehicleAc_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:20px" type="radio" value="false">   Non-AC' + 
                            '</div>' + 
                        '</div>'                        
                        // +'<div class="col-md-12 margin-top" id="overageDiv_' + (i + 1) + '_' + (y + 1) +'">' + 
                        //     '<label class="site_labels" for="overage_' + (i + 1) + '_' + (y + 1) + '">Overage</label>' + 
                        //     '<div class="row" style="margin-left:5px">'
                        //     if(response.service_vehicles[service.id][y].overage){
                        //         html = html + 
                        //         '<input checked="true" class="overage" id="overageYes_' + (i + 1) + '_' + (y + 1) + '" name="overage_' + (i + 1) + '_' + (y + 1) + '" type="radio" value="true">   Yes' + 
                        //         '<input class="overage" id="overageNo_' + (i + 1) + '_' + (y + 1) + '" name="overage_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:20px" type="radio" value="false">   No' + 
                        //     '</div>' + 
                        // '</div>' + 
                        // '<div class="col-md-4 margin-top" id="timeOnDutyDiv_' + (i + 1) + '_' + (y + 1) + '">' + 
                        //     '<label class="site_labels" for="timeOnDuty_' + (i + 1) + '_' + (y + 1) + '">Time on Duty per Day</label>' + 
                        //     '<input class="form-control" id="timeOnDuty_' + (i + 1) + '_' + (y + 1) + '" name="timeOnDuty_' + (i + 1) + '_' + (y + 1) + '" type="number" value="' + formatNull(response.service_vehicles[service.id][y].time_on_duty) + '">' + 
                        // '</div>' + 
                        // '<div class="col-md-4 margin-top" id="overageRateDiv_' + (i + 1) + '_' + (y + 1) + '">' + 
                        //     '<label class="site_labels" for="overageRate_' + (i + 1) + '_' + (y + 1) + '">Overage Rate</label>' + 
                        //     '<input class="form-control" id="overageRate_' + (i + 1) + '_' + (y + 1) + '" name="overageRate_' + (i + 1) + '_' + (y + 1) + '" type="number" value="' + formatNull(response.service_vehicles[service.id][y].overage_per_hour) + '">' + 
                        // '</div>'
                        //     }
                        //     else{
                        //         html = html + 
                        //         '<input class="overage" id="overageYes_' + (i + 1) + '_' + (y + 1) + '" name="overage_' + (i + 1) + '_' + (y + 1) + '" type="radio" value="true">   Yes' + 
                        //         '<input checked="true" class="overage" id="overageNo_' + (i + 1) + '_' + (y + 1) + '" name="overage_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:20px" type="radio" value="false">   No' + 
                        //     '</div>' + 
                        // '</div>' + 
                        // '<div class="col-md-4 margin-top" id="timeOnDutyDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:none">' + 
                        //     '<label class="site_labels" for="timeOnDuty_' + (i + 1) + '_' + (y + 1) + '">Time on Duty per Day</label>' + 
                        //     '<input class="form-control" id="timeOnDuty_' + (i + 1) + '_' + (y + 1) + '" name="timeOnDuty_' + (i + 1) + '_' + (y + 1) + '" type="number" value="' + formatNull(response.service_vehicles[service.id][y].time_on_duty) + '">' + 
                        // '</div>' + 
                        // '<div class="col-md-4 margin-top" id="overageRateDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:none">' + 
                        //     '<label class="site_labels" for="overageRate_' + (i + 1) + '_' + (y + 1) + '">Overage Rate</label>' + 
                        //     '<input class="form-control" id="overageRate_' + (i + 1) + '_' + (y + 1) + '" name="overageRate_' + (i + 1) + '_' + (y + 1) + '" type="number" value="' + formatNull(response.service_vehicles[service.id][y].overage_per_hour) + '">' + 
                        // '</div>'
                        //     }                                        
                        }
                        else{
                            html = html + 
                            '<label class="site_labels" for="vehicleAc_' + (i + 1) + '_' + (y + 1) + '" style="margin-right:20px">AC/Non-AC</label>' + 
                            '<div class="row">' + 
                                '<input id="vehicleAcYes_' + (i + 1) + '_' + (y + 1) + '" name="vehicleAc_' + (i + 1) + '_' + (y + 1) + '" type="radio" value="true">   AC' + 
                                '<input checked="true" id="vehicleAcNo_' + (i + 1) + '_' + (y + 1) + '" name="vehicleAc_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:20px" type="radio" value="false">   Non-AC' + 
                            '</div>' + 
                        '</div>'
                        // +'<div class="col-md-12 margin-top" id="overageDiv_' + (i + 1) + '_' + (y + 1) +'">' + 
                        //     '<label class="site_labels" for="overage_' + (i + 1) + '_' + (y + 1) + '">Overage</label>' + 
                        //     '<div class="row" style="margin-left:5px">'
                        //     if(response.service_vehicles[service.id][y].overage){
                        //         html = html + 
                        //         '<input checked="true" class="overage" id="overageYes_' + (i + 1) + '_' + (y + 1) + '" name="overage_' + (i + 1) + '_' + (y + 1) + '" type="radio" value="true">   Yes' + 
                        //         '<input class="overage" id="overageNo_' + (i + 1) + '_' + (y + 1) + '" name="overage_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:20px" type="radio" value="false">   No' + 
                        //     '</div>' + 
                        // '</div>' + 
                        // '<div class="col-md-4 margin-top" id="timeOnDutyDiv_' + (i + 1) + '_' + (y + 1) + '">' + 
                        //     '<label class="site_labels" for="timeOnDuty_' + (i + 1) + '_' + (y + 1) + '">Time on Duty per Day</label>' + 
                        //     '<input class="form-control" id="timeOnDuty_' + (i + 1) + '_' + (y + 1) + '" name="timeOnDuty_' + (i + 1) + '_' + (y + 1) + '" type="number" value="' + formatNull(response.service_vehicles[service.id][y].time_on_duty) + '">' + 
                        // '</div>' + 
                        // '<div class="col-md-4 margin-top" id="overageRateDiv_' + (i + 1) + '_' + (y + 1) + '">' + 
                        //     '<label class="site_labels" for="overageRate_' + (i + 1) + '_' + (y + 1) + '">Overage Rate</label>' + 
                        //     '<input class="form-control" id="overageRate_' + (i + 1) + '_' + (y + 1) + '" name="overageRate_' + (i + 1) + '_' + (y + 1) + '" type="number" value="' + formatNull(response.service_vehicles[service.id][y].overage_per_hour) + '">' + 
                        // '</div>'
                        //     }
                        //     else{
                        //         html = html + 
                        //         '<input class="overage" id="overageYes_' + (i + 1) + '_' + (y + 1) + '" name="overage_' + (i + 1) + '_' + (y + 1) + '" type="radio" value="true">   Yes' + 
                        //         '<input checked="true" class="overage" id="overageNo_' + (i + 1) + '_' + (y + 1) + '" name="overage_' + (i + 1) + '_' + (y + 1) + '" style="margin-left:20px" type="radio" value="false">   No' + 
                        //     '</div>' + 
                        // '</div>' + 
                        // '<div class="col-md-4 margin-top" id="timeOnDutyDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:none">' + 
                        //     '<label class="site_labels" for="timeOnDuty_' + (i + 1) + '_' + (y + 1) + '">Time on Duty per Day</label>' + 
                        //     '<input class="form-control" id="timeOnDuty_' + (i + 1) + '_' + (y + 1) + '" name="timeOnDuty_' + (i + 1) + '_' + (y + 1) + '" type="number" value="' + formatNull(response.service_vehicles[service.id][y].time_on_duty) + '">' + 
                        // '</div>' + 
                        // '<div class="col-md-4 margin-top" id="overageRateDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:none">' + 
                        //     '<label class="site_labels" for="overageRate_' + (i + 1) + '_' + (y + 1) + '">Overage Rate</label>' + 
                        //     '<input class="form-control" id="overageRate_' + (i + 1) + '_' + (y + 1) + '" name="overageRate_' + (i + 1) + '_' + (y + 1) + '" type="number" value="' + formatNull(response.service_vehicles[service.id][y].overage_per_hour) + '">' + 
                        // '</div>'
                        //     }
                        }
                        html = html + 
                        '<div class="col-md-1 margin-top">' +
                            '<button id="vehicleDelete_' + (i + 1) + '_' + (y + 1) + '" class="fa fa-times deleteIcon" data-serviceNumber="' + (i + 1) + '" data-vehicleNumber="' + (y + 1) + '">' + 
                            '</button>' + 
                        '</div>' + 
                        '<div id="zones_' + (i + 1) + '_' + (y + 1) + '" style="display:' + vehicleZonesDisplay + '">'
                        var n = response.vehicle_zones[response.service_vehicles[service.id][y].id].length
                        for(var z = 0; z < n - 1; z++){
                            zone_name_services[i + 1][y + 1].push(formatNull(response.vehicle_zones[response.service_vehicles[service.id][y].id][z + 1].name))
                            html = html + 
                            '<div class="col-md-12 zone-div">' + 
                                '<div class="col-md-4 margin-top">' + 
                                    '<label class="site_labels" for="zoneName_' + (i + 1) + '_' + (y + 1) + '_' + (z + 1) + '">Zone Name</label>' + 
                                    '<input class="form-control" id="zoneName_' + (i + 1) + '_' + (y + 1) + '_' + (z + 1) + '" name="zoneName_' + (i + 1) + '_' + (y + 1) + '_' + (z + 1) + '" value="' + formatNull(response.vehicle_zones[response.service_vehicles[service.id][y].id][z + 1].name) + '">' + 
                                '</div>' + 
                                '<div class="col-md-4 margin-top">' + 
                                    '<label class="site_labels" for="zoneRate_' + (i + 1) + '_' + (y + 1) + '_' + (z + 1) + '">Zone Rate</label>' + 
                                    '<input class="form-control" id="zoneRate_' + (i + 1) + '_' + (y + 1) + '_' + (z + 1) + '" name="zoneRate_' + (i + 1) + '_' + (y + 1) + '_' + (z + 1) + '" type="number" value="' + formatNull(response.vehicle_zones[response.service_vehicles[service.id][y].id][z + 1].rate) + '">' + 
                                '</div>' + 
                                '<div class="col-md-3 margin-top">' + 
                                    '<label class="site_labels" for="zoneGuardRate_' + (i + 1) + '_' + (y + 1) + '_' + (z + 1) + '">Guard Rate</label>' + 
                                    '<input class="form-control" id="zoneGuardRate_' + (i + 1) + '_' + (y + 1) + '_' + (z + 1) + '" name="zoneGuardRate_' + (i + 1) + '_' + (y + 1) + '_' + (z + 1) + '" type="number" value="' + formatNull(response.vehicle_zones[response.service_vehicles[service.id][y].id][z + 1].guard_rate) + '">' + 
                                '</div>' + 
                                '<div class="col-md-1 margin-top">' +
                                    '<button id="zoneDelete_' + (i + 1) + '_' + (y + 1) + '_' + (z + 1) + '" class="fa fa-times deleteIcon" data-serviceNumber="' + (i + 1) + '" data-vehicleNumber="' + (y + 1) + '" data-zoneNumber="' + (z + 1) + '">' + 
                                    '</button>' + 
                                '</div>' +
                            '</div>'
                        }
                        html = html + 
                            '<div class="col-md-12 zone-div" style="display:hidden">' + 
                                '<div class="col-md-4 margin-top">' + 
                                    '<label class="site_labels" for="zoneName_' + (i + 1) + '_' + (y + 1) + '_' + (n) + '">Zone Name</label>' + 
                                    '<input class="form-control" id="zoneName_' + (i + 1) + '_' + (y + 1) + '_' + (n) + '" name="zoneName_' + (i + 1) + '_' + (y + 1) + '_' + (n) + '" value="">' + 
                                '</div>' + 
                                '<div class="col-md-4 margin-top">' + 
                                    '<label class="site_labels" for="zoneRate_' + (i + 1) + '_' + (y + 1) + '_' + (n) + '">Zone Rate</label>' + 
                                    '<input class="form-control" id="zoneRate_' + (i + 1) + '_' + (y + 1) + '_' + (n) + '" name="zoneRate_' + (i + 1) + '_' + (y + 1) + '_' + (n) + '" type="number" value="">' + 
                                '</div>' + 
                                '<div class="col-md-3 margin-top">' + 
                                    '<label class="site_labels" for="zoneGuardRate_' + (i + 1) + '_' + (y + 1) + '_' + (n) + '">Guard Rate</label>' + 
                                    '<input class="form-control" id="zoneGuardRate_' + (i + 1) + '_' + (y + 1) + '_' + (n) + '" name="zoneGuardRate_' + (i + 1) + '_' + (y + 1) + '_' + (n) + '" type="number" value="">' + 
                                '</div>' + 
                                '<div class="col-md-1 margin-top">' +
                                    '<button id="zoneDelete_' + (i + 1) + '_' + (y + 1) + '_' + (z + 1) + '" class="fa fa-times deleteIcon" data-serviceNumber="' + (i + 1) + '" data-vehicleNumber="' + (y + 1) + '" data-zoneNumber="' + (z + 1) + '">' + 
                                    '</button>' + 
                                '</div>' +
                            '</div>' +
                        '</div>' +
                        '<div class="col-md-12" id="addZonesDiv_' + (i + 1) + '_' + (y + 1) + '" style="display:' + vehicleZonesDisplay + '">' + 
                            '<button id="addZones_' + (i + 1) + '_' + (y + 1) + '" class="margin-top margin-right2x btn btn-primary pull-right addZone" data-servicenumber="' + (i + 1) + '" data-vehiclenumber="' + (y + 1) + '" data-zonenumber="' + (n + 1) + '">Add Zone Rate</button>' + 
                        '</div>' + 
                    '</div>'
                }

                html = html + 
                '</div>' + 
                '<div class="col-md-12" id="addVehiclesDiv_' + (i + 1) + '" style="display:' + vehiclesDisplay + '">' + 
                    '<button class="margin-top margin-right btn btn-primary pull-right addVehicle" data-servicenumber="' + (i + 1) + '" data-vehiclenumber="' + (j + 1) + '" data-zonenumber="1">Add Vehicle Rate</button>' + 
                '</div>'
                    
    return html
}

$(document).on('click', '.fa-times', function(e){
    e.preventDefault()
    var id = e.target.id
    serviceNumber = e.target.dataset.servicenumber
    vehicleNumber = e.target.dataset.vehiclenumber
    zoneNumber = e.target.dataset.zonenumber
    
    if(id.indexOf('service') != -1){
        var totalServices = $('#addServicesDiv').children()[0].dataset['servicenumber']            
        if(totalServices - deletedServices.length > 2){
            deletedServices.push(serviceNumber)
            $("#serviceDelete_" + serviceNumber).parent().parent().css('display', 'none');
            $(".addService").removeAttr("disabled", "disabled")
        }
    }
    else if(id.indexOf('vehicle') != -1){
        var totalVehicles = $('#addVehiclesDiv_' + serviceNumber).children()[0].dataset['vehiclenumber']
        if(deletedVehicles[serviceNumber] == undefined || deletedVehicles[serviceNumber] == null){
            deletedVehicles[serviceNumber] = []
        }
        if(totalVehicles - deletedVehicles[serviceNumber].length > 2){
            deletedVehicles[serviceNumber].push(vehicleNumber)
            $("#vehicleDelete_" + serviceNumber + '_' + vehicleNumber).parent().parent().css('display', 'none');
        }
    }
    else{
        if(vehicleNumber != null && vehicleNumber != undefined && vehicleNumber != ''){
            var totalZones = $('#addZonesDiv_' + serviceNumber + '_' + vehicleNumber).children()[0].dataset['zonenumber']
            if(deletedVehicleZones[serviceNumber] == undefined || deletedVehicleZones[serviceNumber] == null){
                deletedVehicleZones[serviceNumber] = {}
            }
            if(deletedVehicleZones[serviceNumber][vehicleNumber] == undefined || deletedVehicleZones[serviceNumber][vehicleNumber] == null){
                deletedVehicleZones[serviceNumber][vehicleNumber] = []
            }
            if(totalZones - deletedVehicleZones[serviceNumber][vehicleNumber].length > 2){
                deletedVehicleZones[serviceNumber][vehicleNumber].push(zoneNumber)
                $("#zoneDelete_" + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber).parent().parent().css('display', 'none');
            }                
        }
        else{
            var totalZones = $('#addZonesDiv_' + serviceNumber).children()[0].dataset['zonenumber']
            if(deletedZones[serviceNumber] == undefined || deletedZones[serviceNumber] == null){
                deletedZones[serviceNumber] = []
            }
            if(totalZones - deletedZones[serviceNumber].length > 2){
                $("#zoneDelete_" + serviceNumber + '_' + zoneNumber).parent().parent().css('display', 'none');
                deletedZones[serviceNumber].push(zoneNumber)
            }                
        }
    }
});

$(document).on('change', '.serviceType', function(e) {
    serviceNumber = e.target.id.split("_")[1]
});

$(document).on('change', '.billingModel', function(e) {        
    serviceNumber = e.target.id.split("_")[1]        
    if($("input[name='varyWithVehicle_" + serviceNumber + "']:checked").val() == "false"){
        document.getElementById("vehicles_" + serviceNumber).style.display='none';
        if(e.target.value == 'Fixed Rate per Trip'){
            // document.getElementById("defaultRateDiv_" + serviceNumber).style.display='none';
            document.getElementById("zones_" + serviceNumber).style.display='none';
            document.getElementById("addZonesDiv_" + serviceNumber).style.display='none';
            document.getElementById("package_" + serviceNumber).style.display='none';
            document.getElementById("guardRateDiv_" + serviceNumber).style.display='block';
            document.getElementById("defaultRateDiv_" + serviceNumber).style.display='block';                        

            // document.getElementById("ratePerTripDiv_" + serviceNumber).style.display='block';
            // document.getElementById("guardRateDiv_" + serviceNumber).style.display='block';
        }
        else if(e.target.value == 'Fixed Rate per Zone'){
            // document.getElementById("ratePerTripDiv_" + serviceNumber).style.display='none';
            // document.getElementById("guardRateDiv_" + serviceNumber).style.display='none';

            // document.getElementById("defaultRateDiv_" + serviceNumber).style.display='block';
            document.getElementById("package_" + serviceNumber).style.display='none';            
            document.getElementById("zones_" + serviceNumber).style.display='block';
            document.getElementById("addZonesDiv_" + serviceNumber).style.display='block';
            document.getElementById("guardRateDiv_" + serviceNumber).style.display='block';
            document.getElementById("defaultRateDiv_" + serviceNumber).style.display='block';                        
        }
        else if(e.target.value == 'Package Rates'){
            // document.getElementById("ratePerTripDiv_" + serviceNumber).style.display='none';
            document.getElementById("guardRateDiv_" + serviceNumber).style.display='none';
            document.getElementById("defaultRateDiv_" + serviceNumber).style.display='none';                        
            document.getElementById("zones_" + serviceNumber).style.display='none';
            document.getElementById("addZonesDiv_" + serviceNumber).style.display='none';
            document.getElementById("package_" + serviceNumber).style.display='block';

        }
    }
    else{
        vehicleNumber = e.target.dataset.vehiclenumber            
        document.getElementById("vehicles_" + serviceNumber).style.display='block';

        // document.getElementById("ratePerTripDiv_" + serviceNumber).style.display='none';
        document.getElementById("guardRateDiv_" + serviceNumber).style.display='none';
        document.getElementById("defaultRateDiv_" + serviceNumber).style.display='none';            
        document.getElementById("zones_" + serviceNumber).style.display='none';
        document.getElementById("addZonesDiv_" + serviceNumber).style.display='none';

        if(e.target.value == 'Fixed Rate per Trip'){
            for(var i = 1; i <= vehicleNumber; i++){
                document.getElementById("zones_" + serviceNumber + "_" + i).style.display='none';
                // document.getElementById("vehicleDefaultRateDiv_" + serviceNumber + '_' + i).style.display='none';
                document.getElementById("addZonesDiv_" + serviceNumber + "_" + i).style.display='none';
                // document.getElementById("vehicleRatePerTripDiv_" + serviceNumber + '_' + i).style.display='block';  

                document.getElementById("vehicleDefaultRateDiv_" + serviceNumber + "_" + i).style.display='block';
                document.getElementById("vehicleGuardRateDiv_" + serviceNumber + "_" + i).style.display='block';                
                document.getElementById("packageDurationDiv_" + serviceNumber + "_" + i).style.display='none';
                document.getElementById("packageKmDiv_" + serviceNumber + "_" + i).style.display='none';
                document.getElementById("packageRateDiv_" + serviceNumber + "_" + i).style.display='none';
                document.getElementById("packageOveragePerKmDiv_" + serviceNumber + "_" + i).style.display='none';
                document.getElementById("packageOverageTimeDiv_" + serviceNumber + "_" + i).style.display='none';                
                document.getElementById("packageDutyHoursDiv_" + serviceNumber + "_" + i).style.display='none';
                document.getElementById("packageOveragePerTimeDiv_" + serviceNumber + "_" + i).style.display='none';
                document.getElementById("packageMileageCalculationDiv_" + serviceNumber + "_" + i).style.display='none';
            }
        }
        else if(e.target.value == 'Fixed Rate per Zone'){           
            for(var i = 1; i <= vehicleNumber; i++){
                // document.getElementById("vehicleRatePerTripDiv_" + serviceNumber + '_' + i).style.display='none';   
                document.getElementById("zones_" + serviceNumber + "_" + i).style.display='block';
                // document.getElementById("vehicleDefaultRateDiv_" + serviceNumber + '_' + i).style.display='block';
                document.getElementById("addZonesDiv_" + serviceNumber + "_" + i).style.display='block';

                document.getElementById("vehicleDefaultRateDiv_" + serviceNumber + "_" + i).style.display='block';
                document.getElementById("vehicleGuardRateDiv_" + serviceNumber + "_" + i).style.display='block';                
                document.getElementById("packageDurationDiv_" + serviceNumber + "_" + i).style.display='none';
                document.getElementById("packageKmDiv_" + serviceNumber + "_" + i).style.display='none';
                document.getElementById("packageRateDiv_" + serviceNumber + "_" + i).style.display='none';
                document.getElementById("packageOveragePerKmDiv_" + serviceNumber + "_" + i).style.display='none';
                document.getElementById("packageOverageTimeDiv_" + serviceNumber + "_" + i).style.display='none';                
                document.getElementById("packageDutyHoursDiv_" + serviceNumber + "_" + i).style.display='none';
                document.getElementById("packageOveragePerTimeDiv_" + serviceNumber + "_" + i).style.display='none';
                document.getElementById("packageMileageCalculationDiv_" + serviceNumber + "_" + i).style.display='none';
            }
        }
        else if(e.target.value == 'Package Rates'){           
            for(var i = 1; i <= vehicleNumber; i++){
                // document.getElementById("vehicleRatePerTripDiv_" + serviceNumber + '_' + i).style.display='none';   
                document.getElementById("zones_" + serviceNumber + "_" + i).style.display='none';
                // document.getElementById("vehicleDefaultRateDiv_" + serviceNumber + '_' + i).style.display='block';
                document.getElementById("addZonesDiv_" + serviceNumber + "_" + i).style.display='none';

                document.getElementById("vehicleDefaultRateDiv_" + serviceNumber + "_" + i).style.display='none';
                document.getElementById("vehicleGuardRateDiv_" + serviceNumber + "_" + i).style.display='none';                
                document.getElementById("packageDurationDiv_" + serviceNumber + "_" + i).style.display='block';
                document.getElementById("packageKmDiv_" + serviceNumber + "_" + i).style.display='block';
                document.getElementById("packageRateDiv_" + serviceNumber + "_" + i).style.display='block';
                document.getElementById("packageOveragePerKmDiv_" + serviceNumber + "_" + i).style.display='block';
                document.getElementById("packageOverageTimeDiv_" + serviceNumber + "_" + i).style.display='block';
                document.getElementById("packageMileageCalculationDiv_" + serviceNumber + "_" + i).style.display='block';
            }
        }
    }
});

$(document).on('change', '.varyWithVehicle', function(e) {        
    serviceNumber = e.target.id.split("_")[1]
    vehicleNumber = e.target.dataset.vehiclenumber    

    console.log(vehicleNumber)
    console.log(serviceNumber)

    if(e.target.value == "true"){
        document.getElementById("defaultRateDiv_" + serviceNumber).style.display='none';
        document.getElementById("zones_" + serviceNumber).style.display='none';
        // document.getElementById("ratePerTripDiv_" + serviceNumber).style.display='none';
        document.getElementById("guardRateDiv_" + serviceNumber).style.display='none';
        document.getElementById("addZonesDiv_" + serviceNumber).style.display='none';
        // document.getElementById("overageDiv_" + serviceNumber).style.display='none';
        // document.getElementById("timeOnDutyDiv_" + serviceNumber).style.display='none';
        // document.getElementById("overageRateDiv_" + serviceNumber).style.display='none';
        document.getElementById("package_" + serviceNumber).style.display='none';

        document.getElementById("vehicles_" + serviceNumber).style.display='block';
        document.getElementById("addVehiclesDiv_" + serviceNumber).style.display='block';

        for(var x = 0; x < vehicleNumber; x++){
            if($("#billingModel_" + serviceNumber).val() == 'Fixed Rate per Trip'){
                document.getElementById("zones_" + serviceNumber + "_" + (x + 1)).style.display='none';
                // document.getElementById("vehicleDefaultRateDiv_" + serviceNumber + '_' + vehicleNumber).style.display='none';
                document.getElementById("addZonesDiv_" + serviceNumber + "_" + (x + 1)).style.display='none';
                // document.getElementById("vehicleRatePerTripDiv_" + serviceNumber + '_' + vehicleNumber).style.display='block';

                document.getElementById("vehicleDefaultRateDiv_" + serviceNumber + "_" + (x + 1)).style.display='block';
                document.getElementById("vehicleGuardRateDiv_" + serviceNumber + "_" + (x + 1)).style.display='block';

                document.getElementById("packageDurationDiv_" + serviceNumber + "_" + (x + 1)).style.display='none';
                document.getElementById("packageKmDiv_" + serviceNumber + "_" + (x + 1)).style.display='none';
                document.getElementById("packageRateDiv_" + serviceNumber + "_" + (x + 1)).style.display='none';
                document.getElementById("packageOveragePerKmDiv_" + serviceNumber + "_" + (x + 1)).style.display='none';
                document.getElementById("packageOverageTimeDiv_" + serviceNumber + "_" + (x + 1)).style.display='none';
            }
            else if($("#billingModel_" + serviceNumber).val() == 'Fixed Rate per Zone'){
                // document.getElementById("vehicleRatePerTripDiv_" + serviceNumber + '_' + vehicleNumber).style.display='none';
                document.getElementById("zones_" + serviceNumber + "_" + (x + 1)).style.display='block';
                // document.getElementById("vehicleDefaultRateDiv_" + serviceNumber + '_' + vehicleNumber).style.display='block';
                document.getElementById("addZonesDiv_" + serviceNumber + "_" + (x + 1)).style.display='block';

                document.getElementById("vehicleDefaultRateDiv_" + serviceNumber + "_" + (x + 1)).style.display='block';
                document.getElementById("vehicleGuardRateDiv_" + serviceNumber + "_" + (x + 1)).style.display='block';

                document.getElementById("packageDurationDiv_" + serviceNumber + "_" + (x + 1)).style.display='none';
                document.getElementById("packageKmDiv_" + serviceNumber + "_" + (x + 1)).style.display='none';
                document.getElementById("packageRateDiv_" + serviceNumber + "_" + (x + 1)).style.display='none';
                document.getElementById("packageOveragePerKmDiv_" + serviceNumber + "_" + (x + 1)).style.display='none';
                document.getElementById("packageOverageTimeDiv_" + serviceNumber + "_" + (x + 1)).style.display='none';
            }             
            else if($("#billingModel_" + serviceNumber).val() == 'Package Rates'){
                // document.getElementById("vehicleRatePerTripDiv_" + serviceNumber + '_' + vehicleNumber).style.display='none';
                document.getElementById("zones_" + serviceNumber + "_" + (x + 1)).style.display='none';
                // document.getElementById("vehicleDefaultRateDiv_" + serviceNumber + '_' + vehicleNumber).style.display='block';
                document.getElementById("addZonesDiv_" + serviceNumber + "_" + (x + 1)).style.display='none';
                
                document.getElementById("vehicleDefaultRateDiv_" + serviceNumber + "_" + (x + 1)).style.display='none';
                document.getElementById("vehicleGuardRateDiv_" + serviceNumber + "_" + (x + 1)).style.display='none';

                document.getElementById("packageDurationDiv_" + serviceNumber + "_" + (x + 1)).style.display='block';
                document.getElementById("packageKmDiv_" + serviceNumber + "_" + (x + 1)).style.display='block';
                document.getElementById("packageRateDiv_" + serviceNumber + "_" + (x + 1)).style.display='block';
                document.getElementById("packageOveragePerKmDiv_" + serviceNumber + "_" + (x + 1)).style.display='block';
                document.getElementById("packageOverageTimeDiv_" + serviceNumber + "_" + (x + 1)).style.display='block';
                document.getElementById("packageMileageCalculationDiv_" + serviceNumber + "_" + (x + 1)).style.display='block';
            }             
        }
        
    }
    else if(e.target.value == "false"){
        document.getElementById("vehicles_" + serviceNumber).style.display='none';
        document.getElementById("addVehiclesDiv_" + serviceNumber).style.display='none';

        document.getElementById("defaultRateDiv_" + serviceNumber).style.display='block'; 
        // document.getElementById("ratePerTripDiv_" + serviceNumber).style.display='block';
        document.getElementById("guardRateDiv_" + serviceNumber).style.display='block';
        // document.getElementById("overageDiv_" + serviceNumber).style.display='block';

        // if($("input[name='overage_" + serviceNumber + "']:checked").val() == "false"){
        //     document.getElementById("timeOnDutyDiv_" + serviceNumber).style.display='none';
        //     document.getElementById("overageRateDiv_" + serviceNumber).style.display='none';
        // }
        // else if($("input[name='overage_" + serviceNumber + "']:checked").val() == "true"){
        //     document.getElementById("timeOnDutyDiv_" + serviceNumber).style.display='block';
        //     document.getElementById("overageRateDiv_" + serviceNumber).style.display='block';   
        // }

        if($("#billingModel_" + serviceNumber).find(":selected").text() == 'Fixed Rate per Zone'){
            document.getElementById("zones_" + serviceNumber).style.display='block';
            document.getElementById("addZonesDiv_" + serviceNumber).style.display='block';
            document.getElementById("package_" + serviceNumber).style.display='none';
        }
        else if($("#billingModel_" + serviceNumber).find(":selected").text() == 'Fixed Rate per Trip'){
            document.getElementById("zones_" + serviceNumber).style.display='none';
            document.getElementById("addZonesDiv_" + serviceNumber).style.display='none';
            document.getElementById("package_" + serviceNumber).style.display='none';
        }
        else if($("#billingModel_" + serviceNumber).find(":selected").text() == 'Package Rates'){
            document.getElementById("zones_" + serviceNumber).style.display='none';
            document.getElementById("addZonesDiv_" + serviceNumber).style.display='none';
            document.getElementById("defaultRateDiv_" + serviceNumber).style.display='none';             
            document.getElementById("guardRateDiv_" + serviceNumber).style.display='none';
            document.getElementById("package_" + serviceNumber).style.display='block';
        }
    }
    
});

$(document).on('change', '.overage', function(e){
    var data = e.target.id.split("_")
    serviceNumber = data[1]
    if(data.length == 3){
        vehicleNumber = data[2]
        if(e.target.value == "true"){
            document.getElementById("timeOnDutyDiv_" + serviceNumber + "_" + vehicleNumber).style.display='block';
            document.getElementById("overageRateDiv_" + serviceNumber + "_" + vehicleNumber).style.display='block';
        }
        else if(e.target.value == "false"){
            document.getElementById("timeOnDutyDiv_" + serviceNumber + "_" + vehicleNumber).style.display='none';
            document.getElementById("overageRateDiv_" + serviceNumber + "_" + vehicleNumber).style.display='none';
        }
    }
    else{
        if(e.target.value == "true"){
            document.getElementById("timeOnDutyDiv_" + serviceNumber).style.display='block';
            document.getElementById("overageRateDiv_" + serviceNumber).style.display='block';
        }
        else if(e.target.value == "false"){
            document.getElementById("timeOnDutyDiv_" + serviceNumber).style.display='none';
            document.getElementById("overageRateDiv_" + serviceNumber).style.display='none';
        }
    }        
})

$(document).on('change', '.packageOverage', function(e){
    var data = e.target.id.split("_")
    serviceNumber = data[1]
    if(data.length == 3){
        vehicleNumber = data[2]
        if(e.target.value == "true"){
            document.getElementById("packageDutyHoursDiv_" + serviceNumber + "_" + vehicleNumber).style.display='block';
            document.getElementById("packageOveragePerTimeDiv_" + serviceNumber + "_" + vehicleNumber).style.display='block';
        }
        else if(e.target.value == "false"){
            document.getElementById("packageDutyHoursDiv_" + serviceNumber + "_" + vehicleNumber).style.display='none';
            document.getElementById("packageOveragePerTimeDiv_" + serviceNumber + "_" + vehicleNumber).style.display='none';
        }
    }
    else{
        if(e.target.value == "true"){
            document.getElementById("packageDutyHoursDiv_" + serviceNumber).style.display='block';
            document.getElementById("packageOveragePerTimeDiv_" + serviceNumber).style.display='block';
        }
        else if(e.target.value == "false"){
            document.getElementById("packageDutyHoursDiv_" + serviceNumber).style.display='none';
            document.getElementById("packageOveragePerTimeDiv_" + serviceNumber).style.display='none';
        }
    }        
})

function validateZones(serviceNumber, vehicleNumber, i, validationError, zoneDisplay){
    if(zoneDisplay == 'block'){
        if(vehicleNumber != null){
            if($("#zoneName_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() == '' || $("#zoneName_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() == undefined || $("#zoneName_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() == null || zone_name_services[serviceNumber][vehicleNumber].indexOf($("#zoneName_" + serviceNumber + "_" + vehicleNumber + "_" + i).val()) != -1){
                document.getElementById('zoneName_' + serviceNumber + '_' + vehicleNumber + '_' + i).classList.add("border-danger")
                validationError = true
                console.log("zone name error ", serviceNumber, vehicleNumber, i)
            }
            else{
                document.getElementById('zoneName_' + serviceNumber + '_' + vehicleNumber + '_' + i).classList.remove("border-danger")
                validationError = validationError || false
            }
            if($("#zoneRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() == '' || $("#zoneRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() == undefined || $("#zoneRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() == null || $("#zoneRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() < 0){
                document.getElementById('zoneRate_' + serviceNumber + '_' + vehicleNumber + '_' + i).classList.add("border-danger")
                validationError = true
                console.log("zone rate error ", serviceNumber, vehicleNumber, i)
            }
            else{
                document.getElementById('zoneRate_' + serviceNumber + '_' + vehicleNumber + '_' + i).classList.remove("border-danger")
                validationError = validationError || false
            }
            if($("#zoneGuardRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() == '' || $("#zoneGuardRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() == undefined || $("#zoneGuardRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() == null || $("#zoneGuardRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() < 0){
                document.getElementById('zoneGuardRate_' + serviceNumber + '_' + vehicleNumber + '_' + i).classList.add("border-danger")
                validationError = true
                console.log("zone guard rate error ", serviceNumber, vehicleNumber, i)
            }
            else{
                document.getElementById('zoneGuardRate_' + serviceNumber + '_' + vehicleNumber + '_' + i).classList.remove("border-danger")
                validationError = validationError || false
            }
            return validationError
        }
        else{
            if($("#zoneName_" + serviceNumber + '_' + i).val() == '' || $("#zoneName_" + serviceNumber + '_' + i).val() == undefined || $("#zoneName_" + serviceNumber + '_' + i).val() == null || zone_names[serviceNumber].indexOf($("#zoneName_" + serviceNumber + '_' + i).val()) != -1){
                document.getElementById('zoneName_' + serviceNumber + '_' + i).classList.add("border-danger")
                validationError = true
                console.log("zone name error ", serviceNumber)
            }
            else{
                document.getElementById('zoneName_' + serviceNumber + '_' + i).classList.remove("border-danger")
                validationError = validationError || false
            }
            if($("#zoneRate_" + serviceNumber + '_' + i).val() == '' || $("#zoneRate_" + serviceNumber + '_' + i).val() == undefined || $("#zoneRate_" + serviceNumber + '_' + i).val() == null || parseFloat($("#zoneRate_" + serviceNumber + '_' + i).val()) < 0){
                document.getElementById('zoneRate_' + serviceNumber + '_' + i).classList.add("border-danger")
                validationError = true
                console.log("zone rate error ", serviceNumber)
            }
            else{
                document.getElementById('zoneRate_' + serviceNumber + '_' + i).classList.remove("border-danger")
                validationError = validationError || false
            }
            if($("#zoneGuardRate_" + serviceNumber + '_' + i).val() == '' || $("#zoneGuardRate_" + serviceNumber + '_' + i).val() == undefined || $("#zoneGuardRate_" + serviceNumber + '_' + i).val() == null || parseFloat($("#zoneGuardRate_" + serviceNumber + '_' + i).val()) < 0){
                document.getElementById('zoneGuardRate_' + serviceNumber + '_' + i).classList.add("border-danger")
                validationError = true
                console.log("zone guard rate error ", serviceNumber)
            }
            else{
                document.getElementById('zoneGuardRate_' + serviceNumber + '_' + i).classList.remove("border-danger")
                validationError = validationError || false
            }
            return validationError
        }
    }    
    else{
        if(vehicleNumber != null){
            if($("#defaultRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() == '' || $("#defaultRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() == undefined || $("#defaultRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() == null || $("#defaultRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() < 0){
                document.getElementById('defaultRate_' + serviceNumber + '_' + vehicleNumber + '_' + i).classList.add("border-danger")
                validationError = true
                console.log("zone default rate error ", serviceNumber, vehicleNumber, i)
            }
            else{
                document.getElementById('defaultRate_' + serviceNumber + '_' + vehicleNumber + '_' + i).classList.remove("border-danger")
                validationError = validationError || false
            }
            if($("#guardRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() == '' || $("#guardRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() == undefined || $("#guardRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() == null || $("#guardRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val() < 0){
                document.getElementById('guardRate_' + serviceNumber + '_' + vehicleNumber + '_' + i).classList.add("border-danger")
                validationError = true
                console.log("zone guard rate error ", serviceNumber, vehicleNumber, i)
            }
            else{
                document.getElementById('guardRate_' + serviceNumber + '_' + vehicleNumber + '_' + i).classList.remove("border-danger")
                validationError = validationError || false
            }
            return validationError
        }
        else{
            if($("#defaultRate_" + serviceNumber + '_' + i).val() == '' || $("#defaultRate_" + serviceNumber + '_' + i).val() == undefined || $("#defaultRate_" + serviceNumber + '_' + i).val() == null || parseFloat($("#defaultRate_" + serviceNumber + '_' + i).val()) < 0){
                document.getElementById('defaultRate_' + serviceNumber + '_' + i).classList.add("border-danger")
                validationError = true
                console.log("zone default rate error ", serviceNumber, vehicleNumber, i)
            }
            else{
                document.getElementById('defaultRate_' + serviceNumber + '_' + i).classList.remove("border-danger")
                validationError = validationError || false
            }
            if($("#guardRate_" + serviceNumber + '_' + i).val() == '' || $("#guardRate_" + serviceNumber + '_' + i).val() == undefined || $("#guardRate_" + serviceNumber + '_' + i).val() == null || parseFloat($("#guardRate_" + serviceNumber + '_' + i).val()) < 0){
                document.getElementById('guardRate_' + serviceNumber + '_' + i).classList.add("border-danger")
                validationError = true
                console.log("zone guard rate error ", serviceNumber, vehicleNumber, i)
            }
            else{
                document.getElementById('guardRate_' + serviceNumber + '_' + i).classList.remove("border-danger")
                validationError = validationError || false
            }
            return validationError
        }
    }
}

$(document).on('click', '.addZone', function(e){
    e.preventDefault()
    serviceNumber = parseInt(e.target.dataset.servicenumber)        
    zoneNumber = parseInt(e.target.dataset.zonenumber)
    var validationError = false
    if(e.target.dataset.vehiclenumber != undefined){
        vehicleNumber = e.target.dataset.vehiclenumber
        zone_name_services[serviceNumber] = {}
        zone_name_services[serviceNumber][vehicleNumber] = ["Default"]
        var vehicleZonesChildren = $("#zones_" + serviceNumber + "_" + vehicleNumber).children()
        for(var i = 1; i < zoneNumber; i++){
            console.log(vehicleZonesChildren[i-1].style)
            if(vehicleZonesChildren[i - 1].style.display == 'none'){
                continue
            }
            $("#zoneName_" + serviceNumber + "_" + vehicleNumber + "_" + i).attr("value", $("#zoneName_" + serviceNumber + "_" + vehicleNumber + "_" + i).val())
            $("#zoneRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).attr("value", $("#zoneRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val())
            $("#zoneGuardRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).attr("value", $("#zoneGuardRate_" + serviceNumber + "_" + vehicleNumber + "_" + i).val())                
            validationError = validateZones(serviceNumber, vehicleNumber, i, validationError, 'block')
            zone_name_services[serviceNumber][vehicleNumber].push($("#zoneName_" + serviceNumber + "_" + vehicleNumber + "_" + i).val())
        }
        if(!validationError){
            var html = $("#zones_" + serviceNumber + "_" + vehicleNumber)[0].innerHTML;
            html += '<div class="col-md-12 zone-div-no-top">' + 
                        '<div class="col-md-4 margin-top">' +
                            '<label class="site_labels" for="zoneName_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '">Zone Name</label>' + 
                            '<input class="form-control" id="zoneName_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '" name="zoneName_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '" value="">' + 
                        '</div>' + 
                        '<div class="col-md-4 margin-top">' + 
                            '<label class="site_labels" for="zoneRate_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '">Zone Rate</label>' + 
                            '<input class="form-control" id="zoneRate_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '" name="zoneRate_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top">' + 
                            '<label class="site_labels" for="zoneGuardRate_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '">Guard Rate</label>' + 
                            '<input class="form-control" id="zoneGuardRate_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '" name="zoneGuardRate_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-1 margin-top">' +
                            '<button id="zoneDelete_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '" class="fa fa-times deleteIcon" data-serviceNumber="' + serviceNumber + '" data-vehicleNumber="' + vehicleNumber + '" data-zoneNumber="' + zoneNumber + '">' + 
                            '</button>' + 
                        '</div>' +
                    '</div>'
            $("#zones_" + serviceNumber + "_" + vehicleNumber).html(html)
            $("#addZones_" + serviceNumber + "_" + vehicleNumber).attr("data-zoneNumber", zoneNumber + 1)
        }            
    }
    else{
        zone_names[serviceNumber] = ["Default"]
        var zoneChildren = $("#zones_" + serviceNumber).children()
        for(var i = 1; i < zoneNumber; i++){
            if(zoneChildren[i - 1].style.display == 'none'){
                continue
            }
            $("#zoneName_" + serviceNumber + "_" + i).attr("value", $("#zoneName_" + serviceNumber + "_" + i).val())
            $("#zoneRate_" + serviceNumber + "_" + i).attr("value", $("#zoneRate_" + serviceNumber + "_" + i).val())
            $("#zoneGuardRate_" + serviceNumber + "_" + i).attr("value", $("#zoneGuardRate_" + serviceNumber + "_" + i).val())                
            validationError = validateZones(serviceNumber, null, i, validationError, 'block')
            zone_names[serviceNumber].push($("#zoneName_" + serviceNumber + "_" + i).val())
        }            
        if(!validationError){
            var html = $("#zones_" + serviceNumber)[0].innerHTML;
            html += '<div class="col-md-12">' + 
                        '<div class="col-md-4 margin-top">' +
                            '<label class="site_labels" for="zoneName_' + serviceNumber + '_' + zoneNumber + '">Zone Name</label>' + 
                            '<input class="form-control" id="zoneName_' + serviceNumber + '_' + zoneNumber + '" name="zoneName_' + serviceNumber + '_' + zoneNumber + '" value="">' + 
                        '</div>' + 
                        '<div class="col-md-4 margin-top">' + 
                            '<label class="site_labels" for="zoneRate_' + serviceNumber + '_' + zoneNumber + '">Zone Rate</label>' + 
                            '<input class="form-control" id="zoneRate_' + serviceNumber + '_' + zoneNumber + '" name="zoneRate_' + serviceNumber + '_' + zoneNumber + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-3 margin-top">' + 
                            '<label class="site_labels" for="zoneGuardRate_' + serviceNumber + '_' + zoneNumber + '">Guard Rate</label>' + 
                            '<input class="form-control" id="zoneGuardRate_' + serviceNumber + '_' + zoneNumber + '" name="zoneGuardRate_' + serviceNumber + '_' + zoneNumber + '" type="number" value="">' + 
                        '</div>' + 
                        '<div class="col-md-1 margin-top">' +
                            '<button id="zoneDelete_' + serviceNumber  + '_' + zoneNumber + '" class="fa fa-times deleteIcon" data-serviceNumber="' + serviceNumber + '" data-zoneNumber="' + zoneNumber + '">' + 
                            '</button>' + 
                        '</div>' +
                    '</div>'
            $("#zones_" + serviceNumber).html(html)
            $("#addZones_" + serviceNumber).attr("data-zoneNumber", zoneNumber + 1)
        }            
    }
})

function validateVehicles(serviceNumber, i, j, overage, validationError){
    if(j == null){
        if($("#vehicleCapacity_" + serviceNumber + "_" + i).val() == '' || $("#vehicleCapacity_" + serviceNumber + "_" + i).val() == undefined || $("#vehicleCapacity_" + serviceNumber + "_" + i).val() == null || parseFloat($("#vehicleCapacity_" + serviceNumber + "_" + i).val()) < 0){
            document.getElementById("vehicleCapacity_" + serviceNumber + "_" + i).classList.add("border-danger")
            validationError = true
        }
        else{
            document.getElementById("vehicleCapacity_" + serviceNumber + "_" + i).classList.remove("border-danger")
            validationError = validationError || false
        }
        if($("#vehicleDefaultRateDiv_" + serviceNumber + "_" + i).css('display') == 'block'){
            if($("#vehicleDefaultRate_" + serviceNumber + "_" + i).val() == '' || $("#vehicleDefaultRate_" + serviceNumber + "_" + i).val() == undefined || $("#vehicleDefaultRate_" + serviceNumber + "_" + i).val() == null || parseFloat($("#vehicleDefaultRate_" + serviceNumber + "_" + i).val()) < 0){                
                document.getElementById("vehicleDefaultRate_" + serviceNumber + "_" + i).classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("vehicleDefaultRate_" + serviceNumber + "_" + i).classList.remove("border-danger")
                validationError = validationError || false
            }
        }
        if($("#vehicleGuardRateDiv_" + serviceNumber + "_" + i).css('display') == 'block'){
            if($("#vehicleGuardRate_" + serviceNumber + "_" + i).val() == '' || $("#vehicleGuardRate_" + serviceNumber + "_" + i).val() == undefined || $("#vehicleGuardRate_" + serviceNumber + "_" + i).val() == null || parseFloat($("#vehicleGuardRate_" + serviceNumber + "_" + i).val()) < 0){
                document.getElementById("vehicleGuardRate_" + serviceNumber + "_" + i).classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("vehicleGuardRate_" + serviceNumber + "_" + i).classList.remove("border-danger")
                validationError = validationError || false
            }
        }
        if($("#packageDurationDiv_" + serviceNumber + "_" + i).css('display') == 'block'){
            if($("#packageDuration_" + serviceNumber + "_" + i).val() == '' || $("#packageDuration_" + serviceNumber + "_" + i).val() == undefined || $("#packageDuration_" + serviceNumber + "_" + i).val() == null){
                document.getElementById("packageDuration_" + serviceNumber + "_" + i).classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("packageDuration_" + serviceNumber + "_" + i).classList.remove("border-danger")
                validationError = validationError || false
            }
        }        
        if($("#packageKmDiv_" + serviceNumber + "_" + i).css('display') == 'block'){
            if($("#packageKm_" + serviceNumber + "_" + i).val() == '' || $("#packageKm_" + serviceNumber + "_" + i).val() == undefined || $("#packageKm_" + serviceNumber + "_" + i).val() == null || parseFloat($("#packageKm_" + serviceNumber + "_" + i).val()) < 0){
                document.getElementById("packageKm_" + serviceNumber + "_" + i).classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("packageKm_" + serviceNumber + "_" + i).classList.remove("border-danger")
                validationError = validationError || false
            }
        }        
        if($("#packageRateDiv_" + serviceNumber + "_" + i).css('display') == 'block'){
            if($("#packageRate_" + serviceNumber + "_" + i).val() == '' || $("#packageRate_" + serviceNumber + "_" + i).val() == undefined || $("#packageRate_" + serviceNumber + "_" + i).val() == null || parseFloat($("#packageRate_" + serviceNumber + "_" + i).val()) < 0){
                document.getElementById("packageRate_" + serviceNumber + "_" + i).classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("packageRate_" + serviceNumber + "_" + i).classList.remove("border-danger")
                validationError = validationError || false
            }
        }
        if($("#packageOveragePerKmDiv_" + serviceNumber + "_" + i).css('display') == 'block'){
            if($("#packageOveragePerKm_" + serviceNumber + "_" + i).val() == '' || $("#packageOveragePerKm_" + serviceNumber + "_" + i).val() == undefined || $("#packageOveragePerKm_" + serviceNumber + "_" + i).val() == null || parseFloat($("#packageOveragePerKm_" + serviceNumber + "_" + i).val()) < 0){
                document.getElementById("packageOveragePerKm_" + serviceNumber + "_" + i).classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("packageOveragePerKm_" + serviceNumber + "_" + i).classList.remove("border-danger")
                validationError = validationError || false
            }
        }
        if($("#packageDutyHoursDiv_" + serviceNumber + "_" + i).css('display') == 'block'){
            if($("#packageDutyHours_" + serviceNumber + "_" + i).val() == '' || $("#packageDutyHours_" + serviceNumber + "_" + i).val() == undefined || $("#packageDutyHours_" + serviceNumber + "_" + i).val() == null || parseFloat($("#packageDutyHours_" + serviceNumber + "_" + i).val()) < 0){
                document.getElementById("packageDutyHours_" + serviceNumber + "_" + i).classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("packageDutyHours_" + serviceNumber + "_" + i).classList.remove("border-danger")
                validationError = validationError || false
            }
        }
        if($("#packageOveragePerTimeDiv_" + serviceNumber + "_" + i).css('display') == 'block'){
            if($("#packageOveragePerTime_" + serviceNumber + "_" + i).val() == '' || $("#packageOveragePerTime_" + serviceNumber + "_" + i).val() == undefined || $("#packageOveragePerTime_" + serviceNumber + "_" + i).val() == null || parseFloat($("#packageOveragePerTime_" + serviceNumber + "_" + i).val()) < 0){
                document.getElementById("packageOveragePerTime_" + serviceNumber + "_" + i).classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("packageOveragePerTime_" + serviceNumber + "_" + i).classList.remove("border-danger")
                validationError = validationError || false
            }
        }
        
        // if(overage){
        //     if($("#timeOnDuty_" + serviceNumber + "_" + i).val() == '' || $("#timeOnDuty_" + serviceNumber + "_" + i).val() == undefined || $("#timeOnDuty_" + serviceNumber + "_" + i).val() == null || parseFloat($("#timeOnDuty_" + serviceNumber + "_" + i).val()) < 0){
        //         document.getElementById("timeOnDuty_" + serviceNumber + "_" + i).classList.add("border-danger")
        //         validationError = true
        //     }
        //     else{
        //         document.getElementById("timeOnDuty_" + serviceNumber + "_" + i).classList.remove("border-danger")
        //         validationError = validationError || false
        //     }
        //     if($("#overageRate_" + serviceNumber + "_" + i).val() == '' || $("#overageRate_" + serviceNumber + "_" + i).val() == undefined || $("#overageRate_" + serviceNumber + "_" + i).val() == null || parseFloat($("#overageRate_" + serviceNumber + "_" + i).val()) < 0){                
        //         document.getElementById("overageRate_" + serviceNumber + "_" + i).classList.add("border-danger")
        //         validationError = true
        //     }
        //     else{
        //         document.getElementById("overageRate_" + serviceNumber + "_" + i).classList.remove("border-danger")
        //         validationError = validationError || false
        //     }
        // }
        return validationError
    }
    else{

    }

}

$(document).on('click', '.addVehicle', function(e){
    e.preventDefault()
    serviceNumber = parseInt(e.target.dataset.servicenumber)
    vehicleNumber = parseInt(e.target.dataset.vehiclenumber)
    zoneNumber = parseInt(e.target.dataset.zonenumber)
    var validationError = false    
    var zoneDisplay = 'none'
    var packageRatesDisplay = 'none'
    var defaultRateDisplay = 'none'

    // var tripDisplay = 'block'
    if($("#billingModel_" + serviceNumber).val() == 'Fixed Rate per Zone'){
        zoneDisplay = 'block'
        defaultRateDisplay = 'block'
    //     tripDisplay = 'none'
    }
    else if($("#billingModel_" + serviceNumber).val() == 'Fixed Rate per Trip'){
        packageRatesDisplay = 'none'
        defaultRateDisplay = 'block'
    }
    else if($("#billingModel_" + serviceNumber).val() == 'Package Rates'){
        packageRatesDisplay = 'block'
        defaultRateDisplay = 'none'
    }

    zone_name_services[serviceNumber] = {}
    var vehicleChildren = $("#vehicles_" + serviceNumber).children()
    for(var i = 1; i <= vehicleNumber - 1; i++){
        if(vehicleChildren[i - 1].style.display == 'none'){
            continue
        }
        zone_name_services[serviceNumber][i] = ["Default"]
        $("#vehicleCapacity_" + serviceNumber + "_" + i).attr("value", $("#vehicleCapacity_" + serviceNumber + "_" + i).val())
        $("#vehicleRatePerTrip_" + serviceNumber + "_" + i).attr("value", $("#vehicleRatePerTrip_" + serviceNumber + "_" + i).val())
        $("#vehicleDefaultRate_" + serviceNumber + "_" + i).attr("value", $("#vehicleDefaultRate_" + serviceNumber + "_" + i).val())
        $("#vehicleGuardRate_" + serviceNumber + "_" + i).attr("value", $("#vehicleGuardRate_" + serviceNumber + "_" + i).val())
        $("#vehicleAc_" + serviceNumber + "_" + i).attr("value", $("input[name='vehicleAc_" + serviceNumber + "_" + i + "']:checked").val())
        // $("#timeOnDuty_" + serviceNumber + "_" + i).attr("value", $("#timeOnDuty_" + serviceNumber + "_" + i).val())
        // $("#overageRate_" + serviceNumber + "_" + i).attr("value", $("#overageRate_" + serviceNumber + "_" + i).val())

        if($("input[name='vehicleAc_" + serviceNumber + "_" + i + "']:checked").val() == "true"){
            $("#vehicleAcYes_" + serviceNumber + "_" + i).attr("checked", "checked")
            $("#vehicleAcNo_" + serviceNumber + "_" + i).removeAttr("checked")
        }
        else{
            $("#vehicleAcNo_" + serviceNumber + "_" + i).attr("checked", "checked")   
            $("#vehicleAcYes_" + serviceNumber + "_" + i).removeAttr("checked")
        }

        var packageDuration = $("#packageDuration_" + serviceNumber + "_" + i).val() == "" ? "Choose Package Duration" : $("#packageDuration_" + serviceNumber + "_" + i).val()
        $("#packageDuration_" + serviceNumber + "_" + i + " option:contains(" + packageDuration + ")").attr('selected', 'selected');
        $("#packageKm_" + serviceNumber + "_" + i).attr("value", $("#packageKm_" + serviceNumber + "_" + i).val())
        $("#packageRate_" + serviceNumber + "_" + i).attr("value", $("#packageRate_" + serviceNumber + "_" + i).val())
        $("#packageOveragePerKm_" + serviceNumber + "_" + i).attr("value", $("#packageOveragePerKm_" + serviceNumber + "_" + i).val())
        $("#packageDutyHours_" + serviceNumber + "_" + i).attr("value", $("#packageDutyHours_" + serviceNumber + "_" + i).val())
        $("#packageOveragePerTime_" + serviceNumber + "_" + i).attr("value", $("#packageOveragePerTime_" + serviceNumber + "_" + i).val())
        if($("input[name='packageOverageTime_" + serviceNumber + "_" + i + "']:checked").val() == true){
            $("#packageOverageTimeYes_" + serviceNumber + "_" + i).attr("checked", "checked")
            $("#packageOverageTimeNo_" + serviceNumber + "_" + i).removeAttr("checked")
        }
        else{
            $("#packageOverageTimeNo_" + serviceNumber + "_" + i).attr("checked", "checked")
            $("#packageOverageTimeYes_" + serviceNumber + "_" + i).removeAttr("checked")                
        }            
        
        // if($("input[name='overage_" + serviceNumber + "_" + i + "']:checked").val() == "true"){
        //     $("#overageYes_" + serviceNumber + "_" + i).attr("checked", "checked")
        //     $("#overageNo_" + serviceNumber + "_" + i).removeAttr("checked")                
        // }
        // else{
        //     $("#overageNo_" + serviceNumber + "_" + i).attr("checked", "checked")   
        //     $("#overageYes_" + serviceNumber + "_" + i).removeAttr("checked")
        // }
        validationError = validateVehicles(serviceNumber, i, null, true, validationError)
        var vehicleZonesChildren = $("#zones_" + serviceNumber + "_" + i).children()
        for(var j = 1; j <= MAX_LIMIT; j++){
            if(zoneDisplay == 'block' && document.getElementById("zoneName_" + serviceNumber + "_" + i + "_" + j) != undefined){
                $("#zoneName_" + serviceNumber + "_" + i + "_" + j).attr("value", $("#zoneName_" + serviceNumber + "_" + i + "_" + j).val())
                $("#zoneRate_" + serviceNumber + "_" + i + "_" + j).attr("value", $("#zoneRate_" + serviceNumber + "_" + i + "_" + j).val())
                $("#zoneGuardRate_" + serviceNumber + "_" + i + "_" + j).attr("value", $("#zoneGuardRate_" + serviceNumber + "_" + i + "_" + j).val())
                if(vehicleZonesChildren[j - 1].style.display == 'none'){
                    continue
                }
                validationError = validateZones(serviceNumber, i, j, validationError, zoneDisplay)
                zone_name_services[serviceNumber][i].push($("#zoneName_" + serviceNumber + "_" + i + "_" + j).val())
            }
            else{
                break;
            }
        }
    }

    if(!validationError){
        var html = $("#vehicles_" + serviceNumber)[0].innerHTML;
        html += '<div class="col-md-12 vehicle-div-no-top">' + 
                    '<div class="col-md-3 margin-top">' + 
                        '<label class="site_labels" for="vehicleCapacity_' + serviceNumber + '_' + vehicleNumber + '">Vehicle Capacity</label>' + 
                        '<input class="form-control" id="vehicleCapacity_' + serviceNumber + '_' + vehicleNumber + '" name="vehicleCapacity_' + serviceNumber + '_' + vehicleNumber + '" type="number" value="">' + 
                    '</div>' + 
                    
                    '<div class="col-md-3 margin-top" id="packageDurationDiv_' + serviceNumber + '_' + vehicleNumber + '"  style="display:' + packageRatesDisplay + '">' + 
                        '<label class="site_labels" for="packageDuration_' + serviceNumber + '_' + vehicleNumber + '">Package Duration</label>' + 
                        '<select class="form-control billingModel" data-vehiclenumber="' + vehicleNumber + '" id="packageDuration_' + serviceNumber + '_' + vehicleNumber + '">' + 
                            '<option value="">Choose Package Duration</option>' + 
                            '<option value="Daily">Daily</option>' + 
                            '<option value="Weekly">Weekly</option>' + 
                            '<option value="Monthly">Monthly</option>' + 
                        '</select>' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="packageKmDiv_' + serviceNumber + '_' + vehicleNumber + '" style="display:' + packageRatesDisplay + '">' + 
                        '<label class="site_labels" for="packageKm_' + serviceNumber + '_' + vehicleNumber + '">Package KMs</label>' + 
                        '<input class="form-control" id="packageKm_' + serviceNumber + '_' + vehicleNumber + '" name="packageKm_' + serviceNumber + '_' + vehicleNumber + '" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="packageRateDiv_' + serviceNumber + '_' + vehicleNumber + '" style="display:' + packageRatesDisplay + '">' + 
                        '<label class="site_labels" for="packageRate_' + serviceNumber + '_' + vehicleNumber + '">Package Rate</label>' + 
                        '<input class="form-control" id="packageRate_' + serviceNumber + '_' + vehicleNumber + '" name="packageRate_' + serviceNumber + '_' + vehicleNumber + '" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="packageOveragePerKmDiv_' + serviceNumber + '_' + vehicleNumber + '" style="display:' + packageRatesDisplay + '">' + 
                        '<label class="site_labels" for="packageOveragePerKm_' + serviceNumber + '_' + vehicleNumber + '">Overage (per KM)</label>' + 
                        '<input class="form-control" id="packageOveragePerKm_' + serviceNumber + '_' + vehicleNumber + '" name="packageOveragePerKm_' + serviceNumber + '_' + vehicleNumber + '" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="packageMileageCalculationDiv_' + serviceNumber + '_' + vehicleNumber + '" style="display:' + packageRatesDisplay + '">' + 
                        '<label class="site_labels" for="packageMileageCalculation_' + serviceNumber + '_' + vehicleNumber + '">Overage for Duty Time</label>' + 
                        '<div class="row">' +                 
                            '<input checked="true" class="packageMileageCalculation" id="packageMileageCalculationOnDuty_' + serviceNumber + '_' + vehicleNumber + '" name="packageMileageCalculation_' + serviceNumber + '_' + vehicleNumber + '" style="margin-left:20px" type="radio" value="On Duty Hours">   On Duty Hours' + 
                            '<input class="packageMileageCalculation" id="packageMileageCalculationTripDuration_' + serviceNumber + '_' + vehicleNumber + '" name="packageMileageCalculation_' + serviceNumber + '_' + vehicleNumber + '" style="margin-left:5px" type="radio" value="Trip Duration">   Trip Duration' +                             
                        '</div>' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="packageOverageTimeDiv_' + serviceNumber + '_' + vehicleNumber + '" style="display:' + packageRatesDisplay + '">' + 
                        '<label class="site_labels" for="packageOverageTime_' + serviceNumber + '_' + vehicleNumber + '">Overage for Duty Time</label>' + 
                        '<div class="row">' + 
                            '<input checked="true" class="packageOverage" id="packageOverageNo_' + serviceNumber + '_' + vehicleNumber + '" name="packageOverageTime_' + serviceNumber + '_' + vehicleNumber + '" style="margin-left:20px" type="radio" value="false">   No' + 
                            '<input class="packageOverage" id="packageOverageTimeYes_' + serviceNumber + '_' + vehicleNumber + '" name="packageOverageTime_' + serviceNumber + '_' + vehicleNumber + '" style="margin-left:5px" type="radio" value="true">   Yes' +                             
                        '</div>' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="packageDutyHoursDiv_' + serviceNumber + '_' + vehicleNumber + '" style="display:none">' + 
                        '<label class="site_labels" for="packageDutyHours_' + serviceNumber + '_' + vehicleNumber + '">Package Duty Hours</label>' + 
                        '<input class="form-control" id="packageDutyHours_' + serviceNumber + '_' + vehicleNumber + '" name="packageDutyHours_' + serviceNumber + '_' + vehicleNumber + '" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="packageOveragePerTimeDiv_' + serviceNumber + '_' + vehicleNumber + '" style="display:none">' + 
                        '<label class="site_labels" for="packageOveragePerTime_' + serviceNumber + '_' + vehicleNumber + '">Overage (per hour)</label>' + 
                        '<input class="form-control" id="packageOveragePerTime_' + serviceNumber + '_' + vehicleNumber + '" name="packageOveragePerTime_' + serviceNumber + '_' + vehicleNumber + '" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="vehicleDefaultRateDiv_' + serviceNumber + '_' + vehicleNumber + '" style="display:' + defaultRateDisplay + '">' + 
                        '<label class="site_labels" for="vehicleDefaultRate_' + serviceNumber + '_' + vehicleNumber + '">Default Rate</label>' + 
                        '<input class="form-control" id="vehicleDefaultRate_' + serviceNumber + '_' + vehicleNumber + '" name="vehicleDefaultRate_' + serviceNumber + '_' + vehicleNumber + '" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="vehicleGuardRateDiv_' + serviceNumber + '_' + vehicleNumber + '" style="display:' + defaultRateDisplay + '">' + 
                        '<label class="site_labels" for="vehicleGuardRate_' + serviceNumber + '_' + vehicleNumber + '">Default Guard Rate</label>' + 
                        '<input class="form-control" id="vehicleGuardRate_' + serviceNumber + '_' + vehicleNumber + '" name="vehicleGuardRate_' + serviceNumber + '_' + vehicleNumber + '" type="number" value="">' + 
                    '</div>' + 
                    


                    '<div class="col-md-2 margin-top">' + 
                        '<label class="site_labels" for="vehicleAc_' + serviceNumber + '_' + vehicleNumber + '" style="margin-right:20px">AC/Non-AC</label>' + 
                        '<div class="row">' + 
                            '<input checked="true" id="vehicleAcYes_' + serviceNumber + '_' + vehicleNumber + '" name="vehicleAc_' + serviceNumber + '_' + vehicleNumber + '" type="radio" value="true">   AC' + 
                            '<input id="vehicleAcNo_' + serviceNumber + '_' + vehicleNumber + '" name="vehicleAc_' + serviceNumber + '_' + vehicleNumber + '" style="margin-left:20px" type="radio" value="false">   Non-AC' + 
                        '</div>' + 
                    '</div>' + 
                    '<div class="col-md-1 margin-top">' +
                        '<button id="vehicleDelete_' + serviceNumber + '_' + vehicleNumber + '" class="fa fa-times deleteIcon" data-serviceNumber="' + serviceNumber + '" data-vehicleNumber="' + vehicleNumber + '">' + 
                        '</button>' + 
                    '</div>' +
                    // '<div class="col-md-12 margin-top" id="overageDiv_' + serviceNumber + '_' + vehicleNumber + '">' + 
                    //     '<label class="site_labels" for="overage_' + serviceNumber + '_' + vehicleNumber + '">Overage</label>' + 
                    //     '<div class="row" style="margin-left:5px">' + 
                    //         '<input class="overage" id="overageYes_' + serviceNumber + '_' + vehicleNumber + '" name="overage_' + serviceNumber + '_' + vehicleNumber + '" type="radio" value="true">   Yes' + 
                    //         '<input checked="true" class="overage" id="overageNo_' + serviceNumber + '_' + vehicleNumber + '" name="overage_' + serviceNumber + '_' + vehicleNumber + '" style="margin-left:20px" type="radio" value="false">   No' + 
                    //     '</div>' + 
                    // '</div>' + 
                    // '<div class="col-md-4 margin-top" id="timeOnDutyDiv_' + serviceNumber + '_' + vehicleNumber + '" style="display: none;">' + 
                    //     '<label class="site_labels" for="timeOnDuty_' + serviceNumber + '_' + vehicleNumber + '">Time on Duty per Day</label>' + 
                    //     '<input class="form-control" id="timeOnDuty_' + serviceNumber + '_' + vehicleNumber + '" name="timeOnDuty_' + serviceNumber + '_' + vehicleNumber + '" type="number" value="">' + 
                    // '</div>' +
                    // '<div class="col-md-4 margin-top" id="overageRateDiv_' + serviceNumber + '_' + vehicleNumber + '" style="display: none;">' + 
                    //     '<label class="site_labels" for="overageRate_' + serviceNumber + '_' + vehicleNumber + '">Overage Rate</label>' + 
                    //     '<input class="form-control" id="overageRate_' + serviceNumber + '_' + vehicleNumber + '" name="overageRate_' + serviceNumber + '_' + vehicleNumber + '" type="number" value="">' + 
                    // '</div>' + 
                    '<div id="zones_' + serviceNumber + '_' + vehicleNumber + '" style="display: ' + zoneDisplay + '">' + 
                        '<div class="col-md-12 zone-div">' + 
                            '<div class="col-md-4 margin-top">' + 
                                '<label class="site_labels" for="zoneName_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '">Zone Name</label>' + 
                                '<input class="form-control" id="zoneName_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '" name="zoneName_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '" value="">' + 
                            '</div>' + 
                            '<div class="col-md-4 margin-top">' + 
                                '<label class="site_labels" for="zoneRate_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '">Zone Rate</label>' + 
                                '<input class="form-control" id="zoneRate_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '" name="zoneRate_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '" type="number" value="">' + 
                            '</div>' + 
                            '<div class="col-md-3 margin-top">' + 
                                '<label class="site_labels" for="zoneGuardRate_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '">Guard Rate</label>' + 
                                '<input class="form-control" id="zoneGuardRate_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '" name="zoneGuardRate_' + serviceNumber + '_' + vehicleNumber + '_' + zoneNumber + '" type="number" value="">' + 
                            '</div>' + 
                            '<div class="col-md-1 margin-top">' +
                                '<button id="zoneDelete_' + serviceNumber  + '_' + vehicleNumber + '_' + zoneNumber + '" class="fa fa-times deleteIcon" data-serviceNumber="' + serviceNumber + '" data-vehicleNumber="' + vehicleNumber + '" data-zoneNumber="' + zoneNumber + '">' + 
                                '</button>' + 
                            '</div>' +
                        '</div>' + 
                    '</div>' + 
                    '<div class="col-md-12" id="addZonesDiv_' + serviceNumber + '_' + vehicleNumber + '" style="display: ' + zoneDisplay + '">' + 
                        '<button id="addZones_' + serviceNumber + "_" + vehicleNumber + '" class="margin-top margin-right2x btn btn-primary pull-right addZone" data-servicenumber="' + serviceNumber + '" data-vehiclenumber="' + vehicleNumber + '" data-zoneNumber="' + (zoneNumber + 1) + '">Add Zone Rate</button>' + 
                    '</div>' + 
                '</div>'
        $("#vehicles_" + serviceNumber).html(html)
        $(".addVehicle").attr("data-vehicleNumber", vehicleNumber + 1)
        $("#billingModel_" + serviceNumber).attr("data-vehicleNumber", vehicleNumber)
        $("#varyWithVehicleYes_" + serviceNumber).attr("data-vehicleNumber", vehicleNumber)
        $("#varyWithVehicleNo_" + serviceNumber).attr("data-vehicleNumber", vehicleNumber)
    }        
})

$(document).on('click', '.addService', function(e){
    e.preventDefault()    
    serviceTypes = []
    serviceNumber = parseInt(e.target.dataset.servicenumber)
    vehicleNumber = parseInt(e.target.dataset.vehiclenumber)
    zoneNumber = parseInt(e.target.dataset.zonenumber)
    var validationError = false
    var varyWithVehicle = false

    var html = $("#services")[0].innerHTML;
        
    
    for(var s = 1; s <= serviceNumber - 1; s++){
        if($("#service_" + s).css('display') == 'none'){
            continue
        }

        var serviceType = $("#serviceType_" + s).val() == "" ? "Choose Service Type" : $("#serviceType_" + s).val()
        var billingModel = $("#billingModel_" + s).val() == "" ? "Choose Billing Model" : $("#billingModel_" + s).val()

        var vehicleNumber = $("#addVehiclesDiv_" + s).children()[0].dataset.vehiclenumber - 1
        $("#serviceType_" + s + " option:contains(" + serviceType + ")").attr('selected', 'selected');            
        $("#billingModel_" + s + " option:contains(" + billingModel + ")").attr('selected', 'selected');
        if($("input[name='varyWithVehicle_" + s + "']:checked").val() == "true"){
            varyWithVehicle = true
            $("#varyWithVehicleYes_" + s).attr("checked", "checked")
            $("#varyWithVehicleNo_" + s).removeAttr("checked")
        }
        else{
            varyWithVehicle = false
            $("#varyWithVehicleNo_" + s).attr("checked", "checked")
            $("#varyWithVehicleYes_" + s).removeAttr("checked")                
        }
        $("#defaultRate_" + s).attr("value", $("#defaultRate_" + s).val())
        $("#guardRate_" + s).attr("value", $("#guardRate_" + s).val())

        var zoneDisplay = 'none'
        if($("#billingModel_" + s).val() == 'Fixed Rate per Zone'){
            zoneDisplay = 'block'
        }
        if($("#billingModel_" + s).val() == 'Package Rates' && varyWithVehicle == false){
            var packageDuration = $("#packageDuration_" + s).val() == "" ? "Choose Package Duration" : $("#packageDuration_" + s).val()
            $("#packageDuration_" + s + " option:contains(" + packageDuration + ")").attr('selected', 'selected');
            $("#packageKm_" + s).attr("value", $("#packageKm_" + s).val())
            $("#packageRate_" + s).attr("value", $("#packageRate_" + s).val())
            $("#packageOveragePerKm_" + s).attr("value", $("#packageOveragePerKm_" + s).val())
            $("#packageDutyHours_" + s).attr("value", $("#packageDutyHours_" + s).val())
            $("#packageOveragePerTime_" + s).attr("value", $("#packageOveragePerTime_" + s).val())            
            if($("input[name='packageOverageTime_" + s + "']:checked").val() == true){
                $("#packageOverageTimeYes_" + s).attr("checked", "checked")
                $("#packageOverageTimeNo_" + s).removeAttr("checked")
            }
            else{
                $("#packageOverageTimeNo_" + s).attr("checked", "checked")
                $("#packageOverageTimeYes_" + s).removeAttr("checked")                
            }            
        }

        var zoneNumber = $("#addZonesDiv_" + s).children()[0].dataset.zonenumber - 1
        zone_names[s] = ["Default"]
        var zoneChildren = $("#zones_" + s).children()
        for(var i = 1; i <= zoneNumber; i++){
            console.log(zoneChildren[i - 1].style)
            if(zoneChildren[i - 1].style.display != 'block'){
                continue
            }
            $("#zoneName_" + s + "_" + i).attr("value", $("#zoneName_" + s + "_" + i).val())
            $("#zoneRate_" + s + "_" + i).attr("value", $("#zoneRate_" + s + "_" + i).val())
            $("#zoneGuardRate_" + s + "_" + i).attr("value", $("#zoneGuardRate_" + s + "_" + i).val())
            validationError = validateZones(s, null, i, validationError, zoneDisplay)
            zone_names[s].push($("#zoneName_" + s + "_" + i).val())
        }

        validationError = validateServices(getServiceData(), validationError)
        zone_name_services[s] = {}
        if(varyWithVehicle){
            for(var i = 1; i <= vehicleNumber; i++){                    
                zone_name_services[s][i] = ["Default"]
                $("#vehicleCapacity_" + s + "_" + i).attr("value", $("#vehicleCapacity_" + s + "_" + i).val())
                $("#vehicleRatePerTrip_" + s + "_" + i).attr("value", $("#vehicleRatePerTrip_" + s + "_" + i).val())
                $("#vehicleDefaultRate_" + s + "_" + i).attr("value", $("#vehicleDefaultRate_" + s + "_" + i).val())
                $("#vehicleGuardRate_" + s + "_" + i).attr("value", $("#vehicleGuardRate_" + s + "_" + i).val())
                $("#vehicleAc_" + s + "_" + i).attr("value", $("input[name='vehicleAc_" + s + "_" + i + "']:checked").val())
                // $("#timeOnDuty_" + s + "_" + i).attr("value", $("#timeOnDuty_" + s + "_" + i).val())
                // $("#overageRate_" + s + "_" + i).attr("value", $("#overageRate_" + s + "_" + i).val())

                if($("input[name='vehicleAc_" + s + "_" + i + "']:checked").val() == "true"){
                    $("#vehicleAcYes_" + s + "_" + i).attr("checked", "checked")
                    $("#vehicleAcNo_" + s + "_" + i).removeAttr("checked")
                }
                else{
                    $("#vehicleAcNo_" + s + "_" + i).attr("checked", "checked")   
                    $("#vehicleAcYes_" + s + "_" + i).removeAttr("checked")
                }

                if($("#billingModel_" + s).val() == 'Package Rates'){
                    var packageDuration = $("#packageDuration_" + s + "_" + i).val() == "" ? "Choose Package Duration" : $("#packageDuration_" + s + "_" + i).val()
                    $("#packageDuration_" + s + "_" + i + " option:contains(" + packageDuration + ")").attr('selected', 'selected');
                    $("#packageKm_" + s + "_" + i).attr("value", $("#packageKm_" + s + "_" + i).val())
                    $("#packageRate_" + s + "_" + i).attr("value", $("#packageRate_" + s + "_" + i).val())
                    $("#packageOveragePerKm_" + s + "_" + i).attr("value", $("#packageOveragePerKm_" + s + "_" + i).val())
                    $("#packageDutyHours_" + s + "_" + i).attr("value", $("#packageDutyHours_" + s + "_" + i).val())
                    $("#packageOveragePerTime_" + s + "_" + i).attr("value", $("#packageOveragePerTime_" + s + "_" + i).val())
                    if($("input[name='packageOverageTime_" + s + "_" + i + "']:checked").val() == "true"){
                        $("#packageOverageTimeYes_" + s + "_" + i).attr("checked", "checked")
                        $("#packageOverageTimeNo_" + s + "_" + i).removeAttr("checked")
                    }
                    else{
                        $("#packageOverageTimeNo_" + s + "_" + i).attr("checked", "checked")
                        $("#packageOverageTimeYes_" + s + "_" + i).removeAttr("checked")
                    }            
                }

                // if($("input[name='overage_" + s + "_" + i + "']:checked").val() == "true"){
                //     $("#overageYes_" + s + "_" + i).attr("checked", "checked")
                //     $("#overageNo_" + s + "_" + i).removeAttr("checked")                
                // }
                // else{
                //     $("#overageNo_" + s + "_" + i).attr("checked", "checked")   
                //     $("#overageYes_" + s + "_" + i).removeAttr("checked")
                // }


                validationError = validateVehicles(s, i, null, true, validationError)
                var vehicleZonesChildren = $("#zones_" + s + "_" + i).children()
                for(var j = 1; j <= MAX_LIMIT; j++){                
                    if(zoneDisplay == 'block' && document.getElementById("zoneName_" + s + "_" + i + "_" + j) != undefined){
                        $("#zoneName_" + s + "_" + i + "_" + j).attr("value", $("#zoneName_" + s + "_" + i + "_" + j).val())
                        $("#zoneRate_" + s + "_" + i + "_" + j).attr("value", $("#zoneRate_" + s + "_" + i + "_" + j).val())
                        $("#zoneGuardRate_" + s + "_" + i + "_" + j).attr("value", $("#zoneGuardRate_" + s + "_" + i + "_" + j).val())
                        if(vehicleZonesChildren[j - 1].style.display == 'none'){
                            continue
                        }
                        validationError = validateZones(s, i, j, validationError, zoneDisplay)
                        zone_name_services[s][i].push($("#zoneName_" + s + "_" + i + "_" + j).val())
                    }
                    else{
                        break;
                    }
                }
            }
        }
    }

    if(!validationError){
        var html = $("#services")[0].innerHTML;
        html += 
        '<div class="row vehicle-div" id="service_' + serviceNumber + '">' + 
            '<div class="col-md-4 margin-top">' + 
                '<label class="site_labels" for="serviceType">Service Type</label>' + 
                '<select class="form-control serviceType" id="serviceType_' + serviceNumber + '">' + 
                    '<option value="" selected="selected">Choose Service Type</option>' + 
                    '<option value="Door To Door">Door To Door</option>' + 
                    '<option value="Nodal">Nodal</option>' + 
                '</select>' + 
            '</div>' + 
            '<div class="col-md-4 margin-top">' + 
                '<label class="site_labels" for="billingModel">Billing Model</label>' + 
                '<select class="form-control billingModel" data-vehiclenumber="1" id="billingModel_' + serviceNumber + '">' + 
                    '<option value="" selected="selected">Choose Billing Model</option>' + 
                    '<option value="Fixed Rate per Trip">Fixed Rate per Trip</option>' + 
                    '<option value="Fixed Rate per Zone">Fixed Rate per Zone</option>' + 
                    '<option value="Package Rates">Package Rates</option>' + 
                '</select>' +
            '</div>' + 
            '<div class="col-md-4 pull-right margin-top">' + 
                '<button class="fa fa-times deleteIcon" data-servicenumber="' + serviceNumber + '" id="serviceDelete_' + serviceNumber + '"></button>' + 
            '</div>' + 
            '<div class="col-md-4 margin-top" style="clear:both">' + 
                '<label class="site_labels" for="varyWithVehicle_' + serviceNumber + '">Vary With Vehicle</label>' + 
                '<div class="row" style="margin-left:5px">' + 
                    '<input class="varyWithVehicle" data-vehiclenumber="1" id="varyWithVehicleYes_' + serviceNumber + '" name="varyWithVehicle_' + serviceNumber + '" type="radio" value="true">   Yes' + 
                    '<input checked="checked" class="varyWithVehicle" data-vehiclenumber="1" id="varyWithVehicleNo_' + serviceNumber + '" name="varyWithVehicle_' + serviceNumber + '" style="margin-left:20px" type="radio" value="false">   No' +
                '</div>' + 
            '</div>' + 
            '<div class="col-md-4 margin-top" id="defaultRateDiv_' + serviceNumber + '" style="display: block;">' + 
                '<label class="site_labels" for="defaultRate_' + serviceNumber + '">Default Rate</label>' + 
                '<input class="form-control" id="defaultRate_' + serviceNumber + '" name="defaultRate_' + serviceNumber + '" type="number" value="">' + 
            '</div>' + 
            '<div class="col-md-4 margin-top" id="guardRateDiv_' + serviceNumber + '" style="display: block;">' + 
                '<label class="site_labels" for="guardRate_' + serviceNumber + '">Default Guard Rate</label>' + 
                '<input class="form-control" id="guardRate_' + serviceNumber + '" name="guardRate_' + serviceNumber + '" type="number" value="">' + 
            '</div>' + 
            '<div class="col-md-4 col-md-offset-4 hidden margin-top" id="overageDiv_' + serviceNumber + '">' + 
                '<label class="site_labels" for="overage">Overage</label>' + 
                '<div class="row" style="margin-left:5px">' + 
                    '<input class="overage" id="overageYes_' + serviceNumber + '" name="overage_' + serviceNumber + '" type="radio" value="true">   Yes' + 
                    '<input checked="true" class="overage" id="overageNo_' + serviceNumber + '" name="overage_' + serviceNumber + '" style="margin-left:20px" type="radio" value="false">   No' + 
                '</div>' + 
            '</div>' + 
            '<div class="col-md-4 col-md-offset-4 hidden margin-top" id="timeOnDutyDiv_' + serviceNumber + '" style="display:none">' + 
                '<label class="site_labels" for="timeOnDuty_' + serviceNumber + '">Time on Duty per Day</label>' + 
                '<input class="form-control" id="timeOnDuty_' + serviceNumber + '" name="timeOnDuty_' + serviceNumber + '" type="number" value="">' + 
            '</div>' + 
            '<div class="col-md-4 hidden margin-top" id="overageRateDiv_' + serviceNumber + '" style="display:none">' + 
                '<label class="site_labels" for="overageRate_' + serviceNumber + '">Overage Rate</label>' + 
                '<input class="form-control" id="overageRate_' + serviceNumber + '" name="overageRate_' + serviceNumber + '" type="number" value="">' + 
            '</div>' + 
            '<div id="zones_' + serviceNumber + '" style="display:none">' + 
                '<div class="col-md-12">' + 
                    '<div class="col-md-4 margin-top">' + 
                        '<label class="site_labels" for="zoneName_' + serviceNumber + '_1">Zone Name</label>' + 
                        '<input class="form-control" id="zoneName_' + serviceNumber + '_1" name="zoneName_' + serviceNumber + '_1" value="">' + 
                    '</div>' + 
                    '<div class="col-md-4 margin-top">' + 
                        '<label class="site_labels" for="zoneRate_' + serviceNumber + '_1">Zone Rate</label>' + 
                        '<input class="form-control" id="zoneRate_' + serviceNumber + '_1" name="zoneRate_' + serviceNumber + '_1" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top">' + 
                        '<label class="site_labels" for="zoneGuardRate_' + serviceNumber + '_1">Guard Rate</label>' + 
                        '<input class="form-control" id="zoneGuardRate_' + serviceNumber + '_1" name="zoneGuardRate_' + serviceNumber + '_1" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-1 margin-top">' + 
                        '<button class="fa fa-times deleteIcon" data-servicenumber="' + serviceNumber + '" data-zonenumber="1" id="zoneDelete_' + serviceNumber + '_1"></button>' + 
                    '</div>' + 
                '</div>' + 
            '</div>' + 
            '<div class="col-md-12" id="addZonesDiv_' + serviceNumber + '" style="display:none">' + 
                '<button class="margin-top margin-right btn btn-primary pull-right addZone" data-servicenumber="' + serviceNumber + '" data-zonenumber="2" id="addZones_' + serviceNumber + '">Add Zone Rate</button>' + 
            '</div>' + 
            '<div id="package_' + serviceNumber + '" style="display: none;">' + 
                '<div class="col-md-12" style="padding:0px">' + 
                    '<div class="col-md-3 margin-top">' + 
                        '<label class="site_labels" for="packageDuration_' + serviceNumber + '">Package Duration</label>' + 
                        '<select class="form-control billingModel" data-vehiclenumber="1" id="packageDuration_' + serviceNumber + '">' + 
                            '<option value="">Choose Package Duration</option>' + 
                            '<option value="Daily">Daily</option>' + 
                            '<option value="Weekly">Weekly</option>' + 
                            '<option value="Monthly">Monthly</option>' + 
                        '</select>' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top">' + 
                        '<label class="site_labels" for="packageKm_' + serviceNumber + '">Package KMs</label>' +
                        '<input class="form-control" id="packageKm_' + serviceNumber + '" name="packageKm_' + serviceNumber + '" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top">' + 
                        '<label class="site_labels" for="packageRate_' + serviceNumber + '">Package Rate</label>' + 
                        '<input class="form-control" id="packageRate_' + serviceNumber + '" name="packageRate_' + serviceNumber + '" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top">' + 
                        '<label class="site_labels" for="packageOveragePerKm_' + serviceNumber + '">Overage (per KM)</label>' + 
                        '<input class="form-control" id="packageOveragePerKm_' + serviceNumber + '" name="packageOveragePerKm_' + serviceNumber + '" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top">' + 
                        '<label class="site_labels" for="packageMileageCalculation_' + serviceNumber + '">Mileage Calculation</label>' + 
                        '<div class="row">' + 
                            '<input checked="true" class="packageMileageCalculation" id="packageMileageCalculationOnDuty_' + serviceNumber + '" name="packageMileageCalculation_' + serviceNumber + '" style="margin-left:20px" type="radio" value="On Duty Hours">   On Duty Hours' + 
                            '<input class="packageMileageCalculation" id="packageMileageCalculationTripDuration_' + serviceNumber + '" name="packageMileageCalculation_' + serviceNumber + '" style="margin-left:5px" type="radio" value="Trip Duration">   Trip Duration' + 
                        '</div>' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top">' + 
                        '<label class="site_labels" for="packageOverageTime_' + serviceNumber + '">Overage for Duty Time</label>' + 
                        '<div class="row">' + 
                            '<input checked="true" class="packageOverage" id="packageOverageNo_' + serviceNumber + '" name="packageOverageTime_' + serviceNumber + '" style="margin-left:20px" type="radio" value="false">   No' + 
                            '<input class="packageOverage" id="packageOverageTimeYes_' + serviceNumber + '" name="packageOverageTime_' + serviceNumber + '" style="margin-left:5px" type="radio" value="true">   Yes' +                             
                        '</div>' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="packageDutyHoursDiv_' + serviceNumber + '" style="display:none">' + 
                        '<label class="site_labels" for="packageDutyHours_' + serviceNumber + '">Package Duty Hours</label>' + 
                        '<input class="form-control" id="packageDutyHours_' + serviceNumber + '" name="packageDutyHours_' + serviceNumber + '" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="packageOveragePerTimeDiv_' + serviceNumber + '" style="display:none">' + 
                        '<label class="site_labels" for="packageOveragePerTime_' + serviceNumber + '">Overage (per hour)</label>' + 
                        '<input class="form-control" id="packageOveragePerTime_' + serviceNumber + '" name="packageOveragePerTime_' + serviceNumber + '" type="number" value="">' + 
                    '</div>' + 
                '</div>' + 
            '</div>' + 
            '<div class="vehicles" id="vehicles_' + serviceNumber + '" style="display:none">' + 
                '<div class="col-md-12 vehicle-div">' + 
                    '<div class="col-md-3 margin-top">' + 
                        '<label class="site_labels" for="vehicleCapacity_' + serviceNumber + '_1">Vehicle Capacity</label>' + 
                        '<input class="form-control" id="vehicleCapacity_' + serviceNumber + '_1" name="vehicleCapacity_' + serviceNumber + '_1" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="packageDurationDiv_' + serviceNumber + '_1" style="display:none">' + 
                        '<label class="site_labels" for="packageDuration_' + serviceNumber + '_1">Package Duration</label>' + 
                        '<select class="form-control billingModel" data-vehiclenumber="1" id="packageDuration_' + serviceNumber + '_1">' + 
                            '<option value="">Choose Package Duration</option>' + 
                            '<option value="Daily">Daily</option>' + 
                            '<option value="Weekly">Weekly</option>' + 
                            '<option value="Monthly">Monthly</option>' + 
                        '</select>' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="packageKmDiv_' + serviceNumber + '_1" style="display:none">' + 
                        '<label class="site_labels" for="packageKm_' + serviceNumber + '_1">Package KMs</label>' + 
                        '<input class="form-control" id="packageKm_' + serviceNumber + '_1" name="packageKm_' + serviceNumber + '_1" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="packageRateDiv_' + serviceNumber + '_1" style="display:none">' + 
                        '<label class="site_labels" for="packageRate_' + serviceNumber + '_1">Package Rate</label>' + 
                        '<input class="form-control" id="packageRate_' + serviceNumber + '_1" name="packageRate_' + serviceNumber + '_1" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="packageOveragePerKmDiv_' + serviceNumber + '_1" style="display:none">' + 
                        '<label class="site_labels" for="packageOveragePerKm_' + serviceNumber + '_1">Overage (per KM)</label>' + 
                        '<input class="form-control" id="packageOveragePerKm_' + serviceNumber + '_1" name="packageOveragePerKm_' + serviceNumber + '_1" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="packageOverageTimeDiv_' + serviceNumber + '_1" style="display:none">' + 
                        '<label class="site_labels" for="packageOverageTime_' + serviceNumber + '_1">Overage for Duty Time</label>' + 
                        '<div class="row">' + 
                            '<input checked="true" class="packageOverage" id="packageOverageNo_' + serviceNumber + '_1" name="packageOverageTime_' + serviceNumber + '_1" style="margin-left:20px" type="radio" value="false">   No' + 
                            '<input class="packageOverage" id="packageOverageTimeYes_' + serviceNumber + '_1" name="packageOverageTime_' + serviceNumber + '_1" style="margin-left:5px" type="radio" value="true">   Yes' +                             
                        '</div>' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="packageDutyHoursDiv_' + serviceNumber + '_1" style="display:none">' + 
                        '<label class="site_labels" for="packageDutyHours_' + serviceNumber + '_1">Package Duty Hours</label>' + 
                        '<input class="form-control" id="packageDutyHours_' + serviceNumber + '_1" name="packageDutyHours_' + serviceNumber + '_1" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="packageOveragePerTimeDiv_' + serviceNumber + '_1" style="display:none">' + 
                        '<label class="site_labels" for="packageOveragePerTime_' + serviceNumber + '_1">Overage (per hour)</label>' + 
                        '<input class="form-control" id="packageOveragePerTime_' + serviceNumber + '_1" name="packageOveragePerTime_' + serviceNumber + '_1" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="vehicleDefaultRateDiv_' + serviceNumber + '_1">' + 
                        '<label class="site_labels" for="vehicleDefaultRate_' + serviceNumber + '_1">Default Rate</label>' + 
                        '<input class="form-control" id="vehicleDefaultRate_' + serviceNumber + '_1" name="vehicleDefaultRate_' + serviceNumber + '_1" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-3 margin-top" id="vehicleGuardRateDiv_' + serviceNumber + '_1">' + 
                        '<label class="site_labels" for="vehicleGuardRate_' + serviceNumber + '_1">Default Guard Rate</label>' + 
                        '<input class="form-control" id="vehicleGuardRate_' + serviceNumber + '_1" name="vehicleGuardRate_' + serviceNumber + '_1" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-2 margin-top">' + 
                        '<label class="site_labels" for="vehicleAc_' + serviceNumber + '_1" style="margin-right:20px">AC/Non-AC</label>' + 
                        '<div class="row">' + 
                            '<input checked="true" id="vehicleAcYes_' + serviceNumber + '_1" name="vehicleAc_' + serviceNumber + '_1" type="radio" value="true">   AC' + 
                            '<input id="vehicleAcNo_' + serviceNumber + '_1" name="vehicleAc_' + serviceNumber + '_1" style="margin-left:20px" type="radio" value="false">   Non-AC' + 
                        '</div>' + 
                    '</div>' + 
                    '<div class="col-md-1 margin-top">' + 
                        '<button class="fa fa-times deleteIcon" data-servicenumber="' + serviceNumber + '" data-vehiclenumber="1" id="vehicleDelete_' + serviceNumber + '_1"></button>' + 
                    '</div>' + 
                    '<div class="col-md-12 margin-top hidden" id="overageDiv_' + serviceNumber + '_1">' + 
                        '<label class="site_labels" for="overage_' + serviceNumber + '_1">Overage</label>' + 
                        '<div class="row" style="margin-left:5px">' + 
                            '<input class="overage" id="overageYes_' + serviceNumber + '_1" name="overage_' + serviceNumber + '_1" type="radio" value="true">   Yes' + 
                            '<input checked="true" class="overage" id="overageNo_' + serviceNumber + '_1" name="overage_' + serviceNumber + '_1" style="margin-left:20px" type="radio" value="false">   No' + 
                        '</div>' + 
                    '</div>' + 
                    '<div class="col-md-4 margin-top hidden" id="timeOnDutyDiv_' + serviceNumber + '_1" style="display:none">' + 
                        '<label class="site_labels" for="timeOnDuty_' + serviceNumber + '_1">Time on Duty per Day</label>' + 
                        '<input class="form-control" id="timeOnDuty_' + serviceNumber + '_1" name="timeOnDuty_' + serviceNumber + '_1" type="number" value="">' + 
                    '</div>' + 
                    '<div class="col-md-4 margin-top hidden" id="overageRateDiv_' + serviceNumber + '_1" style="display:none">' + 
                        '<label class="site_labels" for="overageRate_' + serviceNumber + '_1">Overage Rate</label>' + 
                        '<input class="form-control" id="overageRate_' + serviceNumber + '_1" name="overageRate_' + serviceNumber + '_1" type="number" value="">' + 
                    '</div>' + 
                    '<div id="zones_' + serviceNumber + '_1" style="display:none">' + 
                        '<div class="col-md-12 zone-div">' + 
                            '<div class="col-md-4 margin-top">' + 
                                '<label class="site_labels" for="zoneName_' + serviceNumber + '_1_1">Zone Name</label>' + 
                                '<input class="form-control" id="zoneName_' + serviceNumber + '_1_1" name="zoneName_' + serviceNumber + '_1_1" value="">' + 
                            '</div>' + 
                            '<div class="col-md-4 margin-top">' + 
                                '<label class="site_labels" for="zoneRate_' + serviceNumber + '_1_1">Zone Rate</label>' + 
                                '<input class="form-control" id="zoneRate_' + serviceNumber + '_1_1" name="zoneRate_' + serviceNumber + '_1_1" type="number" value="">' + 
                            '</div>' + 
                            '<div class="col-md-3 margin-top">' + 
                                '<label class="site_labels" for="zoneGuardRate_' + serviceNumber + '_1_1">Guard Rate</label>' + 
                                '<input class="form-control" id="zoneGuardRate_' + serviceNumber + '_1_1" name="zoneGuardRate_' + serviceNumber + '_1_1" type="number" value="">' + 
                            '</div>' + 
                            '<div class="col-md-1 margin-top">' + 
                                '<button class="fa fa-times deleteIcon" data-servicenumber="' + serviceNumber + '" data-vehiclenumber="1" data-zonenumber="1" id="zoneDelete_' + serviceNumber + '_1_1"></button>' + 
                            '</div>' + 
                        '</div>' + 
                    '</div>' + 
                    '<div class="col-md-12" id="addZonesDiv_' + serviceNumber + '_1" style="display:none">' + 
                        '<button class="margin-top margin-right2x btn btn-primary pull-right addZone" data-servicenumber="' + serviceNumber + '" data-vehiclenumber="1" data-zonenumber="2" id="addZones_' + serviceNumber + '_1">Add Zone Rate</button>' + 
                    '</div>' + 
                '</div>' + 
            '</div>' + 
            '<div class="col-md-12" id="addVehiclesDiv_' + serviceNumber + '" style="display:none">' + 
                '<button class="margin-top margin-right btn btn-primary pull-right addVehicle" data-servicenumber="' + serviceNumber + '" data-vehiclenumber="2" data-zonenumber="1">Add Vehicle Rate</button>' + 
            '</div>' + 
        '</div>' 

        $("#services").html(html)
        $(".addService").attr("disabled", "disabled")
        $(".addService").attr("data-serviceNumber", serviceNumber + 1)
    }        
})

function isCountMore(arr, val){
    var count = 0
    for( var l = 0; l < arr.length; l++){
        if(arr[l] == val){
            count = count + 1
        }
    }
    if(count > 1){
        return true
    }
    return false
}

function validateServices(services, validationError){
    serviceTypes = []
    for(var i = 0; i < services.length; i++){
        if(serviceTypes.indexOf($("#serviceType_" + services[i].serviceNumber).val()) != -1 || $("#serviceType_" + services[i].serviceNumber).val() == '' || $("#serviceType_" + services[i].serviceNumber).val() == undefined || $("#serviceType_" + services[i].serviceNumber).val() == null){
            document.getElementById("serviceType_" + services[i].serviceNumber).classList.add("border-danger")
            validationError = true
            console.log("error", services[i].serviceNumber)
        }
        else{
            document.getElementById("serviceType_" + services[i].serviceNumber).classList.remove("border-danger")
            validationError = validationError || false
            serviceTypes.push($("#serviceType_" + services[i].serviceNumber).val())
        }
        console.log(serviceTypes)
        if($("#billingModel_" + services[i].serviceNumber).val() == '' || $("#billingModel_" + services[i].serviceNumber).val() == undefined || $("#billingModel_" + services[i].serviceNumber).val() == null){
            document.getElementById("billingModel_" + services[i].serviceNumber).classList.add("border-danger")
            validationError = true
        }
        else{
            document.getElementById("billingModel_" + services[i].serviceNumber).classList.remove("border-danger")
            validationError = validationError || false
        }

        // if($("#defaultRate_" + i).val() == '' || $("#defaultRate_" + i).val() == undefined || $("#defaultRate_" + i).val() == null){
        //     document.getElementById("defaultRate_" + (i + 1)).classList.add("border-danger")
        //     validationError = true
        // }
        // else{
        //     document.getElementById("defaultRate_" + (i + 1)).classList.remove("border-danger")
        //     validationError = validationError || false
        // }
        // if($("#guardRate_" + i).val() == '' || $("guardRate_" + i).val() == undefined || $("#guardRate_" + i).val() == null){
        //     document.getElementById("guardRate_" + (i + 1)).classList.add("border-danger")
        //     validationError = true
        // }
        // else{
        //     document.getElementById("guardRate_" + (i + 1)).classList.remove("border-danger")
        //     validationError = validationError || false
        // }

        for(var j = 0; j < services[i].vehicles.length; j++){
            var vehicle = services[i].vehicles[j]
            if(vehicle.cgst == '' || vehicle.cgst == undefined || vehicle.cgst == null || parseFloat(vehicle.cgst) < 0){
                document.getElementById("cgst_1").classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("cgst_1").classList.remove("border-danger")
                validationError = validationError || false
            }
            if(vehicle.sgst == '' || vehicle.sgst == undefined || vehicle.sgst == null || parseFloat(vehicle.sgst) < 0){
                document.getElementById("sgst_1").classList.add("border-danger")
                validationError = true
            }
            else{
                document.getElementById("sgst_1").classList.remove("border-danger")
                validationError = validationError || false
            }
            if(services[i].vary_with_vehicle == "true"){
                if(services[i].billing_model == 'Fixed Rate per Trip' || services[i].billing_model == 'Fixed Rate per Zone'){
                    zone_name_services[i + 1][j + 1] = []
                    for(var k = 0; k < vehicle.zones.length; k++){
                        var zone = vehicle.zones[k]
                        zone_name_services[i + 1][j + 1].push(zone.name)
                    }

                    if(vehicle.vehicle_capacity == '' || vehicle.vehicle_capacity == undefined || vehicle.vehicle_capacity == null || parseFloat(vehicle.vehicle_capacity) < 0){
                        document.getElementById("vehicleCapacity_" + (i + 1) + "_" + (j + 1)).classList.add("border-danger")
                        validationError = true
                    }
                    else{
                        document.getElementById("vehicleCapacity_" + (i + 1) + "_" + (j + 1)).classList.remove("border-danger")
                        validationError = validationError || false
                    }
                    // if(vehicle.overage == 1){
                    //     if(vehicle.overage_per_hour == '' || vehicle.overage_per_hour == undefined || vehicle.overage_per_hour == null || parseFloat(vehicle.overage_per_hour) < 0){
                    //         document.getElementById("overageRate_" + (i + 1) + "_" + (j + 1)).classList.add("border-danger")
                    //         validationError = true
                    //     }
                    //     else{
                    //         document.getElementById("overageRate_" + (i + 1) + "_" + (j + 1)).classList.remove("border-danger")
                    //         validationError = validationError || false
                    //     }
                    //     if(vehicle.time_on_duty == '' || vehicle.time_on_duty == undefined || vehicle.time_on_duty == null || parseFloat(vehicle.time_on_duty) < 0){
                    //         document.getElementById("timeOnDuty_" + (i + 1) + "_" + (j + 1)).classList.add("border-danger")
                    //         validationError = true
                    //     }
                    //     else{
                    //         document.getElementById("timeOnDuty_" + (i + 1) + "_" + (j + 1)).classList.remove("border-danger")
                    //         validationError = validationError || false
                    //     }
                    // }

                    for(var k = 0; k < vehicle.zones.length; k++){                            
                        var zone = vehicle.zones[k]
                        if(zone.name == 'Default'){
                            if(zone.guard_rate == '' || zone.guard_rate == undefined || zone.guard_rate == null || parseFloat(zone.guard_rate) < 0){
                                document.getElementById("vehicleGuardRate_" + (i + 1) + "_" + (j + 1)).classList.add("border-danger")
                                validationError = true
                            }
                            else{
                                document.getElementById("vehicleGuardRate_" + (i + 1) + "_" + (j + 1)).classList.remove("border-danger")
                                validationError = validationError || false
                            }
                            if(zone.rate == '' || zone.rate == undefined || zone.rate == null || parseFloat(zone.rate) < 0){
                                document.getElementById("vehicleDefaultRate_" + (i + 1) + "_" + (j + 1)).classList.add("border-danger")
                                validationError = true
                            }
                            else{
                                document.getElementById("vehicleDefaultRate_" + (i + 1) + "_" + (j + 1)).classList.remove("border-danger")
                                validationError = validationError || false
                            }
                        }
                        else{                            
                            if(zone.name == '' ||  zone.name == undefined || zone.name == null || isCountMore(zone_name_services[i + 1][j + 1], zone.name)){
                                document.getElementById("zoneName_" + (i + 1) + "_" + (j + 1) + "_" + k).classList.add("border-danger")
                                validationError = true
                            }
                            else{
                                document.getElementById("zoneName_" + (i + 1) + "_" + (j + 1) + "_" + k).classList.remove("border-danger")
                                validationError = validationError || false
                            }
                            if(zone.rate == '' ||  zone.rate == undefined || zone.rate == null || parseFloat(zone.rate) < 0){
                                document.getElementById("zoneRate_" + (i + 1) + "_" + (j + 1) + "_" + k).classList.add("border-danger")
                                validationError = true
                            }
                            else{
                                document.getElementById("zoneRate_" + (i + 1) + "_" + (j + 1) + "_" + k).classList.remove("border-danger")
                                validationError = validationError || false
                            }
                            if(zone.guard_rate == '' ||  zone.guard_rate == undefined || zone.guard_rate == null || parseFloat(zone.guard_rate) < 0){
                                document.getElementById("zoneGuardRate_" + (i + 1) + "_" + (j + 1) + "_" + k).classList.add("border-danger")
                                validationError = true
                            }
                            else{
                                document.getElementById("zoneGuardRate_" + (i + 1) + "_" + (j + 1) + "_" + k).classList.remove("border-danger")
                                validationError = validationError || false
                            }
                        }
                    }
                } 
                else if(services[i].billing_model == 'Package Rates'){
                    var package_rate = vehicle.package_rate
                    if(package_rate.duration == '' ||  package_rate.duration == undefined || package_rate.duration == null){
                        document.getElementById("packageDuration_" + (i + 1) + "_" + (j + 1)).classList.add("border-danger")
                        validationError = true
                    }
                    else{
                        document.getElementById("packageDuration_" + (i + 1) + "_" + (j + 1)).classList.remove("border-danger")
                        validationError = validationError || false
                    }
                    if(package_rate.package_km == '' ||  package_rate.package_km == undefined || package_rate.package_km == null){
                        document.getElementById("packageKm_" + (i + 1) + "_" + (j + 1)).classList.add("border-danger")
                        validationError = true
                    }
                    else{
                        document.getElementById("packageKm_" + (i + 1) + "_" + (j + 1)).classList.remove("border-danger")
                        validationError = validationError || false
                    }
                    if(package_rate.package_rate == '' ||  package_rate.package_rate == undefined || package_rate.package_rate == null){
                        document.getElementById("packageRate_" + (i + 1) + "_" + (j + 1)).classList.add("border-danger")
                        validationError = true
                    }
                    else{
                        document.getElementById("packageRate_" + (i + 1) + "_" + (j + 1)).classList.remove("border-danger")
                        validationError = validationError || false
                    }
                    if(package_rate.package_overage_per_km == '' ||  package_rate.package_overage_per_km == undefined || package_rate.package_overage_per_km == null){
                        document.getElementById("packageOveragePerKm_" + (i + 1) + "_" + (j + 1)).classList.add("border-danger")
                        validationError = true
                    }
                    else{
                        document.getElementById("packageOveragePerKm_" + (i + 1) + "_" + (j + 1)).classList.remove("border-danger")
                        validationError = validationError || false
                    }
                    if(package_rate.package_overage_time == 'true'){
                        if(package_rate.package_duty_hours == '' ||  package_rate.package_duty_hours == undefined || package_rate.package_duty_hours == null){
                            document.getElementById("packageDutyHours_" + (i + 1) + "_" + (j + 1)).classList.add("border-danger")
                            validationError = true
                        }
                        else{
                            document.getElementById("packageDutyHours_" + (i + 1) + "_" + (j + 1)).classList.remove("border-danger")
                            validationError = validationError || false
                        }
                        if(package_rate.package_overage_per_time == '' ||  package_rate.package_overage_per_time == undefined || package_rate.package_overage_per_time == null){
                            document.getElementById("packageOveragePerTime_" + (i + 1) + "_" + (j + 1)).classList.add("border-danger")
                            validationError = true
                        }
                        else{
                            document.getElementById("packageOveragePerTime_" + (i + 1) + "_" + (j + 1)).classList.remove("border-danger")
                            validationError = validationError || false
                        }
                    }                    
                }               
            }
            else{
                if(services[i].billing_model == 'Fixed Rate per Trip' || services[i].billing_model == 'Fixed Rate per Zone'){
                    zone_names[i + 1] = []
                    for(var k = 0; k < vehicle.zones.length; k++){
                        var zone = vehicle.zones[k]
                        zone_names[i + 1].push(zone.name)
                    }
                    // if(vehicle.overage == 1){
                    //     if(vehicle.overage_per_hour == '' || vehicle.overage_per_hour == undefined || vehicle.overage_per_hour == null || parseFloat(vehicle.overage_per_hour) < 0){
                    //         document.getElementById("overageRate_" + (i + 1)).classList.add("border-danger")
                    //         validationError = true
                    //     }
                    //     else{
                    //         document.getElementById("overageRate_" + (i + 1)).classList.remove("border-danger")
                    //         validationError = validationError || false
                    //     }
                    //     if(vehicle.time_on_duty == '' || vehicle.time_on_duty == undefined || vehicle.time_on_duty == null || parseFloat(vehicle.time_on_duty) < 0){
                    //         document.getElementById("timeOnDuty_" + (i + 1)).classList.add("border-danger")
                    //         validationError = true
                    //     }
                    //     else{
                    //         document.getElementById("timeOnDuty_" + (i + 1)).classList.remove("border-danger")
                    //         validationError = validationError || false
                    //     }
                    // }

                    for(var k = 0; k < vehicle.zones.length; k++){
                        var zone = vehicle.zones[k]
                        if(zone.name == 'Default'){
                            if(zone.guard_rate == '' || zone.guard_rate == undefined || zone.guard_rate == null || parseFloat(zone.guard_rate) < 0){
                                document.getElementById("guardRate_" + (i + 1)).classList.add("border-danger")
                                validationError = true
                            }
                            else{
                                document.getElementById("guardRate_" + (i + 1)).classList.remove("border-danger")
                                validationError = validationError || false
                            }
                            if(zone.rate == '' || zone.rate == undefined || zone.rate == null || parseFloat(zone.rate) < 0){
                                document.getElementById("defaultRate_" + (i + 1)).classList.add("border-danger")
                                validationError = true
                            }
                            else{
                                document.getElementById("defaultRate_" + (i + 1)).classList.remove("border-danger")
                                validationError = validationError || false
                            }
                        }
                        else{
                            if(zone.name == '' ||  zone.name == undefined || zone.name == null || isCountMore(zone_names[i + 1], zone.name)){
                                document.getElementById("zoneName_" + (i + 1) + "_" + k).classList.add("border-danger")
                                validationError = true
                            }
                            else{
                                document.getElementById("zoneName_" + (i + 1) + "_" + k).classList.remove("border-danger")
                                validationError = validationError || false
                            }
                            if(zone.rate == '' ||  zone.rate == undefined || zone.rate == null || parseFloat(zone.rate) < 0){
                                document.getElementById("zoneRate_" + (i + 1) + "_" + k).classList.add("border-danger")
                                validationError = true
                            }
                            else{
                                document.getElementById("zoneRate_" + (i + 1) + "_" + k).classList.remove("border-danger")
                                validationError = validationError || false
                            }
                            if(zone.guard_rate == '' ||  zone.guard_rate == undefined || zone.guard_rate == null || parseFloat(zone.guard_rate) < 0){
                                document.getElementById("zoneGuardRate_" + (i + 1) + "_" + k).classList.add("border-danger")
                                validationError = true
                            }
                            else{
                                document.getElementById("zoneGuardRate_" + (i + 1) + "_" + k).classList.remove("border-danger")
                                validationError = validationError || false
                            }
                        }
                    }
                } 
                else if(services[i].billing_model == 'Package Rates'){
                    var package_rate = vehicle.package_rate
                    if(package_rate.duration == '' ||  package_rate.duration == undefined || package_rate.duration == null){
                        document.getElementById("packageDuration_" + (i + 1)).classList.add("border-danger")
                        validationError = true
                    }
                    else{
                        document.getElementById("packageDuration_" + (i + 1)).classList.remove("border-danger")
                        validationError = validationError || false
                    }
                    if(package_rate.package_km == '' ||  package_rate.package_km == undefined || package_rate.package_km == null){
                        document.getElementById("packageKm_" + (i + 1)).classList.add("border-danger")
                        validationError = true
                    }
                    else{
                        document.getElementById("packageKm_" + (i + 1)).classList.remove("border-danger")
                        validationError = validationError || false
                    }
                    if(package_rate.package_rate == '' ||  package_rate.package_rate == undefined || package_rate.package_rate == null){
                        document.getElementById("packageRate_" + (i + 1)).classList.add("border-danger")
                        validationError = true
                    }
                    else{
                        document.getElementById("packageRate_" + (i + 1)).classList.remove("border-danger")
                        validationError = validationError || false
                    }
                    if(package_rate.package_overage_per_km == '' ||  package_rate.package_overage_per_km == undefined || package_rate.package_overage_per_km == null){
                        document.getElementById("packageOveragePerKm_" + (i + 1)).classList.add("border-danger")
                        validationError = true
                    }
                    else{
                        document.getElementById("packageOveragePerKm_" + (i + 1)).classList.remove("border-danger")
                        validationError = validationError || false
                    }
                    if(package_rate.package_overage_time == 'true'){
                        if(package_rate.package_duty_hours == '' ||  package_rate.package_duty_hours == undefined || package_rate.package_duty_hours == null){
                            document.getElementById("packageDutyHours_" + (i + 1)).classList.add("border-danger")
                            validationError = true
                        }
                        else{
                            document.getElementById("packageDutyHours_" + (i + 1)).classList.remove("border-danger")
                            validationError = validationError || false
                        }
                        if(package_rate.package_overage_per_time == '' ||  package_rate.package_overage_per_time == undefined || package_rate.package_overage_per_time == null){
                            document.getElementById("packageOveragePerTime_" + (i + 1)).classList.add("border-danger")
                            validationError = true
                        }
                        else{
                            document.getElementById("packageOveragePerTime_" + (i + 1)).classList.remove("border-danger")
                            validationError = validationError || false
                        }
                    }                    
                }
            }
        }               
    }
    return validationError
}

function getServiceData(){
    var totalServices = 0;
    var services = []

    for(var serviceNumber = 1; serviceNumber <= MAX_LIMIT; serviceNumber++){
        if(document.getElementById("service_" + serviceNumber) == undefined){
            totalServices = serviceNumber - 1
            break;
        }
    }
    
    var serviceChildren = $("#services").children()
    for(var serviceNumber = 1; serviceNumber <= totalServices; serviceNumber++){
        if(serviceChildren[serviceNumber - 1].style.display == 'none'){
            continue
        }
        var service = {}

        var serviceType = $("#serviceType_" + serviceNumber).val()
        var billingModel = $("#billingModel_" + serviceNumber).val()        
        var varyWithVehicle = $("input[name='varyWithVehicle_" + serviceNumber + "']:checked").val()
        var cgst = $("#cgst_1").val()
        var sgst = $("#sgst_1").val()
        var defaultRate = $("#defaultRate_" + serviceNumber).val()
        var guardRate = $("#guardRate_" + serviceNumber).val()
        // var overage = $("input[name='overage_" + serviceNumber + "']:checked").val()
        // var timeOnDuty = $("input[name='timeOnDuty_" + serviceNumber + "']").val()
        // var overagePerHour = $("input[name='overageRate_" + serviceNumber + "']").val()
        service['serviceNumber'] = serviceNumber
        service['billing_model'] = billingModel
        service['service_type'] = serviceType
        service['vary_with_vehicle'] = varyWithVehicle

        // if(overage == 'true'){
        //     overage = 1                
        // }
        // else{
        //     overage = 0
        // }

        var vehicles = [];
        if(varyWithVehicle == 'true'){
            var totalVehicles = 0;
            for(var vehicleNumber = 1; vehicleNumber < MAX_LIMIT; vehicleNumber++){
                if(document.getElementById("vehicleCapacity_" + serviceNumber + "_" + vehicleNumber) == undefined){
                    totalVehicles = vehicleNumber - 1
                    break
                }
            }

            var vehicleChildren = $("#vehicles_" + serviceNumber).children()
            for(var vehicleNumber = 1; vehicleNumber <= totalVehicles; vehicleNumber++){
                if(vehicleChildren[vehicleNumber - 1].style.display == 'none'){
                    continue
                }
                var vehicle = {}
                var zones = []
                var zone = {}
                // vehicle['penalty'] = penalty
                vehicle['cgst'] = cgst
                vehicle['sgst'] = sgst

                var totalZones = 0;
                for(var zoneNumber = 1; zoneNumber < MAX_LIMIT; zoneNumber++){
                    if(document.getElementById("zoneName_" + serviceNumber + "_" + vehicleNumber + "_" + zoneNumber) == undefined){
                        totalZones = zoneNumber - 1
                        break
                    }
                }

                // vehicle['overage'] = $("input[name='overage_" + serviceNumber + "_" + vehicleNumber + "']:checked").val()
                // if(vehicle['overage'] == 'true'){
                //     vehicle['overage'] = 1                
                // }
                // else{
                //     vehicle['overage'] = 0
                // }

                // vehicle['time_on_duty'] = $("input[name='timeOnDuty_" + serviceNumber + "_" + vehicleNumber + "']").val()
                // vehicle['overage_per_hour'] = $("input[name='overageRate_" + serviceNumber + "_" + vehicleNumber + "']").val()
                vehicle['vehicle_capacity'] = $("#vehicleCapacity_" + serviceNumber + "_" + vehicleNumber).val()
                vehicle['ac'] = $("input[name='vehicleAc_" + serviceNumber + "_" + vehicleNumber + "']:checked").val()
                
                zone['name'] = 'Default'                    
                zone['rate'] = $("#vehicleDefaultRate_" + serviceNumber + "_" + vehicleNumber).val()
                zone['guard_rate'] = $("#vehicleGuardRate_" + serviceNumber + "_" + vehicleNumber).val()
                zones.push(zone)
                if(billingModel == 'Fixed Rate per Trip'){
                    // vehicle['rate_per_trip'] = $("#vehicleRatePerTrip_" + serviceNumber + "_" + vehicleNumber).val()                        
                    vehicle['zones'] = zones
                }
                else if(billingModel == 'Fixed Rate per Zone'){
                    // vehicle['default_rate'] = $("#vehicleDefaultRate_" + serviceNumber + "_" + vehicleNumber).val()
                    var vehicleZonesChildren = $("#zones_" + serviceNumber + "_" + vehicleNumber).children()
                    for(var zoneNumber = 1; zoneNumber <= totalZones; zoneNumber++){
                        if(vehicleZonesChildren[zoneNumber - 1].style.display == 'none'){
                            continue
                        }
                        zone = {}
                        zone['name'] = $("#zoneName_" + serviceNumber + "_" + vehicleNumber + "_" + zoneNumber).val()
                        zone['rate'] = $("#zoneRate_" + serviceNumber + "_" + vehicleNumber + "_" + zoneNumber).val()
                        zone['guard_rate'] = $("#zoneGuardRate_" + serviceNumber + "_" + vehicleNumber + "_" + zoneNumber).val()
                        zones.push(zone)
                    }
                    vehicle['zones'] = zones
                }
                else if(billingModel == 'Package Rates'){
                    var packageRate = {}
                    packageRate['duration'] = $("#packageDuration_" + serviceNumber + "_" + vehicleNumber).val()
                    packageRate['package_km'] = $("#packageKm_" + serviceNumber + "_" + vehicleNumber).val()
                    packageRate['package_rate'] = $("#packageRate_" + serviceNumber + "_" + vehicleNumber).val()
                    packageRate['package_overage_per_km'] = $("#packageOveragePerKm_" + serviceNumber + "_" + vehicleNumber).val()
                    packageRate['package_overage_time'] = $("input[name='packageOverageTime_" + serviceNumber + "_" + vehicleNumber + "']:checked").val()
                    packageRate['package_mileage_calculation'] = $("input[name='packageMileageCalculation_" + serviceNumber + "_" + vehicleNumber + "']:checked").val()
                    packageRate['package_duty_hours'] = $("#packageDutyHours_" + serviceNumber + "_" + vehicleNumber).val()                    
                    packageRate['package_overage_per_time'] = $("#packageOveragePerTime_" + serviceNumber + "_" + vehicleNumber).val()                    
                    vehicle['package_rate'] = packageRate
                }                
                vehicles.push(vehicle)
            }                
        }
        else{
            var vehicle = {}
            // vehicle['penalty'] = penalty
            vehicle['cgst'] = cgst
            vehicle['sgst'] = sgst
            // vehicle['overage'] = overage
            vehicle['vehicle_capacity'] = 0 //0 means rates for this service does not vary with vehicle
            // if(overage == 1){
            //     vehicle['time_on_duty'] = timeOnDuty
            //     vehicle['overage_per_hour'] = overagePerHour   
            // }
            
            var zones = []
            var zone = {}
            zone['name'] = 'Default'
            zone['rate'] = defaultRate
            zone['guard_rate'] = guardRate
            zones.push(zone)
            if(billingModel == 'Fixed Rate per Trip'){                    
                // vehicle['rate_per_trip'] = ratePerTrip
                // vehicle['guardRate'] = guardRate
                vehicle['zones'] = zones
            }
            else if(billingModel == 'Fixed Rate per Zone'){
                // vehicle['default_rate'] = defaultRate
                var totalZones = 0;                    
                for(var zoneNumber = 1; zoneNumber < MAX_LIMIT; zoneNumber++){
                    if(document.getElementById("zoneName_" + serviceNumber + "_" + zoneNumber) == undefined){
                        totalZones = zoneNumber - 1
                        break
                    }
                }
                var zoneChildren = $("#zones_" + serviceNumber).children()
                for(var zoneNumber = 1; zoneNumber <= totalZones; zoneNumber++){
                    if(zoneChildren[zoneNumber - 1].style.display == 'none'){
                        continue
                    }
                    zone = {}
                    zone['name'] = $("#zoneName_" + serviceNumber + "_" + zoneNumber).val()
                    zone['rate'] = $("#zoneRate_" + serviceNumber + "_" + zoneNumber).val()
                    zone['guard_rate'] = $("#zoneGuardRate_" + serviceNumber + "_" + zoneNumber).val()
                    zones.push(zone)
                }                    
                vehicle['zones'] = zones
            }
            else if(billingModel == 'Package Rates'){
                var packageRate = {}
                packageRate['duration'] = $("#packageDuration_" + serviceNumber).val()
                packageRate['package_km'] = $("#packageKm_" + serviceNumber).val()
                packageRate['package_rate'] = $("#packageRate_" + serviceNumber).val()
                packageRate['package_overage_per_km'] = $("#packageOveragePerKm_" + serviceNumber).val()
                packageRate['package_overage_time'] = $("input[name='packageOverageTime_" + serviceNumber + "']:checked").val()
                packageRate['package_mileage_calculation'] = $("input[name='packageMileageCalculation_" + serviceNumber + "']:checked").val()
                packageRate['package_duty_hours'] = $("#packageDutyHours_" + serviceNumber).val()                    
                packageRate['package_overage_per_time'] = $("#packageOveragePerTime_" + serviceNumber).val()
                vehicle['package_rate'] = packageRate
            }            
            vehicles.push(vehicle)
        }
        service['vehicles'] = vehicles
        services.push(service)
    }
    return services;
};
