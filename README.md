# Minesweeper Board Generator

A Ruby on Rails application that generates customizable minesweeper boards with visual display. Built according to the technical challenge requirements.

## Features

- **Custom Board Generation**: Specify width, height, and number of mines
- **Visual Display**: Clear visualization using ○ (empty) and ● (mine) symbols
- **Board Storage**: Persistent storage of generated boards with creator information
- **Recent Boards List**: Quick access to the 10 most recently generated boards
- **Complete Board Archive**: View all generated boards with statistics
- **Responsive Design**: Bootstrap 5 UI that works on all devices
- **Docker Deployment**: Containerized deployment with SQLite persistence

## Technical Stack

- **Backend**: Ruby on Rails 7.x
- **Frontend**: ERB Templates + Bootstrap 5
- **Database**: SQLite (development & production)
- **Deployment**: Docker Compose
- **Algorithm**: Custom O(n) mine placement using Array.sample

## Quick Start with Docker

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd MinesweeperRoR
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env file and set SECRET_KEY_BASE
   ```

3. **Build and run with Docker Compose**
   ```bash
   docker-compose up -d --build
   ```

4. **Access the application**
   - Open http://localhost:3000 in your browser
   - Start generating minesweeper boards!

## Development Setup

If you want to run the application locally without Docker:

1. **Install dependencies**
   ```bash
   bundle install
   ```

2. **Set up database**
   ```bash
   rails db:create
   rails db:migrate
   ```

3. **Start the server**
   ```bash
   rails server
   ```

## Usage

### Generating a Board

1. Visit the home page at `/`
2. Fill in the form with:
   - Your email address
   - Board name
   - Board width (1-50)
   - Board height (1-50)
   - Number of mines
3. Click "Generate Board"
4. View your generated board with visual mine placement

### Viewing Boards

- **Recent Boards**: The home page shows the 10 most recent boards
- **All Boards**: Click "view all generated boards" to see the complete list
- **Individual Boards**: Click any board name to view its details and visualization

## API Endpoints

- `GET /` - Home page with generation form and recent boards
- `POST /boards` - Generate a new board
- `GET /boards/:id` - View individual board details
- `GET /boards/all` - View all generated boards

## Board Generation Algorithm

The application uses a custom, performant algorithm for mine placement:

1. Creates a 2D array representing the board
2. Uses `Array.sample` to randomly select mine positions in O(n) time
3. Returns a JSON structure with mine placement data

This approach ensures excellent performance even for large boards while maintaining truly random mine distribution.

## Data Storage

Boards are stored in SQLite with the following information:
- Board name and creator email
- Dimensions (width × height)
- Mine count
- Complete board state as JSON
- Creation timestamp

The board state is stored as a 2D array where each cell contains:
```json
{ "mine": true/false }
```

## Docker Configuration

The application is containerized with:
- **Multi-stage build** for optimized image size
- **Volume mounting** for SQLite database persistence
- **Automatic migrations** on container startup
- **Asset precompilation** for production deployment
- **Health checks** for container monitoring

## Deployment

### Environment Variables

- `SECRET_KEY_BASE`: Rails secret key (required)
- `RAILS_ENV`: Environment (production/development)
- `RAILS_SERVE_STATIC_FILES`: Enable static file serving
- `RAILS_LOG_TO_STDOUT`: Enable stdout logging

### Data Persistence

The SQLite database is persisted using Docker volumes:
- Volume: `sqlite_data:/app/db`
- This ensures board data survives container restarts

### Backup

To backup your board data:
```bash
docker run --rm -v minesweeperror_sqlite_data:/data -v $(pwd):/backup alpine tar czf /backup/boards_backup.tar.gz -C /data .
```

## Testing

The application includes comprehensive testing for:
- ✅ Board generation algorithm accuracy
- ✅ Form validation and error handling
- ✅ Visual display correctness
- ✅ Database persistence
- ✅ Navigation and user flows
- ✅ Performance with large boards

Run tests with:
```bash
rails test
```

## Requirements Compliance

This application fully meets all requirements specified in `Requirement.md`:

- ✅ Custom minesweeper board generation
- ✅ Email and board name collection
- ✅ Visual board display with ○ and ● symbols
- ✅ Database storage of boards and creator info
- ✅ Recent boards listing (10 most recent)
- ✅ Complete boards archive
- ✅ Performant algorithm for any board size
- ✅ Custom algorithm (no external board generation gems)
- ✅ Bootstrap styling
- ✅ Deployment ready configuration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is created as a technical challenge demonstration.