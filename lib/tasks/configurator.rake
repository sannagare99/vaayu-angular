require 'geohash'

namespace :configurator do

  desc 'Init Configurator'
  task :init_configurator => [:environment] do
    new_conf_sequence = [
        {
          request_type: "send_last_mile_sms",
          value: 1,
          conf_type: 0
        },
        {
          request_type: "send_drivers_off_duty",
          value: 0,
          conf_type: 0,
          display_name: "Automatically send Driver off duty?"
        },
        {
          request_type: "female_exception_required",
          value: 1,
          conf_type: 0,
          display_name: "Enforce female first / last policy"
        },
        {
          request_type: "female_exception_resequence_required",
          value: 1,
          conf_type: 0,
          display_name: "Allow re-sequencing to manage female first/last exception?"
        },
        {
          request_type: "no_show_approval_required",
          value: 0,
          conf_type: 0,
          display_name: "Require approval when a Driver signals an Employee No Show"
        },
        {
          request_type: "driver_no_show_allowed_D2D",
          value: 1,
          conf_type: 0,
          display_name: "Requrie the Driver to do an Employee No Show for D2D pick-up?"
        },
        {
          request_type: "passcode_required_driver_check_in_D2D",
          value: 0,
          conf_type: 0,
          display_name: "Require a passcode at the Driver\'s end while checking in an Emloyee for a D2D pick-up?"
        },
        {
          request_type: "employee_check_in_allowed_D2D",
          value: 0,
          conf_type: 0,
          display_name: "Can an Employee check themselves in from their App for a D2D pick-up?"
        },
        {
          request_type: "employee_no_show_allowed_D2D",
          value: 0,
          conf_type: 0,
          display_name: "Can an Employee No Show themselves from their App for a D2D pick-up?"
        },
        {
          request_type: "move_to_next_step_required_D2D",
          value: 0,
          conf_type: 0,
          display_name: "Allow move to next state without checking in all the Employees for D2D pick-up?"
        },
        {
          request_type: "driver_no_show_allowed_BUS",
          value: 0,
          conf_type: 0,
          display_name: "Requrie the Driver to do an Employee No Show for a Bus pick-up?"
        },
        {
          request_type: "passcode_required_driver_check_in_BUS",
          value: 1,
          conf_type: 0,
          display_name: "Require a passcode at the Driver\'s end while checking in an Emloyee for a Bus pick-up?"
        },
        {
          request_type: "employee_check_in_allowed_BUS",
          value: 1,
          conf_type: 0,
          display_name: "Can an Employee check themselves in from their App for a Bus pick-up?"
        },
        {
          request_type: "employee_no_show_allowed_BUS",
          value: 1,
          conf_type: 0,
          display_name: "Can an Employee No Show themselves from their App for a Bus pick-up?"
        },
        {
          request_type: "move_to_next_step_required_BUS",
          value: 1,
          conf_type: 0,
          display_name: "Allow move to next state without checking in all the Employees for a Bus pick-up?"
        },
        {
          request_type: "driver_no_show_allowed_NODAL",
          value: 1,
          conf_type: 0,
          display_name: "Requrie the Driver to do an Employee No Show for a pick-up away from home?"
        },
        {
          request_type: "passcode_required_driver_check_in_NODAL",
          value: 0,
          conf_type: 0,
          display_name: "Require a passcode at the Driver\'s end while checking in an Emloyee for a pick-up away from home?"
        },
        {
          request_type: "employee_check_in_allowed_NODAL",
          value: 0,
          conf_type: 0,
          display_name: "Can an Employee check themselves in from their App for a pick-up away from home?"
        },
        {
          request_type: "employee_no_show_allowed_NODAL",
          value: 0,
          conf_type: 0,
          display_name: "Can an Employee No Show themselves from their App for a pick-up away from home?"
        },
        {
          request_type: "move_to_next_step_required_NODAL",
          value: 0,
          conf_type: 0,
          display_name: "Allow move to next state without checking in all the Employees for pick-up away from home?"
        },
        {
          request_type: "female_exception_check_in_time",
          value: "06:00",
          conf_type: 2,
          display_name: "Start time before which a shift should fall for the female first/last policy to be applicable:"
        },
        {
          request_type: "female_exception_check_out_time",
          value: "20:00",
          conf_type: 2,
          display_name: "End time after which a shift should fall for the female first/last policy to be applicable:"
        },
        {
          request_type: "female_exception_aerial_distance",
          value: 1500,
          conf_type: 1,
          display_name: "Do re-sequencing only when the next male employee is within __ meters of the female employee"
        },
        {
          request_type: "reports_download_button",
          value: 0,
          conf_type: 0
        },
        {
          request_type: "change_time_check_in",
          value: 480,
          conf_type: 1,
          display_name: "Lead time to place a change request for Login __ minutes before the shift logout time"
        },
        {
          request_type: "change_time_check_out",
          value: 240,
          conf_type: 1,
          display_name: "Lead time to place a change request for Logout __ minutes before the shift logout time"
        },
        {
          request_type: "change_request_require_approval",
          value: 1,
          conf_type: 0,
          display_name: "Require an approval for a change request?"
        },
        {
          request_type: "consider_non_compliant_cancel_as_no_show",
          value: 1,
          conf_type: 0,
          display_name: "Last minute cancellation by Employees should be considered as a No Show?"
        },
        {
          request_type: "cancel_time_check_in",
          value: 240,
          conf_type: 1,
          display_name: "Lead time to cancel a scheduled ride __ mintues before the shift login time"
        },
        {
          request_type: "cancel_time_check_out",
          value: 30,
          conf_type: 1,
          display_name: "Lead time to cancel a scheduled ride __ minutes before the shift logout time"
        },
        {
          request_type: "wait_time_at_pickup_D2D",
          value: 3,
          conf_type: 1,
          display_name: "Wait time at a pick-up __ mins for D2D pickups."
        },
        {
          request_type: "start_time_NODAL",
          value: "06:00",
          conf_type: 2,
          display_name: "Start time for which pick-ups / drop-offs away from home are allowed:"
        },
        {
          request_type: "end_time_NODAL",
          value: "20:00",
          conf_type: 2,
          display_name: "End Time for which pick-ups / drop-offs away from home are allowed:"
        },
        {
          request_type: "is_nodal_trip_allowed",
          value: 1,
          conf_type: 0,
          display_name: "Are pick-ups / drop-offs away from home allowed?"
        },
        {
          request_type: "wait_time_at_pickup_BUS",
          value: 10,
          conf_type: 1,
          display_name: "Wait time at a pick-up __ mins for nodal pick-ups"
        },
        {
          request_type: "report_time_check_in",
          value: 15,
          conf_type: 1,
          display_name: "Employees should reach office __ minutes before the shift login time (used for calculating the pick-up times)"
        },
        {
          request_type: "report_time_delay_check_in",
          value: 15,
          conf_type: 1,
          display_name: "Allowed buffer time __ mins"
        },
        {
          request_type: "departure_time_check_out",
          value: 15,
          conf_type: 1,
          display_name: "For logouts, Employee should depart from the Site within __ mins of the shift logout time"
        },
        {
          request_type: "speed_limit",
          value: 60,
          conf_type: 1,
          display_name: "A driver has to comply to a speed limit of __ kms/hr"
        },
        {
          request_type: "speed_limit_violation_time",
          value: 10,
          conf_type: 1,
          display_name: "Consider a speed violation if the Driver exceeds the speed limit for more than __ seconds"
        },
        {
          request_type: "max_allowed_distance_trip",
          value: 40,
          conf_type: 1,
          display_name: "Maximum distance allowed for a Trip __ kms"
        },
        {
          request_type: "max_duration_allowed_trip",
          value: 120,
          conf_type: 1,
          display_name: "Maximum duration allowed for a Trip __ minutes"
        },
        {
          request_type: "buffer_duration_for_start_trip_notification",
          value: 10,
          conf_type: 1,
          display_name: "Lead time to notify Drivers to start their assigned Trip __ minutes (lead time is w.r.t the scheduled start time)"
        },
        {
          request_type: "buffer_duration_for_delayed_trip_notification",
          value: 10,
          conf_type: 1,
          display_name: "Buffer time after which operator should be notified of delayed trip in minutes"
        },
        {
          request_type: "buffer_duration_to_allow_start_trip",
          value: 60,
          conf_type: 1,
          display_name: "Allow the Driver to start the Trip freely __ minutes before the first pick-up time"
        },
        {
          request_type: "min_distance_to_calc_start_trip_eta",
          value: 500,
          conf_type: 1,
          display_name: "Minimum distance to be travelled by the Driver before re-calculating scheduled time for the driver to start the trip __ meters"
        },
        {
          request_type: "max_time_to_calc_start_trip_eta",
          value: 120,
          conf_type: 1,
          display_name: "Start calculating the scheduled start trip time for any assigned trip __ minutes before the first pick-up time"
        },
        {
          request_type: "send_notification_driver_assigned",
          value: 1,
          conf_type: 0,
          display_name: "Send SMS notification to Employees when a Driver is assigned?"
        },
        {
          request_type: "send_notification_driver_start_trip",
          value: 0,
          conf_type: 0,
          display_name: "Send SMS notification to Employee when Driver starts the trip?"
        },
        {
          request_type: "send_notification_employee_check_out",
          value: 1,
          conf_type: 0,
          display_name: "Send SMS notification to Employee when Driver checks them out?"
        },
        {
          request_type: "driver_narrow_geofence_distance",
          value: 200,
          conf_type: 1,
          display_name: "Set the geofence for pick-up and drop-off locations as __ meters"
        },
        {
          request_type: "buffer_time_allowed_check_in",
          value: 1,
          conf_type: 0,
          display_name: "Any buffer time for on-time arrivals at the Site"
        },
        {
          request_type: "show_driver_licence_expiry_date_notification",
          value: 1,
          conf_type: 0,
          display_name: "Show alerts for Driver\'s Licence Expiry?"
        },
        {
          request_type: "driver_licence_expiry_date_notification_lead_time",
          value: 30,
          conf_type: 1,
          display_name: "Start showing the alert X days ahead of the actual Licence Expiry date. X is:"
        },
        {
          request_type: "show_driver_badge_expiry_date_notification",
          value: 1,
          conf_type: 0,
          display_name: "Show notifications for Driver\'s Badge Expiry?"
        },
        {
          request_type: "driver_badge_expiry_date_notification_lead_time",
          value: 30,
          conf_type: 1,
          display_name: "Start showing the alert X days ahead of the actual Badge Expiry date X is:"
        },
        {
          request_type: "show_vehicle_insurance_expiry_date_notification",
          value: 1,
          conf_type: 0,
          display_name: "Show notifications for Vehicle\'s Insurance Expiry?"
        },
        {
          request_type: "vehicle_insurance_expiry_date_notification_lead_time",
          value: 30,
          conf_type: 1,
          display_name: "Start showing the alert X days ahead of the actual Insurance Expiry date. X is:"
        },
        {
          request_type: "show_vehicle_permit_expiry_date_notification",
          value: 1,
          conf_type: 0,
          display_name: "Show notifications for Vehicle\'s Permit Expiry?"
        },
        {
          request_type: "vehicle_permit_expiry_date_notification_lead_time",
          value: 30,
          conf_type: 1,
          display_name: "Start showing the alert X days ahead of the actual Permit Expiry date. X is:"
        },
        {
          request_type: "show_vehicle_puc_expiry_date_notification",
          value: 1,
          conf_type: 0,
          display_name: "Show notifications for Vehicle\'s P.U.C Expiry?"
        },
        {
          request_type: "vehicle_puc_expiry_date_notification_lead_time",
          value: 30,
          conf_type: 1,
          display_name: "Start showing the alert X days ahead of the actual P.U.C Expiry date. X is:"
        },
        {
          request_type: "show_vehicle_fc_expiry_date_notification",
          value: 1,
          conf_type: 0,
          display_name: "Show notifications for Vehicle\'s F.C Expiry?"
        },
        {
          request_type: "vehicle_fc_expiry_date_notification_lead_time",
          value: 30,
          conf_type: 1,
          display_name: "Start showing the alert X days ahead of the actual F.C Expiry date. X is:"
        },
        {
          request_type: "driver_wide_geofence_distance",
          value: 1500,
          conf_type: 1,
          display_name: "Set the geofence for triggering the Driver Arriving notification to the Employees as X meters. X is:"
        },
        {
          request_type: "driver_auto_signal_i_am_here_by_geofence",
          value: 0,
          conf_type: 0,
          display_name: "Automatically signal an I Am Here based on geofencing? (the drivers are notified by default)"
        },
        {
          request_type: "driver_auto_complete_trip_by_geofence",
          value: 0,
          conf_type: 0,
          display_name: "Automatically complete a Trip based on geofencing? (the drivers are notified by default)"
        },
        {
          request_type: "driver_restrict_i_am_here_by_geofence",
          value: 0,
          conf_type: 0,
          display_name: "Restrict the Driver from signalling an I Am Here outside the defined geofence?"
        },
        {
          request_type: "wait_time_at_pickup_NODAL",
          value: 3,
          conf_type: 1,
          display_name: "Wait time at a pick-up __ mins for Nodal pickups."
        },
        {
          request_type: "send_notification_driver_arrived",
          value: 1,
          conf_type: 0,
          display_name: "Send SMS notification to Employee when Driver reaches their pick-up point?"
        }
      ]
    
    #Delete all existing configuration values
    Configurator.delete_all
    new_conf_sequence.each do |conf|
      Configurator.create_with({value: conf[:value], conf_type: conf[:conf_type], options: conf[:options], display_name: conf[:display_name]}).find_or_create_by(request_type: conf[:request_type])
    end
  end

  desc 'Init Compliance'
  task :init_compliance => [:environment] do
    #Create Driver and Vehicle Checkliet
    Driver.create_checklist
    Vehicle.create_checklist

    #Create Driver and Vehicle Notification
    Driver.create_notification
    Vehicle.create_notification  
  end
end