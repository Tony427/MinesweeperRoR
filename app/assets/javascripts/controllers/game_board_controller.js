import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["cell", "status", "grid"];
  static values = {
    boardData: String,
    width: Number,
    height: Number,
    minesCount: Number,
    gameOver: Boolean,
  };

  connect() {
    this.reset();
  }

  reset() {
    this.board = JSON.parse(this.boardDataValue);
    this.gameOverValue = false;
    this.revealedCount = 0;
    this.statusTarget.textContent = "";
    this.cellTargets.forEach(cell => {
      cell.classList.remove("revealed", "mine", "flagged");
      cell.classList.add("covered");
      cell.textContent = "";
    });
  }

  reveal(event) {
    if (this.gameOverValue) return;

    const cell = event.currentTarget;
    if (cell.classList.contains("flagged") || cell.classList.contains("revealed")) {
      return;
    }

    const row = parseInt(cell.dataset.row);
    const col = parseInt(cell.dataset.col);

    if (this.board[row][col].mine === true) {
      this.endGame(false);
    } else {
      this.revealCell(row, col);
      this.checkWinCondition();
    }
  }

  toggle(event) {
    event.preventDefault();
    if (this.gameOverValue) return;

    const cell = event.currentTarget;
    if (cell.classList.contains("revealed")) return;

    if (cell.classList.contains("flagged")) {
      cell.classList.remove("flagged");
      cell.textContent = "";
    } else {
      cell.classList.add("flagged");
      cell.textContent = "🚩";
    }
  }

  flag(event) {
    event.preventDefault();
    if (this.gameOverValue) return;

    const cell = event.currentTarget;
    if (!cell.classList.contains("revealed")) {
      cell.classList.toggle("flagged");
      cell.textContent = cell.classList.contains("flagged") ? "🚩" : "";
    }
  }

  revealCell(row, col) {
    if (row < 0 || row >= this.heightValue || col < 0 || col >= this.widthValue) {
      return;
    }

    const cell = this.getCell(row, col);
    if (!cell || cell.classList.contains("revealed") || cell.classList.contains("flagged")) {
      return;
    }

    cell.classList.remove("covered");
    cell.classList.add("revealed");
    this.revealedCount++;

    const mineCount = this.countAdjacentMines(row, col);

    if (mineCount > 0) {
      cell.textContent = mineCount;
      cell.classList.add(`mines-${mineCount}`);
    } else {
      // Recursively reveal neighbors if there are no adjacent mines
      for (let r = -1; r <= 1; r++) {
        for (let c = -1; c <= 1; c++) {
          if (r === 0 && c === 0) continue;
          this.revealCell(row + r, col + c);
        }
      }
    }
  }

  countAdjacentMines(row, col) {
    let count = 0;
    for (let r = -1; r <= 1; r++) {
      for (let c = -1; c <= 1; c++) {
        if (r === 0 && c === 0) continue;
        const newRow = row + r;
        const newCol = col + c;
        if (
          newRow >= 0 && newRow < this.heightValue &&
          newCol >= 0 && newCol < this.widthValue &&
          this.board[newRow][newCol] === 'X'
        ) {
          count++;
        }
      }
    }
    return count;
  }

  endGame(isWin) {
    this.gameOverValue = true;
    if (isWin) {
      this.statusTarget.textContent = "You Win!";
      this.statusTarget.classList.add("text-success");
    } else {
      this.statusTarget.textContent = "Game Over!";
      this.statusTarget.classList.add("text-danger");
      this.revealAllMines();
    }
  }

  revealAllMines() {
    this.cells.forEach(cell => {
      const row = parseInt(cell.dataset.row);
      const col = parseInt(cell.dataset.col);
      if (this.board[row][col] === 'X') {
        cell.classList.remove("covered", "flagged");
        cell.classList.add("mine");
        cell.textContent = "💣";
      }
    });
  }

  checkWinCondition() {
    const totalNonMineCells = (this.widthValue * this.heightValue) - this.minesCountValue;
    if (this.revealedCount === totalNonMineCells) {
      this.endGame(true);
    }
  }

  getCell(row, col) {
    return this.cells.find(cell => {
      return parseInt(cell.dataset.row) === row && parseInt(cell.dataset.col) === col;
    });
  }
}
