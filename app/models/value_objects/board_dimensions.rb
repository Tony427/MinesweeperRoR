class ValueObjects::BoardDimensions
  attr_reader :width, :height

  def initialize(width, height)
    @width = width&.to_i
    @height = height&.to_i
    validate!
  end

  def valid?
    errors.empty?
  end

  def errors
    @errors ||= begin
      errors = []
      errors << "Width must be greater than 0" unless width_valid?
      errors << "Height must be greater than 0" unless height_valid?
      errors << "Board dimensions too large (max 50x50)" if too_large?
      errors
    end
  end

  def total_cells
    @width * @height
  end

  def max_mines
    total_cells - 1
  end

  def to_h
    {
      width: @width,
      height: @height,
      total_cells: total_cells,
      max_mines: max_mines
    }
  end

  def ==(other)
    other.is_a?(self.class) && @width == other.width && @height == other.height
  end

  def eql?(other)
    self == other
  end

  def hash
    [@width, @height].hash
  end

  def to_s
    "#{@width}x#{@height}"
  end

  private

  def validate!
    raise ::Errors::ValidationError.new(errors, "Invalid board dimensions: #{errors.join(', ')}") unless valid?
  end

  def width_valid?
    @width.present? && @width.is_a?(Integer) && @width > 0
  end

  def height_valid?
    @height.present? && @height.is_a?(Integer) && @height > 0
  end

  def too_large?
    width_valid? && height_valid? && (@width > 50 || @height > 50)
  end
end