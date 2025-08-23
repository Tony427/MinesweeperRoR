class Board < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :width, presence: true, numericality: { greater_than: 0 }
  validates :height, presence: true, numericality: { greater_than: 0 }
  validates :mines_count, presence: true, numericality: { greater_than: 0 }

  validate :mines_count_within_board_size
  validate :board_dimensions_valid
  validate :mine_count_valid

  scope :recent, -> { order(created_at: :desc) }
  scope :latest_ten, -> { recent.limit(10) }
  
  def self.repository
    @repository ||= BoardRepository.new(self)
  end

  def dimensions
    @dimensions ||= ValueObjects::BoardDimensions.new(width, height)
  rescue ::Errors::ValidationError
    nil
  end

  def mine_count_object
    return nil unless dimensions
    @mine_count_object ||= ValueObjects::MineCount.new(mines_count, dimensions.max_mines)
  rescue ::Errors::ValidationError
    nil
  end

  def difficulty
    mine_count_object&.difficulty || :unknown
  end

  def mine_percentage
    mine_count_object&.percentage_of_board || 0
  end

  def board_info
    {
      dimensions: dimensions&.to_h,
      mines: mine_count_object&.to_h,
      difficulty: difficulty
    }
  end

  private

  def mines_count_within_board_size
    return unless width && height && mines_count
    
    max_mines = width * height - 1
    errors.add(:mines_count, "cannot exceed #{max_mines}") if mines_count > max_mines
  end

  def board_dimensions_valid
    return unless width && height
    
    begin
      ValueObjects::BoardDimensions.new(width, height)
    rescue ::Errors::ValidationError => e
      errors.add(:base, "Invalid board dimensions: #{e.message}")
    end
  end

  def mine_count_valid
    return unless width && height && mines_count
    
    begin
      dimensions = ValueObjects::BoardDimensions.new(width, height)
      ValueObjects::MineCount.new(mines_count, dimensions.max_mines)
    rescue ::Errors::ValidationError => e
      errors.add(:mines_count, e.message)
    end
  end
end