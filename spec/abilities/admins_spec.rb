require 'rails_helper'
require 'cancan/matchers'
require 'support/abilities_helper'

describe Canard::Abilities, 'for :admin' do
  include AbilitiesHelper

  let(:user) { create(:user, :as_admin) }
  subject { Ability.new(user) }

  describe 'god mode' do
    it { can([:read, :create, :destroy, :update, :manage], :all) }

    # You then need to check every object
    # The above line is checking if (can :manage, :all) is present,
    # But it could be followed by a (cannot :manage, User) for example, which overrides so all must be checked
    it { can([:read, :create, :destroy, :update, :manage], any(:authentication)) }
    it { can([:accept_invitation, :read, :create, :destroy, :update, :manage], any(:user_group)) }
    it { can([:set_store, :recipes, :checkout, :do_checkout, :email_group, :recipes, :read, :create, :destroy, :update, :manage], any(:grocery)) }
    it { can([:auto_complete, :read, :create, :destroy, :update, :manage], any(:item)) }
    it { can([:default_group, :auto_complete, :activate, :read, :create, :destroy, :update, :manage], any(:user)) }
  end
end
