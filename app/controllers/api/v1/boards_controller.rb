class Api::V1::BoardsController < Api::V1::BaseController
  def index
    boards = Application::Boards::BoardQueryService.recent_boards
    render_success(
      boards.map { |board| Api::V1::BoardSerializer.new(board).as_json },
      message: "Successfully retrieved #{boards.count} boards"
    )
  end

  def show
    board = Application::Boards::BoardQueryService.find_board(params[:id])
    render_success(
      Api::V1::BoardSerializer.new(board).as_json,
      message: 'Board retrieved successfully'
    )
  end

  def create
    service = Application::Boards::CreateBoardService.new(board_params)
    result = service.call
    
    if result[:success]
      render_success(
        Api::V1::BoardSerializer.new(result[:board]).as_json,
        message: result[:message],
        status: :created
      )
    else
      render_error(
        'Failed to create board',
        details: result[:errors],
        status: :unprocessable_entity
      )
    end
  end

  def recent
    boards = Application::Boards::BoardQueryService.latest_ten_boards
    render_success(
      boards.map { |board| Api::V1::BoardSerializer.new(board).as_json },
      message: "Successfully retrieved #{boards.count} recent boards"
    )
  end

  def stats
    count = Application::Boards::BoardQueryService.boards_count
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