source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.3"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.0"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails", ">= 3.4.0"

# Use sqlite3 as the database for Active Record in development
gem "sqlite3", "~> 1.4", group: [:development, :test]

# Use PostgreSQL as the database for production and docker development
gem "pg", "~> 1.5", group: [:development, :production]

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://github.com/hotwired/turbo-rails]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://github.com/hotwired/stimulus-rails]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder" - Removed: No JSON API views in this app

# Use Redis adapter to run Action Cable in production  
# gem "redis", "~> 4.0" - Removed: Simple app doesn't need caching

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
gem "sassc-rails"

# Bootstrap for styling
gem "bootstrap", "~> 5.3"

# Use image_processing for variant generation
# gem "image_processing", "~> 1.2" - Removed: No image processing in this app

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  # gem "capybara" - Removed: No tests exist in this project
  # gem "selenium-webdriver" - Removed: No tests exist in this project  
  # gem "webdrivers" - Removed: No tests exist in this project
end

# Production specific gems (Docker and Heroku)
group :production do
  # JavaScript runtime for asset compilation
  gem "mini_racer"
  
  # Heroku logging and monitoring
  gem "rails_12factor"
  
  # For better asset handling in production
  gem "sprockets", "~> 4.0"
end