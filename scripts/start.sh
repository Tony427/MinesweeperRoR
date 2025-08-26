#!/bin/bash
# Cross-platform Rails development starter script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}🎯 MinesweeperRoR Development Starter${NC}"
    echo -e "${BLUE}====================================${NC}"
    echo
}

print_usage() {
    echo "Usage: $0 [local|docker] [options]"
    echo
    echo "Modes:"
    echo "  local   Start local development server (default)"
    echo "  docker  Start with Docker containers"
    echo
    echo "Options:"
    echo "  -p, --port PORT     Set server port (default: 3001 for local, 3000 for docker)"
    echo "  -h, --host HOST     Set server host (default: 0.0.0.0)"
    echo "  --help              Show this help message"
    echo
    echo "Examples:"
    echo "  $0                  # Start local server on default port"
    echo "  $0 local -p 3002    # Start local server on port 3002"
    echo "  $0 docker           # Start with Docker"
    echo
}

# Default values
MODE="local"
PORT=""
HOST=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        local|docker)
            MODE="$1"
            shift
            ;;
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -h|--host)
            HOST="$2"
            shift 2
            ;;
        --help)
            print_header
            print_usage
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            print_usage
            exit 1
            ;;
    esac
done

print_header

# Check if we're in the right directory
if [ ! -f "Gemfile" ] || [ ! -f "config.ru" ]; then
    echo -e "${RED}❌ This doesn't appear to be a Rails application directory.${NC}"
    echo "Please run this script from the Rails app root directory."
    exit 1
fi

# Set environment variables if provided
[ -n "$PORT" ] && export PORT="$PORT"
[ -n "$HOST" ] && export HOST="$HOST"

echo -e "${GREEN}🚀 Starting in ${YELLOW}$MODE${GREEN} mode...${NC}"
echo

# Execute the appropriate script
case $MODE in
    local)
        if [ -f "scripts/local.sh" ]; then
            exec bash scripts/local.sh
        else
            echo -e "${RED}❌ scripts/local.sh not found${NC}"
            exit 1
        fi
        ;;
    docker)
        if [ -f "scripts/docker.sh" ]; then
            exec bash scripts/docker.sh
        else
            echo -e "${RED}❌ scripts/docker.sh not found${NC}"
            exit 1
        fi
        ;;
    *)
        echo -e "${RED}❌ Invalid mode: $MODE${NC}"
        print_usage
        exit 1
        ;;
esac