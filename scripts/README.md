# Development Environment Startup Scripts

Cross-platform development scripts for Windows and Unix-like systems (Linux/macOS).

## Quick Start

### Universal Starter (Recommended)
**Windows:**
```cmd
scripts\start.bat [local|docker] [options]
```

**Unix-like (Linux/macOS):**
```bash
./scripts/start.sh [local|docker] [options]
```

**Examples:**
```bash
# Start local development server (default)
scripts\start.bat              # Windows
./scripts/start.sh             # Unix

# Start local server on custom port
scripts\start.bat local -p 3002
./scripts/start.sh local -p 3002

# Start with Docker
scripts\start.bat docker
./scripts/start.sh docker
```

## Platform-Specific Scripts

### Local Development Environment

**Windows:**
```cmd
scripts\local.bat
```

**Unix-like (Linux/macOS):**
```bash
./scripts/local.sh
```

- Starts Rails server at `http://localhost:3001`
- Uses local Ruby environment
- Database: `db/development.sqlite3`

### Docker Development Environment

**Windows:**
```cmd
scripts\docker.bat
```

**Unix-like (Linux/macOS):**
```bash
./scripts/docker.sh
```

- Starts Docker container at `http://localhost:3000`
- Uses containerized Ruby environment
- Database: Docker volume

## Prerequisites

### Local Environment

**All Platforms:**
- Ruby 3.4.5+ installed
- Bundler gem installed

**Windows-specific:**
- **MSYS2 development toolchain** (for native gems like sqlite3, nio4r, etc.)
  - Install from: https://www.msys2.org/
  - Or run: `ridk install` (if using RubyInstaller)

**Unix-like systems:**
- Build tools: `gcc`, `make`, `pkg-config`
- SQLite development headers
  - Ubuntu/Debian: `sudo apt-get install build-essential libsqlite3-dev`
  - macOS: Install Xcode Command Line Tools: `xcode-select --install`
  - CentOS/RHEL: `sudo yum groupinstall "Development Tools" && sudo yum install sqlite-devel`

### Docker Environment

**All Platforms:**
- Docker Desktop installed and running
- Docker Compose available

## Running Simultaneously
Both environments can run simultaneously on different ports:
- Local: http://localhost:3001
- Docker: http://localhost:3000

## Installation Guide for Local Environment

If you encounter native gem compilation errors, follow these steps:

1. **Install MSYS2 Toolchain**:
   ```bash
   ridk install
   ```
   Select option [3] to install the full development toolchain.

2. **Install Dependencies**:
   ```bash
   bundle install
   ```

3. **Setup Database**:
   ```bash
   bundle exec rails db:create db:migrate db:seed
   ```

4. **Start Server**:
   ```bash
   scripts\local.bat
   ```