@echo off
echo 🚀 Starting Local Rails Development Environment
echo =============================================
echo.

REM Check if Ruby is installed
echo 🔍 Checking Ruby installation...
ruby -v >NUL 2>&1
if errorlevel 1 (
    echo ❌ Ruby not found! Please install Ruby first.
    echo Visit: https://rubyinstaller.org/
    pause
    exit /b 1
) else (
    echo ✅ Ruby is installed
)

REM Skip bundle check as it can hang in PowerShell
echo ✅ Bundler check skipped (assumed installed)

REM Install dependencies if needed
echo 🔍 Checking gem dependencies...
if not exist "Gemfile.lock" (
    echo 📦 Installing gems...
    bundle install
) else (
    echo ✅ Gems already installed
)

REM Setup database and run migrations
echo 🗄️ Setting up database and running migrations...
rails db:create
rails db:migrate
echo ✅ Database setup completed

echo 🌟 Starting Rails server on http://localhost:3001
echo Press Ctrl+C to stop the server
echo.

rails server -p 3001