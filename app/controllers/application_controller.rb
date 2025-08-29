class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  def health
    # Basic health check - verify database and cache connections
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
    
    # Cache check (memory store)
    begin
      Rails.cache.write('health_check', 'ok', expires_in: 1.second)
      health_value = Rails.cache.read('health_check')
      checks[:cache] = health_value == 'ok' ? 'ok' : 'error'
    rescue => e
      checks[:cache] = 'error'  
      checks[:cache_error] = e.message
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