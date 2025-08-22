class BoardsController < ApplicationController
  def index
    @board = Board.new
    @recent_boards = Board.latest_ten
  end

  def show
    @board = Board.find(params[:id])
  end

  def create
    @board = Board.new(board_params)
    
    if @board.valid?
      generator = MinesweeperGenerator.new(@board.width, @board.height, @board.mines_count)
      @board.board_data = generator.generate.to_json
      
      if @board.save
        redirect_to @board, notice: 'Board generated successfully!'
      else
        @recent_boards = Board.latest_ten
        render :index, status: :unprocessable_entity
      end
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