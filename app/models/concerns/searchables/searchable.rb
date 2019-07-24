module Searchables
  class Searchable
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def by_name
      { user_full_name_cont: @value }
    end

    def by_email
      { user_email_cont: @value }
    end

    def by_phone
      { user_phone_cont: @value }
    end

    def by_username
      { user_username_cont: @value }
    end

    def method_missing(method, *args, &block)
      respond_to?(method) ? self[method] : {}
    end
  end
end
