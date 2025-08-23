class Web::BaseController < ApplicationController
  protect_from_forgery with: :exception

  rescue_from Errors::DomainError, with: :handle_domain_error
  rescue_from Errors::ValidationError, with: :handle_validation_error
  rescue_from Errors::NotFoundError, with: :handle_not_found_error

  private

  def handle_domain_error(error)
    redirect_back_or_to root_path, alert: error.message
  end

  def handle_validation_error(error)
    flash[:alert] = error.message
    redirect_back fallback_location: root_path
  end

  def handle_not_found_error(error)
    redirect_to root_path, alert: error.message
  end

  def redirect_back_or_to(path, **options)
    if request.referer.present?
      redirect_back(fallback_location: path, **options)
    else
      redirect_to(path, **options)
    end
  end
end