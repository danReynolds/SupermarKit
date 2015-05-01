require 'rails_helper'

RSpec.describe OauthsController, :type => :controller do

  describe "GET oauth" do
    it "returns http success" do
      get :oauth
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET callback" do
    it "returns http success" do
      get :callback
      expect(response).to have_http_status(:success)
    end
  end

end
