# Minesweeper Board Generator - Technical Specification

## 1. 專案概述

基於 `Requirement.md` 的需求，本專案開發一個 Ruby on Rails 應用程式，用於生成 Minesweeper 板子並提供視覺化展示。

### 核心功能需求
- ✅ 用戶輸入參數生成 Minesweeper 板子
- ✅ 儲存板子到資料庫（名稱、email、板子資料）
- ✅ 展示板子視覺化（○ 空格，● 地雷）
- ✅ 顯示最近 10 個板子列表
- ✅ 查看所有板子頁面
- ✅ 自製板子生成演算法（高效能）
- ✅ Docker Compose 部署

## 2. 技術架構

### 2.1 技術選型
- **後端框架**：Ruby on Rails 7.x
- **前端技術**：ERB Templates + Bootstrap 5
- **資料庫**：SQLite（開發 + 生產環境）
- **部署方式**：Docker Compose
- **快取系統**：Redis（選用）

### 2.2 架構模式
- **MVC 架構**：標準 Rails MVC 模式
- **服務層**：MinesweeperGenerator 獨立服務類
- **資料序列化**：JSON 格式儲存 2D 陣列

## 3. 資料庫設計

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

### 3.2 資料庫表結構
```sql
CREATE TABLE boards (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR NOT NULL,
  email VARCHAR NOT NULL,
  width INTEGER NOT NULL,
  height INTEGER NOT NULL,
  mines_count INTEGER NOT NULL,
  board_data TEXT NOT NULL,  -- JSON 格式的 2D 陣列
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);

CREATE INDEX index_boards_on_created_at ON boards (created_at);
CREATE INDEX index_boards_on_email ON boards (email);
```

## 4. 後端規格

### 4.1 路由設計
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
        redirect_to @board
      else
        @recent_boards = Board.latest_ten
        render :index
      end
    else
      @recent_boards = Board.latest_ten
      render :index
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

### 4.3 MinesweeperGenerator 服務
```ruby
# app/services/minesweeper_generator.rb
class MinesweeperGenerator
  def initialize(width, height, mines_count)
    @width = width
    @height = height
    @mines_count = mines_count
  end

  def generate
    # 初始化空板子
    board = Array.new(@height) { Array.new(@width) { { mine: false } } }
    
    # 使用 Array.sample 高效放置地雷 (O(n))
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

## 5. 前端規格

### 5.1 頁面結構
1. **首頁** (`boards#index`) - `/`
2. **板子詳情** (`boards#show`) - `/boards/:id`
3. **所有板子** (`boards#all`) - `/boards`

### 5.2 Layout Template
```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <title>Minesweeper Generator</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
  </head>

  <body>
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
      <div class="container">
        <a class="navbar-brand" href="/">Minesweeper Generator</a>
        
        <div class="navbar-nav">
          <a class="nav-link" href="/">Home</a>
          <a class="nav-link" href="/boards">All Boards</a>
        </div>
      </div>
    </nav>
    
    <main class="container mt-4">
      <% flash.each do |type, message| %>
        <div class="alert alert-<%= type == 'notice' ? 'success' : 'danger' %> alert-dismissible fade show">
          <%= message %>
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
      <% end %>
      
      <%= yield %>
    </main>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <%= javascript_importmap_tags %>
  </body>
</html>
```

