require 'rails_helper'
require 'cancan/matchers'
require 'support/abilities_helper'

describe Canard::Abilities, 'for :user' do
  include AbilitiesHelper
  include_context 'own objects'

  let(:user) { create(:user) }
  subject { Ability.new(user) }

  describe 'user group' do
    context 'should be able to' do
      it { can([:payments, :do_payment, :accept_invitation, :read, :manage, :destroy, :leave, :show_users], own_user_group) }
      it { can([:payments, :do_payment, :accept_invitation, :read, :update, :manage, :destroy], own_owned_user_group) }
      it { can([:create], any(:user_group)) }
    end

    context 'should not be able to' do
      it { cant([:payments, :do_payment, :read, :update, :destroy, :accept_invitation, :manage, :leave], any(:user_group)) }
      it { cant([:update], own_user_group) }
      it { cant([:leave], own_owned_user_group) }
    end
  end

  describe 'grocery' do
    context 'should be able to' do
      it { can([:set_store, :receipt, :create_receipts, :update_items, :show_items, :update_recipes, :confirm_receipt, :checkout, :do_checkout, :email_group, :read, :update, :create, :destroy, :manage], own_grocery) }
      it { can([:create], any(:grocery)) }
    end

    context 'should not be able to' do
      it { cant([:receipt, :create_receipts, :update_recipes, :update_items, :show_items, :confirm_receipt, :checkout, :do_checkout, :email_group, :read, :update, :destroy, :manage], any(:grocery)) }
    end
  end

  describe 'grocery store' do
    context 'should be able to' do
      it { can([:create, :read], any(:grocery_store)) }
    end

    context 'should not be able to' do
      it { cant([:update, :destroy, :manage], any(:grocery_store)) }
    end
  end

  describe 'item' do
    context 'should be able to' do
      it { can([:auto_complete, :read, :update, :create, :update, :destroy, :manage], own_item) }
      it { can([:create], any(:item)) }
    end

    context 'should not be able to' do
      it { cant([:read, :update, :destroy, :update, :auto_complete, :manage], any(:item)) }
    end
  end

  describe 'user' do
    context 'should be able to' do
      it { can([:read, :auto_complete], any(:user)) }
      it { can([:view_email], related_user) }
      it { can([:read, :destroy, :update, :activate, :auto_complete, :default_group, :manage], user) }
    end

    context 'should not be able to' do
      it { cant([:update, :create, :destroy, :activate, :default_group, :view_email, :manage], any(:user)) }
    end
  end

  describe 'authentication' do
    context 'should be able to' do
      it { can([:create], any(:authentication)) }
      it { can([:read, :destroy, :update, :manage], own_authentication) }
    end

    context 'should not be able to' do
      it { cant([:update, :destroy, :activate, :manage], any(:authentication)) }
    end
  end
end
