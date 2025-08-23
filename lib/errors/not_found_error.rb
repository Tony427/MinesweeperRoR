module Errors
  class NotFoundError < DomainError
    def initialize(message = 'Resource not found')
      super(message)
    end
  end
end