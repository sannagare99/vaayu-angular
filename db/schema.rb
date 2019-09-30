# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190725064846) do

  create_table "ba_invoices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "company_type"
    t.integer  "company_id"
    t.datetime "date"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "trips_count"
    t.decimal  "amount",       precision: 12, scale: 2
    t.string   "status"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.index ["company_type", "company_id"], name: "index_ba_invoices_on_company_type_and_company_id", using: :btree
  end

  create_table "ba_package_rates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "ba_vehicle_rate_id"
    t.string  "duration"
    t.decimal "package_duty_hours",          precision: 10, default: 0
    t.decimal "package_km",                  precision: 10, default: 0
    t.decimal "package_overage_per_km",      precision: 10, default: 0
    t.decimal "package_overage_per_time",    precision: 10, default: 0
    t.boolean "package_overage_time",                       default: false
    t.decimal "package_rate",                precision: 10, default: 0
    t.string  "package_mileage_calculation"
    t.index ["ba_vehicle_rate_id"], name: "index_ba_package_rates_on_ba_vehicle_rate_id", using: :btree
  end

  create_table "ba_services", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "business_associate_id"
    t.string  "service_type"
    t.string  "billing_model"
    t.boolean "vary_with_vehicle",     default: false
    t.integer "logistics_company_id"
    t.index ["business_associate_id"], name: "index_ba_services_on_business_associate_id", using: :btree
    t.index ["logistics_company_id"], name: "index_ba_services_on_logistics_company_id", using: :btree
  end

  create_table "ba_trip_invoices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "trip_id"
    t.integer "ba_invoice_id"
    t.decimal "trip_amount",        precision: 10, default: 0
    t.decimal "trip_penalty",       precision: 10, default: 0
    t.decimal "trip_toll",          precision: 10, default: 0
    t.integer "ba_vehicle_rate_id"
    t.integer "ba_zone_rate_id"
    t.integer "vehicle_id"
    t.integer "ba_package_rate_id"
    t.index ["ba_invoice_id"], name: "index_ba_trip_invoices_on_ba_invoice_id", using: :btree
    t.index ["ba_package_rate_id"], name: "index_ba_trip_invoices_on_ba_package_rate_id", using: :btree
    t.index ["ba_vehicle_rate_id"], name: "index_ba_trip_invoices_on_ba_vehicle_rate_id", using: :btree
    t.index ["ba_zone_rate_id"], name: "index_ba_trip_invoices_on_ba_zone_rate_id", using: :btree
    t.index ["trip_id"], name: "index_ba_trip_invoices_on_trip_id", using: :btree
    t.index ["vehicle_id"], name: "index_ba_trip_invoices_on_vehicle_id", using: :btree
  end

  create_table "ba_vehicle_rates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "ba_service_id"
    t.integer "vehicle_capacity"
    t.boolean "ac",                              default: true
    t.decimal "cgst",             precision: 10
    t.decimal "sgst",             precision: 10
    t.boolean "overage",                         default: false
    t.integer "time_on_duty"
    t.decimal "overage_per_hour", precision: 10
    t.index ["ba_service_id"], name: "index_ba_vehicle_rates_on_ba_service_id", using: :btree
  end

  create_table "ba_zone_rates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "ba_vehicle_rate_id"
    t.decimal "rate",               precision: 10
    t.decimal "guard_rate",         precision: 10
    t.string  "name"
    t.index ["ba_vehicle_rate_id"], name: "index_ba_zone_rates_on_ba_vehicle_rate_id", using: :btree
  end

  create_table "bus_trip_routes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.text    "stop_name",      limit: 65535
    t.text    "stop_address",   limit: 65535
    t.decimal "stop_latitude",                precision: 10, scale: 6
    t.decimal "stop_longitude",               precision: 10, scale: 6
    t.integer "stop_order"
    t.integer "bus_trip_id"
    t.text    "name",           limit: 65535
    t.index ["bus_trip_id"], name: "index_bus_trip_routes_on_bus_trip_id", using: :btree
  end

  create_table "bus_trips", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "status"
    t.string   "route_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "business_associates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "admin_f_name"
    t.string   "admin_m_name"
    t.string   "admin_l_name"
    t.string   "admin_email"
    t.string   "admin_phone"
    t.string   "legal_name"
    t.string   "pan"
    t.string   "tan"
    t.string   "business_type"
    t.string   "service_tax_no"
    t.string   "hq_address"
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.string   "name"
    t.decimal  "standard_price",       precision: 10,           default: 0
    t.integer  "pay_period",                                    default: 0
    t.integer  "time_on_duty_limit",                            default: 0
    t.integer  "distance_limit",                                default: 0
    t.decimal  "rate_by_time",         precision: 10,           default: 0
    t.decimal  "rate_by_distance",     precision: 10,           default: 0
    t.integer  "invoice_frequency",                             default: 0
    t.decimal  "service_tax_percent",  precision: 5,  scale: 4, default: "0.0"
    t.decimal  "swachh_bharat_cess",   precision: 5,  scale: 4, default: "0.002"
    t.decimal  "krishi_kalyan_cess",   precision: 5,  scale: 4, default: "0.002"
    t.integer  "logistics_company_id"
    t.string   "profit_centre"
    t.datetime "agreement_date"
    t.index ["logistics_company_id"], name: "index_business_associates_on_logistics_company_id", using: :btree
  end

  create_table "checklist_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "checklist_id"
    t.string   "key"
    t.boolean  "value"
    t.integer  "compliance_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "checklists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "vehicle_id"
    t.integer  "driver_id"
    t.integer  "status",     default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "cluster_vehicles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "date"
    t.integer  "vehicle_id"
    t.integer  "employee_cluster_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["employee_cluster_id"], name: "index_cluster_vehicles_on_employee_cluster_id", using: :btree
    t.index ["vehicle_id"], name: "index_cluster_vehicles_on_vehicle_id", using: :btree
  end

  create_table "compliance_notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "driver_id"
    t.integer  "vehicle_id"
    t.string   "message"
    t.integer  "status",          default: 0
    t.integer  "compliance_type"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "compliances", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "key"
    t.integer  "modal_type"
    t.integer  "compliance_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "configurators", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string  "request_type"
    t.string  "value",                      default: "0"
    t.integer "conf_type",                  default: 0
    t.string  "display_name"
    t.text    "options",      limit: 65535
  end

  create_table "devices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "device_id"
    t.string   "make"
    t.string   "model"
    t.string   "os"
    t.string   "os_version"
    t.integer  "status"
    t.integer  "driver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_id"], name: "index_devices_on_driver_id", using: :btree
  end

  create_table "driver_first_pickups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "trip_id"
    t.integer  "driver_id"
    t.integer  "pickup_time"
    t.datetime "time"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["driver_id"], name: "index_driver_first_pickups_on_driver_id", using: :btree
    t.index ["trip_id"], name: "index_driver_first_pickups_on_trip_id", using: :btree
  end

  create_table "driver_requests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "request_type"
    t.integer  "reason"
    t.integer  "trip_type"
    t.string   "request_state"
    t.datetime "request_date"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "driver_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "vehicle_id"
    t.index ["driver_id"], name: "index_driver_requests_on_driver_id", using: :btree
    t.index ["vehicle_id"], name: "index_driver_requests_on_vehicle_id", using: :btree
  end

  create_table "drivers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "business_associate_id"
    t.integer  "logistics_company_id"
    t.integer  "site_id"
    t.string   "status"
    t.string   "badge_number"
    t.date     "badge_issue_date"
    t.date     "badge_expire_date"
    t.string   "local_address"
    t.string   "permanent_address"
    t.string   "aadhaar_number"
    t.string   "aadhaar_mobile_number"
    t.string   "licence_number"
    t.date     "licence_validity"
    t.boolean  "verified_by_police"
    t.boolean  "uniform"
    t.boolean  "licence"
    t.boolean  "badge"
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.string   "aadhaar_address"
    t.string   "offline_phone"
    t.integer  "sort_status",                                   default: -1
    t.integer  "active_checklist_id"
    t.text     "compliance_notification_message", limit: 65535
    t.text     "compliance_notification_type",    limit: 65535
    t.index ["business_associate_id"], name: "index_drivers_on_business_associate_id", using: :btree
    t.index ["logistics_company_id"], name: "index_drivers_on_logistics_company_id", using: :btree
    t.index ["site_id"], name: "index_drivers_on_site_id", using: :btree
  end

  create_table "drivers_shifts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "driver_id"
    t.integer  "vehicle_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_id"], name: "index_drivers_shifts_on_driver_id", using: :btree
    t.index ["vehicle_id"], name: "index_drivers_shifts_on_vehicle_id", using: :btree
  end

  create_table "employee_clusters", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "error"
    t.datetime "date"
    t.integer  "driver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_id"], name: "index_employee_clusters_on_driver_id", using: :btree
  end

  create_table "employee_companies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "logistics_company_id"
    t.string   "name"
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.string   "pan"
    t.string   "tan"
    t.string   "business_type"
    t.string   "service_tax_no"
    t.string   "hq_address"
    t.decimal  "standard_price",       precision: 10,           default: 0
    t.integer  "pay_period",                                    default: 0
    t.integer  "time_on_duty_limit",                            default: 0
    t.integer  "distance_limit",                                default: 0
    t.decimal  "rate_by_time",         precision: 10,           default: 0
    t.decimal  "rate_by_distance",     precision: 10,           default: 0
    t.integer  "invoice_frequency",                             default: 0
    t.decimal  "service_tax_percent",  precision: 5,  scale: 4, default: "0.0"
    t.decimal  "swachh_bharat_cess",   precision: 5,  scale: 4, default: "0.002"
    t.decimal  "krishi_kalyan_cess",   precision: 5,  scale: 4, default: "0.002"
    t.string   "profit_centre"
    t.datetime "agreement_date"
    t.index ["logistics_company_id"], name: "index_employee_companies_on_logistics_company_id", using: :btree
  end

  create_table "employee_schedules", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "employee_id"
    t.integer  "day"
    t.time     "check_in"
    t.time     "check_out"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "date"
    t.index ["employee_id"], name: "index_employee_schedules_on_employee_id", using: :btree
  end

  create_table "employee_trip_issues", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "issue"
    t.integer "employee_trip_id"
    t.index ["employee_trip_id"], name: "index_employee_trip_issues_on_employee_trip_id", using: :btree
  end

  create_table "employee_trips", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "employee_id"
    t.integer  "trip_id"
    t.datetime "date"
    t.integer  "trip_type"
    t.string   "status"
    t.integer  "employee_schedule_id"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.integer  "trip_route_id"
    t.integer  "rating"
    t.text     "rating_feedback",                limit: 65535
    t.boolean  "dismissed",                                    default: false
    t.integer  "site_id"
    t.integer  "state"
    t.datetime "schedule_date"
    t.integer  "zone"
    t.text     "cluster_error",                  limit: 65535
    t.boolean  "bus_rider",                                    default: false
    t.integer  "shift_id"
    t.boolean  "is_clustered",                                 default: false
    t.text     "route_order",                    limit: 65535
    t.integer  "employee_cluster_id"
    t.text     "cancel_status",                  limit: 65535
    t.string   "exception_status"
    t.boolean  "is_rating_screen_shown",                       default: false
    t.boolean  "is_still_on_board_screen_shown",               default: false
    t.index ["employee_cluster_id"], name: "index_employee_trips_on_employee_cluster_id", using: :btree
    t.index ["employee_id"], name: "index_employee_trips_on_employee_id", using: :btree
    t.index ["trip_id"], name: "index_employee_trips_on_trip_id", using: :btree
    t.index ["trip_route_id"], name: "index_employee_trips_on_trip_route_id", using: :btree
  end

  create_table "employees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "employee_company_id"
    t.integer  "site_id"
    t.integer  "zone_id"
    t.string   "employee_id"
    t.integer  "gender"
    t.string   "home_address"
    t.decimal  "home_address_latitude",                 precision: 10, scale: 6
    t.decimal  "home_address_longitude",                precision: 10, scale: 6
    t.integer  "distance_to_site"
    t.date     "date_of_birth"
    t.string   "managers_employee_id"
    t.string   "managers_email_id"
    t.datetime "created_at",                                                                         null: false
    t.datetime "updated_at",                                                                         null: false
    t.string   "emergency_contact_name"
    t.string   "emergency_contact_phone"
    t.integer  "line_manager_id"
    t.boolean  "is_guard",                                                       default: false
    t.text     "geohash",                 limit: 65535
    t.boolean  "bus_travel",                                                     default: false
    t.integer  "bus_trip_route_id"
    t.string   "billing_zone",                                                   default: "Default"
    t.string   "landmark"
    t.string   "nodal_address"
    t.decimal  "nodal_address_latitude",                precision: 10, scale: 6
    t.decimal  "nodal_address_longitude",               precision: 10, scale: 6
    t.string   "nodal_name"
    t.index ["bus_trip_route_id"], name: "index_employees_on_bus_trip_route_id", using: :btree
    t.index ["employee_company_id"], name: "index_employees_on_employee_company_id", using: :btree
    t.index ["site_id"], name: "index_employees_on_site_id", using: :btree
    t.index ["zone_id"], name: "index_employees_on_zone_id", using: :btree
  end

  create_table "employer_shift_managers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "employee_company_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "employers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "employee_company_id"
    t.string   "legal_name"
    t.string   "pan"
    t.string   "tan"
    t.string   "business_type"
    t.string   "service_tax_no"
    t.string   "hq_address"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["employee_company_id"], name: "index_employers_on_employee_company_id", using: :btree
  end

  create_table "google_api_keys", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "key"
    t.string   "status"
    t.datetime "rate_limited_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.datetime "disabled_at"
  end

  create_table "ingest_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.date     "start_date"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "status"
    t.integer  "user_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "error_file_file_name"
    t.string   "error_file_content_type"
    t.integer  "error_file_file_size"
    t.datetime "error_file_updated_at"
    t.integer  "failed_row_count",           default: 0
    t.integer  "processed_row_count",        default: 0
    t.integer  "schedule_updated_count",     default: 0
    t.integer  "employee_provisioned_count", default: 0
    t.integer  "schedule_provisioned_count", default: 0
    t.integer  "schedule_assigned_count",    default: 0
    t.string   "ingest_type"
    t.string   "file_digest"
    t.index ["user_id"], name: "index_ingest_jobs_on_user_id", using: :btree
  end

  create_table "invoice_attachments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "invoice_id"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.index ["invoice_id"], name: "index_invoice_attachments_on_invoice_id", using: :btree
  end

  create_table "invoices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "company_type"
    t.integer  "company_id"
    t.datetime "date"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "trips_count"
    t.decimal  "amount",       precision: 12, scale: 2
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "status"
    t.index ["company_type", "company_id"], name: "index_invoices_on_company_type_and_company_id", using: :btree
  end

  create_table "line_managers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "employee_company_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["employee_company_id"], name: "index_line_managers_on_employee_company_id", using: :btree
  end

  create_table "logistics_companies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "pan"
    t.string   "tan"
    t.string   "business_type"
    t.string   "service_tax_no"
    t.string   "hq_address"
    t.text     "phone",          limit: 65535
  end

  create_table "notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "driver_id"
    t.integer  "employee_id"
    t.integer  "trip_id"
    t.string   "message"
    t.integer  "receiver"
    t.integer  "status"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.boolean  "resolved_status",                 default: true
    t.text     "call_sid",          limit: 65535
    t.boolean  "new_notification",                default: false
    t.integer  "sequence"
    t.string   "reporter"
    t.string   "remarks"
    t.integer  "employee_trip_id"
    t.integer  "driver_request_id"
    t.index ["driver_id"], name: "index_notifications_on_driver_id", using: :btree
    t.index ["driver_request_id"], name: "index_notifications_on_driver_request_id", using: :btree
    t.index ["employee_id"], name: "index_notifications_on_employee_id", using: :btree
    t.index ["employee_trip_id"], name: "index_notifications_on_employee_trip_id", using: :btree
    t.index ["trip_id"], name: "index_notifications_on_trip_id", using: :btree
  end

  create_table "operator_shift_managers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "logistics_company_id"
    t.string   "legal_name"
    t.string   "pan"
    t.string   "tan"
    t.string   "business_type"
    t.string   "service_tax_no"
    t.string   "hq_address"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "operators", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "logistics_company_id"
    t.string   "legal_name"
    t.string   "pan"
    t.string   "tan"
    t.string   "business_type"
    t.string   "service_tax_no"
    t.string   "hq_address"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["logistics_company_id"], name: "index_operators_on_logistics_company_id", using: :btree
  end

  create_table "package_rates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "vehicle_rate_id"
    t.string  "duration"
    t.decimal "package_duty_hours",          precision: 10, default: 0
    t.decimal "package_km",                  precision: 10, default: 0
    t.decimal "package_overage_per_km",      precision: 10, default: 0
    t.decimal "package_overage_per_time",    precision: 10, default: 0
    t.boolean "package_overage_time",                       default: false
    t.decimal "package_rate",                precision: 10, default: 0
    t.string  "package_mileage_calculation"
    t.index ["vehicle_rate_id"], name: "index_package_rates_on_vehicle_rate_id", using: :btree
  end

  create_table "services", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "site_id"
    t.string  "service_type"
    t.string  "billing_model"
    t.boolean "vary_with_vehicle",    default: false
    t.integer "logistics_company_id"
    t.index ["logistics_company_id"], name: "index_services_on_logistics_company_id", using: :btree
    t.index ["site_id"], name: "index_services_on_site_id", using: :btree
  end

  create_table "shift_times", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "shift_manager_id"
    t.integer  "site_id"
    t.integer  "shift_type"
    t.datetime "date"
    t.datetime "schedule_date"
    t.string   "type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "shift_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "shift_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shifts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name"
    t.string   "start_time"
    t.string   "end_time"
    t.string   "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sites", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.decimal  "latitude",                          precision: 10, scale: 6
    t.decimal  "longitude",                         precision: 10, scale: 6
    t.integer  "employee_company_id"
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.string   "address"
    t.text     "phone",               limit: 65535
    t.index ["employee_company_id"], name: "index_sites_on_employee_company_id", using: :btree
  end

  create_table "transport_desk_managers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "employee_company_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["employee_company_id"], name: "index_transport_desk_managers_on_employee_company_id", using: :btree
  end

  create_table "trip_change_requests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "request_type"
    t.integer  "reason"
    t.integer  "trip_type"
    t.string   "request_state"
    t.datetime "new_date"
    t.integer  "employee_id"
    t.integer  "employee_trip_id"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "shift",                          default: false
    t.boolean  "bus_rider",                      default: false
    t.text     "schedule_date",    limit: 65535
    t.index ["employee_id"], name: "index_trip_change_requests_on_employee_id", using: :btree
    t.index ["employee_trip_id"], name: "index_trip_change_requests_on_employee_trip_id", using: :btree
  end

  create_table "trip_invoices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "trip_id"
    t.integer "invoice_id"
    t.decimal "trip_amount",     precision: 10, default: 0
    t.decimal "trip_penalty",    precision: 10, default: 0
    t.decimal "trip_toll",       precision: 10, default: 0
    t.integer "vehicle_rate_id"
    t.integer "zone_rate_id"
    t.integer "vehicle_id"
    t.integer "package_rate_id"
    t.index ["invoice_id"], name: "index_trip_invoices_on_invoice_id", using: :btree
    t.index ["package_rate_id"], name: "index_trip_invoices_on_package_rate_id", using: :btree
    t.index ["trip_id"], name: "index_trip_invoices_on_trip_id", using: :btree
    t.index ["vehicle_id"], name: "index_trip_invoices_on_vehicle_id", using: :btree
    t.index ["vehicle_rate_id"], name: "index_trip_invoices_on_vehicle_rate_id", using: :btree
    t.index ["zone_rate_id"], name: "index_trip_invoices_on_zone_rate_id", using: :btree
  end

  create_table "trip_locations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "trip_id"
    t.text     "location",   limit: 65535
    t.datetime "time"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "distance"
    t.text     "speed",      limit: 65535
    t.index ["trip_id"], name: "index_trip_locations_on_trip_id", using: :btree
  end

  create_table "trip_route_exceptions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "trip_route_id"
    t.datetime "date"
    t.integer  "exception_type"
    t.string   "status"
    t.datetime "resolved_date"
  end

  create_table "trip_routes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "planned_duration"
    t.integer  "planned_distance"
    t.integer  "planned_route_order"
    t.text     "planned_start_location",           limit: 65535
    t.text     "planned_end_location",             limit: 65535
    t.integer  "employee_trip_id"
    t.integer  "trip_id"
    t.datetime "driver_arrived_date"
    t.datetime "on_board_date"
    t.datetime "completed_date"
    t.string   "status"
    t.integer  "scheduled_distance"
    t.integer  "scheduled_duration"
    t.integer  "scheduled_route_order"
    t.text     "scheduled_start_location",         limit: 65535
    t.text     "scheduled_end_location",           limit: 65535
    t.text     "driver_arrived_location",          limit: 65535
    t.text     "check_in_location",                limit: 65535
    t.text     "drop_off_location",                limit: 65535
    t.text     "missed_location",                  limit: 65535
    t.boolean  "cancel_exception",                               default: false
    t.text     "cab_type",                         limit: 65535
    t.integer  "cab_fare"
    t.text     "cab_driver_name",                  limit: 65535
    t.text     "cab_licence_number",               limit: 65535
    t.text     "cab_start_location",               limit: 65535
    t.text     "cab_end_location",                 limit: 65535
    t.boolean  "bus_rider",                                      default: false
    t.text     "bus_stop_name",                    limit: 65535
    t.text     "bus_stop_address",                 limit: 65535
    t.datetime "missed_date"
    t.datetime "geofence_driver_arrived_date"
    t.datetime "geofence_completed_date"
    t.text     "geofence_driver_arrived_location", limit: 65535
    t.text     "geofence_completed_location",      limit: 65535
    t.datetime "move_to_next_step_date"
    t.text     "move_to_next_step_location",       limit: 65535
    t.datetime "pick_up_time"
    t.datetime "drop_off_time"
    t.string   "exception_status"
    t.index ["employee_trip_id"], name: "index_trip_routes_on_employee_trip_id", using: :btree
    t.index ["trip_id"], name: "index_trip_routes_on_trip_id", using: :btree
  end

  create_table "trips", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "driver_id"
    t.string   "status"
    t.datetime "planned_date"
    t.datetime "created_at",                                                                      null: false
    t.datetime "updated_at",                                                                      null: false
    t.integer  "trip_type"
    t.integer  "planned_approximate_duration"
    t.datetime "start_date"
    t.datetime "assign_request_expired_date"
    t.integer  "planned_approximate_distance"
    t.integer  "vehicle_id"
    t.integer  "site_id"
    t.integer  "real_duration"
    t.datetime "completed_date"
    t.datetime "trip_accept_time"
    t.text     "start_location",                     limit: 65535
    t.integer  "scheduled_approximate_duration"
    t.integer  "scheduled_approximate_distance"
    t.datetime "scheduled_date"
    t.text     "cancel_status",                      limit: 65535
    t.boolean  "book_ola",                                                        default: false
    t.text     "ola_fare",                           limit: 65535
    t.boolean  "bus_rider",                                                       default: false
    t.decimal  "toll",                                             precision: 10, default: 0
    t.decimal  "penalty",                                          precision: 10, default: 0
    t.decimal  "amount",                                           precision: 10, default: 0
    t.boolean  "paid",                                                            default: false
    t.boolean  "is_manual",                                                       default: false
    t.integer  "employee_cluster_id"
    t.text     "trip_accept_location",               limit: 65535
    t.decimal  "ba_toll",                                          precision: 10, default: 0
    t.decimal  "ba_penalty",                                       precision: 10, default: 0
    t.decimal  "ba_amount",                                        precision: 10, default: 0
    t.boolean  "ba_paid",                                                         default: false
    t.integer  "actual_mileage",                                                  default: 0
    t.datetime "driver_should_start_trip_time"
    t.text     "driver_should_start_trip_location",  limit: 65535
    t.datetime "driver_should_start_trip_timestamp"
    t.datetime "trip_assign_date"
    t.boolean  "verified_driver_image",                                           default: false
    t.index ["driver_id"], name: "index_trips_on_driver_id", using: :btree
    t.index ["employee_cluster_id"], name: "index_trips_on_employee_cluster_id", using: :btree
    t.index ["scheduled_date"], name: "index_trips_on_scheduled_date", using: :btree
    t.index ["site_id"], name: "index_trips_on_site_id", using: :btree
    t.index ["status"], name: "index_trips_on_status", using: :btree
    t.index ["vehicle_id"], name: "index_trips_on_vehicle_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                                default: "",                    null: false
    t.string   "username"
    t.string   "f_name"
    t.string   "m_name"
    t.string   "l_name"
    t.integer  "role",                                 default: 0
    t.string   "entity_type"
    t.integer  "entity_id"
    t.string   "phone"
    t.string   "encrypted_password",                   default: "",                    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        default: 0,                     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
    t.text     "tokens",                 limit: 65535
    t.string   "provider",                             default: "email",               null: false
    t.string   "uid",                                  default: "",                    null: false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "last_active_time",                     default: '2009-01-01 00:00:00'
    t.integer  "status"
    t.string   "passcode"
    t.integer  "invite_count",                         default: 0
    t.text     "current_location",       limit: 65535
    t.string   "process_code"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["entity_type", "entity_id"], name: "index_users_on_entity_type_and_entity_id", using: :btree
    t.index ["phone"], name: "index_users_on_phone", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["uid"], name: "index_users_on_uid", using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

  create_table "vehicle_rates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "service_id"
    t.integer "vehicle_capacity"
    t.boolean "ac",                              default: true
    t.decimal "cgst",             precision: 10, default: 0
    t.decimal "sgst",             precision: 10, default: 0
    t.boolean "overage",                         default: false
    t.decimal "time_on_duty",     precision: 10, default: 0
    t.decimal "overage_per_hour", precision: 10, default: 0
    t.index ["service_id"], name: "index_vehicle_rates_on_service_id", using: :btree
  end

  create_table "vehicle_trip_invoices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "trip_id"
    t.integer "trip_invoice_id"
    t.integer "vehicle_id"
    t.integer "ba_trip_invoice_id"
    t.index ["ba_trip_invoice_id"], name: "index_vehicle_trip_invoices_on_ba_trip_invoice_id", using: :btree
    t.index ["trip_id"], name: "index_vehicle_trip_invoices_on_trip_id", using: :btree
    t.index ["trip_invoice_id"], name: "index_vehicle_trip_invoices_on_trip_invoice_id", using: :btree
    t.index ["vehicle_id"], name: "index_vehicle_trip_invoices_on_vehicle_id", using: :btree
  end

  create_table "vehicles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "driver_id"
    t.integer  "business_associate_id"
    t.string   "name"
    t.string   "plate_number"
    t.string   "make"
    t.string   "model"
    t.string   "colour"
    t.string   "driverid"
    t.string   "driver_name"
    t.string   "rc_book_no"
    t.date     "registration_date"
    t.date     "insurance_date"
    t.string   "permit_type"
    t.date     "permit_validity_date"
    t.date     "puc_validity_date"
    t.date     "fc_validity_date"
    t.boolean  "ac"
    t.integer  "seats",                                         default: 0
    t.string   "fuel_type"
    t.integer  "make_year",                                                  null: false, unsigned: true
    t.integer  "odometer",                                                                unsigned: true
    t.boolean  "spare_type"
    t.boolean  "first_aid_kit"
    t.string   "tyre_condition"
    t.string   "fuel_level"
    t.string   "plate_condition"
    t.integer  "device_id",                                                               unsigned: true
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.text     "status",                          limit: 65535
    t.date     "induction_date"
    t.integer  "sort_status",                                   default: -1
    t.integer  "active_checklist_id"
    t.text     "compliance_notification_message", limit: 65535
    t.text     "compliance_notification_type",    limit: 65535
    t.index ["business_associate_id"], name: "index_vehicles_on_business_associate_id", using: :btree
    t.index ["driver_id"], name: "index_vehicles_on_driver_id", using: :btree
    t.index ["plate_number"], name: "index_vehicles_on_plate_number", using: :btree
  end

  create_table "zone_rates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.decimal "rate",                          precision: 10, default: 0
    t.decimal "guard_rate",                    precision: 10, default: 0
    t.text    "name",            limit: 65535
    t.integer "vehicle_rate_id"
    t.index ["vehicle_rate_id"], name: "index_zone_rates_on_vehicle_rate_id", using: :btree
  end

  create_table "zones", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "name"
    t.decimal  "latitude",   precision: 10, scale: 6
    t.decimal  "longitude",  precision: 10, scale: 6
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "site_id"
    t.index ["site_id"], name: "index_zones_on_site_id", using: :btree
  end

  add_foreign_key "employee_trips", "employee_clusters"
  add_foreign_key "trip_change_requests", "employees"
  add_foreign_key "trip_routes", "employee_trips"
  add_foreign_key "trip_routes", "trips"
  add_foreign_key "trips", "employee_clusters"
end
