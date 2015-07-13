require 'rails_helper'

class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to user_groups_path, alert: exception.message
  end
end

describe ApplicationController, type: :controller do
  controller do
    def index
      raise CanCan::AccessDenied
    end
  end

  describe 'handle access denied' do
    it 'redirects to user groups page' do
      get :index
      expect(response).to redirect_to user_groups_path
    end
  end
end
