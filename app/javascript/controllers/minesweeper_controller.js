// Main minesweeper game coordinator controller
import { Controller } from "@hotwired/stimulus"
import { GameEngine } from "services/game_engine"

export default class extends Controller {
  static targets = ["board", "resetBtn"]
  static values = { 
    width: Number, 
    height: Number, 
    mines: Number,
    boardData: String
  }

  connect() {
    console.log('minesweeper #connect', this.element, {
      width: this.widthValue,
      height: this.heightValue,
      mines: this.minesValue,
      hasBoardTarget: this.hasBoardTarget
    })
    // Listen for game-board:ready event before initializing game
    this.element.addEventListener('game-board:ready', this.startMinesweeperGame.bind(this))
  }

  disconnect() {
    this.cleanup()
  }

  initializeGame() {
    // Parse board data from server
    const boardData = this.boardDataValue ? JSON.parse(this.boardDataValue) : null
    
    // Initialize game engine
    this.gameEngine = new GameEngine(
      this.widthValue, 
      this.heightValue, 
      this.minesValue, 
      boardData
    )
    console.log('minesweeper #initializeGame: After GameEngine init', this.gameEngine)

    // Set CSS custom properties for board dimensions
    this.element.style.setProperty('--board-width', this.widthValue)
    this.element.style.setProperty('--board-height', this.heightValue)
    
    // Initialize UI
    this.updateGameStatus()
    this.resetBoard()
  }

  setupEventListeners() {
    // Listen for board interaction events
    this.element.addEventListener('game-board:reveal', this.handleReveal.bind(this))
    this.element.addEventListener('game-board:toggle', this.handleToggle.bind(this))
  }

  // Handle cell reveal from board controller
  handleReveal(event) {
    console.log('minesweeper #handleReveal', event.detail)
    const { row, col, element } = event.detail
    const result = this.gameEngine.revealCell(row, col)

    if (!result.success) return

    // Update the clicked cell
    if (result.isMine) {
      this.getBoardController().updateCell(row, col, { 
        status: 'mine', 
        isDetonated: true 
      })
      
      // Reveal all other mines
      if (result.revealedCells) {
        result.revealedCells.forEach(({ row: r, col: c }) => {
          if (!(r === row && c === col)) {
            this.getBoardController().updateCell(r, c, { 
              status: 'mine', 
              isDetonated: false 
            })
          }
        })
      }
    } else {
      // Update revealed cell
      this.getBoardController().updateCell(row, col, { 
        status: 'revealed', 
        adjacentMines: result.adjacentMines 
      })

      // Update auto-revealed cells
      if (result.autoRevealed) {
        result.autoRevealed.forEach(({ row: r, col: c, adjacentMines }) => {
          this.getBoardController().updateCell(r, c, { 
            status: 'revealed', 
            adjacentMines 
          })
        })
      }

      // Handle win condition
      if (result.gameStatus === 'won' && result.winMines) {
        result.winMines.forEach(({ row: r, col: c }) => {
          this.getBoardController().updateCell(r, c, { status: 'win-mine' })
        })
      }
    }

    this.updateGameStatus()
  }

  // Handle cell flag toggle from board controller
  handleToggle(event) {
    console.log('minesweeper #handleToggle', event.detail)
    const { row, col, element } = event.detail
    const result = this.gameEngine.toggleFlag(row, col)

    if (!result.success) return

    const status = result.flagged ? 'flagged' : 'hidden'
    this.getBoardController().updateCell(row, col, { status })
    
    this.updateGameStatus()
  }

  // Reset game
  reset(event) {
    if (event) event.preventDefault()
    
    // Add loading state to reset button
    this.addLoadingState()
    
    // Small delay for visual feedback
    setTimeout(() => {
      this.gameEngine.reset()
      this.resetBoard()
      this.updateGameStatus()
      this.getStatusController().resetTimer()
      this.removeLoadingState()
    }, 200)
  }

  resetBoard() {
    // Dispatch a custom event for the game-board controller to reset itself
    this.dispatch('reset-board', { target: this.boardTarget, bubbles: true })
  }

  updateGameStatus() {
    const stats = this.gameEngine.getGameStats()
    const statusController = this.getStatusController()
    
    if (statusController) {
      statusController.updateMines(stats.remainingMines)
      statusController.updateStatus(stats.status)
    }
  }

  // Helper methods to get other controllers
  getBoardController() {
    return this.application.getControllerForElementAndIdentifier(
      this.boardTarget, "game-board"
    )
  }

  getStatusController() {
    const statusElement = document.querySelector('[data-controller~="game-status"]')
    return statusElement ? 
      this.application.getControllerForElementAndIdentifier(statusElement, "game-status") : 
      null
  }

  addLoadingState() {
    if (this.hasResetBtnTarget) {
      this.resetBtnTarget.classList.add('loading')
      this.resetBtnTarget.disabled = true
    }
  }

  removeLoadingState() {
    if (this.hasResetBtnTarget) {
      this.resetBtnTarget.classList.remove('loading')
      this.resetBtnTarget.disabled = false
    }
  }

  cleanup() {
    // Clean up any intervals or event listeners if needed
    if (this.gameEngine) {
      // Game engine cleanup if needed
    }
  }

  startMinesweeperGame() {
    this.initializeGame()
    this.setupEventListeners()
  }
}