### 5.3 首頁設計
```erb
<!-- app/views/boards/index.html.erb -->
<div class="row">
  <div class="col-md-8">
    <h1>Minesweeper Board Generator</h1>
    
    <%= form_with model: @board, local: true, class: "row g-3" do |form| %>
      <% if @board.errors.any? %>
        <div class="col-12">
          <div class="alert alert-danger">
            <ul class="mb-0">
              <% @board.errors.full_messages.each do |message| %>
                <li><%= message %></li>
              <% end %>
            </ul>
          </div>
        </div>
      <% end %>
      
      <div class="col-md-6">
        <%= form.label :email, class: "form-label" %>
        <%= form.email_field :email, class: "form-control", required: true %>
      </div>
      
      <div class="col-md-6">
        <%= form.label :name, "Board Name", class: "form-label" %>
        <%= form.text_field :name, class: "form-control", required: true %>
      </div>
      
      <div class="col-md-4">
        <%= form.label :width, "Board Width", class: "form-label" %>
        <%= form.number_field :width, class: "form-control", min: 1, required: true %>
      </div>
      
      <div class="col-md-4">
        <%= form.label :height, "Board Height", class: "form-label" %>
        <%= form.number_field :height, class: "form-control", min: 1, required: true %>
      </div>
      
      <div class="col-md-4">
        <%= form.label :mines_count, "Number of Mines", class: "form-label" %>
        <%= form.number_field :mines_count, class: "form-control", min: 1, required: true %>
      </div>
      
      <div class="col-12">
        <%= form.submit "Generate Board", class: "btn btn-primary" %>
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
          <small>Dimensions: <%= board.width %>x<%= board.height %>, Mines: <%= board.mines_count %></small>
        <% end %>
      <% end %>
    </div>
    
    <div class="mt-3">
      <%= link_to "view all generated boards", all_boards_path, class: "btn btn-outline-secondary" %>
    </div>
  <% else %>
    <p class="text-muted">No boards generated yet. Create the first one above!</p>
  <% end %>
</section>
```

### 5.4 板子詳情頁
```erb
<!-- app/views/boards/show.html.erb -->
<div class="row">
  <div class="col-md-8">
    <h1><%= @board.name %></h1>
    <p class="text-muted">Created by: <%= @board.email %></p>
    <p class="text-muted">Created at: <%= @board.created_at.strftime("%B %d, %Y at %I:%M %p") %></p>
    <p class="text-muted">Dimensions: <%= @board.width %>x<%= @board.height %>, Mines: <%= @board.mines_count %></p>
  </div>
</div>

<div class="mt-4">
  <h4>Minesweeper Board</h4>
  
  <div class="board-container" style="overflow-x: auto;">
    <div class="board-grid" style="
      display: grid;
      grid-template-columns: repeat(<%= @board.width %>, 30px);
      grid-template-rows: repeat(<%= @board.height %>, 30px);
      gap: 1px;
      background-color: #ccc;
      padding: 1px;
      width: fit-content;
      font-family: monospace;
    ">
      <% JSON.parse(@board.board_data).each do |row| %>
        <% row.each do |cell| %>
          <div class="cell" style="
            width: 30px;
            height: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: <%= cell['mine'] ? '#dc3545' : '#f8f9fa' %>;
            color: <%= cell['mine'] ? 'white' : '#333' %>;
            font-size: 16px;
            font-weight: bold;
          ">
            <%= cell['mine'] ? '●' : '○' %>
          </div>
        <% end %>
      <% end %>
    </div>
  </div>
</div>

<div class="mt-4">
  <%= link_to "Back to Home", root_path, class: "btn btn-secondary" %>
  <%= link_to "View All Boards", all_boards_path, class: "btn btn-outline-secondary" %>
</div>
```

### 5.5 所有板子頁面
```erb
<!-- app/views/boards/all.html.erb -->
<h1>All Generated Boards</h1>

<% if @boards.any? %>
  <div class="table-responsive">
    <table class="table table-striped">
      <thead>
        <tr>
          <th>Board Name</th>
          <th>Creator Email</th>
          <th>Dimensions</th>
          <th>Mines</th>
          <th>Created At</th>
        </tr>
      </thead>
      <tbody>
        <% @boards.each do |board| %>
          <tr>
            <td><%= link_to board.name, board %></td>
            <td><%= board.email %></td>
            <td><%= board.width %>x<%= board.height %></td>
            <td><%= board.mines_count %></td>
            <td><%= board.created_at.strftime("%B %d, %Y") %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
  </div>
<% else %>
  <p class="text-muted">No boards have been generated yet.</p>
  <%= link_to "Generate First Board", root_path, class: "btn btn-primary" %>
<% end %>

<div class="mt-3">
  <%= link_to "Back to Home", root_path, class: "btn btn-secondary" %>
</div>
```

