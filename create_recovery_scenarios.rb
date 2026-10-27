# Create test scenarios for migration recovery

# Create an orphaned schema entry
begin
  ActiveRecord::Base.connection.execute("INSERT INTO schema_migrations (version) VALUES ('20250618999999')")
  puts "Created orphaned schema entry: 20250618999999"
rescue => e
  puts "Schema entry may already exist: #{e.message}"
end

# Update migration guard records to stuck state
count = MigrationGuard::MigrationGuardRecord.where(version: '20250617214330').update(status: 'rolling_back', updated_at: 2.hours.ago)
puts "Updated migration 20250617214330 to rolling_back state (2 hours ago): #{count} records"

count = MigrationGuard::MigrationGuardRecord.where(version: '20250618020646').update(status: 'rolling_back', updated_at: 10.minutes.ago)
puts "Updated migration 20250618020646 to rolling_back state (10 minutes ago): #{count} records"

# Create a partially completed migration record
begin
  MigrationGuard::MigrationGuardRecord.create!(
    version: '20250618888888',
    branch: 'feature/test-recovery',
    author: 'test@example.com',
    status: 'rolling_back',
    updated_at: 3.hours.ago
  )
  puts "Created stuck migration: 20250618888888"
rescue => e
  puts "Migration record may already exist: #{e.message}"
end

puts "\n=== Current Migration Issues ==="

puts "\nMigrations stuck in rollback:"
MigrationGuard::MigrationGuardRecord.where(status: 'rolling_back').each do |r|
  puts "  Version: #{r.version}, Updated: #{r.updated_at}"
end

puts "\nOrphaned schema entries (in schema but not tracked):"
schema_versions = ActiveRecord::Base.connection.select_values('SELECT version FROM schema_migrations')
tracked_versions = MigrationGuard::MigrationGuardRecord.pluck(:version)
orphaned = schema_versions - tracked_versions
orphaned.each { |v| puts "  Version: #{v}" }

puts "\nUsing stuck_in_rollback scope (> 1 hour):"
MigrationGuard::MigrationGuardRecord.stuck_in_rollback(1.hour).each do |r|
  puts "  Version: #{r.version}, Stuck for: #{((Time.now - r.updated_at) / 60).round} minutes"
end