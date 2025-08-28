# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `worker_timeout` threshold that Puma will use to wait before
# terminating a worker in development environments.
#
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
# Enable clustering in production environment
if ENV.fetch("RAILS_ENV") { "development" } != "development"
  workers ENV.fetch("WEB_CONCURRENCY") { 2 }
  
  # Use the `preload_app!` method when specifying a `workers` number.
  # This directive tells Puma to first boot the application and load code
  # before forking the application. This takes advantage of Copy On Write
  # process behavior so workers use less memory.
  preload_app!
  
  # Worker configuration for production
  worker_boot_timeout 60
  worker_shutdown_timeout 30
  
  # Redirect worker stdout/stderr to log files in production
  stdout_redirect 'log/puma_access.log', 'log/puma_error.log', true if ENV.fetch("RAILS_ENV") { "development" } == "production"
else
  # Single worker in development for easier debugging
  workers 0
end

# Configure queue requests for better throughput
queue_requests true

# Backlog option is no longer supported in newer Puma versions

# Bind configuration - allow binding to specific interface
bind_to = ENV.fetch("PUMA_BIND") { "tcp://0.0.0.0:#{ENV.fetch('PORT') { 3000 }}" }
bind bind_to unless bind_to == "tcp://0.0.0.0:#{ENV.fetch('PORT') { 3000 }}"

# Performance tuning
nakayoshi_fork if respond_to?(:nakayoshi_fork) && ENV.fetch("RAILS_ENV") { "development" } != "development"

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Health check endpoint plugin not available