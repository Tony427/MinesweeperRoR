class Application::Boards::BoardQueryService
  def initialize(repository: BoardRepository.new)
    @repository = repository
  end

  def self.recent_boards(repository: BoardRepository.new)
    repository.recent
  end

  def self.latest_ten_boards(repository: BoardRepository.new)
    repository.latest_ten
  end

  def self.find_board(id, repository: BoardRepository.new)
    repository.find(id)
  end

  def self.board_exists?(id, repository: BoardRepository.new)
    repository.exists?(id)
  end

  def self.boards_count(repository: BoardRepository.new)
    repository.count
  end
end