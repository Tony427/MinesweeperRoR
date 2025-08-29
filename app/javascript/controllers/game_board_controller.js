// Game board interaction controller
import { Controller } from "@hotwired/stimulus"
import { DOMHelpers } from "../utils/dom_helpers.js"
import { CellStyler } from "../utils/cell_styler.js"

export default class extends Controller {
  static targets = ["cell"]
  static values = { width: Number, height: Number }

  connect() {
    console.log('game-board #connect', this.element, {
      targets: this.cellTargets.length,
      width: this.widthValue,
      height: this.heightValue
    })
    this.setupKeyboardNavigation()
    this.preventContextMenu()
    this.currentFocusRow = 0
    this.currentFocusCol = 0

    // Listen for custom event to reset the board
    this.element.addEventListener('minesweeper:reset-board', this.handleResetBoard.bind(this))

    // Attempt to focus the game board element for keyboard navigation
    this.element.focus()
  }

  disconnect() {
    this.removeKeyboardNavigation()
  }

  // Handle left click - reveal cell
  reveal(event) {
    console.log('game-board #reveal called', event, event.currentTarget)
    event.preventDefault()
    const { row, col } = DOMHelpers.getCellCoordinates(event.currentTarget)
    console.log('Revealing cell at:', { row, col })
    
    // Dispatch custom event to minesweeper controller
    const customEvent = new CustomEvent('game-board:reveal', {
      detail: { row, col, element: event.currentTarget },
      bubbles: true
    })
    this.element.dispatchEvent(customEvent)
    console.log('Custom event dispatched:', customEvent)
  }

  // Handle right click - toggle flag
  toggle(event) {
    console.log('game-board #toggle called', event, event.currentTarget)
    event.preventDefault()
    const { row, col } = DOMHelpers.getCellCoordinates(event.currentTarget)
    console.log('Toggling flag at:', { row, col })
    
    // Dispatch custom event to minesweeper controller
    const customEvent = new CustomEvent('game-board:toggle', {
      detail: { row, col, element: event.currentTarget },
      bubbles: true
    })
    this.element.dispatchEvent(customEvent)
    console.log('Custom event dispatched:', customEvent)
  }

  // Update single cell appearance
  updateCell(row, col, state) {
    const element = DOMHelpers.findCell(this.element, row, col)
    if (!element) return

    element.dataset.status = state.status
    
    switch (state.status) {
      case 'revealed':
        if (state.adjacentMines > 0) {
          element.dataset.adjacent = state.adjacentMines
        }
        CellStyler.revealCell(element, state.adjacentMines)
        break
      case 'flagged':
        CellStyler.flagCell(element)
        break
      case 'hidden':
        CellStyler.unflagCell(element)
        break
      case 'mine':
        CellStyler.showMine(element, state.isDetonated)
        break
      case 'win-mine':
        CellStyler.showWinMine(element)
        break
    }
  }

  // Update multiple cells
  updateCells(updates) {
    updates.forEach(({ row, col, state }) => {
      this.updateCell(row, col, state)
    })
  }

  // Reset all cells to initial state
  resetCells() {
    this.cellTargets.forEach(cell => {
      delete cell.dataset.status
      delete cell.dataset.adjacent
      CellStyler.resetCell(cell)
    })
  }

  // Keyboard navigation setup
  setupKeyboardNavigation() {
    this.keyboardHandler = this.handleKeyboard.bind(this)
    document.addEventListener('keydown', this.keyboardHandler)
  }

  removeKeyboardNavigation() {
    if (this.keyboardHandler) {
      document.removeEventListener('keydown', this.keyboardHandler)
    }
  }

  handleKeyboard(event) {
    if (!this.element.contains(document.activeElement) && 
        !this.element.contains(event.target)) return

    const maxRow = this.heightValue - 1
    const maxCol = this.widthValue - 1

    switch (event.key) {
      case 'ArrowUp':
        event.preventDefault()
        this.currentFocusRow = Math.max(0, this.currentFocusRow - 1)
        this.focusCell()
        break
      case 'ArrowDown':
        event.preventDefault()
        this.currentFocusRow = Math.min(maxRow, this.currentFocusRow + 1)
        this.focusCell()
        break
      case 'ArrowLeft':
        event.preventDefault()
        this.currentFocusCol = Math.max(0, this.currentFocusCol - 1)
        this.focusCell()
        break
      case 'ArrowRight':
        event.preventDefault()
        this.currentFocusCol = Math.min(maxCol, this.currentFocusCol + 1)
        this.focusCell()
        break
      case ' ':
      case 'Enter':
        event.preventDefault()
        this.revealFocusedCell()
        break
      case 'f':
      case 'F':
        event.preventDefault()
        this.toggleFocusedCell()
        break
    }
  }

  focusCell() {
    const cell = DOMHelpers.findCell(this.element, this.currentFocusRow, this.currentFocusCol)
    if (cell) {
      cell.focus()
    }
  }

  revealFocusedCell() {
    const cell = DOMHelpers.findCell(this.element, this.currentFocusRow, this.currentFocusCol)
    if (cell) {
      cell.click()
    }
  }

  toggleFocusedCell() {
    const cell = DOMHelpers.findCell(this.element, this.currentFocusRow, this.currentFocusCol)
    if (cell) {
      this.toggle({ preventDefault: () => {}, currentTarget: cell })
    }
  }

  preventContextMenu() {
    this.element.addEventListener('contextmenu', (e) => e.preventDefault())
  }

  // New method to handle the reset board event
  handleResetBoard(event) {
    console.log('game-board #handleResetBoard received', event)
    this.resetCells()
  }
}