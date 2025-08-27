class ValueObjects::MineCount
  attr_reader :count, :max_allowed

  def initialize(count, max_allowed)
    @count = count&.to_i
    @max_allowed = max_allowed&.to_i
    validate!
  end

  def valid?
    errors.empty?
  end

  def errors
    @errors ||= begin
      errors = []
      errors << "Mine count must be greater than 0" unless count_valid?
      errors << "Mine count cannot exceed #{@max_allowed}" if exceeds_maximum?
      errors
    end
  end

  def percentage_of_board
    return 0 if @max_allowed <= 0
    ((@count.to_f / (@max_allowed + 1)) * 100).round(2)
  end

  def difficulty
    case percentage_of_board
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

  def to_h
    {
      count: @count,
      max_allowed: @max_allowed,
      percentage: percentage_of_board,
      difficulty: difficulty
    }
  end

  def ==(other)
    other.is_a?(self.class) && @count == other.count && @max_allowed == other.max_allowed
  end

  def eql?(other)
    self == other
  end

  def hash
    [@count, @max_allowed].hash
  end

  def to_s
    "#{@count}/#{@max_allowed + 1} (#{percentage_of_board}%)"
  end

  def to_i
    @count
  end

  private

  def validate!
    raise ::Errors::ValidationError.new(errors, "Invalid mine count: #{errors.join(', ')}") unless valid?
  end

  def count_valid?
    @count.present? && @count.is_a?(Integer) && @count > 0
  end

  def exceeds_maximum?
    count_valid? && @max_allowed.present? && @count > @max_allowed
  end
end