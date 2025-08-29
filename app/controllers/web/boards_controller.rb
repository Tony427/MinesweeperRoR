class Web::BoardsController < Web::BaseController
  def index
    @board = Board.new
    @recent_boards = Board.latest_ten
  end

  def show
    @board = Board.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to boards_path, alert: 'Board not found'
  end

  def create
    @board = Board.new(board_params)
    
    if @board.save
      generator = MinesweeperGenerator.new(@board.width, @board.height, @board.mines_count)
      @board.update(board_data: generator.generate.to_json)
      redirect_to board_path(@board), notice: 'Board generated successfully!'
    else
      @recent_boards = Board.latest_ten
      render :index, status: :unprocessable_entity
    end
  end

  def all
    @boards = Board.recent
  end

  private

  def board_params
    params.require(:board).permit(:name, :email, :width, :height, :mines_count)
  end
end