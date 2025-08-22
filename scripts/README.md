# Development Environment Startup Scripts

## Usage

### Local Development Environment
```bash
scripts\local.bat
```
- Starts Rails server at `http://localhost:3001`
- Uses local Ruby environment
- Database: `db/development.sqlite3`
- **Note**: Requires MSYS2 development toolchain for native gem compilation

### Docker Development Environment  
```bash
scripts\docker.bat
```
- Starts Docker container at `http://localhost:3000`
- Uses containerized Ruby environment
- Database: Docker volume

## Prerequisites

### Local Environment
- Ruby 3.4.5+ installed
- Bundler gem installed
- **MSYS2 development toolchain** (for native gems like sqlite3, nio4r, etc.)
  - Install from: https://www.msys2.org/
  - Or run: `ridk install` (if using RubyInstaller)

### Docker Environment
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