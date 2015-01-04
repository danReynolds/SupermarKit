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
      it { can([:metrics, :read, :update, :create, :destroy, :manage], own_user_group) }
      it { can([:create], any(:user_group)) }
    end

    context 'should not be able to' do
      it { cant([:read, :update, :destroy, :metrics, :manage], any(:grocery)) }
    end
  end

  describe 'grocery' do

    context 'should be able to' do
      it { can([:read, :update, :create, :destroy, :toggle_finish, :manage], own_grocery) }
      it { can([:create], any(:grocery)) }
    end

    context 'should not be able to' do
      it { cant([:read, :update, :destroy, :toggle_finish, :manage], any(:grocery)) }
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
    end

    context 'should not be able to' do
      it { cant([:create, :update, :destroy, :activate, :manage], any(:user)) }
    end
  end
end