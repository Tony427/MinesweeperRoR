# Minesweeper Board Generator - Technical Specification

## 1. Project Overview

This Ruby on Rails application generates customizable minesweeper boards with visual display capabilities. Built as a technical challenge demonstration, it showcases professional-grade architecture, performance optimization, and deployment readiness.

### Core Functional Requirements
- ✅ User input-driven board generation with custom parameters
- ✅ Database persistence (board name, email, board data)
- ✅ Visual board representation (○ empty cells, ● mines)
- ✅ Recent boards listing (10 most recent)
- ✅ Complete board archive with search capabilities
- ✅ Custom high-performance mine placement algorithm
- ✅ Docker Compose deployment configuration

## 2. Technical Architecture

### 2.1 Technology Stack
- **Backend Framework**: Ruby on Rails 7.x
- **Frontend Technology**: ERB Templates + Bootstrap 5
- **Database**: SQLite (development & production)
- **Deployment Method**: Docker Compose
- **Caching System**: Redis (optional)

### 2.2 Architectural Patterns
- **MVC Architecture**: Standard Rails Model-View-Controller pattern
- **Service Layer**: MinesweeperGenerator isolated service class
- **Data Serialization**: JSON format for 2D array storage

## 3. Database Design

### 3.1 Board Model
```ruby
# app/models/board.rb
class Board < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :width, presence: true, numericality: { greater_than: 0 }
  validates :height, presence: true, numericality: { greater_than: 0 }
  validates :mines_count, presence: true, numericality: { greater_than: 0 }
  validates :board_data, presence: true

  validate :mines_count_within_board_size

  scope :recent, -> { order(created_at: :desc) }
  scope :latest_ten, -> { recent.limit(10) }

  private

  def mines_count_within_board_size
    return unless width && height && mines_count
    max_mines = width * height - 1
    errors.add(:mines_count, "cannot exceed #{max_mines}") if mines_count > max_mines
  end
end
```

### 3.2 Database Schema
```sql
CREATE TABLE boards (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR NOT NULL,
  email VARCHAR NOT NULL,
  width INTEGER NOT NULL,
  height INTEGER NOT NULL,
  mines_count INTEGER NOT NULL,
  board_data TEXT NOT NULL,  -- JSON format 2D array
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);

CREATE INDEX index_boards_on_created_at ON boards (created_at);
CREATE INDEX index_boards_on_email ON boards (email);
```

## 4. Backend Specification

### 4.1 Routing Design
```ruby
# config/routes.rb
Rails.application.routes.draw do
  root 'boards#index'
  resources :boards, only: [:index, :show, :create] do
    collection do
      get :all
    end
  end
end
```

### 4.2 BoardsController
```ruby
# app/controllers/boards_controller.rb
class BoardsController < ApplicationController
  def index
    @board = Board.new
    @recent_boards = Board.latest_ten
  end

  def show
    @board = Board.find(params[:id])
  end

  def create
    @board = Board.new(board_params)
    
    if @board.valid?
      generator = MinesweeperGenerator.new(@board.width, @board.height, @board.mines_count)
      @board.board_data = generator.generate.to_json
      
      if @board.save
        redirect_to @board, notice: 'Board generated successfully!'
      else
        @recent_boards = Board.latest_ten
        render :index, status: :unprocessable_entity
      end
    else
      @recent_boards = Board.latest_ten
      render :index, status: :unprocessable_entity
    end
  end

  def all
    @boards = Board.recent
  end

  private

  def board_params
    params.require(:board).permit(:name, :email, :width, :height, :mines_count)
  end
end
```

### 4.3 MinesweeperGenerator Service
```ruby
# app/services/minesweeper_generator.rb
class MinesweeperGenerator
  def initialize(width, height, mines_count)
    @width = width
    @height = height
    @mines_count = mines_count
  end

  def generate
    # Initialize empty board
    board = Array.new(@height) { Array.new(@width) { { mine: false } } }
    
    # Use Array.sample for efficient mine placement (O(n))
    mine_positions = generate_mine_positions
    mine_positions.each do |row, col|
      board[row][col][:mine] = true
    end
    
    board
  end

  private

  def generate_mine_positions
    total_cells = @width * @height
    positions = (0...total_cells).to_a.sample(@mines_count)
    
    positions.map do |pos|
      [pos / @width, pos % @width]
    end
  end
end
```