## 6. Docker 部署規格

### 6.1 Dockerfile
```dockerfile
FROM ruby:3.2-alpine

# 安裝系統依賴
RUN apk add --no-cache \
    build-base \
    sqlite-dev \
    nodejs \
    yarn \
    tzdata

# 設置工作目錄
WORKDIR /app

# 複製 Gemfile 並安裝 gems
COPY Gemfile Gemfile.lock ./
RUN bundle config --global frozen 1 && \
    bundle install --without development test

# 複製應用程式碼
COPY . .

# 編譯 assets
RUN RAILS_ENV=production bundle exec rails assets:precompile

# 創建資料庫目錄並設置權限
RUN mkdir -p /app/db && \
    chmod 755 /app/db

# 暴露端口
EXPOSE 3000

# 啟動腳本
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
      - SECRET_KEY_BASE=${SECRET_KEY_BASE}
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

# 等待資料庫目錄準備就緒
until [ -d "/app/db" ]; do
  echo "Waiting for db directory..."
  sleep 1
done

# 設置資料庫權限
chown -R $(whoami):$(whoami) /app/db || true

# 如果資料庫不存在，則創建並遷移
if [ ! -f "/app/db/production.sqlite3" ]; then
  echo "Initializing database..."
  bundle exec rails db:create RAILS_ENV=production
  bundle exec rails db:migrate RAILS_ENV=production
else
  echo "Running migrations..."
  bundle exec rails db:migrate RAILS_ENV=production
fi

# 啟動應用
exec "$@"
```

## 7. 開發任務清單

### Phase 1: Rails 應用初始化
1. 初始化 Rails 7 應用
2. 配置 Gemfile（SQLite, Bootstrap, 等）
3. 設置基本路由

### Phase 2: 後端開發
1. 創建 Board model 和 migration
2. 實作 MinesweeperGenerator 服務
3. 實作 BoardsController
4. 添加表單驗證

### Phase 3: 前端開發
1. 設置 application layout 和 Bootstrap
2. 實作 boards/index view（首頁）
3. 實作 boards/show view（板子詳情）
4. 實作 boards/all view（所有板子）
5. 添加 CSS 樣式

### Phase 4: Docker 配置
1. 創建 Dockerfile
2. 設置 docker-compose.yml
3. 配置 entrypoint.sh
4. 環境變數配置

### Phase 5: 測試和優化
1. 功能測試
2. 效能測試（大型板子）
3. UI/UX 測試
4. Docker 部署測試

## 8. 測試計畫

### 8.1 功能測試項目
- [ ] 表單驗證（email 格式、數字範圍、地雷數量限制）
- [ ] 板子生成演算法正確性
- [ ] 視覺化展示正確性（○ ● 符號對應）
- [ ] 資料庫儲存和讀取
- [ ] 頁面導航功能
- [ ] 最近 10 筆板子顯示
- [ ] 所有板子列表功能

### 8.2 效能測試項目
- [ ] 小型板子生成（10x10, 10 mines）
- [ ] 中型板子生成（20x20, 50 mines）
- [ ] 大型板子生成（50x50, 500 mines）
- [ ] 頁面載入速度
- [ ] 資料庫查詢效能

### 8.3 部署測試項目
- [ ] Docker 容器建構成功
- [ ] 資料庫持久化驗證
- [ ] 環境變數配置正確
- [ ] 應用啟動成功
- [ ] 所有功能在容器中正常運作

## 9. 成功標準

✅ 完全符合 Requirement.md 中的所有功能需求  
✅ 自製地雷生成演算法，不使用外部 gems  
✅ 清晰的 ○ ● 視覺化展示  
✅ 響應式 Bootstrap UI  
✅ SQLite 資料持久化  
✅ Docker Compose 部署就緒  
✅ 所有測試項目通過  

---

**注意事項**：
- 此規格專注於符合需求，避免過度設計
- 演算法使用 Array.sample() 確保 O(n) 效能
- 前端使用標準 Rails ERB + Bootstrap，無複雜 JavaScript
- Docker 配置適合生產環境部署