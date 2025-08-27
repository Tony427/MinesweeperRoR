class BoardRepository
  def initialize(model = Board)
    @model = model
  end

  def find(id)
    @model.find(id)
  rescue ActiveRecord::RecordNotFound => e
    raise ::Errors::NotFoundError, "Board with id #{id} not found"
  end

  def create(attributes)
    @model.create(attributes)
  end

  def save(board)
    board.save
  end

  def all
    @model.all
  end

  def recent
    @model.recent
  end

  def latest_ten
    @model.latest_ten
  end

  def exists?(id)
    @model.exists?(id)
  end

  def count
    @model.count
  end

  def where(conditions)
    @model.where(conditions)
  end

  def find_by(conditions)
    @model.find_by(conditions)
  end

  def find_by!(conditions)
    @model.find_by!(conditions)
  rescue ActiveRecord::RecordNotFound => e
    raise ::Errors::NotFoundError, "Board not found with conditions: #{conditions}"
  end
end