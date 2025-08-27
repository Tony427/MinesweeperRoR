class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  def health
    # Basic health check - verify database connection and Redis if available
    checks = {
      status: 'ok',
      timestamp: Time.current.iso8601,
      version: Rails.application.class.module_parent_name.downcase,
      environment: Rails.env
    }
    
    begin
      # Check database connection
      ActiveRecord::Base.connection.execute('SELECT 1')
      checks[:database] = 'ok'
    rescue => e
      checks[:database] = 'error'
      checks[:database_error] = e.message
      checks[:status] = 'error'
    end
    
    begin
      # Check Redis connection if configured
      if defined?(Redis) && Rails.application.config.cache_store.is_a?(Array) && Rails.application.config.cache_store.first == :redis_cache_store
        Rails.cache.redis.ping
        checks[:redis] = 'ok'
      else
        checks[:redis] = 'not_configured'
      end
    rescue => e
      checks[:redis] = 'error'
      checks[:redis_error] = e.message
      checks[:status] = 'degraded' if checks[:status] == 'ok'
    end
    
    status_code = case checks[:status]
                  when 'ok' then 200
                  when 'degraded' then 200
                  when 'error' then 503
                  else 500
                  end
    
    render json: checks, status: status_code
  end
end