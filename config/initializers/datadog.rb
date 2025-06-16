# Datadog APM configuration
# The ddtrace gem will auto-instrument Rails components by default
# For manual configuration, see: https://docs.datadoghq.com/tracing/setup_overview/setup/ruby/

if defined?(Datadog) && defined?(Rails::VERSION)
  # Set environment variables for Datadog:
  # DD_SERVICE - Service name (defaults to 'ruby')
  # DD_ENV - Environment (defaults to Rails.env)
  # DD_AGENT_HOST - Agent hostname (defaults to localhost)
  # DD_TRACE_AGENT_PORT - Agent port (defaults to 8126)
  
  # Basic configuration
  ENV['DD_SERVICE'] ||= 'migration-guard-test-app'
  ENV['DD_ENV'] ||= Rails.env.to_s
  
  # Disable startup logs in test
  ENV['DD_TRACE_STARTUP_LOGS'] = 'false' if Rails.env.test?
end
