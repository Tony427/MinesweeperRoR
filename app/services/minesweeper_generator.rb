# Service class for generating minesweeper boards
# Implements a high-performance O(n) algorithm using Array.sample for mine placement
class MinesweeperGenerator
  def initialize(width, height, mines_count)
    @width = width
    @height = height
    @mines_count = mines_count
  end

  # Generates a new minesweeper board with randomly placed mines
  # Returns a 2D array where each cell is represented as { mine: boolean }
  def generate
    # Initialize empty board with all cells marked as non-mines
    board = Array.new(@height) { Array.new(@width) { { mine: false } } }
    
    # Use Array.sample for efficient O(n) mine placement
    mine_positions = generate_mine_positions
    mine_positions.each do |row, col|
      board[row][col][:mine] = true
    end
    
    board
  end

  private

  # Generates random mine positions using efficient sampling
  # Converts linear positions to 2D coordinates to ensure uniform distribution
  def generate_mine_positions
    total_cells = @width * @height
    positions = (0...total_cells).to_a.sample(@mines_count)
    
    positions.map do |pos|
      [pos / @width, pos % @width]
    end
  end
end