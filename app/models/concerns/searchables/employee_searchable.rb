module Searchables
  class EmployeeSearchable < Searchables::Searchable
    [:home_address, :employee_id].each do |m_name|
      define_method("by_#{m_name}") do
        key = m_name.to_s << "_cont"
        { key.to_sym => @value }
      end
    end

    def by_gender
      value = ""
      value = 0 if @value.downcase == "female"
      value = 1 if @value.downcase == "male"
      { gender_eq: value }
    end

    def by_zone
      { zone_name_cont: @value }
    end

    def by_line_manager
      { line_manager_user_name_cont: @value }
    end
  end
end
