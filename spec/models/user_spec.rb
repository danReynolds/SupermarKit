require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#with_name' do
    it 'scopes by name' do
      softie1 = create(:user, name: 'Dan Reynolds')
      softie2 = create(:user, name: 'John Reynolds')

      search = User.with_name('Dan')
      expect(search).to eq [softie1]
    end
  end

  describe '#gravatar_url' do
    it 'should return the gravatar url for the given email' do
      user = create(:user)
      gravatar = Digest::MD5::hexdigest(user.email).downcase
      expect(user.gravatar_url(50)).to eq "https://gravatar.com/avatar/#{gravatar}.png?s=50"
    end
  end
end
