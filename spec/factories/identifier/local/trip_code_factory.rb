# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :identifier_local_trip_code, class: 'Identifier::Local::TripCode', traits: [:housekeeping] do
  end
end
