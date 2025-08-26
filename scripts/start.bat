@echo off
setlocal enabledelayedexpansion

REM Cross-platform Rails development starter script for Windows

:print_header
echo 🎯 MinesweeperRoR Development Starter
echo ====================================
echo.
goto :eof

:print_usage
echo Usage: %~nx0 [local^|docker] [options]
echo.
echo Modes:
echo   local   Start local development server (default)
echo   docker  Start with Docker containers
echo.
echo Options:
echo   -p PORT     Set server port (default: 3001 for local, 3000 for docker)
echo   -h HOST     Set server host (default: 0.0.0.0)
echo   --help      Show this help message
echo.
echo Examples:
echo   %~nx0                  # Start local server on default port
echo   %~nx0 local -p 3002    # Start local server on port 3002
echo   %~nx0 docker           # Start with Docker
echo.
goto :eof

REM Default values
set MODE=local
set PORT=
set HOST=

REM Parse arguments
:parse_args
if "%~1"=="" goto :done_parsing
if "%~1"=="local" (
    set MODE=local
    shift
    goto :parse_args
)
if "%~1"=="docker" (
    set MODE=docker
    shift
    goto :parse_args
)
if "%~1"=="-p" (
    set PORT=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-h" (
    set HOST=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--help" (
    call :print_header
    call :print_usage
    exit /b 0
)
echo ❌ Unknown option: %~1
call :print_usage
exit /b 1

:done_parsing
call :print_header

REM Check if we're in the right directory
if not exist "Gemfile" (
    echo ❌ This doesn't appear to be a Rails application directory.
    echo Please run this script from the Rails app root directory.
    pause
    exit /b 1
)
if not exist "config.ru" (
    echo ❌ This doesn't appear to be a Rails application directory.
    echo Please run this script from the Rails app root directory.
    pause
    exit /b 1
)

echo 🚀 Starting in %MODE% mode...
echo.

REM Execute the appropriate script
if "%MODE%"=="local" (
    if exist "scripts\local.bat" (
        call scripts\local.bat
    ) else (
        echo ❌ scripts\local.bat not found
        pause
        exit /b 1
    )
) else if "%MODE%"=="docker" (
    if exist "scripts\docker.bat" (
        call scripts\docker.bat
    ) else (
        echo ❌ scripts\docker.bat not found
        pause
        exit /b 1
    )
) else (
    echo ❌ Invalid mode: %MODE%
    call :print_usage
    pause
    exit /b 1
)