# Minesweeper Game

A simple Ruby on Rails app that creates minesweeper boards you can play in your browser.

## What it does

- Create custom minesweeper boards (set width, height, and mine count)
- Play the game by clicking cells to reveal or flag them
- View your recent games
- Responsive design that works on phones and computers

## Tech Stack

- **Ruby on Rails 7.1** - Web framework
- **Bootstrap 5** - CSS styling 
- **SQLite/PostgreSQL** - Database
- **Docker** - Easy deployment

## Quick Start

### Option 1: Using Docker (Easiest)

```bash
git clone <repository-url>
cd MinesweeperRoR
docker-compose up -d --build
```

Then open http://localhost:3000

### Option 2: Local Development

```bash
# Install Ruby gems
bundle install

# Set up database  
rails db:create
rails db:migrate

# Start the server
rails server
```

Then open http://localhost:3000

## How to Use

1. Go to the home page
2. Fill out the form:
   - Your email
   - Board name
   - Width and height (1-50 cells)
   - Number of mines
3. Click "Generate Board"
4. Play the game:
   - Left click to reveal cells
   - Right click to flag mines

## Project Structure

```
app/
├── controllers/     # Handle web requests
├── models/         # Database models (Board)
├── views/          # HTML templates
├── javascript/     # Frontend game logic
└── assets/         # CSS styles

config/             # Rails configuration
db/                 # Database files and migrations
```

## Learning Rails

This project is a good example of:
- **MVC Pattern**: Models, Views, Controllers
- **Database migrations**: `db/migrate/`
- **Routes**: `config/routes.rb`
- **Stimulus JS**: Frontend interactivity
- **Bootstrap**: Responsive styling

## License

This project is created for educational purposes.