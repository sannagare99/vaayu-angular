class Vehicle < ApplicationRecord
  extend AdditionalFinders
  include AASM
  # include ComplianceNotificationConcern
  
  DATATABLE_PREFIX = 'vehicle'
  NOTIFICATION_FIELDS = {insurance_date: "Insurance", puc_validity_date: "PUC", permit_validity_date: "Permit", fc_validity_date: "FC"}

  belongs_to :driver
  belongs_to :business_associate
  has_many :trips
  has_many :drivers_shifts
  has_many :cluster_vehicles
  has_many :checklists
  has_many :compliance_notifications

  has_attached_file :photo, styles: { medium: '300x300>', thumb: '100x100>' }, default_url: 'https://wsa1.pakwheels.com/assets/default-display-image-car-638815e7606c67291ff77fd17e1dbb16.png', s3_protocol: 'http'
  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\z/

  validates :plate_number, presence: true, uniqueness: true
  validates :make, presence: true
  validates :model, presence: true
  validates :colour, presence: true

  validates :rc_book_no, presence: true
  validates :registration_date, presence: true
  validates :insurance_date, presence: true
  validates :permit_type, presence: true
  validates :permit_validity_date, presence: true

  validates :seats, presence: true
  validates :make_year, presence: true

  validates :device_id, presence: true

  after_update :update_notification

  after_create :create_new_checklist  

  after_update :update_vehicle_sort_status

  aasm column: :status do
    state :vehicle_ok, initial: true

    state :vehicle_broke_down
    state :vehicle_broke_down_pending

    state :vehicle_ok_pending

    event :vehicle_ok do
      transitions to: :vehicle_ok
    end

    event :vehicle_broke_down do
      transitions to: :vehicle_broke_down
    end

    event :vehicle_broke_down_pending do
      transitions to: :vehicle_broke_down_pending
    end

    event :vehicle_ok_pending do
      transitions to: :vehicle_ok_pending
    end
  end

  def self.create_notification
    configuration = {insurance_date: {field: "vehicle_insurance_expiry_date_notification_lead_time", flag: "show_vehicle_insurance_expiry_date_notification"}, puc_validity_date: {field: "vehicle_puc_expiry_date_notification_lead_time", flag: "show_vehicle_puc_expiry_date_notification"}, permit_validity_date: {field: "vehicle_permit_expiry_date_notification_lead_time", flag: "show_vehicle_permit_expiry_date_notification"}, fc_validity_date: {field: "vehicle_fc_expiry_date_notification_lead_time", flag: "show_vehicle_fc_expiry_date_notification"}}
    Vehicle.all.each do |vehicle|
      ComplianceNotification.create_provisioning_notification(configuration, vehicle)
    end
  end

  def self.create_checklist
    Vehicle.all.select("id").each { |v| Checklist.create_checklist(nil, v.id) }
  end  

  def update_notification
    configuration = {insurance_date: {field: "vehicle_insurance_expiry_date_notification_lead_time", flag: "show_vehicle_insurance_expiry_date_notification"}, puc_validity_date: {field: "vehicle_puc_expiry_date_notification_lead_time", flag: "show_vehicle_puc_expiry_date_notification"}, permit_validity_date: {field: "vehicle_permit_expiry_date_notification_lead_time", flag: "show_vehicle_permit_expiry_date_notification"}, fc_validity_date: {field: "vehicle_fc_expiry_date_notification_lead_time", flag: "show_vehicle_fc_expiry_date_notification"}}
    ComplianceNotification.create_provisioning_notification(configuration, self)
  end

  def create_new_checklist
    configuration = {insurance_date: {field: "vehicle_insurance_expiry_date_notification_lead_time", flag: "show_vehicle_insurance_expiry_date_notification"}, puc_validity_date: {field: "vehicle_puc_expiry_date_notification_lead_time", flag: "show_vehicle_puc_expiry_date_notification"}, permit_validity_date: {field: "vehicle_permit_expiry_date_notification_lead_time", flag: "show_vehicle_permit_expiry_date_notification"}, fc_validity_date: {field: "vehicle_fc_expiry_date_notification_lead_time", flag: "show_vehicle_fc_expiry_date_notification"}}
    Checklist.create_checklist(nil, self.id)
    ComplianceNotification.create_provisioning_notification(configuration, self)
  end

  def update_vehicle_sort_status
    status = -1

    notification = self.compliance_notifications.active.order(updated_at: :desc).first
    # This notification to be shown below any car broke down or leave notification

    if notification.present?
      notification.checklist? ? status = 1 : status = 2
    end

    case self.status
    when 'vehicle_ok_pending'
      status = 3
    when 'vehicle_broke_down_pending'
      status = 4
    when 'vehicle_broke_down'
      status = 0      
    end

    self.update_column('sort_status', status)    
  end
end
