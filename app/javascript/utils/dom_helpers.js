// DOM manipulation helpers
export class DOMHelpers {
  static updateElement(element, content = '', styles = {}) {
    if (content !== '') {
      element.textContent = content
    }
    
    Object.assign(element.style, styles)
  }

  static findCell(board, row, col) {
    return board.querySelector(`[data-row="${row}"][data-col="${col}"]`)
  }

  static getCellCoordinates(element) {
    return {
      row: parseInt(element.dataset.row),
      col: parseInt(element.dataset.col)
    }
  }

  static updateBadge(element, text, className) {
    element.textContent = text
    element.parentElement.className = `badge ${className}`
  }

  static preventContextMenu(element) {
    element.addEventListener('contextmenu', (e) => e.preventDefault())
  }
}