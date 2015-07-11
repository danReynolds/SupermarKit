shared_context 'login user' do
  let(:grocery) { controller.current_user.user_groups.first.groceries.first }
  let(:user_group) { controller.current_user.user_groups.first }
  before(:each) do
    @user = create(:user, :full_user)
    @user.activate!
    login_user
  end
end
