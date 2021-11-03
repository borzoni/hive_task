module Base::InteractorValidation
  def self.extended(base)
    base.extend ClassMethods
    base.include InstanceMethods
  end

  module ClassMethods
    def contract(&block)
      if block_given?
        @contract = Dry::Validation.Contract(**{}, &block)
      end

      @contract
    end
  end

  module InstanceMethods
    def contract
      @contract ||= self.class.contract
    end

    def validate
      if contract.nil?
        @inputs = args
        @result = Success(@inputs)
        return @result 
      end

      res = contract.call(args.slice(*contract.schema.key_map.keys.map(&:id)))
      if res.success?
        @inputs = res.values
        @result = Success(@inputs)
      else
        errors!(res.errors)
      end
    end

    def errors!(new_errors)
      raise ArgumentError, 'Errors should be a hash' if new_errors.nil? || !new_errors.respond_to?(:to_h)

      new_errors.to_h.each do |key, value|
        errors[key] = errors.key?(key) ? [errors[key]].flatten(1) + [value].flatten(1) : value
      end
      @result = Failure(type: :validation, errors: errors)
    end

    def errors
      @errors ||= {}
    end

    def errors?
      errors.any?
    end
  end
end 