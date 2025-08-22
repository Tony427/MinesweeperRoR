FROM ruby:3.2.1-alpine

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
COPY Gemfile* ./
RUN bundle install

# 複製應用程式碼
COPY . .

# 創建資料庫目錄並設置權限並生成Rails binstubs
RUN mkdir -p /app/db /app/tmp/pids && \
    chmod 755 /app/db && \
    bundle exec rake app:update:bin || true

# 暴露端口
EXPOSE 3000

# 啟動命令
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]