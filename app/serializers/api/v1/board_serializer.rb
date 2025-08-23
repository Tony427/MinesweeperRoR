class Api::V1::BoardSerializer
  def initialize(board)
    @board = board
  end

  def as_json
    {
      id: @board.id,
      name: @board.name,
      email: @board.email,
      dimensions: {
        width: @board.width,
        height: @board.height
      },
      mines_count: @board.mines_count,
      board_data: parse_board_data,
      created_at: @board.created_at,
      updated_at: @board.updated_at,
      links: {
        self: "/api/v1/boards/#{@board.id}",
        web_view: "/boards/#{@board.id}"
      }
    }
  end

  def as_summary_json
    {
      id: @board.id,
      name: @board.name,
      dimensions: {
        width: @board.width,
        height: @board.height
      },
      mines_count: @board.mines_count,
      created_at: @board.created_at,
      links: {
        self: "/api/v1/boards/#{@board.id}"
      }
    }
  end

  private

  def parse_board_data
    return nil unless @board.board_data.present?
    
    begin
      JSON.parse(@board.board_data)
    rescue JSON::ParserError
      nil
    end
  end
end