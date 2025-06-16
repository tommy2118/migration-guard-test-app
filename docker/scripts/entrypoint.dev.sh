#!/bin/bash
set -e

# Ensure we're in development mode
export RAILS_ENV=development

# Remove potentially pre-existing server.pid
rm -f /app/tmp/pids/server.pid

# Create required directories
mkdir -p tmp/pids tmp/cache tmp/sockets

# Install missing gems
bundle check || bundle install --with development test

# Run database setup if needed
if ! RAILS_ENV=development bundle exec rails db:version &> /dev/null; then
  echo "Setting up database..."
  RAILS_ENV=development bundle exec rails db:create db:migrate db:seed
fi

# Execute the main command
exec "$@"
