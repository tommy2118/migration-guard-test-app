HealthCheck.setup do |config|
  # Text output upon success
  config.success = 'success'

  # Text output upon failure
  config.failure = 'health_check failed'

  # Disable standard checks
  config.standard_checks = %w[database migrations cache]

  # Add custom check
  config.add_custom_check('redis') do
    Redis.current.ping == 'PONG'
  end if defined?(Redis)
end
