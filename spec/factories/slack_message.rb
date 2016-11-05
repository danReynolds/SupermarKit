FactoryGirl.define do
  factory :slack_message do
    message_type  { "#{CONFIGURABLES[:slack_messages].first[:id]}" }
    format 'For {title} {contributors} for {recipients}'
    enabled false
  end
end
