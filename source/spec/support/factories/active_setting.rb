# frozen_string_literal: true

FactoryBot.define do
  factory :active_setting, class: 'ActiveSetting' do
    sequence(:key) { |n| "key_#{n}" }

    value { SecureRandom.hex(16) }
  end
end
