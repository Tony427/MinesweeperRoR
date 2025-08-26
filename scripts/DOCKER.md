# Docker Development Guide

This guide covers Docker-based development for the MinesweeperRoR application with cross-platform support.

## Quick Start

### Using Cross-platform Scripts
**Windows:**
```cmd
scripts\start.bat docker
```

**Unix-like (Linux/macOS):**
```bash
./scripts/start.sh docker
```

### Using Docker Compose Directly

#### Development Environment (Default)
```bash
# Start development services
docker-compose up --build

# Or run in background
docker-compose up -d --build

# View logs
docker-compose logs -f web
```

#### Production-like Environment
```bash
# Start with production configuration
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up --build
```

## Docker Configuration Files

### Development Setup
- `docker-compose.yml` - Base configuration with development defaults
- `docker-compose.override.yml` - Development-specific overrides (auto-loaded)
- `Dockerfile` - Multi-stage build with Ruby 3.4.5 Alpine Linux

### Production Setup  
- `docker-compose.prod.yml` - Production configuration with PostgreSQL
- Uses PostgreSQL instead of SQLite
- Includes production security settings and resource limits

### Optimization
- `.dockerignore` - Optimized to exclude development files from Docker context
- Multi-stage Dockerfile for smaller production images
- Health checks for all services

## Services

### Web Application (Rails)
- **Port:** 3000 (mapped to host:3000)
- **Environment:** Development by default
- **Database:** SQLite (development) or PostgreSQL (production)
- **Hot Reloading:** Enabled via volume mounts in development

### Redis (Cache/Sessions)
- **Port:** 6379 (mapped to host:6379)
- **Persistence:** Enabled with volume storage
- **Usage:** Optional for caching and background jobs

### PostgreSQL (Production)
- **Port:** 5432 (internal only)
- **Available in:** `docker-compose.prod.yml` only
- **Data:** Persisted via Docker volumes

## Environment Variables

### Development
The following environment variables are set automatically:
```bash
RAILS_ENV=development
SECRET_KEY_BASE=development_secret_key_base_change_in_production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=1
```

### Production
Set these environment variables for production:
```bash
RAILS_ENV=production
POSTGRES_DB=minesweeper_production
POSTGRES_USER=your_postgres_user
POSTGRES_PASSWORD=your_secure_password
REDIS_PASSWORD=your_redis_password
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=2
```

## Volume Mounts

### Development Volumes
- `./app:/app/app` - Hot reload for application code
- `./config:/app/config` - Hot reload for configuration
- `./lib:/app/lib` - Hot reload for libraries
- `sqlite_data:/app/db` - SQLite database persistence
- `./log:/app/log` - Application logs

### Production Volumes
- `postgres_data:/var/lib/postgresql/data` - PostgreSQL data
- `redis_data:/data` - Redis persistence
- `app_storage:/app/storage` - Rails Active Storage files
- `app_log:/app/log` - Application logs

## Common Commands

### Development Workflow
```bash
# Start all services
docker-compose up --build

# Stop all services
docker-compose down

# View application logs
docker-compose logs -f web

# Access Rails console
docker-compose exec web bundle exec rails console

# Run database migrations
docker-compose exec web bundle exec rails db:migrate

# Run tests
docker-compose exec web bundle exec rspec

# Access container shell
docker-compose exec web sh
```

### Database Management
```bash
# Reset database
docker-compose exec web bundle exec rails db:drop db:create db:migrate

# Load seed data
docker-compose exec web bundle exec rails db:seed

# Database console
docker-compose exec web bundle exec rails dbconsole
```

### Cleanup
```bash
# Remove containers and networks
docker-compose down

# Remove containers, networks, and volumes
docker-compose down -v

# Remove all unused Docker resources
docker system prune -a
```

## Troubleshooting

### Port Conflicts
If port 3000 or 6379 are already in use:
```bash
# Check what's using the port
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows

# Stop conflicting services or change port in docker-compose.yml
```

### Permission Issues (Linux/macOS)
```bash
# Fix file permissions
sudo chown -R $(id -u):$(id -g) .

# Or run Docker with user mapping
export UID=$(id -u)
export GID=$(id -g)
docker-compose up
```

### Database Connection Issues
```bash
# Check database container logs
docker-compose logs postgres

# Verify database is running
docker-compose exec postgres pg_isready -U postgres

# Reset database if corrupted
docker-compose down -v
docker-compose up --build
```

### Build Issues
```bash
# Force rebuild without cache
docker-compose build --no-cache

# Clean up build context
docker system prune -a
```

## Performance Optimization

### Development
- Uses volume mounts for hot reloading
- SQLite for faster local database operations
- Reduced resource limits for development

### Production
- Multi-stage Dockerfile reduces image size
- PostgreSQL for production-grade database
- Proper resource limits and health checks
- Asset precompilation included in startup

## Health Checks

All services include health checks:
- **Web:** HTTP request to `/health` endpoint
- **Redis:** Redis PING command
- **PostgreSQL:** `pg_isready` command

Monitor service health:
```bash
docker-compose ps
```

## Cross-Platform Compatibility

### Windows Development
- Use `scripts\start.bat docker` or `scripts\docker.bat`
- Docker Desktop required
- PowerShell or Command Prompt supported

### Unix-like Development (Linux/macOS)
- Use `./scripts/start.sh docker` or `./scripts/docker.sh`
- Docker and Docker Compose required
- Bash shell recommended

### Consistent Ruby Version
- All Docker images use Ruby 3.4.5
- Consistent behavior across development and production
- Alpine Linux base for smaller image size