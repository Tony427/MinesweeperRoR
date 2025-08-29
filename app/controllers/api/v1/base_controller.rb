class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :ensure_json_request

  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found_error

  private

  def ensure_json_request
    request.format = :json
  end

  def handle_not_found_error(error)
    render json: { error: error.message }, status: :not_found
  end

  def render_success(data, message: nil, status: :ok)
    response = { data: data }
    response[:message] = message if message
    render json: response, status: status
  end

  def render_error(message, details: nil, status: :unprocessable_entity)
    response = { error: message }
    response[:details] = details if details
    render json: response, status: status
  end
end