// Board calculation utilities
export class BoardCalculator {
  static countAdjacentMines(board, row, col) {
    let count = 0
    const height = board.length
    const width = board[0].length

    for (let r = row - 1; r <= row + 1; r++) {
      for (let c = col - 1; c <= col + 1; c++) {
        if (this.isValidCell(r, c, height, width) && board[r][c].isMine) {
          count++
        }
      }
    }

    return count
  }

  static getAdjacentCells(row, col, height, width) {
    const adjacent = []

    for (let r = row - 1; r <= row + 1; r++) {
      for (let c = col - 1; c <= col + 1; c++) {
        if (this.isValidCell(r, c, height, width) && !(r === row && c === col)) {
          adjacent.push({ row: r, col: c })
        }
      }
    }

    return adjacent
  }

  static isValidCell(row, col, height, width) {
    return row >= 0 && row < height && col >= 0 && col < width
  }

  static calculateWinCondition(board, revealedCells) {
    const totalCells = board.length * board[0].length
    const totalMines = board.flat().filter(cell => cell.isMine).length
    const nonMineCells = totalCells - totalMines

    return revealedCells === nonMineCells
  }
}