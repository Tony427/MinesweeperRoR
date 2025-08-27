#!/bin/bash
set -e

echo "🐳 Starting Docker Rails Development Environment"
echo "============================================"
echo

# Check if Docker is available
if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Docker not found! Please install Docker."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
    echo "❌ Docker Compose not found! Please install Docker Compose."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "🔨 Building and starting Docker containers..."
echo "Server will be available at http://localhost:3000"
echo "Press Ctrl+C to stop the containers"
echo

# Use docker compose if available (newer version), otherwise fallback to docker-compose
if docker compose version >/dev/null 2>&1; then
    docker compose up --build
else
    docker-compose up --build
fi