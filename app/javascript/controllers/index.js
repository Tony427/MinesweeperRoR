// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"

// Import controllers explicitly to ensure proper registration
import GameBoardController from "controllers/game_board_controller"
import GameStatusController from "controllers/game_status_controller"
import MinesweeperController from "controllers/minesweeper_controller"

// Register controllers explicitly
application.register("game-board", GameBoardController)
application.register("game-status", GameStatusController)
application.register("minesweeper", MinesweeperController)

// Also try eager loading as fallback
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)