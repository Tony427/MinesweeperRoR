module Errors
  class DomainError < StandardError
    def initialize(message = nil)
      super(message)
    end
  end
end