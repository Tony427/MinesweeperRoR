# Load all error classes at startup to prevent constant loading issues
require_relative '../../lib/errors/domain_error'
require_relative '../../lib/errors/validation_error'
require_relative '../../lib/errors/not_found_error'