# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: 'User' do
    sequence(:name)  { |n| "User Name#{n}" }
    sequence(:login) { |n| "user-#{n}" }
    email            { "#{login}@email.com" }
    password         { 'myPass' }
    admin            { false }
  end
end
