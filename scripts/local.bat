@echo off
echo 🚀 Starting Local Rails Development Environment
echo =============================================
echo.

REM Check if Ruby is installed
ruby -v >nul 2>&1
if errorlevel 1 (
    echo ❌ Ruby not found! Please install Ruby first.
    echo Visit: https://rubyinstaller.org/
    pause
    exit /b 1
)

REM Check if bundle is available
bundle --version >nul 2>&1
if errorlevel 1 (
    echo 📦 Installing bundler...
    gem install bundler
)

REM Install dependencies if needed
if not exist "Gemfile.lock" (
    echo 📦 Installing gems...
    bundle install
)

REM Check if database exists
if not exist "db\development.sqlite3" (
    echo 🗄️ Setting up database...
    bundle exec rails db:create db:migrate db:seed
)

echo 🌟 Starting Rails server on http://localhost:3001
echo Press Ctrl+C to stop the server
echo.

bundle exec rails server -p 3001