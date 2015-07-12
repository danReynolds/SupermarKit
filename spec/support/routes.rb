require 'support/login_user'

shared_examples 'routes' do |routes|
  describe 'check routes' do
    routes.each do |k, v|
      it "#{k} should be successful" do
        args = {}

        if v[:login]
          @user = create(:user)
          @user.activate!
          login_user
          id = controller.current_user.id
        end

        if v[:id]
          args[:id] = id
        end

        method = v[:method] || :get
        status = v[:status] || :ok

        self.send(method, k, args)
        expect(response).to have_http_status(status)
      end
    end
  end
end
