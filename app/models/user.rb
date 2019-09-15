class User < ApplicationRecord
  include AASM
  extend AdditionalFinders

  DATATABLE_PREFIX = 'user'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  unless ENV['PRECOMPILE'] == "true"
    include DeviseTokenAuth::Concerns::User
  end

  enum role: [:employee, :employer, :operator, :driver, :admin, :transport_desk_manager, :line_manager, :employer_shift_manager, :operator_shift_manager]
  enum status: [:pending, :on_boarded, :active]

  # @TODO: add proper default images: default_url: '/images/:style/user.png'
  has_attached_file :avatar, styles: { medium: '300x300>', thumb: '100x100>', large: '500x500>' }, default_url: "https://s3.ap-south-1.amazonaws.com/#{ENV['S3_BUCKET']}/DX_SQ.jpg", s3_protocol: 'http'
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  belongs_to :entity, polymorphic: true, :dependent => :destroy
  has_many :shift_users
  has_many :shifts, through: :shift_users

  accepts_nested_attributes_for :entity

  attr_accessor :skip_password_validation

  ransacker :full_name do |parent|
    Arel::Nodes::NamedFunction.new('CONCAT_WS', [
      Arel::Nodes.build_quoted(' '), parent.table[:f_name], parent.table[:m_name], parent.table[:l_name]
    ])
  end

  aasm :column => :role do
    state :employee, :initial => true
    state :employer
    state :operator
    state :driver
    state :admin
    state :transport_desk_manager
    state :line_manager    
    state :employer_shift_manager    
    state :operator_shift_manager    
  end

  # validates :username, presence: true, uniqueness: true
  # validates :email, presence: true, uniqueness: true , :if => Proc.new{|user| user.role == "driver" } 
  # validates :phone, presence: true, uniqueness: true
  # validates :f_name, presence: true
  # validates :l_name, presence: true
  validate :login_credentials_cannot_duplicate

  before_save :update_username
  before_create :set_status
  before_update :after_reset_password

  after_update :whitelist_number

  serialize :current_location, Hash

  def attributes=(attributes = {})
    self.entity_type = attributes[:entity_type]
    super
  end

  def entity_attributes=(attributes)
    entity_v = self.entity_type.constantize.find_or_initialize_by(:id=>attributes.delete(:entity_id))
    entity_v.attributes = attributes
    self.entity = entity_v
  end

  def generate_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    self.save
    raw
  end

  def save_with_notify
    if self.driver?
      # generated_password = self.entity.licence_number.last(6)
      # self.username = self.phone if self.username.blank?
      self.password = self.entity.licence_number.last(6)
    end

    # @TODO - refactoring: probably duplicated code with generate_reset_password_token method
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    self.username = self.email&.parameterize if self.username.blank?# && !self.driver?
    self.skip_password_validation = true unless self.driver?

    result = save
    result = self.update_attribute("f_name",self.f_name)
    if result
      UserNotifierMailer.user_create(self, raw).deliver_now! unless self.driver? || (self.employee? && self.entity.is_guard?)
      self.update_invite_count
      send_sms if self.driver? or self.employee?
    end
    result
  end

  def save_with_notify_for_driver
    if self.driver?
      generated_password = self.entity.licence_number.last(6) if self.entity.present? && self.entity.licence_number.present?
      self.username = self.phone if self.username.blank?
      self.password = self.entity.licence_number.last(6) if self.entity.present? && self.entity.licence_number.present?
    end
    # @TODO - refactoring: probably duplicated code with generate_reset_password_token method
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    self.skip_password_validation = true unless self.driver?
    # self.created_at = Time.now
    self.email = self.phone + '@gmail.com'  if self.phone.present?
    result = save
    # result = false
    if result
      # UserNotifierMailer.user_create(self, raw).deliver_now! unless self.driver? || (self.employee? && self.entity.is_guard?)
      self.update_invite_count
      # send_sms if self.driver? or self.employee?
    end
    result
  end

  def save_with_notify!
    save_with_notify
    save!
  end

  def send_sms
    SMSWorker.perform_async(phone, ENV['OPERATOR_NUMBER'], sms_message)
    SMSWorker.perform_async(phone, ENV['OPERATOR_NUMBER'], I18n.t("user.welcome_sms")) if employee?
  end

  # @TODO - refactoring: move to template
  def sms_message
    return I18n.t("user.guard_sms_notification", first_name: first_name, customer_name: customer_name) if employee? && entity.is_guard?
    app_link = employee? ? employee_link : Configurator.get('provider_app_android')
    return I18n.t("user.driver_sms_notification", full_name: first_name, link: app_link) if driver?
    I18n.t("user.sms_notification", full_name: full_name, link: app_link)
  end

  def employee_link
    "Android App - #{Configurator.get('rider_app_android')} iPhone App - #{Configurator.get('rider_app_ios')}"
  end

  # def entity_attributes
  #   self.attributes
  # end

  def role= role
    self.entity =
        case role
          when 0
            Employee.new
          when 1
            Employer.new
          when 2
            Operator.new
          when 3
            Driver.new
          when 5
            TransportDeskManager.new
          when 6
            LineManager.new                        
          when 7
            EmployerShiftManager.new                        
          when 8
            OperatorShiftManager.new                        
        end
    super
  end

  def entity= entity
    if self.entity && !new_record? && self.entity != entity
      raise 'You can not change existing user type!'
    else
      super
    end
  end

  def hashed_id
    Digest::MD5.hexdigest(self.id.to_s).to_s
  end

  def full_name
    self.f_name.to_s + ' ' + self.l_name.to_s
  end

  def first_name
    self.f_name.to_s
  end

  def customer_name
    self.entity.employee_company.name.to_s
  end

  # Get absolute url to profile picture (used for api calls)
  def full_avatar_url
    self.avatar.url
  end

  # Driver can access only drivers app through api, so do employee
  def has_access_to_app?(app_name)
    (app_name == 'driver' && self.driver?) || (app_name == 'employee' && self.employee?)
  end

  # Sign in through username or email or phone
  def self.find_for_database_authentication(conditions={})
    login = conditions[:username]
    find_by(username: login) || find_by(email: login)
  end

  def self.generate_random_password
    Devise.friendly_token.first(8)
  end

  def update_invite_count
    self.update_attributes({invite_count: self.invite_count.to_i + 1})
  end

  def update_status(status)
    return unless self.driver? || self.employee?
    self.update(status: status)
  end

  def whitelist_number
    params = {
      :VirtualNumber => ENV['EXOTEL_CALLER_ID'],
      :Number => self.phone
    }

    @response = HTTParty.post(URI.escape("https://#{ENV['EXOTEL_SID']}:#{ENV['EXOTEL_TOKEN']}@api.exotel.com/v1/Accounts/#{ENV['EXOTEL_SID']}/CustomerWhitelist"),
    {
      :query => params,
      :body => params
    })
  end

  protected
  # Validates if there should not be any duplicates in login fields
  def login_credentials_cannot_duplicate
    # define fields that should be unique
    # login_columns = [:username, :phone, :email]
    login_columns = [:phone, :email]
    values = []

    login_columns.each do |column|
      # compare current column with other N
      compare_columns = login_columns - [ column ]
      # save current value of this column for later comparasion
      values << self.try(column)

      # make where query and check if there are any columns with the same item in db
      where_clause = compare_columns.map{|col| "#{col} = '#{values.last}'"}.join(' OR ')
      errors.add('', 'email or phone has already been taken') if User.where(where_clause).exists?
    end

    # check if we're trying to save any
    values.reject!(&:blank?)
    if values.uniq.count != values.count
      message = "#{login_columns[0..-2].join(', ')} and #{login_columns[-1]} cannot be same"
      login_columns.each{ |col| errors.add(col, message) }
    end
  end

  def password_required?
    return false if skip_password_validation
    super
  end

  private

  def set_status
    self.status = 0 if ["employee", "driver", "line_manager", "transport_desk_manager", "operator"].include? self.role
  end

  def after_reset_password
    return unless self.driver? || self.employee? || self.line_manager? || self.transport_desk_manager? || self.employer_shift_manager? || self.operator?
    if encrypted_password_changed? && status == "pending"
      self.update(status: self.employee? ? 1 : 2)
    end
  end

  def update_username
    self.username = self.email.parameterize if self.changed.include?("email") && !self.driver?
  end
end
