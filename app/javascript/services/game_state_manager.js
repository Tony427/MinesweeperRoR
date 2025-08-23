// Game state management service
import { GAME_STATUS } from '../utils/constants.js'

export class GameStateManager {
  constructor(width, height, totalMines) {
    this.width = width
    this.height = height
    this.totalMines = totalMines
    this.reset()
  }

  reset() {
    this.gameStatus = GAME_STATUS.PLAYING
    this.revealedCells = 0
    this.flaggedMines = 0
    this.startTime = Date.now()
    this.endTime = null
  }

  incrementRevealedCells() {
    this.revealedCells++
  }

  incrementFlaggedMines() {
    this.flaggedMines++
  }

  decrementFlaggedMines() {
    this.flaggedMines--
  }

  setGameWon() {
    this.gameStatus = GAME_STATUS.WON
    this.endTime = Date.now()
  }

  setGameLost() {
    this.gameStatus = GAME_STATUS.LOST
    this.endTime = Date.now()
  }

  isPlaying() {
    return this.gameStatus === GAME_STATUS.PLAYING
  }

  isGameOver() {
    return this.gameStatus === GAME_STATUS.WON || this.gameStatus === GAME_STATUS.LOST
  }

  getRemainingMines() {
    return Math.max(0, this.totalMines - this.flaggedMines)
  }

  getGameDuration() {
    const endTime = this.endTime || Date.now()
    return Math.floor((endTime - this.startTime) / 1000)
  }

  getGameStats() {
    return {
      status: this.gameStatus,
      revealedCells: this.revealedCells,
      flaggedMines: this.flaggedMines,
      remainingMines: this.getRemainingMines(),
      duration: this.getGameDuration()
    }
  }
}