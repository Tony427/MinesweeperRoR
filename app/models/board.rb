class Board < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :width, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 50 }
  validates :height, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 50 }
  validates :mines_count, presence: true, numericality: { greater_than: 0 }

  validate :mines_count_within_board_size

  scope :recent, -> { order(created_at: :desc) }
  scope :latest_ten, -> { recent.limit(10) }

  def total_cells
    width * height
  end

  def max_mines
    total_cells - 1
  end

  def mine_percentage
    return 0 if total_cells <= 0
    ((mines_count.to_f / total_cells) * 100).round(2)
  end

  def difficulty
    case mine_percentage
    when 0..10
      :beginner
    when 10..20
      :intermediate
    when 20..30
      :advanced
    else
      :expert
    end
  end

  def board_info
    {
      dimensions: { width: width, height: height, total_cells: total_cells },
      mines: { count: mines_count, max_allowed: max_mines, percentage: mine_percentage },
      difficulty: difficulty
    }
  end

  private

  def mines_count_within_board_size
    return unless width && height && mines_count
    
    errors.add(:mines_count, "cannot exceed #{max_mines}") if mines_count > max_mines
  end
end