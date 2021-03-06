require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  let(:user) { create(:user) }

  describe 'activation_needed_email' do
    let(:mail) { UserMailer.activation_needed_email(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Join SupermarKit')
      expect(mail.to).to eq(["#{user.email}"])
      expect(mail.from).to eq(['team@supermarkit.io'])
    end
  end

  describe 'activation_success_email' do
    let(:mail) { UserMailer.activation_success_email(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Shop with SupermarKit')
      expect(mail.to).to eq(["#{user.email}"])
      expect(mail.from).to eq(['team@supermarkit.io'])
    end
  end

  describe 'send_grocery_list_email' do
    let(:grocery) { create(:grocery) }
    let(:mail) { UserMailer.send_grocery_list_email(user, grocery) }

    it 'renders the headers' do
      expect(mail.subject).to eq("Groceries For #{grocery.name}")
      expect(mail.to).to eq(["#{user.email}"])
      expect(mail.from).to eq(['team@supermarkit.io'])
    end
  end
end
