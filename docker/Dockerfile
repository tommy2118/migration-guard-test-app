# syntax=docker/dockerfile:1
FROM migration-guard-test-app-base:latest AS base

# Production build stage
FROM base AS build

# Install production dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' &&     bundle install --jobs 4 --retry 3 &&     rm -rf ~/.bundle/cache

# Copy application code
COPY . .

# Precompile assets (skip if API only)
RUN bundle exec rails assets:precompile

# Final stage
FROM base

# Copy installed gems from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle

# Copy application from build stage
COPY --from=build /app /app

# Create non-root user
RUN useradd -m -u 1000 rails &&     chown -R rails:rails /app

USER rails

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3   CMD curl -f http://localhost:3000/health || exit 1

# Start server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
