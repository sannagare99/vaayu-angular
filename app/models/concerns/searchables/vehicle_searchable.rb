module Searchables
  class VehicleSearchable < Searchables::Searchable
    [:plate_number, :make, :model, :colour].each do |m_name|
      define_method("by_#{m_name}") do
        key = m_name.to_s << "_cont"
        { key.to_sym => @value }
      end
    end

    def by_seats
      { seats_eq: @value }
    end
  end
end