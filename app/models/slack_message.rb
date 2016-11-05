class SlackMessage < ActiveRecord::Base
  belongs_to :slack_bot
  validates :message_type, uniqueness: { scope: :slack_bot_id }
  validates :message_type, inclusion: {
    in: CONFIGURABLES[:slack_messages].map do |message|
      message[:id]
    end
  }
end
