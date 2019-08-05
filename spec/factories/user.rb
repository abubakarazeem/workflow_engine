require 'faker'

FactoryGirl.define do
  factory :user do
    first_name  { Faker::Name.first_name }
    last_name   { Faker::Name.last_name }
    email       { Faker::Internet.email }
    password    { Faker::Internet.password }
    confirmed_at { Date.today }
    association :role, factory: :role_member
  end

  factory :admin, class: User do
    first_name  { Faker::Name.first_name }
    last_name   { Faker::Name.last_name }
    email       { Faker::Internet.email }
    password    { Faker::Internet.password }
    confirmed_at { Date.today }
    association :role, factory: :role_admin
  end

  factory :member, class: User do
    first_name  { Faker::Name.first_name }
    last_name   { Faker::Name.last_name }
    email       { Faker::Internet.email }
    password    { Faker::Internet.password }
    confirmed_at { Date.today }
    association :role, factory: :role_member
  end
end
