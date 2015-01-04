require_relative '../spec_helper'
require "cancan/matchers"
require 'support/abilities_helper'

describe Canard::Abilities, "for guests" do
  include AbilitiesHelper

  subject { Ability.new }
  
  context 'should be able to' do
    it { can([:create, :activate], any(:user)) }
  end
  
  context 'should not be able to' do
    it { cant([:metrics, :read, :create, :destroy, :update, :manage], any(:user_group)) }
    it { cant([:toggle_finish, :read, :create, :destroy, :update, :manage], any(:grocery)) }
    it { cant([:auto_complete, :add, :remove, :read, :create, :destroy, :update, :manage], any(:item)) }
    it { cant([:auto_complte, :read, :destroy, :update, :manage], any(:user)) }
  end
end
  
