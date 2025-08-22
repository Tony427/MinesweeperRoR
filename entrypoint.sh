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

# 預編譯 assets
echo "Precompiling assets..."
bundle exec rails assets:precompile RAILS_ENV=production

# 啟動應用
exec "$@"