## 5. Frontend Specification

### 5.1 Page Structure
1. **Home Page** (`boards#index`) - `/`
2. **Board Details** (`boards#show`) - `/boards/:id`
3. **All Boards** (`boards#all`) - `/boards`

### 5.2 Layout Template
```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <title>Minesweeper Board Generator</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <style>
      .board-grid {
        font-family: 'Courier New', monospace;
        line-height: 1;
      }
      
      .cell {
        width: 30px;
        height: 30px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 16px;
        font-weight: bold;
        border: 1px solid #ddd;
      }
      
      .cell.mine {
        background-color: #dc3545;
        color: white;
      }
      
      .cell.empty {
        background-color: #f8f9fa;
        color: #333;
      }
    </style>
  </head>

  <body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
      <div class="container">
        <%= link_to "Minesweeper Generator", root_path, class: "navbar-brand" %>
        
        <div class="navbar-nav">
          <%= link_to "Home", root_path, class: "nav-link" %>
          <%= link_to "All Boards", all_boards_path, class: "nav-link" %>
        </div>
      </div>
    </nav>
    
    <!-- Main Content -->
    <main class="container mt-4">
      <!-- Flash Messages -->
      <% flash.each do |type, message| %>
        <div class="alert alert-<%= type == 'notice' ? 'success' : 'danger' %> alert-dismissible fade show">
          <%= message %>
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
      <% end %>
      
      <%= yield %>
    </main>
    
    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
  </body>
</html>
```

### 5.3 Home Page Design
```erb
<!-- app/views/boards/index.html.erb -->
<div class="row">
  <div class="col-md-8">
    <h1>Minesweeper Board Generator</h1>
    <p class="text-muted">Generate custom minesweeper boards with your specifications</p>
    
    <%= form_with model: @board, local: true, class: "row g-3" do |form| %>
      <% if @board.errors.any? %>
        <div class="col-12">
          <div class="alert alert-danger">
            <strong>Please fix the following errors:</strong>
            <ul class="mb-0 mt-2">
              <% @board.errors.full_messages.each do |message| %>
                <li><%= message %></li>
              <% end %>
            </ul>
          </div>
        </div>
      <% end %>
      
      <div class="col-md-6">
        <%= form.label :email, class: "form-label" %>
        <%= form.email_field :email, class: "form-control", required: true, placeholder: "your.email@example.com" %>
      </div>
      
      <div class="col-md-6">
        <%= form.label :name, "Board Name", class: "form-label" %>
        <%= form.text_field :name, class: "form-control", required: true, placeholder: "My Minesweeper Board" %>
      </div>
      
      <div class="col-md-4">
        <%= form.label :width, "Board Width", class: "form-label" %>
        <%= form.number_field :width, class: "form-control", min: 1, max: 50, required: true, placeholder: "10" %>
      </div>
      
      <div class="col-md-4">
        <%= form.label :height, "Board Height", class: "form-label" %>
        <%= form.number_field :height, class: "form-control", min: 1, max: 50, required: true, placeholder: "10" %>
      </div>
      
      <div class="col-md-4">
        <%= form.label :mines_count, "Number of Mines", class: "form-label" %>
        <%= form.number_field :mines_count, class: "form-control", min: 1, required: true, placeholder: "10" %>
      </div>
      
      <div class="col-12">
        <%= form.submit "Generate Board", class: "btn btn-primary btn-lg" %>
      </div>
    <% end %>
  </div>
</div>

<hr class="my-5">

<section class="recent-boards">
  <h3>Recently Generated Boards</h3>
  
  <% if @recent_boards.any? %>
    <div class="list-group">
      <% @recent_boards.each do |board| %>
        <%= link_to board, class: "list-group-item list-group-item-action" do %>
          <div class="d-flex w-100 justify-content-between">
            <h5 class="mb-1"><%= board.name %></h5>
            <small><%= board.created_at.strftime("%B %d, %Y at %I:%M %p") %></small>
          </div>
          <p class="mb-1">Created by: <%= board.email %></p>
          <small>Dimensions: <%= board.width %>×<%= board.height %>, Mines: <%= board.mines_count %></small>
        <% end %>
      <% end %>
    </div>
    
    <div class="mt-3">
      <%= link_to "view all generated boards", all_boards_path, class: "btn btn-outline-secondary" %>
    </div>
  <% else %>
    <div class="alert alert-info">
      <strong>No boards generated yet.</strong> Create the first one using the form above!
    </div>
  <% end %>
</section>
```

