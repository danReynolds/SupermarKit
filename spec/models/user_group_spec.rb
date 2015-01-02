require 'rails_helper'

RSpec.describe UserGroup, :type => :model do
  context 'with groceries' do

    it 'scopes by unfinished' do
      group = create(:user_group, :with_groceries)
      result = group.active_groceries

      expect(result).to eq group.groceries
    end

    it 'scopes by finished' do
      group = create(:user_group, :with_groceries)
      group.groceries.update_all(finished_at: DateTime.now)
      result = group.finished_groceries

      expect(result).to eq group.groceries
    end

  end
end
