class Board < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :width, presence: true, numericality: { greater_than: 0 }
  validates :height, presence: true, numericality: { greater_than: 0 }
  validates :mines_count, presence: true, numericality: { greater_than: 0 }

  validate :mines_count_within_board_size

  scope :recent, -> { order(created_at: :desc) }
  scope :latest_ten, -> { recent.limit(10) }
  
  def self.repository
    @repository ||= BoardRepository.new(self)
  end

  private

  def mines_count_within_board_size
    return unless width && height && mines_count
    
    max_mines = width * height - 1
    errors.add(:mines_count, "cannot exceed #{max_mines}") if mines_count > max_mines
  end
end