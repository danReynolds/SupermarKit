require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  let(:user) { create(:user) }

  describe "activation_needed_email" do
    let(:mail) { UserMailer.activation_needed_email(user) }

    it "renders the headers" do
      expect(mail.subject).to eq('Join Supermarkit')
      expect(mail.to).to eq(["#{user.email}"])
      expect(mail.from).to eq(["supermarkit@danreynolds.ca"])
    end
  end

  describe "activation_success_email" do
    let(:mail) { UserMailer.activation_success_email(user) }

    it "renders the headers" do
      expect(mail.subject).to eq('Shop with Supermarkit')
      expect(mail.to).to eq(["#{user.email}"])
      expect(mail.from).to eq(["supermarkit@danreynolds.ca"])
    end
  end

end
