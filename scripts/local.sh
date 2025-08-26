#!/bin/bash
set -e

# Configuration
DEFAULT_PORT=3001
DEFAULT_HOST="0.0.0.0"
RAILS_ENV="development"

# Allow environment variable overrides
SERVER_PORT=${PORT:-$DEFAULT_PORT}
SERVER_HOST=${HOST:-$DEFAULT_HOST}

echo "🚀 Starting Local Rails Development Environment"
echo "============================================="
echo "Environment: $RAILS_ENV"
echo "Server: http://$SERVER_HOST:$SERVER_PORT"
echo

# Check if Ruby is installed
echo "🔍 Checking Ruby installation..."
if ! command -v ruby >/dev/null 2>&1; then
    echo "❌ Ruby not found! Please install Ruby first."
    echo "Visit: https://www.ruby-lang.org/en/downloads/"
    exit 1
else
    ruby_version=$(ruby -v | cut -d' ' -f2)
    echo "✅ Ruby $ruby_version is installed"
fi

# Check if Bundler is installed
echo "🔍 Checking Bundler installation..."
if ! command -v bundle >/dev/null 2>&1; then
    echo "📦 Installing Bundler..."
    gem install bundler
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install Bundler"
        exit 1
    fi
else
    echo "✅ Bundler is installed"
fi

# Install dependencies if needed
echo "🔍 Checking gem dependencies..."
if [ ! -f "Gemfile.lock" ]; then
    echo "📦 Installing gems..."
    bundle install --jobs 4
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install gems"
        exit 1
    fi
else
    echo "📦 Checking for gem updates..."
    if ! bundle check >/dev/null 2>&1; then
        echo "📦 Installing missing gems..."
        bundle install --jobs 4
        if [ $? -ne 0 ]; then
            echo "❌ Failed to install missing gems"
            exit 1
        fi
    else
        echo "✅ All gems are installed and up to date"
    fi
fi

# Setup database and run migrations
echo "🗄️ Setting up database..."
if [ ! -f "db/development.sqlite3" ]; then
    echo "📊 Creating database..."
    rails db:create
    if [ $? -ne 0 ]; then
        echo "❌ Failed to create database"
        exit 1
    fi
    echo "✅ Database created"
fi

echo "🔄 Running migrations..."
rails db:migrate
if [ $? -ne 0 ]; then
    echo "❌ Failed to run migrations"
    exit 1
fi
echo "✅ Database migrations completed"

# Check for pending migrations
if rails db:migrate:status | grep -q "down"; then
    echo "⚠️ Warning: Some migrations might be pending"
fi

# Clean up temporary files
echo "🧹 Cleaning up temporary files..."
[ -f "tmp/pids/server.pid" ] && rm "tmp/pids/server.pid"
[ ! -d "tmp/pids" ] && mkdir -p "tmp/pids"

echo
echo "🌟 Starting Rails server..."
echo "Server URL: http://$SERVER_HOST:$SERVER_PORT"
echo "Press Ctrl+C to stop the server"
echo

# Start the Rails server with error handling
rails server -b $SERVER_HOST -p $SERVER_PORT
if [ $? -ne 0 ]; then
    echo
    echo "❌ Rails server failed to start"
    echo "Check the error messages above for details"
    exit 1
fi