### 5.4 Board Details Page
```erb
<!-- app/views/boards/show.html.erb -->
<div class="row">
  <div class="col-md-8">
    <h1><%= @board.name %></h1>
    <div class="mb-3">
      <p class="text-muted mb-1">Created by: <strong><%= @board.email %></strong></p>
      <p class="text-muted mb-1">Created at: <%= @board.created_at.strftime("%B %d, %Y at %I:%M %p") %></p>
      <p class="text-muted">Dimensions: <strong><%= @board.width %>×<%= @board.height %></strong>, Mines: <strong><%= @board.mines_count %></strong></p>
    </div>
  </div>
</div>

<div class="mt-4">
  <h4>Minesweeper Board</h4>
  <p class="text-muted">○ = Empty cell, ● = Mine</p>
  
  <div class="board-container" style="overflow-x: auto;">
    <div class="board-grid" style="
      display: grid;
      grid-template-columns: repeat(<%= @board.width %>, 30px);
      grid-template-rows: repeat(<%= @board.height %>, 30px);
      gap: 1px;
      background-color: #ccc;
      padding: 1px;
      width: fit-content;
      margin: 20px 0;
    ">
      <% JSON.parse(@board.board_data).each do |row| %>
        <% row.each do |cell| %>
          <div class="cell <%= cell['mine'] ? 'mine' : 'empty' %>">
            <%= cell['mine'] ? '●' : '○' %>
          </div>
        <% end %>
      <% end %>
    </div>
  </div>
  
  <div class="mt-3">
    <small class="text-muted">
      Total cells: <%= @board.width * @board.height %> | 
      Mine density: <%= ((@board.mines_count.to_f / (@board.width * @board.height)) * 100).round(1) %>%
    </small>
  </div>
</div>

<div class="mt-4">
  <%= link_to "Back to Home", root_path, class: "btn btn-secondary" %>
  <%= link_to "View All Boards", all_boards_path, class: "btn btn-outline-secondary" %>
  <%= link_to "Generate New Board", root_path, class: "btn btn-primary" %>
</div>
```

### 5.5 All Boards Page
```erb
<!-- app/views/boards/all.html.erb -->
<h1>All Generated Boards</h1>
<p class="text-muted">Complete list of all minesweeper boards generated in the system</p>

<% if @boards.any? %>
  <div class="table-responsive">
    <table class="table table-striped">
      <thead class="table-dark">
        <tr>
          <th>Board Name</th>
          <th>Creator Email</th>
          <th>Dimensions</th>
          <th>Mines</th>
          <th>Mine Density</th>
          <th>Created At</th>
        </tr>
      </thead>
      <tbody>
        <% @boards.each do |board| %>
          <tr>
            <td>
              <%= link_to board.name, board, class: "text-decoration-none" %>
            </td>
            <td><%= board.email %></td>
            <td><%= board.width %>×<%= board.height %></td>
            <td><%= board.mines_count %></td>
            <td>
              <%= ((board.mines_count.to_f / (board.width * board.height)) * 100).round(1) %>%
            </td>
            <td><%= board.created_at.strftime("%B %d, %Y") %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
  </div>
  
  <div class="mt-3">
    <p class="text-muted">Total boards generated: <strong><%= @boards.count %></strong></p>
  </div>
<% else %>
  <div class="alert alert-info">
    <h4 class="alert-heading">No boards found</h4>
    <p>No minesweeper boards have been generated yet.</p>
    <hr>
    <p class="mb-0">
      <%= link_to "Generate the first board", root_path, class: "btn btn-primary" %>
    </p>
  </div>
<% end %>

<div class="mt-4">
  <%= link_to "Back to Home", root_path, class: "btn btn-secondary" %>
  <% if @boards.any? %>
    <%= link_to "Generate New Board", root_path, class: "btn btn-primary" %>
  <% end %>
</div>
```

