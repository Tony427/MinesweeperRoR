@echo off
echo 🐳 Starting Docker Rails Development Environment
echo ============================================
echo.

REM Check if Docker is available
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker not found! Please install Docker Desktop.
    pause
    exit /b 1
)

REM Check if Docker Compose is available
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Compose not found! Please install Docker Compose.
    pause
    exit /b 1
)

echo 🔨 Building and starting Docker containers...
echo Server will be available at http://localhost:3000
echo Press Ctrl+C to stop the containers
echo.

docker-compose up --build