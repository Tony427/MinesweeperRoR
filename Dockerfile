FROM ruby:3.4.5-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    sqlite-dev \
    nodejs \
    yarn \
    tzdata \
    yaml-dev \
    zlib-dev

# Set working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile ./
RUN bundle lock --add-platform x86_64-linux-musl
RUN bundle install

# Copy application code
COPY . .

# Create database directory, set permissions and generate Rails binstubs
RUN mkdir -p /app/db /app/tmp/pids && \
    chmod 755 /app/db && \
    bundle exec rake app:update:bin || true

# Expose port
EXPOSE 3000

# Start command
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]