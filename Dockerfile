# Build stage
FROM ruby:3.4.5-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    sqlite-dev \
    nodejs \
    yarn \
    tzdata \
    yaml-dev \
    zlib-dev \
    git

# Set working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile* ./
RUN bundle lock --add-platform x86_64-linux-musl
RUN bundle config --global frozen 1 && \
    bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Generate Rails binstubs
RUN bundle exec rake app:update:bin || true

# Runtime stage
FROM ruby:3.4.5-alpine AS runtime

# Install runtime dependencies only
RUN apk add --no-cache \
    sqlite \
    tzdata \
    nodejs \
    && rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1001 -S rails && \
    adduser -S rails -u 1001 -G rails

# Set working directory
WORKDIR /app

# Copy gems from builder stage
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy application code with proper ownership
COPY --from=builder --chown=rails:rails /app /app

# Create necessary directories with proper permissions
RUN mkdir -p /app/db /app/tmp/pids /app/log && \
    chown -R rails:rails /app/db /app/tmp /app/log && \
    chmod 755 /app/db

# Switch to non-root user
USER rails

# Expose port
EXPOSE 3000

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Start command
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]