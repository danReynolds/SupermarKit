class ApplicationController < ActionController::Base
  before_action :require_login
  protect_from_forgery with: :exception
  extend HappyPath
  setup_happy_path
  check_authorization

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to user_groups_path, alert: exception.message
  end

  def not_authenticated
    flash[:notice] ||= 'You must be logged in to view this page.'
    redirect_to login_path
  end
end
