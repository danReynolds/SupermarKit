require 'rails_helper'
require 'support/basic_user'
require 'support/routes'

describe UserGroupsController, type: :controller do
  include_context 'basic user'

  let(:id) { user_group }
  it_should_behave_like 'routes', {
    edit: { id: true },
    show: { id: true },
    index: {},
    new: {}
  }

  describe 'POST create' do
    let(:user_group_params) { attributes_for(:user_group) }
    let(:subject) { post :create, user_group: user_group_params.merge!(user_ids: "#{group_member.id}") }
    let(:group_member) { create(:user) }
    let(:new_group) { UserGroup.last }

    context 'with valid params' do
      it 'creates the new group' do
        expect { subject }.to change(UserGroup, :count).by(1)
      end

      it 'adds specified and current user to group' do
        subject
        expect(new_group.users).to contain_exactly(group_member, controller.current_user)
      end

      context 'without a default group' do
        it 'sets the default group' do
          controller.current_user.update_attribute(:default_group, nil)
          subject
          expect(controller.current_user.default_group).to eq new_group
        end
      end

      context 'with a default group' do
        it 'does not change the default' do
          default_group = create(:user_group)
          controller.current_user.update_attribute(:default_group, default_group)
          subject
          expect(controller.current_user.default_group).to eq default_group
        end
      end

      it 'accepts the current user and invites all others' do
        subject
        current_group_user = new_group.user_groups_users.find_by_user_id(controller.current_user.id)
        remaining_user_group_users = new_group.user_groups_users - [current_group_user]
        expect(current_group_user.state).to eq(UserGroupsUsers::ACCEPTED)

        remaining_user_group_users.each do |user_group_user|
          expect(user_group_user.state).to eq(UserGroupsUsers::INVITED)
        end
      end
    end

    context 'with invalid params' do
      it 'should render the new template' do
        user_group_params[:name] = nil
        expect(subject).to render_template :new
      end
    end
  end

  describe 'PATCH update' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:group) { create(:user_group, users: [user1, controller.current_user]) }
    let(:subject) { patch :update, id: group, user_group: { user_ids: "#{controller.current_user.id},#{user2.id}"} }

    it 'replaces users with new ones' do
      subject
      expect(group.reload.users).to contain_exactly(controller.current_user, user2)
    end

    it 'makes removed users with that group as a default have no default' do
      user1.update_attribute(:default_group, group)
      expect(user1.default_group).to eq group
      subject
      expect(user1.reload.default_group).to eq nil
    end
  end

  describe 'PATCH accept_invitation' do
    it 'should accept the invitation and change UserGroupUser state' do
      user = create(:user)
      user2 = controller.current_user
      user_group = create(:user_group)

      user_group.users << [user, user2]
      user_group.user_groups_users.find_by_user_id(user.id).update_attribute(:state, UserGroupsUsers::ACCEPTED)
      user_group_user = user_group.user_groups_users.find_by_user_id(user2.id)

      expect(user_group_user.state).to eq(UserGroupsUsers::INVITED)
      patch :accept_invitation, id: user_group.id
      expect(user_group_user.reload.state).to eq(UserGroupsUsers::ACCEPTED)
    end
  end

  describe 'PATCH do_payment' do
    let(:payee) { create(:user) }
    let(:group) { create(:user_group, users: [payee, controller.current_user]) }
    let(:subject) { patch :do_payment, id: group.id, user_group: payment_params }
    let(:payment_params) {
      {
        reason: 'This is a reason',
        price: 4,
        payee_id: payee.id
      }
    }

    it 'should create the payment with the correct values and users' do
      expect { subject }.to change(UserPayment, :count).by 1
      payment = UserPayment.last
      expect(payment.payer).to eq controller.current_user
      expect(payment.payee).to eq payee
      expect(payment.user_group).to eq group
      expect(payment.price).to eq payment_params[:price].to_money
      expect(payment.reason).to eq payment_params[:reason]
    end
  end
end
