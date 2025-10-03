class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :http_basic_authenticate, unless: :skip_basic_auth?

  private

  def skip_basic_auth?
    Rails.env.test?
  end

  def http_basic_authenticate
    authenticate_or_request_with_http_basic("Por Comprar") do |username, password|
      username == ENV["BASIC_AUTH_USER"] && password == ENV["BASIC_AUTH_PASSWORD"]
    end
  end
end
