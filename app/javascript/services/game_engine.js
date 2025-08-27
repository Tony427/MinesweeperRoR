// Core game engine service
import { BoardCalculator } from './board_calculator.js'
import { GameStateManager } from './game_state_manager.js'
import { GAME_STATUS, CELL_STATUS } from '../utils/constants.js'

export class GameEngine {
  constructor(width, height, totalMines, boardData = null) {
    this.width = width
    this.height = height
    this.totalMines = totalMines
    this.stateManager = new GameStateManager(width, height, totalMines)
    
    this.initializeBoard(boardData)
    this.calculateAdjacentMines()
  }

  initializeBoard(boardData) {
    this.board = []
    
    for (let row = 0; row < this.height; row++) {
      this.board[row] = []
      for (let col = 0; col < this.width; col++) {
        this.board[row][col] = {
          isMine: boardData ? boardData[row][col].mine : false,
          status: CELL_STATUS.HIDDEN,
          adjacentMines: 0
        }
      }
    }
  }

  calculateAdjacentMines() {
    for (let row = 0; row < this.height; row++) {
      for (let col = 0; col < this.width; col++) {
        if (!this.board[row][col].isMine) {
          this.board[row][col].adjacentMines = 
            BoardCalculator.countAdjacentMines(this.board, row, col)
        }
      }
    }
  }

  revealCell(row, col) {
    if (!this.stateManager.isPlaying()) return { success: false, reason: 'Game over' }
    
    const cell = this.board[row][col]
    if (cell.status !== CELL_STATUS.HIDDEN) return { success: false, reason: 'Already revealed or flagged' }

    cell.status = CELL_STATUS.REVEALED
    this.stateManager.incrementRevealedCells()

    if (cell.isMine) {
      this.stateManager.setGameLost()
      return { 
        success: true, 
        isMine: true, 
        gameStatus: this.stateManager.gameStatus,
        revealedCells: this.getAllMines()
      }
    }

    // Auto-reveal adjacent empty cells
    const autoRevealed = []
    if (cell.adjacentMines === 0) {
      autoRevealed.push(...this.autoRevealAdjacentCells(row, col))
    }

    // Check win condition
    if (BoardCalculator.calculateWinCondition(this.board, this.stateManager.revealedCells)) {
      this.stateManager.setGameWon()
      return {
        success: true,
        isMine: false,
        adjacentMines: cell.adjacentMines,
        autoRevealed,
        gameStatus: this.stateManager.gameStatus,
        winMines: this.getAllMines()
      }
    }

    return {
      success: true,
      isMine: false,
      adjacentMines: cell.adjacentMines,
      autoRevealed,
      gameStatus: this.stateManager.gameStatus
    }
  }

  toggleFlag(row, col) {
    if (!this.stateManager.isPlaying()) return { success: false, reason: 'Game over' }
    
    const cell = this.board[row][col]
    if (cell.status === CELL_STATUS.REVEALED) return { success: false, reason: 'Cell already revealed' }

    if (cell.status === CELL_STATUS.FLAGGED) {
      cell.status = CELL_STATUS.HIDDEN
      this.stateManager.decrementFlaggedMines()
      return { success: true, flagged: false }
    } else {
      cell.status = CELL_STATUS.FLAGGED
      this.stateManager.incrementFlaggedMines()
      return { success: true, flagged: true }
    }
  }

  autoRevealAdjacentCells(row, col) {
    const revealed = []
    const adjacent = BoardCalculator.getAdjacentCells(row, col, this.height, this.width)

    adjacent.forEach(({ row: r, col: c }) => {
      const result = this.revealCell(r, c)
      if (result.success && !result.isMine) {
        revealed.push({ row: r, col: c, adjacentMines: this.board[r][c].adjacentMines })
        if (result.autoRevealed) {
          revealed.push(...result.autoRevealed)
        }
      }
    })

    return revealed
  }

  getAllMines() {
    const mines = []
    for (let row = 0; row < this.height; row++) {
      for (let col = 0; col < this.width; col++) {
        if (this.board[row][col].isMine) {
          mines.push({ row, col })
        }
      }
    }
    return mines
  }

  reset() {
    this.stateManager.reset()
    this.board.forEach(row => {
      row.forEach(cell => {
        cell.status = CELL_STATUS.HIDDEN
      })
    })
  }

  getGameStats() {
    return this.stateManager.getGameStats()
  }
}