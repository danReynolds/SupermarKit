class PagesController < ApplicationController
  skip_authorization_check
  skip_before_filter :require_login

  def home
  end
end