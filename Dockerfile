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