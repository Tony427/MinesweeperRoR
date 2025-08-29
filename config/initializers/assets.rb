# Be sure to restart your server when you modify this file.

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# Add JavaScript controllers to precompile list for Heroku deployment
Rails.application.config.assets.precompile += %w( controllers/application.js )
Rails.application.config.assets.precompile += %w( controllers/game_board_controller.js )
Rails.application.config.assets.precompile += %w( controllers/game_status_controller.js )
Rails.application.config.assets.precompile += %w( controllers/minesweeper_controller.js )
Rails.application.config.assets.precompile += %w( services/game_engine.js )
Rails.application.config.assets.precompile += %w( services/board_calculator.js )
Rails.application.config.assets.precompile += %w( services/game_state_manager.js )
Rails.application.config.assets.precompile += %w( utils/cell_styler.js )
Rails.application.config.assets.precompile += %w( utils/constants.js )
Rails.application.config.assets.precompile += %w( utils/dom_helpers.js )