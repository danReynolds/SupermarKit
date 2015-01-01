require 'rails_helper'

RSpec.describe User, type: :model do
  it 'scopes by name' do
    softie1 = create(:user, name: 'Dan Reynolds')
    softie2 = create(:user, name: 'John Reynolds')

    search = User.with_name('Dan')

    expect(search).to eq [softie1]
  end
end
