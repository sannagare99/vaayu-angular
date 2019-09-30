class MllComplianceUser < ApplicationRecord
    extend AdditionalFinders
    include UserData

    DATATABLE_PREFIX = 'mll_audit_user'

    has_one :user, :as => :entity, :dependent => :destroy
    belongs_to :employee_company

    validates :employee_company, presence: true
end
