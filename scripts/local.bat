@echo off
setlocal enabledelayedexpansion

REM Configuration
set DEFAULT_PORT=3001
set DEFAULT_HOST=0.0.0.0
set RAILS_ENV=development

REM Allow environment variable overrides
if defined PORT (
    set SERVER_PORT=%PORT%
) else (
    set SERVER_PORT=%DEFAULT_PORT%
)

if defined HOST (
    set SERVER_HOST=%HOST%
) else (
    set SERVER_HOST=%DEFAULT_HOST%
)

echo 🚀 Starting Local Rails Development Environment
echo =============================================
echo Environment: %RAILS_ENV%
echo Server: http://%SERVER_HOST%:%SERVER_PORT%
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
    for /f "tokens=2" %%i in ('ruby -v') do echo ✅ Ruby %%i is installed
)

REM Check if Bundler is installed
echo 🔍 Checking Bundler installation...
bundle -v >NUL 2>&1
if errorlevel 1 (
    echo 📦 Installing Bundler...
    gem install bundler
    if errorlevel 1 (
        echo ❌ Failed to install Bundler
        pause
        exit /b 1
    )
) else (
    echo ✅ Bundler is installed
)

REM Install dependencies if needed
echo 🔍 Checking gem dependencies...
if not exist "Gemfile.lock" (
    echo 📦 Installing gems...
    bundle install --jobs 4
    if errorlevel 1 (
        echo ❌ Failed to install gems
        pause
        exit /b 1
    )
) else (
    echo 📦 Checking for gem updates...
    bundle check >NUL 2>&1
    if errorlevel 1 (
        echo 📦 Installing missing gems...
        bundle install --jobs 4
        if errorlevel 1 (
            echo ❌ Failed to install missing gems
            pause
            exit /b 1
        )
    ) else (
        echo ✅ All gems are installed and up to date
    )
)

REM Setup database and run migrations
echo 🗄️ Setting up database...
if not exist "db\development.sqlite3" (
    echo 📊 Creating database...
    rails db:create
    if errorlevel 1 (
        echo ❌ Failed to create database
        pause
        exit /b 1
    )
    echo ✅ Database created
)

echo 🔄 Running migrations...
rails db:migrate
if errorlevel 1 (
    echo ❌ Failed to run migrations
    pause
    exit /b 1
)
echo ✅ Database migrations completed

REM Check for pending migrations
rails db:migrate:status | findstr "down" >NUL 2>&1
if not errorlevel 1 (
    echo ⚠️ Warning: Some migrations might be pending
)

REM Clean up temporary files
echo 🧹 Cleaning up temporary files...
if exist "tmp\pids\server.pid" del "tmp\pids\server.pid"
if not exist "tmp\pids" mkdir "tmp\pids"

echo.
echo 🌟 Starting Rails server...
echo Server URL: http://%SERVER_HOST%:%SERVER_PORT%
echo Press Ctrl+C to stop the server
echo.

REM Start the Rails server with error handling
rails server -b %SERVER_HOST% -p %SERVER_PORT%
if errorlevel 1 (
    echo.
    echo ❌ Rails server failed to start
    echo Check the error messages above for details
    pause
    exit /b 1
)