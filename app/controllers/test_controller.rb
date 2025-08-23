class TestController < ApplicationController
  def index
    render json: { message: "Application is working!", timestamp: Time.current }
  end
end