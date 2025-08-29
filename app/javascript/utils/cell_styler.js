// Cell styling utilities
import { CELL_STYLES, COLORS } from './constants.js'
import { DOMHelpers } from './dom_helpers.js'

export class CellStyler {
  static resetCell(element) {
    // Clear dataset attributes
    delete element.dataset.status
    delete element.dataset.adjacent

    // Remove specific styling classes that might be added
    element.classList.remove('revealed', 'flagged', 'mine', 'win-mine', 'detonated')

    // Reset content and default styles
    DOMHelpers.updateElement(element, '', CELL_STYLES.hidden)
  }

  static revealCell(element, adjacentMines = 0) {
    const styles = { ...CELL_STYLES.revealed }
    let content = ''

    if (adjacentMines > 0) {
      content = adjacentMines.toString()
      styles.color = COLORS[adjacentMines] || '#000000'
    }

    DOMHelpers.updateElement(element, content, styles)
  }

  static flagCell(element) {
    DOMHelpers.updateElement(element, '🚩', CELL_STYLES.flagged)
  }

  static unflagCell(element) {
    DOMHelpers.updateElement(element, '', CELL_STYLES.hidden)
  }

  static showMine(element, isDetonated = false) {
    const content = isDetonated ? '💥' : '💣'
    DOMHelpers.updateElement(element, content, CELL_STYLES.mine)
  }

  static showWinMine(element) {
    DOMHelpers.updateElement(element, '🚩', CELL_STYLES.winMine)
  }
}