## 6. Docker Deployment Specification

### 6.1 Dockerfile
```dockerfile
FROM ruby:3.2-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    sqlite-dev \
    nodejs \
    yarn \
    tzdata

# Set working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config --global frozen 1 && \
    bundle install --without development test

# Copy application code
COPY . .

# Create database directory and set permissions
RUN mkdir -p /app/db && \
    chmod 755 /app/db

# Expose port
EXPOSE 3000

# Entry point script
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
```

### 6.2 docker-compose.yml
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - RAILS_ENV=production
      - SECRET_KEY_BASE=${SECRET_KEY_BASE:-default_secret_key_for_development}
      - RAILS_SERVE_STATIC_FILES=true
      - RAILS_LOG_TO_STDOUT=true
    volumes:
      - sqlite_data:/app/db
      - ./log:/app/log
    restart: unless-stopped

volumes:
  sqlite_data:
    driver: local
```

### 6.3 entrypoint.sh
```bash
#!/bin/sh
set -e

# Wait for database directory to be ready
until [ -d "/app/db" ]; do
  echo "Waiting for db directory..."
  sleep 1
done

# Set database permissions
chown -R $(whoami):$(whoami) /app/db || true

# Create and migrate database if it doesn't exist
if [ ! -f "/app/db/production.sqlite3" ]; then
  echo "Initializing database..."
  bundle exec rails db:create RAILS_ENV=production
  bundle exec rails db:migrate RAILS_ENV=production
else
  echo "Running migrations..."
  bundle exec rails db:migrate RAILS_ENV=production
fi

# Precompile assets
echo "Precompiling assets..."
bundle exec rails assets:precompile RAILS_ENV=production

# Start application
exec "$@"
```

## 7. Development Task List

### Phase 1: Rails Application Initialization
1. Initialize Rails 7 application
2. Configure Gemfile (SQLite, Bootstrap, etc.)
3. Set up basic routing

### Phase 2: Backend Development
1. Create Board model and migration
2. Implement MinesweeperGenerator service
3. Implement BoardsController
4. Add form validations

### Phase 3: Frontend Development
1. Set up application layout and Bootstrap
2. Implement boards/index view (home page)
3. Implement boards/show view (board details)
4. Implement boards/all view (all boards)
5. Add CSS styling

### Phase 4: Docker Configuration
1. Create Dockerfile
2. Set up docker-compose.yml
3. Configure entrypoint.sh
4. Environment variable configuration

### Phase 5: Testing and Optimization
1. Functional testing
2. Performance testing (large boards)
3. UI/UX testing
4. Docker deployment testing

## 8. Testing Plan

### 8.1 Functional Test Items
- [ ] Form validation (email format, numeric ranges, mine count limits)
- [ ] Board generation algorithm correctness
- [ ] Visual display correctness (○ ● symbol mapping)
- [ ] Database storage and retrieval
- [ ] Page navigation functionality
- [ ] Recent 10 boards display
- [ ] All boards list functionality

### 8.2 Performance Test Items
- [ ] Small board generation (10x10, 10 mines)
- [ ] Medium board generation (20x20, 50 mines)
- [ ] Large board generation (50x50, 500 mines)
- [ ] Page load speed
- [ ] Database query performance

### 8.3 Deployment Test Items
- [ ] Docker container builds successfully
- [ ] Database persistence verification
- [ ] Environment variable configuration correctness
- [ ] Application startup success
- [ ] All functionality works correctly in containers

## 9. Success Criteria

✅ Full compliance with all functional requirements  
✅ Custom mine generation algorithm without external gems  
✅ Clear ○ ● visual display  
✅ Responsive Bootstrap UI  
✅ SQLite data persistence  
✅ Docker Compose deployment ready  
✅ All test items passing  

---

**Implementation Notes**:
- This specification focuses on meeting requirements while avoiding over-engineering
- Algorithm uses Array.sample() to ensure O(n) performance
- Frontend uses standard Rails ERB + Bootstrap without complex JavaScript
- Docker configuration suitable for production environment deployment