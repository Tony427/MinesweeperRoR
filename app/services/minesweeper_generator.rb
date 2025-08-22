class MinesweeperGenerator
  def initialize(width, height, mines_count)
    @width = width
    @height = height
    @mines_count = mines_count
  end

  def generate
    # 初始化空板子
    board = Array.new(@height) { Array.new(@width) { { mine: false } } }
    
    # 使用 Array.sample 高效放置地雷 (O(n))
    mine_positions = generate_mine_positions
    mine_positions.each do |row, col|
      board[row][col][:mine] = true
    end
    
    board
  end

  private

  def generate_mine_positions
    total_cells = @width * @height
    positions = (0...total_cells).to_a.sample(@mines_count)
    
    positions.map do |pos|
      [pos / @width, pos % @width]
    end
  end
end