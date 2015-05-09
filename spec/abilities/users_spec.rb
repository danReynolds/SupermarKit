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
      it { can([:accept_invitation, :metrics, :read, :update, :create, :destroy, :manage], own_user_group) }
      it { can([:create], any(:user_group)) }
    end

    context 'should not be able to' do
      it { cant([:read, :update, :destroy, :metrics, :accept_invitation, :manage], any(:grocery)) }
    end
  end

  describe 'grocery' do

    context 'should be able to' do
      it { can([:finish, :email_group, :read, :update, :create, :destroy, :toggle_finish, :manage], own_grocery) }
      it { can([:create], any(:grocery)) }
    end

    context 'should not be able to' do
      it { cant([:finish, :email_group, :read, :update, :destroy, :toggle_finish, :manage], any(:grocery)) }
    end
  end

  describe 'item' do

    context 'should be able to' do
      it { can([:auto_complete, :add, :remove, :read, :create, :update, :destroy, :manage], own_item) }
      it { can([:create], any(:item)) }
    end

    context 'should not be able to' do
      it { cant([:read, :update, :destroy, :auto_complete, :add, :remove, :manage], any(:item)) }
    end
  end

  describe 'user' do

    context 'should be able to' do
      it { can([:read, :auto_complete], any(:user)) }
      it { can([:read, :destroy, :update, :activate, :auto_complete, :manage], user) }
    end

    context 'should not be able to' do
      it { cant([:update, :create, :destroy, :activate, :manage], any(:user)) }
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
