class Application::Boards::CreateBoardService
  def initialize(board_params, minesweeper_generator: MinesweeperGenerator)
    @board_params = board_params
    @minesweeper_generator = minesweeper_generator
  end

  def call
    board = Board.new(@board_params)
    
    return failure_result(board) unless board.valid?
    
    generator = @minesweeper_generator.new(board.width, board.height, board.mines_count)
    board.board_data = generator.generate.to_json
    
    if board.save
      success_result(board)
    else
      failure_result(board)
    end
  end

  private

  def success_result(board)
    {
      success: true,
      board: board,
      message: 'Board generated successfully!'
    }
  end

  def failure_result(board)
    {
      success: false,
      board: board,
      errors: board.errors
    }
  end
end