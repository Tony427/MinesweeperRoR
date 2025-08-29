class Api::V1::BoardsController < Api::V1::BaseController
  def index
    boards = Board.recent
    render_success(
      boards.map { |board| Api::V1::BoardSerializer.new(board).as_json },
      message: "Successfully retrieved #{boards.count} boards"
    )
  end

  def show
    board = Board.find(params[:id])
    render_success(
      Api::V1::BoardSerializer.new(board).as_json,
      message: 'Board retrieved successfully'
    )
  rescue ActiveRecord::RecordNotFound
    render_error('Board not found', status: :not_found)
  end

  def create
    board = Board.new(board_params)
    
    if board.valid?
      generator = MinesweeperGenerator.new(board.width, board.height, board.mines_count)
      board.board_data = generator.generate.to_json
      board.save!
      render_success(
        Api::V1::BoardSerializer.new(board).as_json,
        message: 'Board generated successfully!',
        status: :created
      )
    else
      render_error(
        'Failed to create board',
        details: board.errors,
        status: :unprocessable_entity
      )
    end
  end

  def recent
    boards = Board.latest_ten
    render_success(
      boards.map { |board| Api::V1::BoardSerializer.new(board).as_json },
      message: "Successfully retrieved #{boards.count} recent boards"
    )
  end

  def stats
    count = Board.count
    render_success(
      { total_boards: count },
      message: 'Board statistics retrieved successfully'
    )
  end

  private

  def board_params
    params.require(:board).permit(:name, :email, :width, :height, :mines_count)
  end
end