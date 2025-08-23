module Errors
  class ValidationError < DomainError
    attr_reader :errors

    def initialize(errors = nil, message = 'Validation failed')
      @errors = errors
      super(message)
    end
  end
end