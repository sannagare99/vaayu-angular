module ActiveModel
  class Errors
    def full_messages
      map { |attribute, message| full_message(change_attr(attribute), message) }
    end

    def json_messages
      errors = map do |attribute, message|
        {
            :name => change_attr(attribute, 'entity_attributes.'),
            :status =>  message.capitalize
        }
      end
      { :fieldErrors => errors, :data => [] }
    end

    private
    def change_attr(attr, value = '')
      attr.to_s.gsub('entity.', value).to_sym
    end
  end
end