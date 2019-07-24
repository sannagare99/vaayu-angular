module Searchables
  class DriverSearchable < Searchables::Searchable
    [:local_address, :licence_number, :aadhaar_number, :badge_number].each do |m_name|
      define_method("by_#{m_name}") do
        key = m_name.to_s << "_cont"
        { key.to_sym => @value }
      end
    end

    def by_business_associate
      { business_associate_name_cont: @value }
    end
  end
end