class Application::Boards::BoardQueryService
  def self.recent_boards
    Board.recent
  end

  def self.latest_ten_boards
    Board.latest_ten
  end

  def self.find_board(id)
    Board.find(id)
  rescue ActiveRecord::RecordNotFound => e
    raise Errors::NotFoundError, "Board with id #{id} not found"
  end

  def self.board_exists?(id)
    Board.exists?(id)
  end

  def self.boards_count
    Board.count
  end
end