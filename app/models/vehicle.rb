class Vehicle < ApplicationRecord
  extend AdditionalFinders
  include AASM
  # include ComplianceNotificationConcern
  
  DATATABLE_PREFIX = 'vehicle'
  NOTIFICATION_FIELDS = {insurance_date: "Insurance", puc_validity_date: "PUC", permit_validity_date: "Permit", fc_validity_date: "FC"}

  STEP_VEHICLE = { Step_1: [:business_associate_id,:plate_number, :model, :category, :fuel_type, :colour, :seats, :ac], Step_2: [:insurance_date, :puc_validity_date, :authorization_certificate_validity_date, :fitness_validity_date, :road_tax_validity_date,:permit_validity_date ] }

  belongs_to :driver
  belongs_to :business_associate
  has_many :trips
  has_many :drivers_shifts
  has_many :cluster_vehicles
  has_many :checklists
  has_many :compliance_notifications

  has_attached_file :photo, styles: { medium: '300x300>', thumb: '100x100>' }, default_url: 'https://wsa1.pakwheels.com/assets/default-display-image-car-638815e7606c67291ff77fd17e1dbb16.png', s3_protocol: 'http'
  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\z/

  validates :business_associate_id, presence: true, :if => Proc.new{|f| f.registration_steps == "Step_1"}
  # validates :plate_number, presence: true, uniqueness: true, :if => Proc.new{|f| f.registration_steps == "Step_1"}
  validates :plate_number, format: { with: /[a-zA-Z0-9]/, message: " only alphanumeric." }, :if => Proc.new{|f| f.registration_steps == "Step_1"}
  validates_length_of :plate_number, minimum: 10, maximum: 12
  # validates :make, presence: true, :unless => Proc.new{|f| f.registration_steps.present? }
  validates :model, presence: true, :if => Proc.new{|f| f.registration_steps == "Step_1"}
  validates :colour, presence: true, :if => Proc.new{|f| f.registration_steps == "Step_1"}
  validates :category, presence: true, :if => Proc.new{|f| f.registration_steps == "Step_1"}
  validates :fuel_type, presence: true, :if => Proc.new{|f| f.registration_steps == "Step_1"}
  validates :seats, presence: true, :if => Proc.new{|f| f.registration_steps == "Step_1"}
  validates :ac, presence: true, :if => Proc.new{|f| f.registration_steps == "Step_1"}

  # validates :rc_book_no, presence: true , :if => Proc.new{|f| f.registration_steps != "Step_1" or f.registration_steps != "Step_2" }
  # validates :registration_date, presence: true , :if => Proc.new{|f| f.registration_steps != "Step_1" or f.registration_steps != "Step_2" }
  validates :insurance_date, presence: true, :if => Proc.new{|f| f.registration_steps == "Step_2"}
  validates :puc_validity_date, presence: true, :if => Proc.new{|f| f.registration_steps == "Step_2"}
  validates :authorization_certificate_validity_date, presence: true, :if => Proc.new{|f| f.registration_steps == "Step_2"}
  validates :fitness_validity_date, presence: true, :if => Proc.new{|f| f.registration_steps == "Step_2"}
  validates :road_tax_validity_date, presence: true, :if => Proc.new{|f| f.registration_steps == "Step_2"}
  # validates :permit_type, presence: true, :if => Proc.new{|f| f.registration_steps != "Step_1" or f.registration_steps != "Step_2" }
  validates :permit_validity_date, presence: true, :if => Proc.new{|f| f.registration_steps == "Step_2"}

  validates :seats, presence: true, :if => Proc.new{|f| f.registration_steps == "Step_1"}
  # validates :make_year, presence: true, unless: :first_registration_steps

  # validates :device_id, presence: true, :if => Proc.new{|f| f.registration_steps.blank?}

  ### Upload Docs ##
  has_attached_file :insurance_doc
   validates_attachment :insurance_doc, :content_type => {:content_type => %w(image/jpeg image/jpg image/png application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document)} , :if => Proc.new{|f| f.registration_steps == "Step_3"}

  has_attached_file :rc_book_doc
    validates_attachment :rc_book_doc, :content_type => {:content_type => %w(image/jpeg image/jpg image/png application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document)} , :if => Proc.new{|f| f.registration_steps == "Step_3"}

  has_attached_file :puc_doc
    validates_attachment :puc_doc, :content_type => {:content_type => %w(image/jpeg image/jpg image/png application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document)} , :if => Proc.new{|f| f.registration_steps == "Step_3"}

  has_attached_file :commercial_permit_doc
    validates_attachment :commercial_permit_doc, :content_type => {:content_type => %w(image/jpeg image/jpg image/png application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document)} , :if => Proc.new{|f| f.registration_steps == "Step_3"}

  has_attached_file :road_tax_doc
    validates_attachment :road_tax_doc, :content_type => {:content_type => %w(image/jpeg image/jpg image/png application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document)} , :if => Proc.new{|f| f.registration_steps == "Step_3"}



  after_update :update_notification

  after_create :create_new_checklist  

  after_update :update_vehicle_sort_status
  before_save :validate_insurance_expiry_date  , unless: :first_registration_steps
  before_save :validate_puc_expiry_date, unless: :first_registration_steps

  before_save :validate_commercial_expiry_date, unless: :first_registration_steps
  before_save :validate_road_tax_validity_date, unless: :first_registration_steps
  before_save :validate_fitness_validity_date, unless: :first_registration_steps
  before_save :validate_authorization_certificate_validity_date, unless: :first_registration_steps

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

  def first_registration_steps
    true if self.registration_steps.present? && self.registration_steps == "Step_1"
  end

  def last_registration_steps
    true if self.registration_steps.present? && self.registration_steps == "Step_2"
  end

  def validate_insurance_expiry_date
    if self.registration_steps.present? && (self.registration_steps == "Step_1" ||  self.registration_steps == "Step_2")
      if self.insurance_date.present? && Date.today > self.insurance_date 
          errors.add(:insurance_date, 'Your Licence has expired.')
      end
    end
  end

  def validate_puc_expiry_date
    if self.registration_steps.present? && self.registration_steps == "Step_2"
      if self.puc_validity_date.present? && Date.today > self.puc_validity_date 
          errors.add(:puc_validity_date, 'Your Puc expiry has expired.')
      end
    end  
  end

  def validate_commercial_expiry_date
    if self.registration_steps.present? && (self.registration_steps == "Step_1" ||  self.registration_steps == "Step_2")
      if self.permit_validity_date.present? && Date.today > self.permit_validity_date 
          errors.add(:permit_validity_date, 'Your validate commercial has expired.')
      end
    end
  end

  def validate_road_tax_validity_date
    if self.registration_steps.present? && (self.registration_steps == "Step_1" ||  self.registration_steps == "Step_2")
      if self.road_tax_validity_date.present? && Date.today > self.road_tax_validity_date 
          errors.add(:road_tax_validity_date, 'Your road tax date has expired.')
      end
    end
  end

  def validate_fitness_validity_date
    if self.registration_steps.present? && (self.registration_steps == "Step_1" ||  self.registration_steps == "Step_2")
      if self.fitness_validity_date.present? && Date.today > self.fitness_validity_date 
          errors.add(:fitness_validity_date, 'Your fitness validity date has expired.')
      end
    end
  end

  def validate_authorization_certificate_validity_date
    if self.authorization_certificate_validity_date.present? && Date.today > self.authorization_certificate_validity_date 
        errors.add(:authorization_certificate_validity_date, 'Your fitness validity date has expired.')
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
