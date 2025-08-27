class Web::BoardsController < Web::BaseController
  def index
    @board = Board.new
    @recent_boards = Application::Boards::BoardQueryService.latest_ten_boards
  end

  def show
    @board = Application::Boards::BoardQueryService.find_board(params[:id])
  rescue ::Errors::NotFoundError
    redirect_to boards_path, alert: 'Board not found'
  end

  def create
    service = Application::Boards::CreateBoardService.new(board_params)
    result = service.call
    
    if result[:success]
      @board = result[:board]
      redirect_to board_path(@board), notice: result[:message]
    else
      @board = result[:board]
      @recent_boards = Application::Boards::BoardQueryService.latest_ten_boards
      render :index, status: :unprocessable_entity
    end
  end

  def all
    @boards = Application::Boards::BoardQueryService.recent_boards
  end

  private

  def board_params
    params.require(:board).permit(:name, :email, :width, :height, :mines_count)
  end
end