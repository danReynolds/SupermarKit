require 'support/login_user'

shared_examples 'routes' do |routes|
  describe 'check route' do
    routes.each do |k, v|
      it "#{k} should return success" do
        args = {}

        method = :get
        status = :ok

        v.each do |k2, v2|
          if k2 == :login
            if v2
              user.activate!
              login_user(user)
            else
              logout_user
            end
          elsif k2 == :id && v2
            args[k2] = self.id
          elsif k2 == :method
            method = v2
          elsif k2 == :status
            status = v2
          elsif v2
            args[k2] = self.send(k2)
          else
            raise 'unexpected argument to routes helper'
          end
        end

        self.send(method, k, args)
        expect(response).to have_http_status(status)
      end
    end
  end
end
